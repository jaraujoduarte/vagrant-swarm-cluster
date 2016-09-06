# vagrant-swarm-cluster
A vagrant based implementation of a docker swarm cluster

## Services

There are 3 swarm services being deployed my-app (sinatra app), my-proxy (nginx proxy publishing), my-redis (redis backend) on the manager node, and my-busybox (busybox image for testing). For the sake of simplicity all the services except my-app are being deployed on the manager node.

## Technologies

The backbone of the solution is based on vagrant (plus virtualbox) for environments management and Docker Engine (on swarm mode) for containers/clustering. The provisioning tasks are mainly implemented with shell scripts.

## Requirements

This has been tested on a Windows machine with the following setup:

- Virtualbox 5.x
- Vagrant 1.8.5 
- Git bash bundled in the Git 2.5.1 installer (From which the scale/status scripts are issued)

The solution is expected to run on Linux with no issues (not really sure about OS X).

## Usage

From the root folder you will be able to run the following commands (from git bash if on windows):

### Build infrastructure

Creates and provisions VMs, and makes the first deployment of the my-app service (with 2 replicas). NOTE: If running on Windows, please keep an eye on messages poping up to request permissions for Virtualbox. If it hangs due to an unattended popup please either destroy the cluster or run "vagrant reload node_name[manager|node_1|node_2] --provision".

```
./cluster_up.sh
```

### Scale application

Scales the amount of tasks for the my-app service

```
./app_scale.sh number_of_replicas
```

### Application status

Shows on which nodes is the application currently replicated

```
./app_status.sh
```

### Destroy infrastructure

Shuts down VMs and removes its data.

```
./cluster_destroy.sh
```
