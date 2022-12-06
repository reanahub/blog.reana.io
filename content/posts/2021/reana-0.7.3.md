---
title: "REANA 0.7.3 is released"
date: 2021-03-24T17:00:00+01:00
---

We are happy to announce REANA 0.7.3. This minor bug fix release adds
new `reana-client` validation features for workflow input parameters
and environment images, improves cluster resilience in case of job
failures, and fixes HTCondor and Slurm integration for complex job
commands.

## What's new?

### Validating workflow parameters

Computational workflows often contain tens of input parameters. It
may be hard to keep track of which parameters are being used in the
multiple steps a workflow has. It would be a tedious task to verify
manually that all the parameters referenced in the workflow steps are
properly defined as part of the workflow input parameters.

With the release of `reana-client` 0.7.3, we are introducing a more
advanced validation that performs the input parameter validation
automatically. Let us illustrate how this new feature works with a
simple example.

Given a simple Serial workflow `reana.yaml`:

```yaml
version: 0.7.3
inputs:
  files:
    - code/myanalysis.py
  parameters:
    script_path: code/myanalysis.py
workflow:
  type: serial
  specification:
    steps:
      - name: run-script
        environment: 'python:3.9-slim'
        commands:
          - python "${script_path}"
```

Let us call the validator:

```console
$ reana-client validate -f reana.yaml
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
```

The output displayed is successful, meaning that our REANA
specification is properly built and there were no issues found in
parameters and commands.

Imagine that `myanalysis.py` can receive a second argument. We
define this as a new input parameter `sleeptime`, but we forget
to pass it to the actual Python command:

```diff
     - code/myanalysis.py
   parameters:
     script_path: code/myanalysis.py
+    sleeptime: 10
 workflow:
   type: serial
   specification:
```

Let us verify our REANA specification again:

```console
$ reana-client validate -f reana.yaml
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> WARNING: REANA input parameter "sleeptime" does not seem to be used.
```

The specification remains valid, as it is well-formed, however, a
warning is displayed indicating that `sleeptime` parameter is
defined but it does not seem to be used in the workflow
specification.

Let us fix this problem by adding this unused parameter to the
command, but imagine that we make a typo when adding it and we write
`sleptime` instead of `sleeptime`:

```diff
       - name: run-script
         environment: 'python:3.9-slim'
         commands:
-          - python "${script_path}"
+          - python "${script_path}" "${sleptime}"
```

Let us call the validator to see the output:

```console
$ reana-client validate -f reana.yaml
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> WARNING: REANA input parameter "sleeptime" does not seem to be used.
  -> WARNING: Serial parameter "sleptime" found on step "run-script" is not defined in input parameters.
```

Due to our typo, `sleptime` appears as a new parameter. It is present
in the workflow commands of step `run-script` but it was not defined.
Let us fix the typo and call the validator again:

```diff
     - code/myanalysis.py
   parameters:
     script_path: code/myanalysis.py
+    sleeptime: 10
 workflow:
   type: serial
   specification:
     steps:
       - name: run-script
         environment: 'python:3.9-slim'
         commands:
-          - python "${script_path}" "${sleptime}"
+          - python "${script_path}" "${sleeptime}"
```

```console
$ reana-client validate -f reana.yaml
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
```

Now everything is settled, the warnings disappear as the new
parameter is defined and used properly.

Note that input workflow parameter validation is also implemented for
CWL and Yadage workflows.

### Verifying potentially dangerous workflow commands

The workflow may execute certain commands or operations that are
potentially conflicting with REANA platform's way of executing
workflows. One such example is trying to run commands as superuser
(`sudo`). REANA runs workflows under regular user identity for
security reasons. If a workflow uses sudo in its commands, it often
happened that the workflow failed after many hours of execution. The
new release of `reana-client` alerts us about these possible problems
at the time of workflow submission already.

Let us modify our previous example to illustrate how this works:

