---
title: "Enable users to log in with your own SSO Provider"
date: 2023-09-22T09:00:00+01:00
categories:
- Admin
tags:
- Admin
---

With the latest REANA release, administrators can now configure their own third-party Keycloak Single Sign-On (SSO) authentication provider.

## What is Single Sign-On (SSO)?

Single Sign-On (SSO) is a user authentication service that allows users to use one set of login credentials to access multiple applications. With SSO, users only need to enter their login credentials once, and then they can access all of the applications that are part of the SSO ecosystem without having to enter their login credentials again. This not only saves time but also improves security by reducing the number of passwords users need to remember.

## What is Keycloak?

Keycloak is an open-source identity and access management platform that provides Single Sign-On (SSO) authentication services, making it a popular choice for organizations looking to implement SSO across their applications. You can find out more about Keycloak [here](https://www.keycloak.org/).

## Why is configuring your own third-party SSO authentication provider important?

REANA already provides a built-in SSO authentication provider based on OAuth 2.0, which supports authentication with CERN. However, some users may prefer to use a different authentication provider, such as their organization's SSO provider. With the latest REANA release, it is now possible to configure your own third-party SSO authentication provider, giving users more flexibility and control over their authentication workflow.

## How to configure your own third-party SSO authentication provider in REANA?
 
Configuring your own third-party SSO authentication provider in REANA is a simple process. First, you need to add a new authentication provider configuration in YAML format to the [`login`](https://github.com/reanahub/reana/tree/master/helm/reana) list in the Helm values. This list item should contain the necessary information for REANA to communicate with your SSO provider, such as the authentication endpoint URL. An example can be found below:

```yaml
login:
  - name: "yourprovider"
    type: "keycloak"
    config:
      title: "YOUR PROVIDER"
      base_url: "https:/keycloak.example.org"
      realm_url: "https://keycloak.example.org/auth/realms/your-realm"
      auth_url: "https://keycloak.example.org/auth/realms/your-realm/protocol/openid-connect/auth"
      token_url: "https://keycloak.example.org/auth/realms/your-realm/protocol/openid-connect/token"
      userinfo_url: "https://keycloak.example.org/auth/realms/your-realm/protocol/openid-connect/userinfo"
```

The client key (also referred to as client ID) and the secret can be added in the following way:

```yaml
secrets:
  login:
    yourprovider:
      consumer_key: <your-client-id>
      consumer_secret: <your-client-secret>
```

Alternativly, you can obtain these secrets form a pre existing Kubernetes secret with the client key and secret. Here is an example:

```yaml
apiVersion: v1
data:
  consumer_key: <your-client-id>
  consumer_secret: <your-client-secret>
kind: Secret
metadata:
  name: <your-secret-name>
type: Opaque
```

Depending on the way you deploy it, you can then get these values from the secret. For example, with Flux you could use `ValuesFrom` like this:

```yaml
  valuesFrom:
    - kind: Secret
      name: <your-secret-name>
      valuesKey: consumer_key
      targetPath: secrets.login.escape-iam.consumer_key
    - kind: Secret
      name: <your-secret-name>
      valuesKey: consumer_secret
      targetPath: secrets.login.escape-iam.consumer_secret
```

Once you have updated the values, you can upgrade your Helm deployment. After that, you should be able to see an option to log in with your SSO provider.

![ui-sso-keycloak](/images/ui-sso-keycloak.png)

For full and updated documentation, please visit the [Reana admin documentation](https://docs.reana.io/administration/configuration/configuring-access/#keycloak-single-sign-on-configuration).

## Conclusion

Configuring your own third-party SSO authentication provider in REANA gives users more flexibility and control over their authentication workflow. With the latest REANA release, users can now easily configure their own SSO provider, making it easier for them to access the platform with the same credentials they use for other applications. This not only saves time, but also improves security by reducing the number of passwords users need to remember.
