# Safe Writes

A write operation changes GitHub state. Examples include create, edit, close, reopen, comment, review, merge, workflow dispatch, rerun, cancel, release create/upload, gist create/edit, and project item changes.

Before a write, present:

- Repo: `[HOST/]OWNER/REPO`; include host if not `github.com`.
- Operation: concise command intent.
- Target object: issue, PR, branch, workflow, run, release, gist, project item, or endpoint.
- Payload: title, body file, labels, assignees, state, branch, workflow inputs, release assets, or JSON input file.
- Command summary: the `gh` command shape without secret values.

Read-only operations become writes when they acknowledge, mutate state, trigger jobs, upload files, post comments, or change labels/state.

If the repo or host is ambiguous, do not write. Ask for the repo or require explicit `--repo [HOST/]OWNER/REPO`.

Use body files or JSON input files for nontrivial payloads. Do not echo token values, secret values, or private payload content into logs.

Destructive/admin operations are not ordinary safe writes. Route them to `admin-and-destructive-ops.md`.
