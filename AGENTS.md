# Agent Skills Repository Guidelines

This repository is the authoritative editing source for `kazukitcy/skills`, a collection of agent skills distributed through APM. Each top-level directory with a `SKILL.md` file is a standalone skill.

## Repository Scope

- Edit and commit repository-managed skills in this repository.
- Put a skill in this repository only when it is reusable across multiple projects or should be distributed through APM.
- Keep project-specific skills outside this repository when they depend on a single project's domain, conventions, or file layout.
- Treat APM as the installation and distribution mechanism, not as the editing source.
- Do not assume an APM-managed skill must be installed under `.agents/skills/`. Runtime installations may live under `.agents/skills/`, `.claude/skills/`, or another runtime-specific skills directory.
- Ask the user whether a skill should be repository-managed or project-specific when placement is unclear.

## Skill Structure

- Use lowercase kebab-case for skill directory names.
- Keep the skill directory name identical to the `name:` value in `SKILL.md` frontmatter.
- Put agent-facing instructions in `SKILL.md`.
- Keep each skill self-contained. Put helper scripts in `<skill-name>/scripts/` and supporting reference files inside the same skill directory.
- Make helper scripts executable when agents are expected to run them directly.
- Do not rely on unstated local shell aliases or machine-specific configuration.
- Define mechanically checkable contracts in linters or structured frontmatter where possible. Do not rely on prompt-only rules when a rule can be checked statically.

## Local Runtime Validation

This repository remains the authoritative editing source during local runtime validation. The copy loaded by the current agent runtime is only a validation target.

Only when validating local runtime behavior, copy the skill directory from this repository to `~/.agents/skills/<skill-name>/` and test that copy there. Treat `~/.agents/skills/<skill-name>/` as a temporary validation copy, not as the required installation location for APM-managed skills.

While validating locally, synchronize changes from the repository copy to the validation copy. Apply the same relative-path changes from `<skill-name>/` to `~/.agents/skills/<skill-name>/` for edits, additions, deletions, and renames.

Do not consider a skill change complete if it exists only in `~/.agents/skills/<skill-name>/`. Reflect any useful validation-copy edits back into this repository before testing, documenting, or committing the change.

Repository-level files, including `README.md` and `AGENTS.md`, do not need to be copied into runtime skill directories.

## Skill Lifecycle

- Add new skills at the repository root as `<skill-name>/SKILL.md`.
- Update `README.md` whenever a skill is added, renamed, or removed.
- Include the APM install path in the README: `apm install -g kazukitcy/skills/<skill-name>`.
- Keep private or security-sensitive operational details out of published skills. Store those details locally instead.

## Documentation Policy

- Write public documentation, `SKILL.md`, README entries, and commit messages in English.
- Keep Markdown indentation consistent within each file. Use two spaces for nested list items and continuation lines unless the surrounding file already uses another style.
- Do not commit secrets, private workflow details, personal tokens, local machine paths that are not required by the skill, generated dependency folders, or build artifacts.

## Commit Checklist

- Confirm each changed skill directory still has matching `SKILL.md` frontmatter.
- Confirm `README.md` lists any added, renamed, or removed skill correctly.
- Check `git status --short` and commit only the intended files.
