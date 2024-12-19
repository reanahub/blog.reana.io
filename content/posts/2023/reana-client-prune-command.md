---
title: "Optimizing disk space in REANA workspaces: the prune command"
date: 2023-12-05T07:00:00+01:00
---

With the introduction of the `prune` command, managing disk space in REANA workspaces has been simplified.
This feature offers an efficient way to identify and remove temporary files,
thereby conserving storage while preserving the reproducibility of your workflows.

<!--more-->

To manage the disk space in REANA, you might have used the `rm` command to manually
delete unnecessary files, for example by running `reana-client rm -w myanalysis.42 tmp/mytmpdata.csv`.
Although it worked, it was time-consuming and required extra care not to delete essential input or output files.

`reana-client` includes the `prune` command as a more convenient and safer way to free up disk space
in your REANA workspaces.
It is designed to manage workspace files intelligently, automatically identifying and deleting
temporary files that are neither inputs nor outputs, freeing up your storage significantly and effortlessly.
Here's how you can use it:

```console
$ reana-client prune -w my-analysis.42
==> SUCCESS: The workspace has been correctly pruned.
```

This will delete all temporary files in the workspace of the workflow `my-analysis.42`.
If you need to free up even more space, you can also delete input or output files 
by using the `--include-inputs` or `--include-outputs` flags, respectively.

However, a word of caution: it's important to remember that running the `prune` command will permanently delete the files
from your workspace. This means that you should make sure you have backed up any files you want to keep
before running the command. Additionally, be careful when using the `--include-inputs` or
`--include-outputs` flags, as deleting inputs will make it impossible to run your workflow
again and by deleting output files you will lose the results of your workflow run.

By the way, did you know you can keep your workspaces clean automatically? REANA features the possibility
to configure one or more *workspace file retention rules* for your workflows that will automatically
and periodically delete the specified files after a certain amount of time.
You can read more about this feature in the [related blog post](https://blog.reana.io/posts/2022/workspace-file-retention-rules/).

We hope you find this feature useful for managing your REANA workspaces and freeing up
valuable disk space. As always, if you have any feedback or suggestions for how we can improve
REANA, please let us know!

## See also

- [REANA Client](https://reana-client.readthedocs.io/en/latest/) documentation page
- [Workspace retention rules](https://blog.reana.io/posts/2022/workspace-file-retention-rules/) blog post
