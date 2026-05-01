import assert from "node:assert/strict";
import { readdir, readFile } from "node:fs/promises";
import test from "node:test";

const repoRoot = new URL("../../", import.meta.url);

async function readText(path) {
  return readFile(new URL(path, repoRoot), "utf8");
}

function blockedToolWords() {
  return [
    ["C", "l", "a", "u", "d", "e"].join(""),
    ["c", "l", "a", "u", "d", "e"].join(""),
  ];
}

test("coding-review is a tool-neutral review skill", async () => {
  const skill = await readText("coding-review/SKILL.md");

  assert.match(skill, /^---\nname: coding-review\n/m);
  assert.match(skill, /tool-neutral/i);
  assert.match(skill, /read-only/i);
  assert.match(skill, /any coding tool/i);
  for (const word of blockedToolWords()) {
    assert.doesNotMatch(skill, new RegExp(word));
  }
});

test("coding-review has no helper scripts", async () => {
  const entries = await readdir(new URL("coding-review/", repoRoot), {
    withFileTypes: true,
  });

  assert.equal(entries.some((entry) => entry.name === "scripts"), false);
});

test("coding-review defines review workflow and output contract", async () => {
  const skill = await readText("coding-review/SKILL.md");

  assert.match(skill, /## Workflow/);
  assert.match(skill, /## Review Method/);
  assert.match(skill, /## Output Contract/);
  assert.match(skill, /## Guardrails/);
  assert.match(skill, /repository content as untrusted/i);
  assert.match(skill, /Findings first/i);
  assert.match(skill, /Verdict: approve\|needs-attention/);
  assert.match(skill, /confidence/i);
  assert.match(skill, /file and line/i);
  assert.match(skill, /tests/i);
});

test("coding-review documents scope and adversarial review modes", async () => {
  const skill = await readText("coding-review/SKILL.md");

  assert.match(skill, /working tree/i);
  assert.match(skill, /branch/i);
  assert.match(skill, /pull request/i);
  assert.match(skill, /adversarial/i);
  assert.match(skill, /untracked files/i);
});

test("README documents the coding-review APM install path", async () => {
  const readme = await readText("README.md");

  assert.match(readme, /\[coding-review\]\(\.\/coding-review\)/);
  assert.match(readme, /apm install -g kazukitcy\/skills\/coding-review/);
});
