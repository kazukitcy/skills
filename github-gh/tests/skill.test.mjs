import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { access, mkdtemp, readFile, rm, stat } from "node:fs/promises";
import { constants } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { promisify } from "node:util";
import test from "node:test";

const packageRoot = new URL("../", import.meta.url);
const execFileAsync = promisify(execFile);

async function readText(path) {
  return readFile(new URL(path, packageRoot), "utf8");
}

async function exists(path) {
  await access(new URL(path, packageRoot), constants.F_OK);
}

function assertIncludesAll(text, patterns) {
  for (const pattern of patterns) {
    assert.match(text, pattern);
  }
}

const references = [
  "command-selection.md",
  "repo-context.md",
  "repositories.md",
  "files-search.md",
  "issues.md",
  "pull-requests.md",
  "actions.md",
  "projects.md",
  "releases.md",
  "gists.md",
  "gh-api.md",
  "safe-writes.md",
  "admin-and-destructive-ops.md",
  "mcp-coverage.md",
];

const scripts = [
  "gh-check-auth.sh",
  "gh-resolve-repo.sh",
  "gh-safe-write.sh",
  "gh-api-json.sh",
];

test("github-gh skill has concise trigger metadata", async () => {
  const skill = await readText("SKILL.md");

  assert.match(skill, /^---\nname: github-gh\n/m);
  assert.match(skill, /^description: ".*local gh CLI.*"$/im);
  assert.match(skill, /Do not use/i);
  assert.ok(skill.split(/\s+/).length < 900, "SKILL.md should stay router-sized");
});

