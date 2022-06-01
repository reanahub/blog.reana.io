---
title: "Standalone reana-client executables for Linux systems"
date: 2022-06-01T08:00:00+01:00
tags:
  - client
  - linux
---

The usual way of creating, executing and managing REANA workflows is by means
of the [reana-client](https://docs.reana.io/getting-started/first-example/)
command-line tool. However, installing `reana-client` can be painful in certain
situations, for example when it conflicts with your other Python project
dependencies and you don't want to be switching Python virtual environments all
the time. In these cases, using a fully standalone `reana-client` executable
would be desirable.

<!--more-->

As of REANA 0.8.0, we have started publishing standalone `reana-client`
executables for Linux operating systems using the
[AppImage](https://appimage.org/) technology. Each published application
executable bundles the `reana-client` command-line tool together with Python
and all the necessary dependent libraries so that the client can run fully
independently of your local environment.

You can download `reana-client` standalone executables from our [GitHub releases
page](https://github.com/reanahub/reana-client/releases), for example:

```console
$ wget https://github.com/reanahub/reana-client/releases/download/0.8.1/reana-client-0.8.1-x86_64.AppImage
```

Then you can place the executable into some convenient directory found in your
`PATH`, such as `$HOME/.local/bin`:

```console
$ chmod u+x ./reana-client-0.8.1-x86_64.AppImage
$ mv ./reana-client-0.8.1-x86_64.AppImage $HOME/.local/bin/reana-client-0.8.1
```

You will now be able to use the `reana-client-0.8.1` executable from anywhere:

```console
$ cd myanalysis
$ reana-client-0.8.1 ping
REANA server: https://reana.cern.ch
REANA server version: 0.9.0a5
REANA client version: 0.8.1
Authenticated as: John Doe <john.doe@example.org>
Status: Connected
```

Please note that the `reana-client` AppImage executable format works only on
Linux operating systems. It should be supported by all major Linux
distributions. Please let us know if you encounter any troubles on your
favourite Linux distribution.

If you are using another operating system, such as macOS, you will not be able
to use these executables. But don't worry! We are considering creating
statically-linked cross-platform `reana-client` executables using Go
programming language in the near future. Stay tuned for more news later in the
year.
