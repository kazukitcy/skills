# Files and Code Search

Use structured output for file, content, and code-search reads. Use `[HOST/]OWNER/REPO` for GitHub Enterprise Server when the host is not GitHub.com.

Code search:

```sh
gh search code "functionName repo:owner/repo" --json repository,path,url,textMatches
gh search code "language:go symbol:Handler org:owner" --json repository,path,url
```

File and directory lookup:

```sh
gh api repos/owner/repo/contents/path/to/file --jq '.content'
gh api repos/owner/repo/contents/path/to/dir --jq '.[] | {name,path,type,sha}'
```

The Contents API returns base64 content for files by default. Decode only the requested file content and avoid printing secrets or large binary data. For raw file reads, prefer an explicit API or download path that preserves host and repo context.

Use code search for locating references and the Contents API for reading known paths. Do not clone the repository unless local checkout behavior is specifically needed.
