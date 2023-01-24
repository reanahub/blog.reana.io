---
title: "REANA 0.9.0 is released"
date: 2023-01-24T09:00:00+01:00
---

We are happy to announce REANA 0.9.0, a major update that allows
users to set custom workflow retention rules to automatically delete workspace
files, adds a new way of launching workflows from external sources, and more!

<!--more-->

## What's new for the users?

### Automatically delete workspace files using custom retention rules

It's helpful to have a way to automatically delete files in your workflow's
workspace that you don't need anymore. For example, if your workflow creates
large temporary files that take up a lot of space that consume your
[disk quota](https://docs.reana.io/advanced-usage/user-quotas), you may want to
get rid of them after a certain period of time. Therefore, we're introducing the
ability to set up custom rules for keeping or deleting files in your workspace.
This can save you from having to manually delete them, which can be a
time-consuming process.

![Retention rules in the web UI](/images/ui-retention-rules.png)

Please see the dedicated blog post about [custom file retention rules](/posts/2022/workspace-file-retention-rules/)
to learn more about this feature.

### Launching workflows from external sources using web interface

You can now easily run your analysis workflows from publicly accessible external
sources, like GitHub, GitLab, digital repositories like Zenodo or any website on
the web using the new REANA launcher page. You can host your workflows on a
public location and be able to access and run them on REANA without having to do
any manual steps.

[![Launch home](/images/launching-workflows-launcher-home.png)](https://reana.cern.ch/launch)

For more information about this new feature please check the dedicated blog post
about [launching workflows from external sources using web interface](/posts/2022/launching-workflows/).

### Rucio authentication for workflow jobs

[Rucio](https://rucio.cern.ch/) is a scientific data management system used in
LHC particle physics and related scientific domains. It provides access for
large volumes of data spread across facilities at multiple institutions.

If your workflow needs to use data that is managed by a Rucio system, you can
follow the documentation that describes the [Rucio authentication method](https://docs.reana.io/advanced-usage/access-control/rucio/)
to learn more about it.

### Kerberos authentication for workflow orchestration

Previously, you had to set up Kerberos authentication for each step of your
workflow, one at a time. You can now easily enable Kerberos authentication
for your entire workflow by adding just one line in the specification file. This
makes it much more convenient and efficient. This technique is especially useful
for workflows that need to access files in restricted storage in multiple steps.

Please check our documentation about [enabling Kerberos support for an entire workflow](https://docs.reana.io/advanced-usage/access-control/kerberos/#setting-kerberos-requirement-for-whole-workflow)
to learn more about this feature.

### Notifications to inform when critical levels of quota usage is reached

A new notifications feature has been added to REANA web interface to alert users
when their [quota](https://docs.reana.io/advanced-usage/user-quotas) is
approaching or has reached its limit. This feature is intended to help users
stay within their allocated Disk space and CPU consumption limits and inform
them when deletion of unnecessary workflow runs should be performed in order to
liberate some resources.

## What's new for the administrators?

### Configure workspace retention rules

### Configure an additional volume to be used by the database and the message broker

### Configure scheduler requeue count for busy cluster situations

### Configure the generation of a self-signed TLS certificate

### How to upgrade existing REANA 0.8 clusters

If you are a REANA cluster administrator and you would like to upgrade from
REANA 0.8.0 to REANA 0.9.0, you can proceed as follows.

First of all, you can optionally define the new [Helm
values](https://github.com/reanahub/reana/blob/0.9.0/helm/reana/README.md)
listed above in your Helm values file:

```console
$ vim myvalues.yaml
```

You can then use the [Helm diff plugin](https://github.com/databus23/helm-diff)
to inspect the forthcoming change and then perform the upgrade using the
standard Helm commands:

```console
$ helm repo update
$ helm diff upgrade reana reanahub/reana --version 0.9.0 --values myvalues.yaml
$ helm upgrade reana reanahub/reana --version 0.9.0 --values myvalues.yaml
```

This release introduces several database schema changes to support workflow
retention rules, launching workflows from external sources and introduces some small
improvements and fixes. We thus need to perform database schema upgrade by
following the dedicated [upgrade documentation](http://docs.reana.io/administration/deployment/upgrading-db/):

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic upgrade
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade 6568d7cb6710 -> d34f3905043c, Workflow launcher url.
INFO  [alembic.runtime.migration] Running upgrade d34f3905043c -> b92fe567be5b, Retention rules.
INFO  [alembic.runtime.migration] Running upgrade b92fe567be5b -> 377cfbfccf75, Retention rules pending status.
```

## Further improvements and bug fixes

REANA 0.9.0 release comes with other minor improvements and bug fixes. Please
see the detailed [REANA 0.9.0 release
notes](https://github.com/reanahub/reana/releases/tag/0.9.0) for the complete
list.

Enjoy!
