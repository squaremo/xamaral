Title: SSO for k8s deployed apps.
Date: 2019-06-21
Tags: kubernetes, nginx, auth0, oauth2-proxy
Status: draft

In this article I demonstrate how to implement Single Sign On (SSO) for
applications running in a Kubernetes cluster.

We'll make use of the following tools and services:

- [nginx ingress](https://github.com/kubernetes/ingress-nginx)
  * [nginx ingress external auth
    example](https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/auth/oauth-external-auth)
    
- [oauth2 proxy](https://github.com/pusher/oauth2_proxy)
  * [Some relevant
    discussion](https://github.com/bitly/oauth2_proxy/issues/558)
    
- [Auth0 docs](https://auth0.com/docs). This can be replaced by any oidc
  provider, but using Auth0 allows you to get started quickly since they can
  also handle sign on and storing users. The free tier limits are fine for this use
  case, provided you don't need more user than allowed for.
  


