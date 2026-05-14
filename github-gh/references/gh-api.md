# gh api Fallback

Use `gh api` only when standard `gh` commands cannot express the needed read or write.

Use REST v3 for resource-oriented endpoints and simple pagination. Use GraphQL v4 when you need Project v2 fields, cross-resource joins, node IDs, or mutations not exposed by standard commands. For GitHub Enterprise Server, pass `--hostname HOST` and use endpoints relative to that host.

REST examples:

```sh
gh api repos/owner/repo/collaborators --paginate --jq '.[].login'
gh api --hostname ghe.example.com repos/owner/repo/collaborators --paginate --jq '.[].login'
gh api repos/owner/repo/issues/123/comments --jq '.[] | {id,user:.user.login,body}'
gh api --method PATCH repos/owner/repo/issues/123 --field state=closed
```

GraphQL example:

```sh
gh api graphql \
  -f query='query($owner:String!,$name:String!){repository(owner:$owner,name:$name){id,nameWithOwner}}' \
  -F owner=owner \
  -F name=repo \
  --jq '.data.repository'
```

Flags:

- `--method`: HTTP method; state it explicitly for writes.
- `--hostname HOST`: target GHES instead of `github.com`.
- `--field` / `-F`: typed fields; use for simple values.
- `--raw-field` / `-f`: string fields; use when no type conversion is desired.
- `--input`: JSON body from a file or stdin for complex payloads.
- `--jq`: filter response without exposing unnecessary data.
- `--paginate`: request all pages where supported.
- `--slurp`: combine paginated output for array processing.

Before API fallback, state host, endpoint, method, input file or fields, pagination behavior, and expected output. Avoid `eval`, unsafe shell string concatenation, and token exposure. Prefer JSON bodies via temporary files or stdin.

Helper wrapper examples:

```sh
scripts/gh-api-json.sh --hostname ghe.example.com --endpoint repos/owner/repo/collaborators --paginate --jq '.[].login'
scripts/gh-api-json.sh --endpoint repos/owner/repo/issues/123 --method PATCH --field state=closed
```
