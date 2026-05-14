# Admin and Destructive Operations

Do not use these operations in the normal `github-gh` flow. Handle them only when the user explicitly asks for the specific action and target.

Operations in this class include:

- Repository delete, archive, rename, or ownership transfer (`repo delete`, `repo archive`, and `repo rename` class operations).
- Deploy keys.
- Repository, environment, organization, or Actions secrets.
- Variables.
- Organization administration.
- Branch protection and rulesets.
- Security alert state changes.
- Dependabot alert state changes.
- Secret scanning state changes.
- Notification state changes and bulk notification triage.

Required procedure:

1. Read current state first where possible.
2. Confirm the exact owner, repo or org, target object, host, and action.
3. Prefer dry-run or preview modes when available.
4. Present a confirmation summary with impact and reversibility.
5. Avoid printing credentials, secret values, private keys, or raw secret payloads.
6. Use explicit `--repo`, owner, org, or host flags; never rely on guessed context.

If the command has no reliable dry-run and is irreversible, stop for explicit user confirmation before execution.
