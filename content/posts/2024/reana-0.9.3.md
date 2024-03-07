---
title: "REANA 0.9.3 is released"
date: 2024-03-13T06:00:00+01:00
---

REANA 0.9.3 has just been released. This is a minor update that upgrades
Snakemake workflow engine to version 7, improves job submission performance for
massively-parallel workflows, improves the clean-up processes for stopped and
failed workflows, and brings other minor improvements and bug fixes.

<!--more-->

## What's new for the users?

### Snakemake version 7

The support of Snakemake workflows has been improved by upgrading from
Snakemake 6.8.0 to 7.32.4 which brings compatibility with `reana-client` users
using Python 3.11 or newer versions. Furthermore, you can now make use of the
many new Snakemake 7 features, including:

- ability to access Snakemake rule variables from Bash scripts
  ([docs](https://snakemake.readthedocs.io/en/v7.32.3/snakefiles/rules.html#bash));
- ability to download and upload files to Zenodo
  ([docs](https://snakemake.readthedocs.io/en/v7.32.3/snakefiles/remote_files.html#zenodo));
- improved wildcard matching that reduces rule ambiguity problems;
- improved workflow execution reporting capabilities.

{{< screenshot-browser-mockup src="/images/reana-0.9.3-snakemake-report-output.png" alt="Snakemake report - Workflow output" >}}

### Performance improvements for massively-parallel workflows

Continuing the trend of the last few releases, REANA 0.9.3 brings further
performance improvements. In particular, the submission and creation of jobs
orchestrated by massively-parallel workflows has been optimised by avoiding
unnecessary disk operations that could take a long time in case of workspaces
containing many files.

The difference is especially noticeable for workflows that generate many
hundreds of jobs at the same time, such as a scattering process over many
individual files of a dataset. As an example, a workflow step launching about
750 fast parallel jobs could have been executed in about half the time.

### ... and more!

The new REANA 0.9.3 release brings other small improvements and bug fixes.

On the REANA cluster side, the submission of Snakemake jobs has been improved
to avoid situations where a job could previously fail with a
`FileNotFoundError` due to the unsynchronized disk file access when spawning
asynchronous jobs. Moreover, the workflow engine logs for stopped workflows are
now correctly captured and exposed in logs.

On the REANA web interface side, the launcher badge creator fixes URLs in the
generated Markdown snippets. Furthermore, the web interface and the
command-line client now report the correct workflow duration for stopped and
failed workflows.

Please see the detailed [REANA 0.9.3 release
notes](https://github.com/reanahub/reana/releases/tag/0.9.3) for the complete
list of all changes.

## What's new for the administrators?

### Better handling of stopped workflows

When a workflow failed or was stopped by the user, it could previously happen
that some jobs would not be stopped and cleaned up automatically. If this
occurred, the jobs would continue running until they either finished or failed,
thus utilising computing resources unnecessarily. Furthermore, these jobs were
needed to be cleaned up manually from the Kubernetes cluster by the REANA
administrator.

REANA 0.9.3 improves the situation by making sure that all jobs are cleaned up
before stopping the execution of a workflow. This should result in less cluster
maintenance and a better utilisation of the available computing resources.

### Customising environment of job controller and workflow engines

REANA 0.9.3 brings a new possibility to customise environment variables that
are to be passed to REANA workflow engine and job controller components when
running user jobs. This can be achieved via the following new Helm values:

- `components.reana_job_controller.environment`
- `components.reana_workflow_engine_cwl.environment`
- `components.reana_workflow_engine_serial.environment`
- `components.reana_workflow_engine_snakemake.environment`
- `components.reana_workflow_engine_yadage.environment`

As an example, it is now possible to configure a custom limit for the maximum
number of parallel jobs that Snakemake is allowed to run in parallel to modify
the default hard-coded value. Here is an example on how to allow for up to 1000
parallel Snakemake jobs in your `values.yaml`:

```yaml
components:
  reana_workflow_engine_snakemake:
    environment:
      SNAKEMAKE_MAX_PARALLEL_JOBS: 1000
```

This could be suitable for massively-parallel workflows if your cluster
consists of sufficient amount of computing nodes to allow such a workload.

### Customising PostgreSQL Docker image

REANA 0.9.3 also provides a new Helm value that can be used to customise the
image (and thus the version) of the internal PostgreSQL database. The default
version of database provided by REANA has been PostgreSQL 12.13 with the
official Docker image `docker.io/library/postgres:12.13`.

This will change in the next REANA major release series where the default will
become PostgreSQL 14. If you are using the internal REANA database deployed
inside the cluster, you will eventually have to migrate to the new version of
PostgreSQL sooner or later in the future. The new Helm value allows you to set
the desired PostgreSQL version, for example as a temporary measure to change
the image back to the one you use currently:

```yaml
components:
    reana_db:
      image: docker.io/library/postgres:12.13
```

We shall provide detailed example of the database upgrade in due time as part
of the next REANA release series. Until then, you may skip this possibility or
you may forward-configure the desired database version by means of the new Helm
variable.

### How to upgrade existing REANA 0.9.2 clusters

If you are a REANA cluster administrator and you would like to upgrade from
REANA 0.9.2 to REANA 0.9.3, you can proceed as follows.

Firstly, please note that you can optionally define some of the new [Helm
values](https://github.com/reanahub/reana/blob/0.9.3/helm/reana/README.md),
notably:

- `components.reana_db.image` to choose the PostgreSQL Docker image;
- `components.reana_job_controller.environment` to add additional environment
  variables to reana-job-controller's container;
- `components.reana_ui.privacy_notice_url` to add a link to your privacy notice
  in the web interface;
- `components.reana_workflow_engine_cwl.environment`,
  `components.reana_workflow_engine_serial.environment`,
  `components.reana_workflow_engine_snakemake.environment`, and
  `components.reana_workflow_engine_yadage.environment` to customise the
  environment variables of workflow engine's containers.

You can edit your Helm values file to add any desired new values:

```console
$ vim myvalues.yaml
```

This is however fully optional and you can simply reuse your current
`myvalues.yaml` file without any changes to perform the 0.9.2 to 0.9.3 upgrade.

Secondly, you can use the [Helm diff
plugin](https://github.com/databus23/helm-diff) to inspect the forthcoming
changes and then perform the upgrade using the standard Helm commands:

```console
$ helm repo update
$ helm diff upgrade reana reanahub/reana --version 0.9.3 --values myvalues.yaml
$ helm upgrade reana reanahub/reana --version 0.9.3 --values myvalues.yaml
```

### More information

Please see the detailed [REANA 0.9.3 release
notes](https://github.com/reanahub/reana/releases/tag/0.9.3) for the complete
list of all changes.

Enjoy!
