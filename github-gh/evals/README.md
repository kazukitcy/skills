# github-gh Evals

`prompts.csv` contains routing and safety prompts for the `github-gh` skill.

Use these prompts to check whether an agent:

- Invokes `github-gh` for local `gh` CLI GitHub operations.
- Avoids invoking it for conceptual or browser-only tasks.
- Resolves repository context before writes.
- Separates read, write, and destructive/admin operations.
- Uses references only as needed instead of loading a large manual.

These evals must not execute real GitHub writes. They evaluate expected behavior, references, and safety decisions.
