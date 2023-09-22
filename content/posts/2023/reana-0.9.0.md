---
title: "REANA 0.9.0 is released"
date: 2023-01-26T09:00:00+01:00
---

We are happy to announce REANA 0.9.0, a major update that allows
users to set custom workflow retention rules to automatically delete workspace
files, adds a new way of launching workflows from external sources, and more!

<!--more-->

## What's new for the users?

### Automatically delete workspace files using custom retention rules

It is helpful to have a way to automatically delete files in your workflow's
workspace that you don't need anymore. For example, if your workflow creates
large temporary files that take up a lot of space that consume your
[disk quota](https://docs.reana.io/advanced-usage/user-quotas), you may want to
get rid of them after a certain period of time. The new REANA 0.9.0 release
introduces the ability to set up custom rules for automatic retention and
deletion of files in your workspace.

![Retention rules in the web UI](/images/ui-retention-rules.png)

Please see the dedicated blog post about [custom workspace file retention rules](/posts/2022/workspace-file-retention-rules/)
to learn more about this feature.

### Launching workflows from external sources using web interface

As of this REANA release, you can now easily run your analysis workflows from publicly accessible external
sources, like GitHub, GitLab, digital repositories like Zenodo or any other website
using the new REANA launcher page. You can host your workflows on a
public location and be able to launch them on REANA without having to do any
manual commands in the terminal.

[![Launch home](/images/reana-0.9.0-launcher.png)](https://reana.cern.ch/launch)

For more information about this new feature please check the dedicated blog post
about [launching workflows from external sources using web interface](/posts/2022/launching-workflows/).

### Rucio authentication for workflow jobs

[Rucio](https://rucio.cern.ch/) is a scientific data management system used in
LHC particle physics and related scientific domains. It provides access for
large volumes of data spread across facilities at multiple institutions.

```yaml {hl_lines=[4,5,6]}
rule mystep:
  container:
    "docker://docker.io/reana-env-rucioclient:1.0"
  resources:
    voms_proxy=True,
    rucio=True
  shell:
    "rucio get my_rucio_scope:my_rucio_file"
```

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

A new notification feature has been added to REANA web interface to alert users
when their [quota](https://docs.reana.io/advanced-usage/user-quotas) is
approaching or has reached its limit. This feature is intended to help users
stay within their allocated Disk space and CPU consumption limits and inform
them when deletion of unnecessary workflow runs should be performed in order to
liberate some resources.

![Quota notifications](/images/reana-0.9.0-notifications.png)

## What's new for the administrators?

### Configure global workspace retention rules

Workspace retention rules are giving users the possibility to remove unnecessary files from their workflows' workspaces.
However, administrators can also define a global workspace file retention period, after which all the files that are not listed as inputs or outputs of a workflow will be deleted.
This can be achieved by setting the `workspaces.retention_rules.maximum_period` Helm value to the desired amount of retention days.
Please note that, by default, files are retained forever.

For more information about this, see the related documentation page about [configuring global workspace retention rules](https://docs.reana.io/administration/configuration/configuring-global-workspace-retention-rules).

### Configure an additional volume for infrastructure components

Up until now, REANA has used only one shared storage volume to store all the workflows' workspaces, together with the database's and message broker's data.
This means that, if the shared storage became full, some of the REANA components could fail due to the lack of free disk space.
While this is still the default behaviour of REANA, it is now also possible to configure a second infrastructure storage volume that can be used to better separate the data stored by the REANA infrastructure components from the runtime data generated by user workflows.

If you are interested in this change, please see the documentation page about [configuring storage volumes](https://docs.reana.io/administration/configuration/configuring-storage-volumes).

### Configure scheduler requeue count for busy cluster situations

Under specific circumstances, for example when the REANA cluster is busy, it can happen that some workflows cannot be scheduled.
These workflows are then queued again so that REANA can retry scheduling them in the future.
However, workflows with high priority that are requeued many times can overwhelm the queue, preventing other workflows from being executed.

This limit is set to 200 retries by default, after which incoming workflows will be declared as impossible to schedule. The value of 200 retries can be customised by setting the Helm value of `reana_server.environment.REANA_SCHEDULER_REQUEUE_COUNT`. You may also want to customise the   `reana_server.environment.REANA_SCHEDULER_REQUEUE_SLEEP` Helm value for defining time interval between retries.

### Configure custom TLS certificates

REANA 0.9.0 also improves the handling of TLS certificates.
Without additional configuration needed, a self-signed certificate lasting 90 days is automatically generated each time REANA is deployed or upgraded.
This is enough for development instances, but a valid certificate issued by a trusted Certificate Authority should be used for production deployments.

For this reason, it is possible to disable the generation of the default self-signed certificate by setting the `ingress.tls.self_signed_cert` Helm value to false.
You can then provide a custom TLS certificate by creating an appropriate Kubernetes TLS secret and by setting the Helm value of `ingress.tls.secret_name` to the name of this newly-created secret.

See the documentation page about [configuring TLS certificates](https://docs.reana.io/administration/configuration/configuring-tls-certificates) to learn more about this.

### How to upgrade existing REANA 0.8 clusters

If you are a REANA cluster administrator and you would like to upgrade from
REANA 0.8 to REANA 0.9.0, you can proceed as follows.

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

REANA 0.9.0 release comes with many other improvements and bug fixes,
representing close to one year of development. Please see the detailed
[REANA 0.9.0 release notes](https://github.com/reanahub/reana/releases/tag/0.9.0)
for the complete list.

Enjoy!
