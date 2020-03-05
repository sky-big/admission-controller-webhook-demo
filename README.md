# Kubernetes Admission Controller Webhook Demo

This repository contains a small HTTP server that can be used as a Kubernetes
[MutatingAdmissionWebhook](https://kubernetes.io/docs/admin/admission-controllers/#mutatingadmissionwebhook-beta-in-19).

The logic of this demo webhook is fairly simple: it enforces more secure defaults for running
containers as non-root user. While it is still possible to run containers as root, the webhook
ensures that this is only possible if the setting `runAsNonRoot` is *explicitly* set to `false`
in the `securityContext` of the Pod. If no value is set for `runAsNonRoot`, a default of `true`
is applied, and the user ID defaults to `1234`.

## Prerequisites

A cluster on which this example can be tested must be running Kubernetes 1.9.0 or above,
with the `admissionregistration.k8s.io/v1beta1` API enabled. You can verify that by observing that the
following command produces a non-empty output:
```
kubectl api-versions | grep admissionregistration.k8s.io/v1beta1
```
In addition, the `MutatingAdmissionWebhook` admission controller should be added and listed in the admission-control
flag of `kube-apiserver`.

For building the image, [GNU make](https://www.gnu.org/software/make/) and [Go](https://golang.org) are required.

## Deploy

```
$ make push-image
$ make deploy
```

## UnDeploy

```
$ make undeploy
```

## Verify

1. The `webhook-server` pod in the `webhook-demo` namespace should be running:
```
$ kubectl -n webhook-demo get pods
NAME                             READY     STATUS    RESTARTS   AGE
webhook-server-6f976f7bf-hssc9   1/1       Running   0          35m
```

2. A `MutatingWebhookConfiguration` named `demo-webhook` should exist:
```
$ kubectl get mutatingwebhookconfigurations
NAME           AGE
demo-webhook   36m
```

3. Deploy [a pod](examples/test.yaml)
```
$ kubectl create -f examples/test.yaml
$ kubectl get pods
NAME                                                            READY   STATUS      RESTARTS   AGE
my-test-0                                                       1/1     Running     0          3m46s
```

4. verify pod label
```
$ kubectl describe pod my-test-0
Name:           my-test-0
Namespace:      default
Priority:       0
Node:           k8s-node-vmxo4g-v9nu5bkh1a/172.16.224.5
Start Time:     Thu, 05 Mar 2020 20:12:19 +0800
Labels:         admission.test.admission=hello-world
                app=nginx
                controller-revision-hash=my-test-5d85c59ddf
                statefulset.kubernetes.io/pod-name=my-test-0
Annotations:    <none>
Status:         Running
IP:             172.16.192.22
IPs:            <none>
Controlled By:  StatefulSet/my-test
Containers:
  nginx:
    Container ID:   docker://e5350a35fcbc1f7ef6817665060eb26bf2262b79e52b530dee12cc28a742651e
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:2539d4344dd18e1df02be842ffc435f8e1f699cfc55516e2cf2cb16b7a9aea0b
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 05 Mar 2020 20:12:35 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-2tdts (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  default-token-2tdts:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-2tdts
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From                                 Message
  ----    ------     ----   ----                                 -------
  Normal  Scheduled  5m13s  default-scheduler                    Successfully assigned default/my-test-0 to k8s-node-vmxo4g-v9nu5bkh1a
  Normal  Pulling    5m12s  kubelet, k8s-node-vmxo4g-v9nu5bkh1a  Pulling image "nginx"
  Normal  Pulled     4m57s  kubelet, k8s-node-vmxo4g-v9nu5bkh1a  Successfully pulled image "nginx"
  Normal  Created    4m57s  kubelet, k8s-node-vmxo4g-v9nu5bkh1a  Created container nginx
  Normal  Started    4m57s  kubelet, k8s-node-vmxo4g-v9nu5bkh1a  Started container nginx
```

label `admission.test.admission=hello-world` add Successfully
