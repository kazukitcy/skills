# Releases

Use `gh release` for release reads and ordinary release writes. Use `[HOST/]OWNER/REPO` for GitHub Enterprise Server when the host is not GitHub.com.

Common commands:

```sh
gh release list --repo owner/repo
gh release view v1.2.3 --repo owner/repo --json tagName,name,isDraft,isPrerelease,assets,url
gh release create v1.2.3 --repo owner/repo --title "v1.2.3" --notes-file notes.md
gh release upload v1.2.3 dist/app.tar.gz --repo owner/repo
gh release delete v1.2.3 --repo owner/repo
```

`release create` and `release upload` are writes. `release delete` is destructive and requires the admin/destructive procedure.

Before release writes, summarize repo, tag, title, draft/prerelease state, notes source, assets, and command intent. Do not print secret file contents.
