---
title: "Launching workflows from external sources using the web UI"
date: 2022-04-20T14:00:00+02:00
tags:
  - API
  - cluster
  - ui
---

We are happy to announce that it is now possible to launch workflows that are
hosted on external services directly from the REANA web interface, without
relying on the `reana-client` CLI tool!

<!--more-->

## An overview on how to run workflows

As you might already know, `reana-client` is the command-line tool that can be
used to interact with the REANA platform. You can use it to create workflows,
upload files to their workspaces, and execute them. A tutorial on how to do so
can be found on the page
[First example](https://docs.reana.io/getting-started/first-example/) of the
REANA documentation website.

Another way to manage workflows is to use the Python API. This can be useful if
you want to interact with REANA from your Python application or script. If you
are interested in this topic, you should read the blog post on
[How to run REANA workflows using Python API](/posts/2021/reana-client-python-api/).

However, both approaches require installing `reana-client` and setting it up.
You will also need to upload the necessary files for the workflow. All this can
be a hassle in some cases. For example, if the workflow is available online and
you only want to run it.

## Launching workflows from external sources

If your workflow specification is hosted online, you can now launch it directly
from REANA's web interface. We currently support GitLab and GitHub repositories,
but you can also use any URL that points to a zip archive or to a YAML
specification file.

For example, you can click
[here](https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit)
to launch the [RooFit demo](https://github.com/reanahub/reana-demo-root6-roofit)
on the REANA instance at CERN. If you log in with a valid CERN account, you will
be shown some information about the workflow to be run and a button to launch
it:

![Launch page](/images/launch-page.png)

If you look at the address bar, this is the full URL of the page:

```
https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit
```

As you can see, everything is handled by the `/launch` endpoint, which executes
the workflow specified by the `url` parameter. You can also provide a custom
workflow name with `name`, choose a different specification file with
`specification` or modify the workflow's parameters with `parameters`. For a
detailed description of the endpoint's arguments, see the section
[Launcher arguments](https://docs.reana.io/running-workflows/launching-workflows/#launcher-arguments)
of the documentation.

### Badges

We have also prepared some badges that you can use to make your workflows
runnable by everybody with a single click. Badges are just images that, when
clicked, redirect the user to the launch page of REANA. This means that you can
include them wherever you want, for example in the README of your Git repository
or on your website. There are badges in the
[Examples section](https://reana.io/#examples) of REANA's website and in the
README files of all the
[demo repositories](https://github.com/search?q=org%3Areanahub+reana-demo-&type=Repositories).

This is an example of a badge that will run the RooFit demo on REANA@CERN:

[![Launch on REANA at CERN](https://www.reana.io/static/img/badges/launch-on-reana-at-cern.svg)](https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit)

You can find many more badges on the related
[documentation page](https://docs.reana.io/running-workflows/launching-workflows/#launcher-badges),
along with instructions on how to use them. Of course, you can also generate
custom badges using services like [shields.io](https://shields.io) or
[badgen.net](https://badgen.net).

## Availability and future plans

You can already experiment with launching workflows from remote sources on the
[REANA instance hosted at CERN](https://reana.cern.ch/launch). This feature will
be available for everyone in the 0.9.0 version, which will be released soon.

As of now, you need to manually craft the badges and the URLs to launch your
workflows, but we plan on having a webpage to do it more easily in the future.

For more information, see the page
[Launching workflows from external sources](https://docs.reana.io/running-workflows/launching-workflows/)
of REANA's documentation.
