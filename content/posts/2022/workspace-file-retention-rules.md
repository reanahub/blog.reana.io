---
title: "Automatically delete workspace files using custom retention rules"
date: 2022-12-07T05:00:00+01:00
---

It can be useful to be able to keep some files in your workflow's workspace only
for a limited period of time, for example if your workflow generates huge
temporary files that consume your
[disk quota](https://docs.reana.io/advanced-usage/user-quotas). It is always
possible to remove any unnecessary workspace files manually, but it may be quite
a tedious process. Therefore, we are introducing the possibility to define
custom workspace file retention rules to allow fully automated deletion of
unnecessary files inside workspaces.

<!--more-->

You can define custom file retention rules in the `reana.yaml` specification
file of your workflow. For example, this is how you would specify that you would
like to delete files in `tmp1` one day after the workflow run successfully
terminates, large `tmp2/*.root` files seven days after and temporary
`tmp3/*.csv` files thirty days after:

```yaml
workspace:
  retention_days:
    tmp1: 1
    tmp2/*.root: 7
    tmp3/*.csv: 30
```

Please note that files and directories specified as inputs or outputs of your
workflow will _never_ be deleted, even if they match one of the retention rules.
This is to make sure that your workflows can be recalled and reproduced even
many years in the future.

For any of your workflow runs, you will be able to verify the active file
retention information status through the web interface, where you will also find
the information about any scheduled file deletion times:

![Retention rules in the web UI](/images/ui-retention-rules.png)

You can also use the new `retention-rules-list` command of `reana-client` to
list the retention rules for a particular workflow using the command line:

```console
$ reana-client retention-rules-list -w reana-demo-root6-roofit
WORKSPACE_FILES   RETENTION_DAYS   APPLY_ON              STATUS
tmp1              1                2022-12-06T23:59:59   active
tmp2/*.root       7                2022-12-12T23:59:59   active
tmp3/*.csv        30               2023-01-04T23:59:59   active
```

To learn more about retention rules and how they work, please take a look at the
related
[Workspace retention](https://docs.reana.io/advanced-usage/workspace-retention)
documentation page.

## Availability

Workspace file retention rules will be part of the REANA 0.9.0 release series.
However, you can already use them on the [reana.cern.ch](https://reana.cern.ch)
instance.

## See also

- [Workspace retention](https://docs.reana.io/advanced-usage/workspace-retention)
  documentation page
