---
title: "REANA 0.8.1 is released"
date: 2022-02-15T09:00:00+01:00
---

We are glad to announce the release of REANA 0.8.1, a minor update that allows
users to set job timeout limits, improves workspace web page file name
filtering, allows displaying workspace HTML reports directly, and more!

<!--more-->

## What's new for the users?

### Configurable job timeout limits

If your workflow launches many hundreds of jobs and some of these may be
"running away" --- for example when a job enters a state of infinite loop
waiting for external resources --- it may be useful to set a hard limit on the
run time of potentially fragile jobs. This is now possible thanks to the new
``kubernetes_job_timeout`` clause in the workflow specification:

```yaml {hl_lines=[5]}
  steps:
    - name: mystep
      environment: 'docker.io/mydockerimage:1.0.0'
      compute_backend: kubernetes
      kubernetes_job_timeout: 3600
      commands:
        - ./mycommand mydata.root
```

You can set your preferred job timeout values (in seconds) differently in each
workflow step. If a job exceeds the timeout, it will be forced to terminate. In
this way your workflows will not get "stuck" and you will be able to inspect
workflow logs for possible root cause causing the jobs to exceed the time
limits.

If you don't specify any time limit, note that the default time limit for any
job will be _7 days_.

Please see the [custom job
timeouts](https://docs.reana.io/advanced-usage/compute-backends/kubernetes/#custom-job-timeouts)
documentation page to know more about how to set the job timeout values in your
CWL, Serial, Snakemake, or Yadage workflows.

### Searching workspace files by name

If your workflow generates hundreds of files in the workspace, it is not easy
to locate some particular file on the workspace tab of the workflow web page.

REANA 0.8.1 now allows searching your workspaces for desired file names. Inside
the workspace tab of the workflow details page, there is a new search bar where
you can type a part of the file name and the web interface will show only the
files corresponding to your query:

![workspace-search](/images/reana-0.8.1-workspace-search.png)

### Previewing HTML workspace files directly

In REANA 0.8.0, it was possible to preview plain text files and graphical
images directly on the web interface. As of REANA 0.8.1, you can now also
preview HTML files in your workspace without having to download them locally.
This feature is particularly useful to visualise Snakemake execution reports
that are automatically generated once the workflow finishes successfully:

![snakemake-support-report](/images/snakemake-support-report.png)

### Improved Cluster Health status web page

In REANA 0.8.0, a new "Cluster health" web page with the summary of the cluster
status was introduced. Its purpose was to show the readiness of the cluster to
run user workflows. The displayed charts were showing values based on the
_usage_ of existing cluster resources, showing information about cluster nodes,
workflows, jobs, and notebooks.

As of REANA 0.8.1, the "Cluster health" web page was revamped to show values
based on the _availability_ of cluster resources instead. This makes the charts
easier to read and easier to understand how many available resources the
cluster has for running user workflows at any given moment.

Here is one illustrative picture of the new cluster health charts:

![cluster-health](/images/reana-0.8.1-cluster-health.png)

## What's new for the administrators?

### Configure maximum job timeout limits

The newly introduced user-configurable job timeout limit feature forces
workflows to terminate when a certain amount of time is exceeded. In addition,
the cluster administrators can configure the maximum timeout limit for all user
jobs globally. This feature is always enabled and, by default, it has a value
of _7 days_ (604800 seconds). This means that, if a workflow job keeps running
for more than 7 days, it will be automatically terminated. This global
catch-all value can be configured by cluster administrators by setting the
``kubernetes_jobs_timeout_limit`` [Helm
value](https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md).

As an administrator, you can also set the maximum custom job timeout limit that
the users will be allowed to set in their workflow jobs. By default this value
is _14 days_ (1209600 seconds) and it can be customised at the deployment time
via the ``kubernetes_jobs_max_user_timeout_limit`` [Helm
value](https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md).

### Declare supported compute backends

As of REANA 0.8.1, you can declare which of the compute backends (HTCondor,
Kubernetes, Slurm) are supported in your REANA deployment. The users will be
able to see this information using the `info` command:

```
$ reana-client info
List of supported compute backends: kubernetes
```

This is useful to know which kind of workflows a user can launch on the given
REANA cluster instance the user is connected to. The information is also used
by `reana-client validate` to detect incompatibilities before the workflow
submission.

You can configure which compute backends are supported in your REANA deployment
by setting the ``compute_backends`` [Helm
value](https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md).

### Configure fine-grained server logging

The uWSGI configuration of the REANA-Server component has been changed to log
all HTTP requests by default. In addition, you can also configure the following
[Helm
values](https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md):

- `reana_server.uwsgi.log_all`: Enables all the logging. It corresponds to the opposite of uWSGI option [`disable-logging`](https://uwsgi-docs.readthedocs.io/en/latest/Options.html#disable-logging).
- `reana_server.uwsgi.log_4xx`: It corresponds to the uWSGI option [`log-4xx`](https://uwsgi-docs.readthedocs.io/en/latest/Options.html#log-4xx).
- `reana_server.uwsgi.log_5xx`: It corresponds to the uWSGI option [`log-5xx`](https://uwsgi-docs.readthedocs.io/en/latest/Options.html#log-5xx).

### Configure node labels for Database and Message Broker pods

There are new [Helm configuration
options](https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md)
`node_label_infrastructuredb` and `node_label_infrastructuremq` enabling a
possibility to run the Database and the Message Broker pods in specifically
dedicated cluster nodes. This can be useful for big clusters running thousands
of concurrent workflows where you want to isolate the DB and MQ services to
different nodes in order to improve the overall cluster performance for heavy
user load situations.

### Configure periodic CPU quota usage updates

In REANA 0.8.0, an optional user quota usage accounting feature was introduced,
permitting to keep track of the amount of CPU and Disk usage of users.

It was possible to update CPU and Disk quota usage upon _workflow termination_.
If the `quota.termination_update_policy` Helm value was set, then immediately
after workflow finished, both the CPU and the Disk quotas were calculated.
However, this could slow down the workflow termination procedures, which may
affect cluster performance in case of running thousands of concurrent user
workflows. This was especially true of the Disk quota updates, which REANA
0.8.0 allowed to configure to be updated _periodically_ via a cron job, for
example every night, as governed by the `quota.disk_update` Helm value.

As of REANA 0.8.1, it is now possible to update _both_ CPU and Disk quota
consistently, either during workflow termination or periodically. To reflect
this change, the [Helm
values]((https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md))
`quota.disk_update` was renamed to `quota.periodic_update_policy` and the value
`quota.termination_update_policy` was renamed to
`quota.workflow_termination_update_policy`.

The old Helm value names are still recognised to guarantee backward
compatibility.

### How to upgrade existing REANA 0.8 clusters

If you are a REANA cluster administrator and you would like to upgrade from
REANA 0.8.0 to REANA 0.8.1, you can optionally define the new [Helm
values](https://github.com/reanahub/reana/blob/0.8.1/helm/reana/README.md)
listed above in your Helm values file:

```console
$ vim myvalues.yaml
```

You can then use the [Helm diff plugin](https://github.com/databus23/helm-diff)
to inspect the forthcoming change and then perform the upgrade using the
standard Helm commands:

```console
$ helm repo update
$ helm diff upgrade reana reanahub/reana --version 0.8.1 --values myvalues.yaml
$ helm upgrade reana reanahub/reana --version 0.8.1 --values myvalues.yaml
```

## Further improvements and bug fixes

REANA 0.8.1 release comes with other minor improvements and bug fixes. Please
see the detailed [REANA 0.8.1 release
notes](https://github.com/reanahub/reana/releases/tag/0.8.1) for the complete
list.

Enjoy!
