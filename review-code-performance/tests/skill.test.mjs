// ---- per-skill constants — ONLY this block differs between the nine files ----
const NAME = "review-code-performance";
const KIND = "specialist";
const AREA = "performance";
const DESCRIPTION = "Specialist review lens for performance risks: hot paths, N+1 queries, unbounded work, inefficient algorithms, caching, and pagination. Use as a focused lens, usually routed by the review-code orchestrator, when changes touch queries, loops over large data, caches, pagination, or latency-sensitive paths.";
const OPENAI_DISPLAY = "Review Code: Performance";
// ----------------------------------------------------------------------------

import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const repoRoot = new URL("../../", import.meta.url);
const read = (p) => readFile(new URL(p, repoRoot), "utf8");

// Keep the literal tool word out of the test source too (tool-neutral convention).
function blockedToolWords() {
  return [
    ["C", "l", "a", "u", "d", "e"].join(""),
    ["c", "l", "a", "u", "d", "e"].join(""),
  ];
}

test(NAME + " frontmatter, tool-neutrality, and read-only intent", async () => {
  const skill = await read(NAME + "/SKILL.md");
  assert.match(skill, new RegExp("^---\\nname: " + NAME + "\\n", "m"));
  assert.ok(skill.includes("\ndescription: " + DESCRIPTION + "\n"),
    "frontmatter description must match the canonical routing text exactly");
  assert.match(skill, /tool-neutral/i);
  assert.match(skill, /read-only/i);
  for (const word of blockedToolWords()) assert.doesNotMatch(skill, new RegExp(word));
});

test(NAME + " ships a well-formed agents/openai.yaml", async () => {
  const yaml = await read(NAME + "/agents/openai.yaml");
  assert.match(yaml, /^interface:/m);
  // display_name present, quoted, NON-EMPTY, and equal to the expected value
  assert.match(yaml, /^\s*display_name:\s*"[^"]+"\s*$/m);
  assert.ok(yaml.includes('display_name: "' + OPENAI_DISPLAY + '"'));
  // short_description present, quoted, NON-EMPTY
  assert.match(yaml, /^\s*short_description:\s*"[^"]+"\s*$/m);
  // default_prompt present, non-empty, and references THIS skill via $NAME
  assert.match(yaml, /^\s*default_prompt:\s*"[^"]+"\s*$/m);
  assert.match(yaml, new RegExp("default_prompt:.*\\$" + NAME + "\\b"));
});

test(NAME + " is documented in the README", async () => {
  const readme = await read("README.md");
  assert.match(readme, new RegExp("\\[" + NAME + "\\]\\(\\./" + NAME + "\\)"));
  assert.match(readme, new RegExp("apm install -g kazukitcy/skills/" + NAME));
});

test(NAME + " carries the contract for its kind", async () => {
  const skill = await read(NAME + "/SKILL.md");
  const schemaFields = ["- location:", "- claim:", "- evidence:", "- path:",
    "- impact:", "- fix:", "- test:"];
  assert.ok(skill.includes("severity: P0 | P1 | P2 | P3"));
  assert.ok(skill.includes("## Calibration"));

  if (KIND === "orchestrator") {
    for (const h of ["## Routing rules", "## Final output format",
      "Available specialists", "## Verifying important findings"]) assert.ok(skill.includes(h));
    for (const s of ["correctness", "security", "tests", "design",
      "performance", "reliability", "release", "adversarial"])
      assert.ok(skill.includes("review-code-" + s), "orchestrator must list review-code-" + s);
    for (const v of ["confirmed", "downgraded", "rejected", "needs-info"]) assert.ok(skill.includes(v));
    return;
  }

  // both specialist kinds carry the finding schema and the confidence rule
  for (const f of schemaFields) assert.ok(skill.includes(f), "missing schema field " + f);
  assert.match(skill, /confidence high \| medium|confidence: high \| medium/);

  if (KIND === "adversarial") {
    for (const h of ["Finding threshold", "adversarial scenario",
      "existing protection checked", "## Final check"]) assert.ok(skill.includes(h));
    return;
  }

  // ordinary specialist: full shared contract + area-specific no-findings line
  for (const h of ["## Look for", "## Required evidence", "## Severity", "## Output", "## Final check"])
    assert.ok(skill.includes(h));
  for (const p of ["- P0:", "- P1:", "- P2:", "- P3:"]) assert.ok(skill.includes(p));
  assert.ok(skill.includes("confidence high:") && skill.includes("confidence medium:"));
  assert.ok(skill.includes("No concrete " + AREA + " findings found."),
    "no-findings line must use the skill's AREA value");
});
