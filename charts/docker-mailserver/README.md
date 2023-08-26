# docker-mailserver-helm
## fork from https://github.com/docker-mailserver/docker-mailserver-helm/

This helm chart deploys [Docker
Mailserver](https://github.com/docker-mailserver/docker-mailserver) into a
Kubernetes cluster, in a manner which retains compatibility with the upstream,
docker-specific version.

Docker Mailserver was originally intended to be run with Docker or Docker
Compose, it's been [adapted to
Kubernetes](https://github.com/docker-mailserver/docker-mailserver/wiki/Using-in-Kubernetes).


## Features

The chart includes the following features:

- All configuration is done in values.yaml, or using the native "setup.sh" script (to create mailboxes)
- Avoids the [common problem of masking of source IP](https://kubernetes.io/docs/tutorials/services/source-ip/) by supporting haproxy's PROXY protocol (enabled by default)
- Employs [cert-manager](https://github.com/jetstack/cert-manager) to automatically provide/renew SSL certificates
- Bundles in [RainLoop](https://www.rainloop.net) for webmail access (disabled by default)

## Prerequisites

- Kubernetes 1.16+ ~~(*CI validates against > 1.18.0*)~~
- To use HAProxy ingress, you'll need to deploying the chart to a cluster with a cloud provider capable of provisioning an
external load balancer (e.g. AWS, DO or GKE). (There is an [update planned](https://github.com/funkypenguin/docker-mailserver/issues/5) to support HA ingress on bare-metal deployments)
- You control DNS for the domain(s) you intend to route through Traefik
- __Suggested:__ PV provisioner support in the underlying infrastructure
- [Cert-manager](https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager) => 1.0 requires manual deployment into your cluster (details below)
- [Helm](https://helm.sh) >= 2.13.0 (*errors were encountered when testing with 2.11.0, so the chart has a minimum requirement of 2.13.0*)

## Architecture

There are several ways you might deploy docker-mailserver. The most common would be:

1. Within a cloud provider, utilizing a load balancer service from the cloud provider (i.e. GKE). This is an expensive option, since typically you'd pay for each individual port (25, 465, 993, etc) which gets load-balanced

2. Either within a cloud provider, or in a private Kubernetes cluster, behind a non-integrated load-balancer such as haproxy. An example deployment might be something like [Funky Penguin's Poor Man's K8s Load Balancer](https://www.funkypenguin.co.nz/project/a-simple-free-load-balancer-for-your-kubernetes-cluster/), or even a manually configured haproxy instance/pair.

## Getting Started

### 1. Install helm

You need helm, obviously.   Instructions are [here](https://helm.sh/docs/intro/install/). 

### 2. Install cert-manager ( Recommend )

If you want to set up ssl automatically, you need to install cert-manager, and [setup issuers](https://docs.cert-manager.io/en/latest/index.html). It's easy to install using helm (which you have anyway, right?). Cert-manager is what will request and renew SSL certificates required for `docker-mailserver` to work. The chart will assume that you've configured and tested certmanager.

Here are the TL;DR steps for installing cert-manager:

```console
# Install the CustomResourceDefinition resources separately
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v1.9.1 \
  jetstack/cert-manager
```

### Install docker-mailserver

You will either need a local clone of this repository or to add the docker-mailserver-helm helm chart repository to your helm configuration:

```console
helm repo add docker-mailserver https://docker-mailserver.github.io/docker-mailserver-helm/
```

## Configuration and Operation

### Install

This command will install Docker Mailserver with default values.  You probably want to read the below section for how to configure it before doing this.

```console
helm install --name docker-mailserver docker-mailserver
```

### OpenDKIM ( optional )

The OpenDKIM keys will be generated from `domains` if not exist.

After installation, you can get the TXT records from the secrets.

Example output:
```console
[root@localhost ~] kubectl get secret -n docker-mailserver docker-mailserver-dkimtxts -o=jsonpath="{.data.mail\.test\.domain}" | base64 -d
mail._domainkey	IN	TXT	( "v=DKIM1; h=sha256; k=rsa; "
	  "p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwuiL23AIBT5K/yT0DeS16gMSV2BJupZsice1rl8eZUenYq+d2nELX9Es+C1hFbXIN4zgVHP6vbMi58pzyt13Y/lfmwm2hQuJAAXHBF623FbO4pfC5SlV2lLi4ENHPfP9U4T+IBQNgIyZ0eSXplyHgjrXHIaFNPuGDLdKAlE/zHlDOjp9GGW4Sk+SWo5Ok9OrQEkMP7wXozIx/E"
	  "7aXzS8mKO6SKfqxlGm0ea/FeNgd45pgzNiUZT4IJ96g7qN5q9KabIY3SUpfV5ZYq8U6qDkWKIJ+rH7itcG9ZG/31/Wy31MCBeZnlVbcpdVHCQIILgVNQG2Em6iTNvV4VNOhgnhOWoMdrTrbUhBYOFb3RMj86KkY7W4XzZIVHyW+SHoqUwJDeOc55NWDam7PolW/bwPBNHR13dCVG/rQRB1zwxvf2GrYosbfSfSqu5M7LWNYLvSiqWDywY6"
	  "5N3BpoGDZDuoNEpy/7G++njZ0xAQ4ODeqhuv9EQ1S8sUe3CIjSG5UEa7VUirnnKVNy6iJjcTGXVGIHdBo0oLxAA3crvn//hw7+q/dQQpEBydj2FU3ifrmNEmzG1IT11L3BmNDrEaUzuAKTvTp7CzmwzPvpn+6s/aQbu0DcNlPHaXu19OqPgM1XYQFz26VWY+eoO5YPQiQPcdQ+WXis80U/tjSsh5RVMpN1sCAwEAAQ==" )  ; ----- DKIM key mail for mail.test.domain
```

### Create / Update / Delete users

```bash
mkdir configs
docker run --rm -it -v $(pwd)/configs:/tmp/docker-mailserver/  ghcr.io/docker-mailserver/docker-mailserver:latest setup email add test@test.domain
kubectl create secret generic -n docker-mailserver docker-mailserver-postfix-users --from-file configs/ --dry-run=client -o yaml  | kubectl apply -f -
```

#### Minimal configuration

Most of the values recorded belowe are set to sensible default, butyou'll definately want to pay attention to at least the following:

| Parameter                              | Description                                                                                                           | Default                |
|----------------------------------------|-----------------------------------------------------------------------------------------------------------------------|------------------------|
| `dockermailserver.override_hostname`   | The hostname to be presented on SMTP banners                                                                          | `mail.batcave.org`     |
| `domains`                              | List of domains to be served                                                                                          | `[]`                   |
| `ssl.issuer.name`                      | The name of the cert-manager issuer expected to issue certs                                                           | `letsencrypt-staging`  |
| `ssl.issuer.kind`                      | Whether the issuer is namespaced (`Issuer`) on cluster-wide (`ClusterIssuer`)                                         | `ClusterIssuer`        |
| `ssl.dnsname`                          | DNS domain used for DNS01 validation                                                                                  | `example.com`          |

#### Chart Configuration

The following table lists the configurable parameters of the docker-mailserver chart and their default values.

| Parameter                                     | Description                                                                                                                                                                          | Default                                              |
|-----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| `image.name`                                  | The name of the container image to use                                                                                                                                               | `mailserver/docker-mailserver`                       |
| `image.tag`                                   | The image tag to use (You may prefer "latest" over "v6.1.0", for example)                                                                                                            | `release-v6.1.0`                                     |
| `proxyProtocol.enabled`                       | Support HAProxy PROXY protocol on SMTP, IMAP(S), and POP3(S) connections. Provides real source IP instead of load balancer IP                                                        | `true`                                               |
| `proxyProtocol.trustedNetworks`               | The IPs (*in space-separated CIDR format*) from which to trust inbound HAProxy-enabled connections                                                                                   | `"10.0.0.0/8 192.168.0.0/16 172.16.0.0/16"`          |
| `spfTestsDisabled`                            | Disable all SPF-related spam checks (*if source IP of inbound connections is a problem, and you're not using haproxy*)                                                               | `false`                                              |
| `rblRejectDomains`                            | List extra RBL domains to use for hard reject filtering                                                                                                                              | `[]`                                                 |
| `domains`                                     | List of domains to be served                                                                                                                                                         | `[]`                                                 |
| `livenessTests.enabled`                       | Whether to execute liveness tests by running (arbitrary) commands in the docker-mailserver container. Useful to detect component failure (*i.e., clamd dies due to memory pressure*) | `true`                                               |
| `livenessTests.enabled`                       | Array of commands to execute in sequence, to determine container health. A non-zero exit of any command is considered a failure                                                      | `[ "clamscan /tmp/docker-mailserver/TrustedHosts" ]` |
| `dockermailserver.hostNetwork`                | Whether the pod should be connected to the "host" network (a primitive solution to ingress NAT problem)                                                                              | `false`                                              |                                              |
| `dockermailserver.replicas`                   | How many instances of the container to deploy (*only 1 supported currently*)                                                                                                         | `1`                                                  |
| `dockermailserver.hostPID`                    | Not really sure. TBD.                                                                                                                                                                | `None`                                               |                                           |
| `dockermailserver.securityContext.privileged` | Whether to run this pod in "privileged" mode.                                                                                                                                        | `false`                                              |
| `service.type`                                | What scope the service should be exposed in  (*LoadBalancer/NodePort/ClusterIP*)                                                                                                     | `NodePort`                                           |
| ~~`service.loadBalancer.loadBalancerIP`~~     | The IP to assign to the service (*if LoadBalancer*) scope selected above                                                                                                             | `None`                                               |
| `service.loadBalancer.allowedIps`             | The IPs allowed to access the sevice, in CIDR format (*if LoadBalancer*) scope selected above                                                                                        | `[ "0.0.0.0/0" ]`                                    |
| `service.nodeport.smtp`                       | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's SMTP port (25)                                                              | `30025`                                              |
| `service.nodeport.pop3`                       | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's POP3 port (110)                                                             | `30110`                                              |
| `service.nodeport.imap`                       | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's IMAP port (143)                                                             | `30143`                                              |
| `service.nodeport.smtps`                      | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's SMTPS port (465)                                                            | `30465`                                              |
| `service.nodeport.submission`                 | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's submission (*SMTP-over-TLS*) port (587)                                     | `30587`                                              |
| `service.nodeport.imaps`                      | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's IMAPS port (993)                                                            | `30993`                                              |
| `service.nodeport.pop3s`                      | The port exposed on the node the container is running on, which will be forwarded to docker-mailserver's IMAPS port (993)                                                            | `30995`                                              |
| `persistent.size`                             | How much space to provision for persistent storage                                                                                                                                   | `10Gi`                                               |
| `persistent.annotations`                      | Annotations to add to the persistent storage (*for example, to support [k8s-snapshots](https://github.com/miracle2k/k8s-snapshots)*)                                                 | `{}`                                                 |
| `ssl.issuer.name`                             | The name of the cert-manager issuer expected to issue certs                                                                                                                          | `letsencrypt-staging`                                |
| `ssl.issuer.kind`                             | Whether the issuer is namespaced (`Issuer`) on cluster-wide (`ClusterIssuer`)                                                                                                        | `ClusterIssuer`                                      |
| `ssl.dnsname`                                 | DNS domain used for DNS01 validation                                                                                                                                                 | `example.com`                                        |

#### docker-mailserver Configuration
##### environment variables
There are **many** environment variables which allow you to customize the behaviour of docker-mailserver. The function of each variable is described at https://github.com/docker-mailserver/docker-mailserver#environment-variables

Every variable can be set using `values.yaml`, but note that docker-mailserver expects any true/false values to be set as binary numbers (1/0), rather than boolean (true/false). BadThings(tm) will happen if you try to pass an environment variable as "true" when [`start-mailserver.sh`](https://github.com/docker-mailserver/docker-mailserver/blob/master/target/start-mailserver.sh) is expecting a 1 or a 0!

##### files
And the files below `extraConfigFiles` will be copied to pod config dir.
> unimplemented

#### postfix exporter metrics
* use dashboard :  https://grafana.com/grafana/dashboards/10013-postfix/

| Parameter                               | Description                                                                                  | Default                                                            |
|-----------------------------------------|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `metrics.enabled`                       | enable postfix exporter metrics for prometheus                                               | `false`                                                            |
| `metrics.resource.requests.memory`      | Initial share of RAM for metrics sidecar                                                     | `256Mi`                                                            |
| `metrics.resource.limits.memory`        | Maximum share of RAM for metrics sidecar                                                     | `null`                                                             |
| `metrics.resource.limits.cpu`           | Maximum share of CPU available for metrics                                                   | `null`                                                             |
| `metrics.resource.requests.cpu`         | Iniyial share of CPU available per-pod                                                       | `null`                                                             |
| `metrics.image.name`                    | The name of the container image to use                                                       | `blackflysolutions/postfix-exporter@sha256`                        |
| `metrics.image.tag`                     | The image tag. If use named tag, then remove @sha256 from name, else put sha256 signed value | `7ed7c0534112aff5b44757ae84a206bf659171631edfc325c3c1638d78e74f73` |
| `metrics.image.pullPolicy`              | pullPolicy                                                                                   | `IfNotPresent`                                                     |
| `metrics.serviceMonitor.enabled`        | generate serviceMonitor for metrics                                                          | `false`                                                            |
| `metrics.serviceMonitor.scrapeInterval` | default scrape interval                                                                      | `15s`                                                              |

