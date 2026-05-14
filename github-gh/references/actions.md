# Actions

Start PR-related CI checks with `gh pr checks`. Move to `gh run` only when run details, logs, artifacts, reruns, or cancellation are needed.

Runs:

```sh
gh run list --repo owner/repo --limit 20 --json databaseId,displayTitle,status,conclusion,workflowName,headBranch,event
gh run view RUN_ID --repo owner/repo --json status,conclusion,jobs,url
gh run view RUN_ID --repo owner/repo --log
gh run watch RUN_ID --repo owner/repo
gh run download RUN_ID --repo owner/repo --dir artifacts
```

Workflows:

```sh
gh workflow list --repo owner/repo
gh workflow view workflow.yml --repo owner/repo
gh workflow run workflow.yml --repo owner/repo --ref main -f version=v1.2.3
```

Write operations:

- `gh workflow run` dispatches a workflow.
- `gh run rerun RUN_ID` starts new jobs.
- `gh run cancel RUN_ID` changes run state.

For these writes, summarize repo, workflow or run ID, ref, inputs, and intent first.
