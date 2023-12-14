---
title: "REANA 0.9.2 is released"
date: 2023-12-19T09:00:00+01:00
---

REANA 0.9.2 has just been released! This is a minor update that relieves the limit on the number of restarts of a workflow, allows users to automount any CVMFS repository, provides support for deployment on ARM architecture hardware, and brings further performance improvements and bug fixes.

<!--more-->

## What's new for the users?

### Increased workflow restart limit

REANA already offers the possibility to restart a workflow, that is to execute a new workflow run on the same workspace as the previously executed workflow. This comes in handy when developing a new analysis, for example to test small changes to the code without having to restart the whole analysis from scratch.

Up until now, a workflow could be restarted only up to nine times. This limitation has been removed with REANA 0.9.2 and it is now possible to restart workflows as many times as needed.

![REANA workflow restarts](/images/reana-0.9.2-workflow-restarts.png)

### Performance improvements

Similarly to the previous release, REANA 0.9.2 brings some more performance improvements.
In particular, the usage of the database has been optimised in order to reduce the time needed to perform some of the most common operations, such as listing and filtering of user workflows and jobs.

These improvements can be quite noticeable for users with many workflows. For example, we have measured a speed-up of the `reana-client list` query to be 18 times faster for a user having thousands of workflow runs!

### Launch-on-REANA badge generator

REANA 0.9.0 has introduced the possibility to launch workflows from remote publicly-accessible sources such as GitHub, GitLab, or Zenodo.
This is being done by constructing special launcher URLs that can be then shared with other users and used to create clickable badges that can be embedded in the README files in your remote repositories.

With the new 0.9.2 release, REANA now provides a convenient way to construct these launcher URLs and badges directly from the web interface.
You just need to provide the URL to your analysis, plus some optional details like the desired name of the workflow, the path to the REANA specification file, or any desired custom parameters for the workflow.
REANA will then show you the constructed URL and the code snippet that you can use to embed the Launch-on-REANA badge in your Markdown files.

{{< screenshot-browser-mockup src="/images/reana-0.9.2-badge-creator.png" alt="Launcher badge creator" >}}

### ... and more!

There are more small improvements in this release.
It is now possible to delete all the runs of a given workflow directly from the web interface.
Furthermore, the validation of the REANA specification files has been improved in case of unexpected keywords or invalid YAML constructs.

Please see the detailed [REANA 0.9.2 release notes](https://github.com/reanahub/reana/releases/tag/0.9.2) for the complete list of all user-oriented changes.

## What's new for the administrators?

### Automounting of CVMFS repositories

While users have been able to mount and access CVMFS repositories from their jobs, it was not easily possible to configure and access additional repositories other than the ones allowed by the REANA default configuration.

Thanks to CVMFS CSI v2, REANA 0.9.2 now allows users to mount any available repository, as long as CVMFS is correctly configured in the Kubernetes cluster. To learn more about this, you can consult the official documentation of CVMFS CSI on [adding CVMFS repository configuration](https://github.com/cvmfs-contrib/cvmfs-csi/blob/master/docs/how-to-use.md#adding-cvmfs-repository-configuration).

```yaml {hl_lines=[4,5]}
workflow:
  type: serial
  resources:
    cvmfs:
      - software.igwn.org
  specification:
    steps:
      - environment: "mycontainerimage:1.0"
        commands:
          - python myanalysis.py
```

### Deploying on ARM architecture hardware

Given the rise in interest and the usage of ARM-architecture-based computers for both personal and server use, REANA now supports being deployed on ARM platform.
Starting from this release, we are publishing multi-platform container infrastructure images on [DockerHub](https://hub.docker.com/u/reanahub) with two supported variants, `linux/adm64` and `linux/arm64`.
This change is fully transparent and the correct image variant will be automatically chosen when pulling the image based on the machine architecture where REANA is being deployed.


![REANA Server multi-platform container image](/images/reana-0.9.2-server-arm-image.png)

### How to upgrade existing REANA 0.9.1 clusters

<!-- taken and adapted from 0.9.0 blog post -->

If you are a REANA cluster administrator and you would like to upgrade from REANA 0.9.1 to REANA 0.9.2, you can proceed as follows.

First of all, this release does not introduce any new Helm values, so you can keep using your previous configuration without any changes needed.
Assuming that your custom Helm values are stored in `myvalues.yaml`, you can then use the [Helm diff plugin](https://github.com/databus23/helm-diff) to inspect the forthcoming change, and you can then perform the upgrade using the standard Helm commands:

```console
$ helm repo update
$ helm diff upgrade reana reanahub/reana --version 0.9.2 --values myvalues.yaml
$ helm upgrade reana reanahub/reana --version 0.9.2 --values myvalues.yaml
```

Additionally, this release includes some changes to the database schema, in order to allow for more than nine restarts of user workflows and to improve the performance of common database queries.
To perform the database schema upgrade, you can launch the following command after the upgrade, as further explained in the dedicated [upgrade documentation](https://docs.reana.io/administration/deployment/upgrading-db/):

```
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic upgrade
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade 377cfbfccf75 -> b85c3e601de4, Separate run number into major and minor run numbers.
INFO  [alembic.runtime.migration] Running upgrade b85c3e601de4 -> 2461610e9698, Enforce naming convention.
INFO  [alembic.runtime.migration] Running upgrade 2461610e9698 -> eb5309f3d8ee, Improve indexes usage.
```

Please see the detailed [REANA 0.9.2 release notes](https://github.com/reanahub/reana/releases/tag/0.9.2) for the complete list of administrator-oriented changes.

Enjoy!
