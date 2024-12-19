---
title: "REANA 0.9.4 is released"
date: 2024-12-16T06:00:00+01:00
---

REANA 0.9.4 has just been released. This is a minor update that adds support for
using user secrets in Jupyter notebook sessions, adds support for the
Compute4PUNCH infrastructure, fixes issues with the HTCondor compute backend job
dispatch, and improves the security of the platform.

<!--more-->

## What's new for the users?

### Enhanced Jupyter notebook sessions

REANA user secrets are now usable in Jupyter notebook sessions. If your workflow
accesses restricted storage resources and you have been using the user secrets
feature to access them in your workflow runs, you are now able to use the same
technique from your Jupyter notebook sessions.

<!-- markdownlint-disable MD013 -->

{{< screenshot-browser-mockup src="/images/reana-0.9.4-jupyter.png" alt="Jupyter notebook showing access to secrets" >}}

<!-- markdownlint-enable MD013 -->

Moreover, the default Jupyter Notebook image was updated to version 7, which
comes with many improvements and bug fixes. For example, Jupyter notebooks
provide a visual debugger, theming and dark mode, and a compact view on mobile
devices.

### Improved HTCondor compute backend integration

REANA supports running workflows on HTCondor using unpacked Singularity images
available on CVMFS. However, due to a bug, the job commands were not executed
inside the provided image. Additionally, Snakemake workflow engine rules with
multi-line shell commands were not correctly parsed when being executed on
HTCondor, resulting in workflow failures. Both of these issues are now fixed.

```yaml {hl_lines=[9,13,14,15,16]}
rule helloworld:
    input:
        "input.txt"
    output:
        "output.txt"
    resources:
        kerberos=True,
        compute_backend="htcondorcern",
        unpacked_img=True
    container:
        "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/library/python:3.10"
    shell:
        """
        echo $SINGULARITY_NAME
        python --version
        """
```

### Support for Compute4PUNCH infrastructure

