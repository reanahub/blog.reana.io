---
title: "Integration of Reana into the Virtual Research Environment"
date: 2023-09-18T09:00:00+01:00
categories: Guest
tags: Guest
---

One of the key objectives of European Open Science Cloud projects is to consolidate the analysis workflows used in Cosmology, Astrophysics, and High Energy Physics into a unified framework. This effort aims to simplify the process of data sharing, software distribution, and analysis code dissemination among researchers. The development of Science Projects focuses on specific use cases, particularly those related to Dark Matter and Extreme Universe exploration. These endeavors depend on the implementation of the Virtual Research Environment, a prototype analysis platform that adheres to the FAIR data principles.

The [Virtual Research Environment](https://vre-hub.github.io), which is accessible through a shared authentication framework, provides access to data from various experiments such as ATLAS, Fermi-LAT, CTA, Darkside, Km3Net, Virgo, and LOFAR. This data is made available through a dependable distributed storage infrastructure known as the Data Lake. To access, analyze, and share this data, researchers can use a Jupyterhub instance deployed on a scalable Kubernetes infrastructure, offering an interactive graphical interface.

The data access and browsing capabilities are facilitated through API calls to high-level data management and storage orchestration software called Rucio. Furthermore, Rucio has been seamlessly integrated with workflow schedulers like Reana and Dask, which support a variety of resource managers such as Slurm, HTCondor, and Kubernetes. This integration allows researchers to effectively preserve their analyses and collaborate with peers.

The VRE uses the default configuration of the Reana Helm Chart with two notable additional configurations. One for SSO with a dedicated IAM instance:

```yaml
    login:
      - name: "escape-iam"
        type: "keycloak"
        config:
          title: "ESCAPE IAM"
          base_url: "https://iam-escape.cloud.cnaf.infn.it"
          realm_url: "https://iam-escape.cloud.cnaf.infn.it" 
          auth_url: "https://iam-escape.cloud.cnaf.infn.it/authorize" 
          token_url: "https://iam-escape.cloud.cnaf.infn.it/token" 
          userinfo_url: "https://iam-escape.cloud.cnaf.infn.it/userinfo"
```
*The full configuration can be found [here](https://github.com/vre-hub/vre/blob/main/infrastructure/cluster/flux-v2/reana/reana-release.yaml).*

And another with the [REANA Authentication Rucio](https://github.com/reanahub/reana-auth-rucio), which allows users to integrate Rucio data management to retrieve and upload files within a Reana workflow on the VRE:

```yaml
version: 0.6.0
workflow:
  type: serial
  specification:
    steps:
      - name: fetchdata
        voms_proxy: true
        rucio: true
        environment: 'ghcr.io/vre-hub/vre-rucio-client:v0.1.2-1-0487cc0'
        commands:
        - rucio get <SCOPE_NAME:FILE_NAME>
      - name: fitdata
        environment: <link_to_github_registry_or_dockerhub_image>
        commands:
        - <your_commands>
      - name: uploaddata
        voms_proxy: true
        rucio: true
        environment: 'ghcr.io/vre-hub/vre-rucio-client:v0.1.2-1-0487cc0'
        commands:
        - rucio upload --scope SCOPE_NAME --rse RSE_NAME <your_result_named_as_ProjectType.DataDescription.DataType>
```

A detailed guide can also be found [here](https://vre-hub.github.io/docs/reana.html).
