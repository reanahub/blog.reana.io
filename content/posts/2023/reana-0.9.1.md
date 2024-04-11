---
title: "REANA 0.9.1 is released"
date: 2023-09-28T09:00:00+01:00
---

We are happy to announce REANA 0.9.1, a minor update that allows users to preview PDF and ROOT files from the web interface, makes it easier to clean up old workflows to free disk space, adds support for integrating with Keycloak, and more!

<!--more-->

## What's new for the users?

### Previewing PDF and ROOT files

REANA 0.9.1 improves the preview of workspace files from the web interface by adding support for previewing PDF and ROOT files.
You will be able to interact with ROOT plots directly from your browser, without the need to manually download files to your computer.

![ROOT file preview](/images/reana-0.9.1-root-preview.png)

### Pruning workspaces

REANA already provides tools to keep the disk usage under control, for example by setting up [automatic file retention rules](../../2022/workspace-file-retention-rules) or by deleting old workflows.
REANA 0.9.1 also introduces the new `prune` command, which can be used to clean up your workflows by deleting all the files in their workspaces, with the exclusion of input and output files, so that you don't have to delete each file one by one.

```console
$ reana-client prune -w reana-demo-root6-roofit
==> SUCCESS: The workspace has been correctly pruned.
```

Please look at the dedicated [Prune the workspace](https://docs.reana.io/advanced-usage/user-quotas/#prune-the-workspace) documentation page to learn more about this new command.

### ... and much more!

The 0.9.1 release also brings many more small improvements.
For example, it's now possible to stop workflows from the web UI by clicking on the _Stop workflow_ button in the actions menu.
Furthermore, restarted Snakemake workflows now report the correct total number of jobs for later runs by excluding any cached jobs that were simply reused from previous runs in the workspace and not really executed.

Please see the detailed [REANA 0.9.1 release notes](https://github.com/reanahub/reana/releases/tag/0.9.1) for the complete list of all user-oriented changes.

## What's new for the administrators?

### Authenticating users with Keycloak

You can configure your REANA deployment with two ways for user login, either using local user database with usernames and passwords or using an external Single Sign On provider. Up to now, only CERN SSO was supported. As of REANA 0.9.1, you can now integrate your deployment with any generic [Keycloak](https://www.keycloak.org/) identity and access management instance.

If you are interested in using Keycloak together with REANA, please look at the related [Keycloak Single Sign-On configuration](https://docs.reana.io/administration/configuration/configuring-access/#keycloak-single-sign-on-configuration) documentation page.

### Configure launcher example gallery

REANA 0.9.0 introduced the possibility to launch workflows from external sources such as GitHub, GitLab or Zenodo.
It is now possible to customise the demo examples that are showcased in the Launch-on-REANA welcome page via the new `components.reana_ui.launcher_examples` Helm value.
In this way you can expose your own demos to your users, instead of the default ones provided by REANA.

{{< screenshot-browser-mockup src="/images/reana-0.9.1-launcher-examples.png" alt="Launcher examples" >}}

### Automatic closure of inactive sessions

It might happen that users sometimes open interactive notebook sessions and forget to close them when they are not needed anymore.
To keep resource utilisation under control, REANA 0.9.1 allows to set a maximum time period of inactivity after which inactive sessions will be automatically closed.
The inactivity period can be customised with the `interactive_sessions.maximum_inactivity_period` Helm value.

To learn more about this feature, please have a look at the related [Configuring interactive sessions](https://docs.reana.io/administration/configuration/configuring-interactive-sessions/#auto-closure-of-inactive-sessions) documentation page.

### Performance and stability improvements

There are many improvements in stability and performance of the REANA cluster that are coming with the 0.9.1 release update:

- The periodic quota updater for disk and CPU quotas is now up to four times faster.
- The memory usage of uWSGI and RabbitMQ has been reduced in environments with a very high number of allowed open files.
- Static assets of the web interface, such as CSS files and bundled JS sources, are now also served gzip-compressed to lower bandwidth consumption.
- Monitoring the status of jobs has been improved to avoid some situations in which workflows were not correctly cleaned up in the Kubernetes cluster.

Moreover, it is now possible to customise the file size limit for files that can be previewed form the web UI, so that it can be increased or decreased as necessary, for example to allow previewing large ROOT files.
The email sending feature was also improved and you can now customise whether to enable SSL or STARTTLS.

### How to upgrade existing REANA 0.9 clusters

<!-- taken and adapted from 0.9.0 blog post -->

If you are a REANA cluster administrator and you would like to upgrade from REANA 0.9.0 to REANA 0.9.1, you can proceed as follows.

First of all, you can optionally define some of the new [Helm values](https://github.com/reanahub/reana/blob/0.9.1/helm/reana/README.md) in your Helm values file:

- `components.reana_ui.file_preview_size_limit` to customise the file size limit for file previews;
- `login` and `secrets.login` to integrate with an external Keycloak instance;
- `notifications.email_config.smtp_ssl` and `notifications.email_config.smtp_starttls` to configure how emails are being sent;
- `ingress.extra` and `ingress.tls.hosts` to further customise Kubernetes Ingresses;
- `interactive_sessions.maximum_inactivity_period` and `interactive_sessions.cronjob_schedule` to automatically close interactive sessions after some inactivity time;
- `components.reana_ui.launcher_examples` to choose which examples to show in the main Launch-on-REANA page.

```console
$ vim myvalues.yaml
```

You can then use the [Helm diff plugin](https://github.com/databus23/helm-diff) to inspect the forthcoming change and then perform the upgrade using the standard Helm commands:

```console
$ helm repo update
$ helm diff upgrade reana reanahub/reana --version 0.9.1 --values myvalues.yaml
$ helm upgrade reana reanahub/reana --version 0.9.1 --values myvalues.yaml
```

Please see the detailed [REANA 0.9.1 release notes](https://github.com/reanahub/reana/releases/tag/0.9.1) for the complete list of administrator-oriented changes.

Enjoy!
