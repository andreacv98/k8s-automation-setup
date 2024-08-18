# Kubernetes Cluster Deployment

## Objective

Provision a Kubernetes cluster consisting of a manager and
two workers and deploy an application consisting of at least three services and
presenting a graphical user interface accessible via a browser.

## Virtual Machines Setup

The Kubernetes cluster is deployed on three virtual machines, one manager and two workers. The virtual machines are provisioned using Vagrant and VirtualBox.

The choice of Vagrant is motivated by the fact that it is a tool that allows the creation and configuration of lightweight, reproducible, and portable development environments. It is also a tool that is easy to use and that allows the automation of the creation of virtual machines.

## Ansible Playbooks

Along with the Vagrantfile, there are Ansible playbooks that are used to provision the virtual machines. The playbooks are used to install the necessary software packages and to configure the virtual machines.

The specific tasks have been defined following the best practices for the deployment of Kubernetes clusters, in particular the requirements for a RKE cluster. More information can be found [here](https://rke.docs.rancher.com/os#general-linux-requirements)

## Terraform

The Terraform script is used to provide the Kubernetes RKE cluster upon the virtual machines. The script is used to create the cluster and to deploy the required namespaces and benchmarks.

### Rancher Kubernetes Engine (RKE)

The choice of RKE is motivated by the fact that it is a Kubernetes distribution that is easy to use and that provides a good balance between simplicity and flexibility. Moreover the usage upon the virtual machines is straightforward and well-documented for the integration in the Terraform script.

### RKE Provider

The RKE provider is used to create an Rancher Kubernetes Engine (RKE) cluster. The provider allows the creation of a Kubernetes cluster using a YAML configuration file, that can be found in the `cluster.yml` file [here](./terraform/cluster.yaml).

### Security Benchmark

The Terraform script provides the deployment of the `kube-bench` security benchmark. The benchmark is a Go application that checks whether Kubernetes is deployed according to security best practices. The benchmark is deployed in the `default` namespace.

The choice of the `kube-bench` benchmark is motivated by the fact that it is a tool that is easy to use and that provides a good overview of the security of the Kubernetes cluster. It is widely used in the Kubernetes community and is a good starting point for the security of a Kubernetes cluster.

## Application Deployment

The application designated for deployment is the Google Online Boutique. The application is a cloud-native microservices demo application that is used to demonstrate the use of Kubernetes. The application is composed of several services, including a frontend service that presents a graphical user interface accessible via a browser.

The application can be deployed through an Helm chart in the local repository. The Helm chart is used to deploy the application in the `default` namespace.

You can deploy the application by running the following command:

```bash
helm install online-boutique ./helm/online-boutique
```

## Application update

The application can be updated by running the following command:

```bash
helm upgrade online-boutique ./helm/online-boutique
```