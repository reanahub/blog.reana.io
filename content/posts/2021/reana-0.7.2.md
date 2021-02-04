---
title: "REANA 0.7.2 is released"
date: 2021-02-04T14:46:00+01:00
tags:
  - release
---

We are glad to announce the release of REANA 0.7.2, a minor update
allowing REANA administrators to configure user sign-up and user email
verification options.

## What's new?

### Mandatory user email verification

From REANA 0.7.2 on, the new users who sign up to register an account
will have to confirm their email identity. The users will not be able
to use the system until they confirm their email address by means of a
special link that is sent to them by email after the registration.

![sign-up success](/images/reana-0.7.2-user-sign-up-success.png)

Please don't forget to set up the SMTP deployment options
(`notifications.email_config.*`) so that REANA would be able to send
emails to users.

If you would like to disable this feature and allow any user to sign
up with no confirmation, you can configure
`REANA_USER_EMAIL_CONFIRMATION` value under
[components.reana_server.environment](https://github.com/reanahub/reana/tree/master/helm/reana)
at the Helm deployment time:

```diff
components:
  ...
  reana_server:
    imagePullPolicy: IfNotPresent
    image: reanahub/reana-server:0.7.1
    environment:
      REANA_MAX_CONCURRENT_BATCH_WORKFLOWS: 30
-     REANA_USER_EMAIL_CONFIRMATION: true
+     REANA_USER_EMAIL_CONFIRMATION: false
    uwsgi:
      processes: 6
      threads: 4
```

### Configurable sign-up form

REANA 0.7.2 also enables administrators to fully hide the sign-up form
from the web interface. This will prevent users from registering on
the system. Instead, the users will be given instructions on how to
contact administrators:

![sign-up hidden](/images/reana-0.7.2-user-sign-up-hidden.png)

The option to completely hide the user sign-up form can be interesting
to use if you would like to manage all your users manually.

The sign-up form can be hidden by configuring
[components.reana_ui.hide_signup](https://github.com/reanahub/reana/tree/master/helm/reana)
value at the Helm deployment time:

```diff
components:
   reana_ui:
     enabled: true
     docs_url: http://docs.reana.io
     forum_url: https://forum.reana.io
     imagePullPolicy: IfNotPresent
     image: reanahub/reana-ui:0.7.0
+    hide_signup: true
```

You can also amend an existing REANA deployment in the command line:

```console
$ helm upgrade reana reanahub/reana --set components.reana_ui.hide_signup=true
```

Please don't forget to set up the administrator email notification
receiving address (`notifications.email_config.receiver`) when using
this option.

Enjoy!

See also:
- [REANA 0.7.2 release notes](https://github.com/reanahub/reana/releases/tag/0.7.2)
- [REANA installation guide](https://docs.reana.io/development/deploying-at-scale/)
