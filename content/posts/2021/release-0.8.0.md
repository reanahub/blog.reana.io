---
title: "REANA 0.8.0 is released"
date: 2021-11-29T10:19:06+01:00
tags:
  - release
  - client
  - cluster
---

We are glad to announce the release of REANA 0.8.0, a major update
allowing users to run Snakemake workflows, ... <!--TODO-->
<!--more-->


## What's new?

<!-- TODO: add sections:  -->

### Upgrade your cluster to 0.8.0

Follow these steps to upgrade your cluster from 0.7.x to 0.8.0.

#### 1. Upgrade the cluster using Helm

```console
$ helm upgrade reana reanahub/reana --version 0.8.0
```

For more information, check all the possible Helm values [here](https://github.com/reanahub/reana/blob/0.8.0/helm/reana/README.md).

#### 2. Label the cluster nodes accordingly

Take into account that in this release node labels are richer, including
dedicated labels for runtime batch, jobs and sessions.

For example, in a 4 node cluster, in order to distribute the workload
among the nodes, they can be labeled as follows:

```console
$ kubectl label nodes reana-node-0 reana.io/system=infrastructure
$ kubectl label nodes reana-node-1 reana.io/system=runtimebatch
$ kubectl label nodes reana-node-2 reana.io/system=runtimejobs
$ kubectl label nodes reana-node-3 reana.io/system=runtimesessions
```

#### 3. Upgrade the database schema

This release introduces several database schema changes to support the
quota accounting feature among others. Thus, we need to run the
upgrade by following the dedicated [documentation](http://docs.reana.io/administration/deployment/upgrading-db/).

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic upgrade
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> c912d4f1e1cc, Quota tables.
INFO  [alembic.runtime.migration] Running upgrade c912d4f1e1cc -> ad93dae04483, Interactive sessions.
INFO  [alembic.runtime.migration] Running upgrade ad93dae04483 -> 4801b98f6408, Job started and finished times.
INFO  [alembic.runtime.migration] Running upgrade 4801b98f6408 -> f84e17bd6b18, Workflow complexity.
INFO  [alembic.runtime.migration] Running upgrade f84e17bd6b18 -> 6568d7cb6710, storing full workflow workspace.
```

#### 4. Create default quota resources

Due to the new quota accounting feature, it is necessary to create two
default resources to measure both CPU and Disk usage:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db quota create-default-resources
Created resources: ['processing time', 'shared storage']
```

#### 5. Set the default user quota limits

The last step is to set the quota limits for all the users in the
database. By default, let us set the default quota limit, which is 0,
meaning that there are no limits of usage.

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- flask reana-admin quota-set-default-limits
Quota limit 0 for 'processing time' successfully set to users ['john.doe@example.org', ....]
Quota limit 0 for 'shared storage' successfully set to users ['john.doe@example.org', ....]
```

Later on, it is possible to set quota limits per user and per resource
by using the command `flask reana-admin quota-set`. Do not hesitate to
check how passing the `--help` flag this command.

All set! At this point, you should have your REANA cluster
upgraded to 0.8.0, congratulations!