```diff
       - name: run-script
         environment: 'python:3.9-slim'
         commands:
-          - python "${script_path}" "${sleeptime}"
+          - sudo python "${script_path}" "${sleeptime}"
```

Let us run the validator:

```console
$ reana-client validate -f reana.yaml
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> WARNING: Operation "sudo" found in step "run-script" might be dangerous.
  -> SUCCESS: Workflow parameters and commands appear valid.
```

The output shows a warning message indicating the dangerous operation
and in which step was found.

The `reana-client validate` command may thus save you development
time by providing early warnings about these possibly dangerous
operations that would be encountered only during later runtime.

### Validating workflow environment images

REANA 0.7.3 command line client introduces a new option for the
`reana-client validate` command, called `--environments`. This option
will trigger the possibly-lengthy validation of workflow environment
images, hence it is not done by default. The environment image
validation allows you to ensure image existence, image tag, or image
user and group ID settings compatibility for your workflow.

Workflows run in containerised environments that can be precisely
captured for preservation by means of using tagged images.
We encourage users to tag their images when running analyses as this
will ensure reproducibility in the future, one of the pillars of
[FAIR principles](https://www.nature.com/articles/sdata201618).

#### Validating environment image existence

Besides, it is important to verify the existence of these environment
images, both locally and remotely (Docker Hub and GitLab registry),
to ensure that the REANA cluster can pull them with no issues.

Let us use the previous workflow example to depict this
functionality. In that workflow, the environment used was
`python:3.9-slim`, which is properly tagged and exists in
Docker Hub. We are going to modify it and use a non-existing image
instead, for example `foo:bar`.

```diff
   specification:
     steps:
       - name: run-script
-        environment: 'python:3.9-slim'
+        environment: 'foo:bar'
         commands:
           - python "${script_path}" "${sleeptime}"
```

Let us call the validator, passing the environments option:

```console
$ reana-client validate -f reana.yaml --environments
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
==> Verifying environments in REANA specification file...
  -> SUCCESS: Environment image foo:bar has the correct format.
  -> WARNING: Environment image foo:bar does not exist locally.
  -> WARNING: Environment image foo:bar does not exist in Docker Hub: "Resource not found"
  -> ERROR: Environment image foo:bar does not exist locally or remotely.
```

Let us analyse the environment validation output. First, we get a
success message informing us that the image has the correct format.
This is because the step specifies the image name and the tag, so
in that regard it is correct. Then we get two warnings telling us
that the image was not found either locally nor in the Docker Hub
registry.
As a consequence, we see the validation with an error message,
telling us that the image does not exist, and the validation fails.

#### Validating environment image tag

Let us change the environment to use a valid one. We are going to
revert back to the `python` image but using the `latest` tag instead:

```diff
   specification:
     steps:
       - name: run-script
-        environment: 'foo:bar'
+        environment: 'python:latest'
         commands:
           - python "${script_path}" "${sleeptime}"
```

The use of latest tags is [usually discouraged](https://vsupalov.com/docker-latest-tag/)
because of its "moving target" nature: a `latest` image might be
different today, tomorrow, next week or next year. We always
recommend to used tagged images in order to ensure the computational
reproducibility of results.

Let us run the validator again:

```console
$ reana-client validate -f reana.yaml --environments
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
==> Verifying environments in REANA specification file...
  -> WARNING: Using 'latest' tag is not recommended in python environment image.
  -> WARNING: Environment image python:latest does not exist locally.
  -> SUCCESS: Environment image python:latest exists in Docker Hub.
  -> WARNING: UID/GIDs validation skipped, specify `--pull` to enable it.
```

As part of the environment verification, we get a message warning us
about the usage of the `latest` tag. Additionally, we see two checks to
verify if the image exists locally and remotely. In this particular
case, since we do not have the `python:latest` image pulled locally,
a warning is displayed. On the other hand, the `python:latest` image
exists in Docker Hub registry, this we get a success message.

#### Validating environment image user and group ID

The reproducible workflows should ideally not depend on the given
user who executes them. The workflow should give the same result
regardless of user identity, such as UID (user ID) and GID (group ID)
known from Unix systems.

For security reasons, REANA executes workflows as UID=1000
([see here](https://github.com/reanahub/reana-commons/blob/0ff3eb93b0d03178327e008cc31aba675645bf66/reana_commons/config.py#L303)),
and expects GID=0 to be able to share filesystem write rights across
multiple nodes ([see here](https://github.com/reanahub/reana-commons/blob/0ff3eb93b0d03178327e008cc31aba675645bf66/reana_commons/config.py#L306))
. This technicalities usually don't matter. However, in certain
cases, you may need to execute your workflow under a different user
identity, for example because the environment image expects certain
user privileges. REANA allows this by setting `kubernetes_uid`
workflow hint. However, it can happen that workflow image user ID
expectations are conflicting with the declared UID, which leads to
conflicts at the workflow execution time.

REANA 0.7.3 validation of environments allows to catch these
situations early by inspecting the workflow specification and the
container images. In order to be able to do such inspection, you must
have a running docker on the machine were you run `reana-client`. The
environment image has to be pulled locally, which also consumes disk
space. The validation of image UID and GID is therefore triggered by
another command line option called `--pull`. Please use this option
only if you are used to working with `docker` images locally.

Let us illustrate how the enviroment image UID and GID validation
works by rerunning our past example:

```diff
   specification:
     steps:
       - name: run-script
-        environment: 'python:latest'
+        environment: 'python:3.9-slim'
         commands:
           - python "${script_path}" "${sleeptime}"
```

```console
$ reana-client validate -f reana.yaml --environments --pull
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying environments in REANA specification file...
  -> SUCCESS: Environment image python:3.9-slim has the correct format.
  -> WARNING: Environment image python:3.9-slim does not exist locally.
  -> SUCCESS: Environment image python:3.9-slim exists in Docker Hub.
Unable to find image 'python:3.9-slim' locally
3.9-slim: Pulling from library/python
6f28985ad184: Pulling fs layer
...
Status: Downloaded newer image for python:3.9-slim
  -> INFO: Environment image uses UID 0 but will run as UID 1000.
```

We can see that the image was pulled locally and there is a new
message about UID check. In this case, it is just a warning that
REANA uses UID=1000 by default, and that this image uses UID=0. This
does not necessarily mean that the execution is going to fail,
provided that the environment image does not make any assumption on
user identity. The `python` images don't, so the execution will
succeed. If you are using an image that does require to run processes
under certain user identity, we recommend that you use 1000 which is
the usual default Unix user.

The workflow environment image validation is also compatible with
images hosted in the GitLab registry at CERN, fo example
`gitlab-registry.cern.ch/johndoe/foo`. Please note that if your image
is protected, you would have to authenticate via `docker login` first
so that the validator would be able to fetch it on the machine where
you are executing the validation.

## What's improved?

REANA 0.7.3 release brings two minor improvements to cluster.

You may have seen a situation where a workflow failed, but you have
still seen it reported as `running` in your workflow list. This
appeared because of the miscommunication of internal REANA componets
about the workflow status. REANA 0.7.3 improves the cluster
resilience in these situations by amending the job status consumer to
capture the exceptional situations.

Finally, if you have been using HTCondor or Slurm backends for your
workflows, REANA 0.7.3 cluster improves the job dispatching in case
of complex inline Yadage commands. Also, the job scheduling errors
from remote HTCondor platforms are better caught and reported in the
usual workflow logs.

Please give new features a try and let us know what you think!

See also:
- [REANA 0.7.3 release notes](https://github.com/reanahub/reana/releases/tag/0.7.3)
- [REANA-Client 0.7.3 release notes](https://github.com/reanahub/reana-client/releases/tag/0.7.3)
- [Validating `reana.yaml`](https://docs.reana.io/reference/reana-yaml/#validating-reanayaml)
- [REANA-Client `validate` reference](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-validate)
