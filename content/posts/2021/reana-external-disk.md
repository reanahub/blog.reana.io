---
title: "How to run REANA workflows in an external storage"
date: 2021-09-30T9:00:00+01:00
tags:
  - feature
  - cluster
  - Python
---

While running REANA workflow, the standard storage used is a
predefined directory ---. In this post, we present a guide with a
step-by-step explanation on how to deploy a REANA instance
with an external disk as available storage and how to run a workflow
on this personalized storage.     
<!--more-->

In the following example, we shall use the demo [Hello World](https://github.com/reanahub/reana-demo-helloworld)
example analysis. We shall deploy a REANA instance locally,
and run a workflow on a particular workspace storage.

### Deploying a REANA instance with additional workspaces

Using the instructions present in the [REANA documentation](https://docs.reana.io/administration/deployment/deploying-locally/),
we shall deploy a REANA cluster. After installing the the 
[`docker`](https://docs.docker.com/engine/install/),
[`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/),
[`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/), and
[`helm`](https://helm.sh/docs/intro/install/) dependencies,
the cluster shall be created using the configuration yaml file 
obtained from the REANA raw githubcontent:

```
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.7/etc/kind-localhost-30443.yaml
```

In order to allow the cluster to access the external storage `/home/myexternaldisk`
or a target local storage `/home/myworkflows`, the following lines
must be added to the reana kind configuration file `kind-localhost-30443.yaml`
as under the `node` section:

```yaml
node:
  - extraPortMappings:
      - containerPort: 30443
        hostPort: 30443
        protocol: TCP
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    role: control-plane
    extraMounts:
      - hostPath: /home/myexternaldisk
        containerPath: /home/myexternaldisk
      - hostPath: /home/myworkflows
        containerPath: /home/myworkflows
```

The cluster can now be created with the command:

```
$ kind create cluster --config kind-localhost-30443.yaml
```

We shall also load the docker images of REANA components into
the cluster:

```
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.7/scripts/prefetch-images.sh
$ sh prefetch-images.sh
```

The REANA helm repository shall be added to deploy de cluster:

```
$ helm repo add reanahub https://reanahub.github.io/reana
$ helm repo update
```

We shall install the helm repository to deploy the cluster. In
order to allow different workspaces, the parameter [workspaces.paths](https://github.com/reanahub/reana/tree/master/helm/reana)
is set as a list of the desired paths as strings in the format 
`hostPath:mountPath`, where `hostPath` is the path to the directory
to be mounted from the Kubernetes nodes and `mountPath` is path
inside the cluster containers where the hostPath will be mounted.
In this example, we shall use `/home/myexternaldrive:/myexternaldrive`
and `/home/myworkflows:/workflows` as the wanted workspace storage.
Here is how this values can be set:

```
$ helm install reana reanahub/reana --namespace reana --create-namespace --set "workspaces.paths={/home/myexternaldrive:/myexternaldrive,/home/myworkflows:/workflows}" --wait
```

The first value listed will be the default workspace used, in this 
example is `/myexternaldrive`. The REANA cluster deployment shall
be finished by creating the administrator user:

```
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.7/scripts/create-admin-user.sh
$ sh create-admin-user.sh reana reana john.doe@example.org mysecretpassword
```

And obtaining the REANA environment variables `REANA_SERVER_URL`
and `REANA_ACCESS_TOKEN`. Finally, we install and activate the
REANA command-line client [reana-client](https://pypi.org/project/reana-client/),
setting the environmental variables:

```
$ pip install reana-client
$ export REANA_SERVER_URL=$REANA_SERVER_URL
$ export REANA_ACCESS_TOKEN=$REANA_ACCESS_TOKEN
```

### Creating a workflow with a particular workspace

Now that we have deployed the REANA cluster, we can proceed to
create a workflow. The specification of the workspace is made in
the [REANA specification file `reana.yaml`](http://docs.reana.io/reference/reana-yaml/#about-reanayaml),
as a top section or property. We define it in the following way:

```yaml
version: 0.3.0
inputs:
  files:
    - code/helloworld.py
    - data/names.txt
  parameters:
    helloworld: code/helloworld.py
    inputfile: data/names.txt
    outputfile: results/greetings.txt
    sleeptime: 0
workflow:
  type: serial
  specification:
    steps:
      - environment: 'python:2.7-slim'
        commands:
          - python "${helloworld}"
              --inputfile "${inputfile}"
              --outputfile "${outputfile}"
              --sleeptime ${sleeptime}
outputs:
  files:
   - results/greetings.txt
workspace:
  root_path: /myexternaldrive/workflow1
```

Any subfolder of the available workspaces can be defined as
`root_path`. Once this property is defined in the specification
file, the workflow can be runned in the CLI as:

```
reana-client run -f reana.yaml
```
By doing this, the workspace will be validated, created and the
files will be uploaded in the corresponding directory.

The input and output files from this workflow are
now available on the external storage directory `/home/myexternaldrive/workflow1`

```
$ ls /home/myexternaldrive/workflow1
  code/helloworld.py
  data/names.txt
  results/greetings.txt
```

In case the property `root_path` is not declared in the specification
file, the default workspace will be used as root path.

