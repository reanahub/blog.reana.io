---
title: "Easily enable Kerberos for the whole workflow"
date: 2023-02-16T07:00:00+01:00
---

REANA 0.9.0 makes it easy to enable Kerberos authentication for an entire
workflow orchestration. This can be useful when the workflow decides on its
computational steps depending on the number of input files located on an
external restricted file system. 

<!--more-->

## Enable Kerberos for a single workflow step

Until REANA 0.9.0, it was possible to enable Kerberos support only for certain
workflow steps on a step-by-step basis. For example, if a workflow would like
to publish the output plots on a restricted external storage backend such as
EOS, the `reana.yaml` workflow specification would look as follows:

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

Note that you would need to specify the `kerberos: true` workflow hint for each
step of the workflow where the Kerberos authentication was necessary. This
approach works well, but it may be tedious if you need to add the Kerberos hint
for many steps in your workflow.

## Enable Kerberos at the workflow orchestration level

As of REANA 0.9.0, it is now possible to enable Kerberos at the workflow
orchestration level itself by setting the `kerberos: true` hint in the
`reana.yaml`
[`resources`](https://docs.reana.io/reference/reana-yaml/#reanayaml-workflow)
clause.

As a realistic example of where this feature may come useful, let us consider
an analysis using an unknown number of input files located on a remote server
that is only accessible with Kerberos credentials, for example on
`eosuser.cern.ch`:

```console 
$ xrdfs root://eosuser.cern.ch ls -l /eos/user/j/johndoe/mydata/
---- 2023-01-23 15:10:24       12345 /eos/user/j/johndoe/mydata/myfile_1.csv
---- 2023-01-23 15:10:31       23456 /eos/user/j/johndoe/mydata/myfile_2.csv
---- 2023-01-23 15:10:35       34567 /eos/user/j/johndoe/mydata/myfile_3.csv
...
```

Let us write a Snakemake workflow that will fetch these input data files
concurrently irrespective of their number as the first step of our workflow.
First, we shall include the above mentioned `resources` clause in the
`reana.yaml` workflow specification file:

```yaml {hl_lines=[9,10]}
inputs:
  files:
    - Snakefile
  parameters:
    input: inputs.yaml
workflow:
  type: snakemake
  file: Snakefile
  resources:
    kerberos: true
outputs:
  files:
  - myoutput.png
```

The `Snakefile` workflow definition can now rely on Kerberos being available,
and we can define the first `fetch_data` step using XRootD remote provider as
follows:

```python
from snakemake.remote.XRootD import RemoteProvider as XRootDRemoteProvider

XRootD = XRootDRemoteProvider(stay_on_remote=True)

file_numbers = XRootD.glob_wildcards("root://eosuser.cern.ch//eos/user/j/johndoe/mydata/myfile_{n}.csv").n

rule all:
    input:
        expand("mylocaldata/myfile_{n}.csv", n=file_numbers)

rule fetch_data:
    input:
        XRootD.remote("root://eosuser.cern.ch//eos/user/j/johndoe/mydata/myfile_{n}.csv")
    output:
        "mylocaldata/myfile_{n}.csv"
    container:
        "docker://docker.io/opensciencegrid/osgvo-el7:release-20211029-0011"
    shell:
        "xrdcp {input[0]} {output[0]} && mkdir -p mylocaldata && touch {output[0]}"
```

(Note that currently you need to have a valid Kerberos ticket at the time of
workflow submission on the machine from where you are submitting this workflow,
so that `reana-client` can analyse the remote directory content regarding the
number of file inputs.)

The workflow will automatically generate multiple concurrent `fetch_data` jobs,
one for each remote input file.

The same technique, specifying `kerberos: true` in the `resources` clause of
your `reana.yaml` workflow specification files, can be used to declare the
Kerberos dependency for all the steps of your CWL, Serial, Snakemake or Yadage
workflows.

## See also

- [Kerberos](https://docs.reana.io/advanced-usage/access-control/kerberos/)
  documentation page 
- [reana.yaml](https://docs.reana.io/reference/reana-yaml/) documentation page
