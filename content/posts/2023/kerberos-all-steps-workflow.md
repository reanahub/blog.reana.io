---
title: "Easily enable Kerberos for all the steps of a workflow"
date: 2023-02-14T07:00:00+01:00
---

Up until now, it was only possible to enable Kerberos support for a workflow on
a step-by-step basis. This changes with REANA 0.9.0, which makes it easy to
enable Kerberos authentication for an entire workflow by using only a single
hint in its specification file.

<!--more-->

## Enable Kerberos for a single workflow step

As an example, let's consider a workflow that would like to publish the output
plots on a restricted external storage backend such as EOS. This is how the
`reana.yaml` specification would look like, specifying the `kerberos: true`
workflow hint for the particular workflow step only:

```yaml {hl_lines=[14]}
workflow:
  type: serial
  specification:
    steps:
      - name: myfirststep
        environment: ...
        commands:
          - ...
      - name: mysecondstep
        environment: ...
        commands:
          - ...
      - name: publish
        kerberos: true
        environment: "reanahub/reana-auth-krb5:1.0.1"
        commands:
          - mkdir -p /eos/home-j/johndoe/myoutputs/myplots
          - cp myplots/*.png /eos/home-j/johndoe/myoutputs/myplots
```

You can specify `kerberos: true` analogously for each step of the workflow where
Kerberos authentication is needed. This will work without problems, although it
may be a bit tedious.

## Enable Kerberos at the workflow orchestration level

There are cases where Kerberos authentication is required even for orchestrating
the workflow execution itself, for example when using the Snakemake workflow
engine with input data objects living in a restricted data storage. Here,
specifying `kerberos: true` for workflow steps only wouldn't suffice.

This is now possible with REANA 0.9.0 which makes it easy to enable Kerberos
authentication for an entire workflow by using only a single hint in the
workflow specification file.

You can easily enable the Kerberos support for the whole workflow orchestration
by setting the `kerberos: true` hint at the level of the workflow in its
[`resources`](https://docs.reana.io/reference/reana-yaml/#reanayaml-workflow)
clause:

```yaml {hl_lines=["3-4"]}
workflow:
  type: serial
  resources:
    kerberos: true
  specification:
    steps:
      - name: myfirststep
        environment: ...
        commands:
          - ...
      - name: mysecondstep
        environment: ...
        commands:
          - ...
      - name: publish
        environment: "reanahub/reana-auth-krb5:1.0.1"
        commands:
          - mkdir -p /eos/home-j/johndoe/myoutputs/myplots
          - cp myplots/*.png /eos/home-j/johndoe/myoutputs/myplots
```

As you can see, setting up Kerberos in the `publish` step is not needed anymore.

This technique is especially useful for Snakemake workflows that need to access
files in restricted storage:

```
TODO
```

To learn more about Kerberos support in REANA, please take a look at the
[related documentation page](https://docs.reana.io/advanced-usage/access-control/kerberos/).

## Availability

The possibility to enable Kerberos at the workflow orchestration level is
available starting from REANA 0.9.0 release series. This functionality is
already available for you to try on the [reana.cern.ch](https://reana.cern.ch)
instance.

## See also

- [Kerberos](https://docs.reana.io/advanced-usage/access-control/kerberos/)
  documentation page
- [reana.yaml](https://docs.reana.io/reference/reana-yaml/) documentation page