REANA 0.9.4 enables to run workflow jobs on the
[PUNCH4NFDI compute infrastructure](https://doi.org/10.1051/epjconf/202429507020),
if your REANA deployment supports it.

![REANA with Compute4PUNCH](/images/reana-0.9.4-c4p.png)

You can check whether the REANA instance you are connected to supports
Compute4PUNCH by means of the `reana-client info` command:

```console
$ reana-client info
List of supported compute backends: kubernetes, compute4punch
...
```

If you see `compute4punch` in the list of supported compute backends, then you
can dispatch your jobs to the Compute4PUNCH infrastructure by specifying a
compute backend hint in the workflow specification in the
[usual manner](https://docs.reana.io/advanced-usage/compute-backends/slurm/#examples):

```yaml {hl_lines=[4]}
steps:
  - name: mystep
    environment: "docker.io/johnoe/myimage:1.0"
    compute_backend: compute4punch
    commands:
      - python myanalysis.py
```

## What's new for the administrators?

### Improvements to platform security

REANA 0.9.4 release brings several improvements to the security of the platform.

It is now possible to migrate the application secret key that is used by REANA
for a number of security-related mechanisms, such as for the database column
encryption, by means of the new `reana-admin migrate-secret-key` command. The
secret key is also now correctly propagated to all the component dependencies.

Additionally, the Redis and RabbitMQ instances used internally by REANA can now
have password-protected connection credentials being set up of the box. These
credentials can be customised by means of `secrets.cache.password` and
`secrets.message_broker.password` Helm values.

Furthermore, the security context of workflow and job pods is now customised to
set `allowPrivilegeEscalation` to false in order to prevent possible attempts
from user jobs from obtaining additional privileges than what the jobs were
originally assigned.

Finally, many of the security mechanisms used by REANA can now be easily locally
configured with the following deployment environment variables:

- `APP_DEFAULT_SECURE_HEADERS` can be used to configure
  [Flask-Talisman's settings](https://github.com/GoogleCloudPlatform/flask-talisman?tab=readme-ov-file#options).
- `REANA_FORCE_HTTPS` can be used to disable the automatic redirection of
  requests to HTTPS in case the REANA deployment terminates SSL connections
  before reaching the ingress.
- `PROXYFIX_CONFIG` can be used to configure
  [Werkzeug's ProxyFix](https://werkzeug.palletsprojects.com/en/stable/middleware/proxy_fix/)
  when REANA is served behind multiple proxy servers.

### Setting up Compute4PUNCH integration

If you have access to the Compute4PUNCH infrastructure and you would like to
offer this feature to the users of your REANA deployment, you can add
`compute4punch` to the list of supported compute backends in your Helm values:

```yaml {hl_lines=3}
compute_backends:
  - kubernetes
  - compute4punch
```

You will additionally have to modify `components.reana_job_controller.image`
Helm value to use a special Docker image that includes support for
Compute4PUNCH, for example the image we provide as
`docker.io/reanahub/reana-job-controller-compute4punch:0.9.4`.

### ... and more

This new REANA release includes several other minor fixes and enhancements
improving the deployment and stability of the platform:

- `Ingress`-es needed to access interactive sessions will now set the correct
  hostname, solving possible network accessibility issues in Kubernetes
  non-default namespace deployment scenarios.
- `NetworkPolicy`-s were amended to allow the periodic cronjob that closes
  interactive sessions to connect to the Jupyter notebooks themselves when
  checking their inactivity periods.
- The `set_workflow_status` REST API endpoint has been patched in order to make
  sure that submitted workflows are not able to skip the scheduling queue.

### How to upgrade existing REANA 0.9.3 clusters

If you are a REANA cluster administrator and you would like to upgrade from
REANA 0.9.3 to REANA 0.9.4, you can proceed as follows.

Firstly, please note that you can optionally define some of the new
[Helm values](https://github.com/reanahub/reana/blob/0.9.4/helm/reana/README.md),
notably:

- `secrets.cache.password` to set a custom password for your Redis instance.
- `secrets.message_broker.user` to set a custom username of the RabbitMQ
  instance user account.
- `secrets.message_broker.password` to set a custom password of RabbitMQ user
  account.

Note that setting custom passwords is fully optional and that you can simply
reuse your current `myvalues.yaml` file without any changes to perform the 0.9.3
to 0.9.4 upgrade.

However, if you decide to set new custom passwords, please edit your Helm values
file with the desired `secrets.message_broker.user` and
`secrets.message_broker.password` Helm values:

```console
$ vim myvalues.yaml
```

Afterwards, connect to the running RabbitMQ pod and run the following commadns:

```console
$ kubectl exec -i -t reana-message-broker-0 -- /bin/bash
root@reana-message-broker-0:/# rabbitmqctl add_user "<new-username>" "<new-password>"
root@reana-message-broker-0:/# rabbitmqctl set_user_tags "<new-username>" administrator
root@reana-message-broker-0:/# rabbitmqctl set_permissions -p "/" "<new-username>" ".*" ".*" ".*"
```

Secondly, you can use the
[Helm diff plugin](https://github.com/databus23/helm-diff) to inspect the
forthcoming changes and then perform the upgrade using the standard Helm
commands:

```console
$ helm repo update
$ helm diff upgrade reana reanahub/reana --version 0.9.4 --values myvalues.yaml
$ helm upgrade reana reanahub/reana --version 0.9.4 --values myvalues.yaml
```

After that, if you have created and set up a new RabbitMQ user account, you
should delete the original one:

```console
$ kubectl exec -i -t reana-message-broker-0 -- /bin/bash
root@reana-message-broker-0:/# rabbitmqctl delete_user "test"
```

Finally, you have to run the following command from the `reana-server` pod to
re-build the encrypted database columns using the correct secret key. Note that
the `CHANGE_ME` string in the command below needs to be copy-pasted as is
without change:

```console
$ kubectl exec -i -t deployment/reana-server -c scheduler -- /bin/bash
root@reana-server-65b5c7f54c-h8b2q:/code# invenio instance migrate-secret-key --old-key "CHANGE_ME"
```

If you have decided to change your application secret key value by means of
editing `secrets.reana.REANA_SECRET_KEY` Helm value, you will have to run also
the following command in the `reana-server` pod:

```console
$ kubectl exec -i -t deployment/reana-server -c scheduler -- /bin/bash
root@reana-server-65b5c7f54c-h8b2q:/code# $ flask reana-admin migrate-secret-key --old-key "<previous-secret-key>"
```

### More information

Please see the detailed
[REANA 0.9.4 release notes](https://github.com/reanahub/reana/releases/tag/0.9.4)
for the complete list of all changes.

Enjoy!
