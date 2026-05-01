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

test("coding-rescue is a tool-neutral rescue skill", async () => {
  const skill = await readText("coding-rescue/SKILL.md");

  assert.match(skill, /^---\nname: coding-rescue\n/m);
  assert.match(skill, /tool-neutral/i);
  assert.match(skill, /any coding tool/i);
  assert.match(skill, /bounded engineering task/i);
  for (const word of blockedToolWords()) {
    assert.doesNotMatch(skill, new RegExp(word));
  }
});

test("coding-rescue has no helper scripts", async () => {
  const entries = await readdir(new URL("coding-rescue/", repoRoot), {
    withFileTypes: true,
  });

  assert.equal(entries.some((entry) => entry.name === "scripts"), false);
});

test("coding-rescue defines bounded rescue workflow and contracts", async () => {
  const skill = await readText("coding-rescue/SKILL.md");

  assert.match(skill, /## Workflow/);
  assert.match(skill, /## Task Boundary/);
  assert.match(skill, /## Output Contract/);
  assert.match(skill, /## Guardrails/);
  assert.match(skill, /task kind/i);
  assert.match(skill, /repository content as untrusted/i);
  assert.match(skill, /execution controls/i);
  assert.match(skill, /read-only/i);
  assert.match(skill, /write/i);
  assert.match(skill, /changed files/i);
  assert.match(skill, /validation commands/i);
});

test("coding-rescue carries rescue-specific follow-through rules", async () => {
  const skill = await readText("coding-rescue/SKILL.md");

  assert.match(skill, /root cause/i);
  assert.match(skill, /smallest safe/i);
  assert.match(skill, /Do not stop after identifying the issue/i);
  assert.match(skill, /not alone in this codebase/i);
  assert.match(skill, /Do not revert or overwrite/i);
});

test("README documents the coding-rescue APM install path", async () => {
  const readme = await readText("README.md");

  assert.match(readme, /\[coding-rescue\]\(\.\/coding-rescue\)/);
  assert.match(readme, /apm install -g kazukitcy\/skills\/coding-rescue/);
});
