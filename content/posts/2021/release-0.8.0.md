---
title: "REANA 0.8.0 is released"
date: 2021-11-30T10:19:06+01:00
---

We are glad to announce the release of REANA 0.8.0, a major update
allowing users to run Snakemake workflows, allowing administrators to
set and monitor CPU and Disk quotas for users, and more!

<!--more-->


## What's new for the users?

### Support for running Snakemake workflows

One of the most notable new features of REANA 0.8 release series is
the support for running [Snakemake](https://snakemake.github.io/)
workflows. Snakemake joins CWL and Yadage as another workflow
specification language that you can use to write complex computational
workflows:

```yaml
# Snakefile
rule all:
    input:
        "results/data.root",
        "results/plot.png"

rule gendata:
    input:
        gendata_tool=config["gendata"]
    output:
        "results/data.root"
    params:
        events=config["events"]
    container:
        "docker://docker.io/reanahub/reana-env-root6:6.18.04"
    shell:
        "mkdir -p results && root -b -q '{input.gendata_tool}({params.events},\"{output}\")'"

rule fitdata:
    input:
        fitdata_tool=config["fitdata"],
        data="results/data.root"
    output:
        "results/plot.png"
    container:
        "docker://docker.io/reanahub/reana-env-root6:6.18.04"
    shell:
        "root -b -q '{input.fitdata_tool}(\"{input.data}\",\"{output}\")'"
```

Please see the [dedicated blog
post](/posts/2021/support-for-running-snakemake-workflows) about how
to use Snakemake with REANA.

### Upgrade of CWL workflow engine

The Common Workflow Language engine was upgraded from `cwltool`
version 1 to version 3 and the compliance with the CWL reference test
suite has been improved. This allows using many new CWL constructs in
your workflows.

### CPU and Disk quota accounting

Optionally, the REANA cluster may have CPU and Disk quota accounting
feature turned on. The new command `reana-client quota-show` will
allow seeing your quota limits and current usage:

```console
$ reana-client quota-show --resource cpu --report limit
No limit.

$ reana-client quota-show --resource disk --report limit
No limit.
```

If the quota accounting feature is turned on, the `quota-show` command
will also allow displaying current usage:

```console
$ reana-client quota-show  --resource cpu --report usage -h
36s

$ reana-client quota-show  --resource disk --report usage -h
2.61 GiB
```

If the feature is enabled, the REANA web interface will indicate disk
usage in your workflow list:

![quota-in-workflow-list](/images/reana-0.8.0-quota-workflow.png)

The overall quota consumption can be tracked on your profile page:

![quota-in-profile](/images/reana-0.8.0-quota-profile.png)

### Improved workflow validation

The `reana-client validate` command has been improved to include a
possibility to validate the workflow against the remote REANA cluster
you would like to use. The new option is named
`--server-capabilities`:

```console
$ cd my-analysis
$ reana-client validate --server-capabilities
```

The option will cover the scenarios where your workflow definition can
be theoretically correct, but the remote REANA cloud does not support
the desired feature. One example is the optional `compute_backend`
declaration. If you would like to set `compute_backend` to
`htcondorcern` in order to instruct the REANA cluster to use the
HTCondor high-throughput compute backend for some job, but the remote
REANA cluster where you are connected to does not support it, you
would be warned about the mismatch.

### Improved list command filtering

The `reana-client list` command's performance has been optimised. If
you have a large number of workflows, the `list` will execute much
faster.

The default output focuses on tracking the status of the workflows. If
you would like to track the workflow progress or the workspace disk
usage, please use new options `--include-progress` and
`--include-workspace-size`.

The `list` command also adds a possibility to filter workflows by name
or by status via the new `--filter` option. This can be convenient if
you work on several projects ("project-a", "project-b", ...) and have
run many workflows such as "project-a.1", "project-a.2", up to
"project-z.1". If you are interested in listing the status of
workflow runs from the "project-p" group only, you can use:

```console
$ reana-client list --filter name=project-p
```

You can also filter workflows based on the workflow status. For
example, let us display only those workflow runs that failed:

```console
$ reana-client list --filter status=failed
```

The filtering options can be combined in which case the filters will
be applied one after another as they appear in the command line. For
example, showing "running" workflows from "project-p" only:

```console
$ reana-client list --filter status=running --filter name=project-p
```

The other `reana-client` commands, notably `ls` allowing to list files
and `du` allowing to get information about disk usage, were also
enriched with the `--filter` option.

### Inspecting run times of individual jobs

The `reana-client logs` command was improved to show the started and
finished time for each individual job in the workflow:

```console
$ reana-client logs -w my-analysis.42
...
==> Step: gendata
==> Workflow ID: 4455a6b2-3d94-4694-ae99-e493327cd53f
==> Compute backend: Kubernetes
==> Job ID: reana-run-job-6f57f1c8-8edf-4840-9423-b638e664bf57
==> Docker image: docker.io/reanahub/reana-env-root6:6.18.04
==> Command: mkdir -p results && root -b -q 'code/gendata.C(20000,"results/data.root")'
==> Status: finished
==> Started: 2021-11-26T12:46:17
==> Finished: 2021-11-26T12:46:23
==> Logs:
...
```

If you would like to see a brief overview of all the steps of the
workflow in one go, you can simply grep the '==>' string in the `logs`
command output:

```console
$ reana-client logs -w my-analysis.42 | grep '^==>'
==> Workflow engine logs
==> Job logs
==> Step: gendata
==> Workflow ID: 4455a6b2-3d94-4694-ae99-e493327cd53f
==> Compute backend: Kubernetes
==> Job ID: reana-run-job-6f57f1c8-8edf-4840-9423-b638e664bf57
==> Docker image: docker.io/reanahub/reana-env-root6:6.18.04
==> Command: mkdir -p results && root -b -q 'code/gendata.C(20000,"results/data.root")'
==> Status: finished
==> Started: 2021-11-26T12:46:17
==> Finished: 2021-11-26T12:46:23
==> Logs:
==> Step: fitdata
==> Workflow ID: 4455a6b2-3d94-4694-ae99-e493327cd53f
==> Compute backend: Kubernetes
==> Job ID: reana-run-job-2da81be7-5108-41cd-8b7c-ffc0f081b3bd
==> Docker image: docker.io/reanahub/reana-env-root6:6.18.04
==> Command: root -b -q 'code/fitdata.C("results/data.root","results/plot.png")'
==> Status: finished
==> Started: 2021-11-26T12:46:23
==> Finished: 2021-11-26T12:46:33
==> Logs:
```

### Removal of support for Python 2.7

Following the discontinuation of Python 2.7 official support, REANA
0.8 release series stopped supporting Python 2.7 version. Please
upgrade your `reana-client` installation to use at least Python 3.6.

## What's new for the administrators?

### CPU and Disk quota accounting

REANA 0.8 release series allows cluster administrators to set certain
CPU and Disk quota usage limits for individual users. This can be set
by Helm configuration option `quota.enabled`.

Please note that if you do enable CPU and Disk quota monitoring, you
may want to further configure `quota.termination_update_policy` to
decide whether the CPU and Disk quota usage consumption for users will
be calculated immediately after workflow terminates or via a periodic
cron jobs.

### Improved cluster performance

The cluster performance when running numerous concurrent workflows was
considerably improved. We have tested running up to a thousand of
concurrent workflows running on clusters of up to three hundred
nodes. There are new Helm configuration options that allow
fine-tuning REANA cluster components in these conditions, such as:

- ``reana_server.environment.REANA_WORKFLOW_SCHEDULING_POLICY`` allows
  to set workflow scheduling policy. The value "fifo", meaning
  "first-in first-out", will execute workflows as they are coming. The
  value "balanced" will look at how many workflows a particular user
  launches. If user A uses the system heavily, and user B submits new
  workflows, the system will prefer to schedule the workflow from user
  B before continuing with workflows of the user A. The "balanced"
  scheduling policy will also look at the workflow DAG complexity. If
  a new workflow C would like to launch 10 jobs at the start, and the
  workflow D only 2 jobs, and the cluster is busy and the current
  capacity cannot accept more than 4 jobs at the given time, the
  workflow D would be preferred over workflow C.

- ``reana_server.environment.REANA_RATELIMIT_GUEST_USER`` and
  ``reana_server.environment.REANA_RATELIMIT_AUTHENTICATED_USER``
  allow setting REST API rate limit values.  If your cluster is very
  busy, you can use values such as "2000 per second" enabling heavy
  traffic from running a high amount of concurrent workflows.

- ``reana_server.environment.REANA_SCHEDULER_REQUEUE_SLEEP`` allows
  setting sleep time between processing queued workflows. The default
  value of 15 seconds may be too conservative, as the scheduler will
  pause for 15 seconds before looking at the incoming workflow
  queue. If you are running a lot of concurrent workflows, you may
  want to lower it to 1 second or even 0.1 seconds.

- ``reana_workflow_controller.environment.REANA_JOB_STATUS_CONSUMER_PREFETCH_COUNT``
  allows tweaking the Rabbit MQ prefetch count for the job status
  consumer. The default value was tested to behave well up to a
  thousand of concurrent workflows, so should be probably fine in your
  setups.

### How to upgrade existing REANA 0.7 clusters

If you are a REANA cluster administrator and you would like to upgrade
from REANA 0.7.* to REANA 0.8.0, please follow the steps described
below.

#### 1. Upgrade the cluster using Helm

```console
$ helm upgrade reana reanahub/reana --version 0.8.0
```

You may set various Helm values specified above; see also the full
list of [REANA Helm
values](https://github.com/reanahub/reana/blob/0.8.0/helm/reana/README.md).

#### 2. Label the cluster nodes

REANA 0.8 release series uses more cluster node labels which allows
separating nodes dedicated to running infrastructure pods, runtime
user workflow batch pods, runtime user job pods, and runtime user
interactive sessions. Setting the new values allows preventing
exceptional situations with user jobs, such as exhausting node memory,
from affecting other pods.

We therefore recommend upgrading your cluster node labels. For
example, if you have four nodes in the cluster, you can label them as
follows:

```console
$ kubectl label node reana-cluster-node-0 reana.io/system=infrastructure
$ kubectl label node reana-cluster-node-1 reana.io/system=runtimebatch
$ kubectl label node reana-cluster-node-2 reana.io/system=runtimejobs
$ kubectl label node reana-cluster-node-3 reana.io/system=runtimesessions
```

#### 3. Upgrade the database schema

This release introduces several database schema changes to support
among others the new quota accounting feature. We thus need to perform
database schema upgrade by following the dedicated [upgrade
documentation](http://docs.reana.io/administration/deployment/upgrading-db/):

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
meaning that there are limits of usage for users:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- flask reana-admin quota-set-default-limits
Quota limit 0 for 'processing time' successfully set to users ['john.doe@example.org', ....]
Quota limit 0 for 'shared storage' successfully set to users ['john.doe@example.org', ....]
```

Later on, we could decide to set quota limits per user and per
resource by using the command `flask reana-admin quota-set`.

And we are done with the upgrade! At this point, you should have your
REANA cluster fully upgraded to 0.8.0.

## Further improvements and bug fixes

REANA 0.8.0 release comes with other minor improvements and bug
fixes. Please see the detailed [REANA 0.8.0 release
notes](https://github.com/reanahub/reana/releases/tag/0.8.0).

Enjoy!
