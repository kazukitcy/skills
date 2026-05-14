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

const references = [
  "command-selection.md",
  "repo-context.md",
  "repositories.md",
  "files-search.md",
  "issues.md",
  "pull-requests.md",
  "actions.md",
  "orgs.md",
  "projects.md",
  "releases.md",
  "gists.md",
  "gh-api.md",
  "safe-writes.md",
  "admin-and-destructive-ops.md",
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

test("published docs stay concise and gh CLI focused", async () => {
  const readme = await readText("README.md");
  const docs = [
    "AGENTS.md",
    "README.md",
    "SKILL.md",
    "evals/README.md",
    "evals/prompts.csv",
    ...references.map((ref) => `references/${ref}`),
  ];
  const offScope = new RegExp(["M", "C", "P"].join(""), "i");

  for (const doc of docs) {
    assert.doesNotMatch(await readText(doc), offScope, `${doc} should stay focused on gh CLI`);
  }

  assert.ok(readme.split(/\s+/).length < 220, "README.md should stay concise");
  assert.doesNotMatch(readme, /Examples|Future Split|github-gh-admin/);
});

test("references document safety boundaries", async () => {
  const admin = await readText("references/admin-and-destructive-ops.md");
  const safeWrites = await readText("references/safe-writes.md");

  assert.match(admin, /repo delete/i);
  assert.match(admin, /explicit/i);
  assert.match(safeWrites, /repo/i);
  assert.match(safeWrites, /payload/i);
});

test("reference command examples avoid gh v2.92 help mismatches", async () => {
  const files = [
    "references/command-selection.md",
    "references/repositories.md",
    "references/files-search.md",
    "references/issues.md",
  ];

  for (const file of files) {
    const body = await readText(file);

    assert.doesNotMatch(body, /gh repo view --repo/);
    assert.doesNotMatch(body, /--assign @me/);
    assert.doesNotMatch(body, /\bsymbol:/);
  }
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
  const apiScript = await readText("scripts/gh-api-json.sh");

  for (const { args, options } of [
    { args: ["--repo", "ghe.example.com/owner/repo"] },
    { args: ["--hostname", "ghe.example.com", "--repo", "owner/repo"] },
    {
      args: ["--mode", "read"],
      options: {
        env: { ...process.env, GH_HOST: "ghe.example.com", GH_REPO: "owner/repo" },
      },
    },
  ]) {
    const result = await execFileAsync(resolveScript, args, options);
    assert.equal(result.stdout.trim(), "ghe.example.com/owner/repo");
  }

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
  assert.match(apiScript, /--hostname/);
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
