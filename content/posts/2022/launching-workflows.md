---
title: "Launching workflows from external sources using web interface"
date: 2022-05-18T07:00:00+02:00
---

If you host your analysis workflows on publicly accessible external sources
such as source code repositories (GitHub, GitLab), digital repositories
(Zenodo), or simply other locations on the web (generic URL), it is now
possible to launch your workflows directly on the web using the brand new REANA
launcher web page.

<!--more-->

## An alternative way to execute workflows

The traditional and the most-used way of executing REANA workflows is by means
of the `reana-client` command-line tool. You can use it to create workflows,
upload files to workspaces, start workflow execution, consult logs, download
results, and more. A short tutorial on using `reana-client` can be found on the
[First example](https://docs.reana.io/getting-started/first-example/)
documentation page.

Another, even more low-level way to manage workflows, is to use the Python API.
This can be useful if you want to interact with REANA from your Python
application. A short tutorial on using REANA Python API can be found in the
[How to run REANA workflows using Python
API](/posts/2021/reana-client-python-api/) blog post.

Both of these approaches require installing `reana-client` locally, which can
be non-desirable in certain usage scenarios. For example, if you only want to
execute an already-published workflow to check its results, or re-execute it
with modified input parameters, it may be easier to launch such a workflow
using directly the web interface, saving the work of manually cloning the
repository and editing its input files. The new REANA launcher functionality
enables exactly this kind of usage scenarios.

## Launching workflows using web interface

If you have a valid CERN account, please go to the
[reana.cern.ch/launch](https://reana.cern.ch/launch) where you will see the
launcher home page with several demo examples:

[![Launch
home](/images/launching-workflows-launcher-home.png)](https://reana.cern.ch/launch)

You can click on one of the presented examples to launch the workflow on the
REANA web site. For example, clicking on the RooFit demo will redirect you to
the following page:

[![Launch
RooFit](/images/launching-workflows-roofit-launch.png)](https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit#readme)

where you can further click on the Launch button. REANA will then fetch the
workflow from the remote GitHub repository and start its execution.

## Constructing your own launch URLs

If you look at the browser address bar, you will see the following full URL
before launching the RooFit demo example:

```
https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit
```

The launcher functionality is handled by the `/launch` endpoint which executes
the workflow specified by the `url` argument. By pointing `url` to where you
host your workflow, you can construct your own launch URLs for your analyses.

You can also optionally provide a custom workflow run name via a `name`
argument, or choose a path to a specific `reana.yaml` specification file via
the `specification` argument. Finally, you can also modify workflow's input
parameters via specially encoded `parameters` argument.

For a detailed description of all launcher arguments, please see the [Launcher
arguments](https://docs.reana.io/running-workflows/launching-workflows/#launcher-arguments)
documentation page.

## Using launch badges

We have prepared a set of Launch-on-REANA badges that you can use to make your
workflows runnable by simply clicking on them:

[![Launch on REANA at
CERN](https://www.reana.io/static/img/badges/launch-on-reana-at-cern.svg)](https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit)


Badges are just images that will redirect users to the launch URLs constructed
above. This means that you can include them wherever you want, for example in
the `README` file of your Git repositories.

Here is an example of a badge used in the `README` file of the [RooFit demo
example](https://github.com/reanahub/reana-demo-root6-roofit#readme):

[![Launch RooFit
badges](/images/launching-workflows-roofit-badges.png)](https://github.com/reanahub/reana-demo-root6-roofit#readme)

For more information on available badges, please see the [Launcher
badges](https://docs.reana.io/running-workflows/launching-workflows/#launcher-badges)
documentation page.

## Availability

REANA launcher will be coming with the REANA 0.9.0 release series. The launcher
functionality is already deployed for a preview on the
[reana.cern.ch](https://reana.cern.ch/launch) instance. The launcher currently
supports launching workflows from publicly accessible URLs only. Please give it
a try and let us know what you think!

## See also
- [Launching workflows from external sources](https://docs.reana.io/running-workflows/launching-workflows/) documentation page
