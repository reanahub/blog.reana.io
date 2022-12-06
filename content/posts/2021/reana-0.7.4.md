---
title: "REANA 0.7.4 is released"
date: 2021-07-07T14:00:00+01:00
---

We are glad to announce the release of REANA 0.7.4, a minor update
allowing users and cluster administrators to specify memory limits for
workflow jobs running on the Kubernetes compute backend platform. The
release also improves the REANA client functionality for workflow parameter
validation and contains other minor improvements and bug fixes. <!--more-->

## What's new?

### Custom memory limits for Kubernetes compute backend jobs

REANA 0.7.4 enables users to set custom memory limits for their workflow
jobs by specifying `kubernetes_memory_limit` in the resource clause
specification of each workflow step. The section below will show examples
for Serial, Yadage and CWL workflow engines.

Why is this important? If you launch many workflows, the jobs "compete"
against each other for available cluster resources, as it were. If you declare
that a certain job is light regarding memory requirements, say 2 GiB, and the
cluster has 40 GiB of free resources, the system would be able to
schedule 20 such jobs in parallel. Setting the memory limit values will
therefore provide a hint for the REANA system as to how many user workflows
can be scheduled in order to arrive at your results faster.

Please note that if your job unexpectedly consumes more memory than declared,
the job may be killed by the Kubernetes compute backend platform. This will be
indicated by the out-of-memory killed message in the workflow logs (OOMKilled).
In order to avoid these problems, please specify neither too low nor too high
a limit, so that the jobs can be efficiently scheduled.

If you don't specify any custom memory limit value for some workflow step,
then the REANA cluster will assume a certain default value that was set by
the cluster administrator upon deployment. (Please see below.)

### Example of custom memory limits for Serial workflows

The `kubernetes_memory_limit` for Serial workflow jobs can be set for each
workflow step next to specifying compute backend environment. Note that
various workflow steps may want to use different values, with heavy jobs
consuming more memory than lighter jobs. For example:

```diff
  ...
  steps:
    - name: gendata
      environment: 'reanahub/reana-env-root6:6.18.04'
      compute_backend: kubernetes
+     kubernetes_memory_limit: '8Gi'
      commands:
      - mkdir -p results && root -b -q 'code/gendata.C(${events},"${data}")'
    - name: fitdata
      environment: 'reanahub/reana-env-root6:6.18.04'
      compute_backend: kubernetes
+     kubernetes_memory_limit: '4Gi'
      commands:
      - root -b -q 'code/fitdata.C("${data}","${plot}")'
```

### Example of custom memory limits for Yadage workflows

The `kubernetes_memory_limit` values for Yadage jobs can be specified under resources clause that specifies compute environment for each step:

```diff
  ...
  stages:
    - name: gendata
      dependencies: [init]
      scheduler:
        scheduler_type: 'singlestep-stage'
        parameters:
          events: {step: init, output: events}
          gendata: {step: init, output: gendata}
          outfilename: '{workdir}/data.root'
        step:
          process:
            process_type: 'interpolated-script-cmd'
            script: root -b -q '{gendata}({events},"{outfilename}")'
          publisher:
            publisher_type: 'frompar-pub'
            outputmap:
              data: outfilename
          environment:
            environment_type: 'docker-encapsulated'
            image: 'reanahub/reana-env-root6'
            imagetag: '6.18.04'
            resources:
              - compute_backend: kubernetes
+             - kubernetes_memory_limit: '8Gi'
```

### Example of custom memory limits for CWL workflows

The `kubernetes_memory_limit` values for CWL jobs can be specified as a workflow hint under the `hints` clause:

```diff
  ...
  steps:
    gendata:
      run: gendata.cwl
      in:
        gendata_tool: gendata_tool
        events: events
      hints:
        reana:
          compute_backend: kubernetes
+         kubernetes_memory_limit: '8Gi'
      out: [data]
```

### Cluster-wide defaults

REANA cluster administrators can configure the default memory limit for user
job containers by setting [kubernetes_jobs_memory_limit](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value to the desired value such as "8Gi". Please note that the best value
to use would depend both on the typical user workflows and on the parameters of
the cluster nodes, most notably the available memory on the nodes. Typically a
few GiBs should be left reserved for the Kubernetes system, so for the cluster
nodes of 16 GiB the maximum limit should be around 12 GiB.

REANA cluster administrators can also set the maximum custom memory limit value
that users would be able to ask for in their custom job resource clauses.
The value could be changed via [kubernetes_jobs_max_user_memory_limit](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value during cluster deployment. If a user asks for more memory,
the workflow would not be started and an error will be signaled to the user.

Please refer to the official [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory)
to know more about the container memory limits and the expected value format.

### Further improvements and bug fixes

REANA 0.7.4 command-line client introduces support for wildcard matching of
files for `ls` and `download` commands. This brings useful file name filtering
capabilities for workspaces which might contain many thousands of files.
The release also improved workflow validation of input parameters and
environment images for the `validate` command that was introduced previously
in [REANA 0.7.3](https://blog.reana.io/posts/2021/reana-0.7.3/).

REANA 0.7.4 fixes several minor issues such as problems with CWL workflows
on HTCondor compute backend due to wrong job command encoding.
Please see [full release notes](https://github.com/reanahub/reana/releases/tag/0.7.4)
for more information.

Enjoy!

See also:
- [REANA 0.7.4 release notes](https://github.com/reanahub/reana/releases/tag/0.7.4)
- [REANA installation guide](https://docs.reana.io/administration/deployment/deploying-at-scale/)
- [REANA custom memory limits for Kubernetes](https://docs.reana.io/advanced-usage/compute-backends/kubernetes/#custom-memory-limit)
