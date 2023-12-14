# blog.reana.io

[![CI Actions Status](https://github.com/reanahub/blog.reana.io/workflows/CI/badge.svg)](https://github.com/reanahub/blog.reana.io/actions) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/reanahub/reana?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![License](https://img.shields.io/github/license/reanahub/blog.reana.io.svg)](https://github.com/reanahub/blog.reana.io/blob/master/LICENSE)

## Clone

```console
$ git clone git@github.com:reanahub/blog.reana.io.git
$ cd blog.reana.io
$ git submodule init
$ git submodule update
```

## Run locally

```console
$ hugo server -DF # shows drafts and future posts
$ firefox http://localhost:1313
```

## Create a new post
```console
$ hugo new posts/2021/my-new-post.md
```

## Run on Docker
### Dev mode

```console
$ docker build -t docker.io/reanahub/blog.reana.io --build-arg HUGO_CMD='-D' .
$ docker run --rm --name reanablog -p 8080:8080 docker.io/reanahub/blog.reana.io
$ firefox http://localhost:8080
```

### Production mode

```console
$ docker build -t docker.io/reanahub/blog.reana.io --build-arg HUGO_CMD='--minify --gc' .
$ docker run --rm --name reanablog -p 8080:8080 docker.io/reanahub/blog.reana.io
$ firefox http://localhost:8080
```

## Openshift

```console
$ oc new-build https://github.com/reanahub/blog.reana.io --build-arg=HUGO_CMD='--minify --gc'
$ oc new-app openshift-registry.web.cern.ch/reana-blog/blogreanaio
# create route manually via UI
```
