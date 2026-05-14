# Gists

Use `gh gist` for gist reads and ordinary gist writes. Gists are account-scoped, so repository resolution is usually not relevant; still keep host/account context clear when using GitHub Enterprise Server.

Common commands:

```sh
gh gist list --limit 20
gh gist view GIST_ID --files
gh gist create file.txt --public --desc "Description"
gh gist edit GIST_ID file.txt
gh gist delete GIST_ID
```

`gist create` and `gist edit` are writes. `gist delete` is destructive and requires the admin/destructive procedure.

Before gist writes, summarize gist ID or creation intent, visibility, files, description, and command intent. Do not print secret file contents.