test("github-gh skill routes details to all required references", async () => {
  const skill = await readText("SKILL.md");

  for (const ref of references) {
    await exists(`references/${ref}`);
    assert.match(skill, new RegExp(ref.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
});

test("issue and pull request references stay independently routable", async () => {
  const skill = await readText("SKILL.md");
  const issues = await readText("references/issues.md");
  const pullRequests = await readText("references/pull-requests.md");
  const csv = await readText("evals/prompts.csv");

  assert.doesNotMatch(skill, /issues-prs\.md/);
  assertIncludesAll(skill, [/references\/issues\.md/, /references\/pull-requests\.md/]);

  assertIncludesAll(issues, [/gh issue list/, /gh search issues/]);
  assert.doesNotMatch(issues, /gh pr merge/);

  assertIncludesAll(pullRequests, [/gh pr checks/, /gh pr merge/, /gh search issues/]);

  assertIncludesAll(csv, [
    /command-selection\.md;issues\.md;repo-context\.md/,
    /pull-requests\.md;actions\.md/,
  ]);
  assert.doesNotMatch(csv, /issues-prs\.md/);
});

test("repository, file search, release, and gist references stay independently routable", async () => {
  const skill = await readText("SKILL.md");
  const repositories = await readText("references/repositories.md");
  const filesSearch = await readText("references/files-search.md");
  const releases = await readText("references/releases.md");
  const gists = await readText("references/gists.md");
  const csv = await readText("evals/prompts.csv");

  assert.doesNotMatch(skill, /repos-files-search\.md|releases-gists\.md/);
  assertIncludesAll(skill, [
    /references\/repositories\.md/,
    /references\/files-search\.md/,
    /references\/releases\.md/,
    /references\/gists\.md/,
  ]);

  assertIncludesAll(repositories, [/gh repo view/, /gh api repos\/owner\/repo\/compare/]);
  assert.doesNotMatch(repositories, /gh search code/);

  assertIncludesAll(filesSearch, [/gh search code/, /contents\/path\/to\/file/]);
  assert.doesNotMatch(filesSearch, /gh repo create/);

  assert.match(releases, /gh release create/);
  assert.doesNotMatch(releases, /gh gist/);

  assert.match(gists, /gh gist create/);
  assert.doesNotMatch(gists, /gh release/);

  assertIncludesAll(csv, [
    /files-search\.md/,
    /repositories\.md;repo-context\.md/,
    /releases\.md;safe-writes\.md/,
    /gists\.md;admin-and-destructive-ops\.md/,
  ]);
  assert.doesNotMatch(csv, /repos-files-search\.md|releases-gists\.md/);
});

test("references document safety boundaries instead of MCP compatibility", async () => {
  const admin = await readText("references/admin-and-destructive-ops.md");
  const mcp = await readText("references/mcp-coverage.md");
  const safeWrites = await readText("references/safe-writes.md");

  assert.match(admin, /repo delete/i);
  assert.match(admin, /explicit/i);
  assert.match(safeWrites, /repo/i);
  assert.match(safeWrites, /payload/i);
  assert.match(mcp, /not.*compatib/i);
  assert.match(mcp, /full|partial|custom|gap/i);
});

test("helper scripts are executable and avoid unsafe shell patterns", async () => {
  for (const script of scripts) {
    const path = `scripts/${script}`;
    const mode = (await stat(new URL(path, packageRoot))).mode;
    const body = await readText(path);

    assert.ok(mode & 0o111, `${script} should be executable`);
    assert.match(body, /set -euo pipefail/);
    assert.doesNotMatch(body, /\beval\b/);
    assert.doesNotMatch(body, /GITHUB_TOKEN|GH_TOKEN/);
  }
});

test("repository helpers support GitHub Enterprise Server repo specs", async () => {
  const resolveScript = new URL("scripts/gh-resolve-repo.sh", packageRoot).pathname;
  const safeWriteScript = new URL("scripts/gh-safe-write.sh", packageRoot).pathname;

  const explicitHost = await execFileAsync(resolveScript, [
    "--repo",
    "ghe.example.com/owner/repo",
  ]);
  assert.equal(explicitHost.stdout.trim(), "ghe.example.com/owner/repo");

  const separateHost = await execFileAsync(resolveScript, [
    "--hostname",
    "ghe.example.com",
    "--repo",
    "owner/repo",
  ]);
  assert.equal(separateHost.stdout.trim(), "ghe.example.com/owner/repo");

  const envHost = await execFileAsync(resolveScript, ["--mode", "read"], {
    env: {
      ...process.env,
      GH_HOST: "ghe.example.com",
      GH_REPO: "owner/repo",
    },
  });
  assert.equal(envHost.stdout.trim(), "ghe.example.com/owner/repo");

  const tempRepo = await mkdtemp(join(tmpdir(), "github-gh-ghes-"));
  try {
    await execFileAsync("git", ["init"], { cwd: tempRepo });
    await execFileAsync("git", [
      "remote",
      "add",
      "origin",
      "https://ghe.example.com/owner/repo.git",
    ], { cwd: tempRepo });
    const remoteHost = await execFileAsync(resolveScript, ["--mode", "read"], {
      cwd: tempRepo,
      env: { ...process.env, GH_HOST: "", GH_REPO: "" },
    });
    assert.equal(remoteHost.stdout.trim(), "ghe.example.com/owner/repo");
  } finally {
    await rm(tempRepo, { force: true, recursive: true });
  }

  await assert.rejects(
    execFileAsync(resolveScript, ["--mode", "write"], {
      env: { ...process.env, GH_HOST: "ghe.example.com", GH_REPO: "owner/repo" },
    }),
    /Refusing to infer repository for write mode/,
  );

  const summary = await execFileAsync(safeWriteScript, [
    "--repo",
    "ghe.example.com/owner/repo",
    "--operation",
    "comment",
    "--target",
    "PR-10",
    "--command-summary",
    "gh pr comment --repo ghe.example.com/owner/repo --body-file comment.md",
  ]);
  assert.match(summary.stdout, /repo: ghe\.example\.com\/owner\/repo/);
});

test("gh api wrapper exposes GitHub Enterprise Server hostname routing", async () => {
  const script = await readText("scripts/gh-api-json.sh");
  const reference = await readText("references/gh-api.md");
  const repoContext = await readText("references/repo-context.md");

  assert.match(script, /--hostname/);
  assert.match(reference, /--hostname HOST/);
  assert.match(repoContext, /\[HOST\/\]OWNER\/REPO/);
});

test("eval prompts cover required routing categories", async () => {
  const csv = await readText("evals/prompts.csv");
  const lines = csv.trim().split("\n");

  assert.ok(lines.length >= 21, "header plus at least 20 eval rows");
  for (const category of [
    "positive",
    "negative",
    "read",
    "write",
    "destructive",
    "ambiguous-repo",
    "api-fallback",
    "actions",
    "cross-domain",
  ]) {
    assert.match(csv, new RegExp(category));
  }
});
