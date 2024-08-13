# Cloud-Based File Storage System in Kubernetes

This folder contains the solution for the first exercise of the **Cloud Advanced** assignment, which consists of the deployment of a cloud-based file storage system in a single-node `Kubernetes` cluster. Specifically, the solution deploys a [Nextcloud](https://nextcloud.com/) instance with a `PostgreSQL` database and a `Redis` cache.

## Folder Structure

This folder is organized with the following structure:

``` bash

.
├── README.md # This file
├── deploy_nextcloud.sh # To deploy the Nextcloud instance
├── initial_setup.sh # To setup the k8s cluster on a VM
└── nextcloud # Nextcloud deployment manifests
    ├── metallb # MetalLB manifests
    │   ├── configmap.yaml
    │   ├── ipaddresspool.yaml
    │   └── l2advertisement.yaml
    ├── secrets # Secrets manifests
    │   ├── nextcloud-postgresql-secrets.yaml
    │   ├── nextcloud-redis-secrets.yaml
    │   └── nextcloud-secrets.yaml
    ├── values.yaml # Helm custom values for Nextcloud
    └── volumes # Volumes manifests
        ├── nextcloud-postgresql-pv.yaml
        ├── nextcloud-postgresql-pvc.yaml
        ├── nextcloud-pv.yaml
        └── nextcloud-pvc.yaml

```

## Deployment

To deploy the Nextcloud instance, you first need to create a new virtual machine (VM) with `Kubernetes` and all the necessary components installed. Specifically, we need to build a single-node `Kubernetes` cluster.

### VM Setup

You first need to install a new VM using a [Fedora39](https://fedoraproject.org/server/download) image. I used `UTM` to create the VM, but you can use any other virtualization tool. The important thing is to have a VM with at least 2 CPUs and 2GB of RAM.

When creating the VM, make sure to enable the root login via `SSH` in order to be able to easily access the VM from your host machine. 

After creating the VM, you can access it via `SSH` using the following command:

``` bash

ssh root@<VM_IP>

```

### Initial Setup

Once you have access to the VM, you first need to copy the `initial_setup.sh` script to the VM. You can do this by running the following command on your host machine:

``` bash

scp initial_setup.sh root@<VM_IP>:/root

```

Then, you can run the script on the VM; it will install `Kubernetes`, `Helm` and other necessary components on the VM and set up the `Kubernetes` single-node cluster and all the required environment.

You can check the status of the cluster either with the installed `k9s` tool or by running the following command:

``` bash

kubectl get nodes

```

You should see the single node of the cluster with the status `Ready`.

You can also check the status of the pods running in the cluster by running the following command:

``` bash

kubectl get pods --all-namespaces -o wide

```

### Nextcloud Deployment

After setting up the VM, you can deploy the Nextcloud instance. To do so, you first need to copy the `deploy_nextcloud.sh` script and the `nextcloud` folder to the VM. You can do this by running the following commands on your host machine:

``` bash

scp deploy_nextcloud.sh root@<VM_IP>:/root/home

scp -r nextcloud root@<VM_IP>:/root/home

```

Then, you can run the script on the VM; it will deploy the *Nextcloud* instance with a `PostgreSQL` database and a `Redis` cache. The script will also create a `MetalLB` load balancer to expose the *Nextcloud* instance to the outside world, define the necessary persistent volumes (`pv`) and persistent volume claims (`pvc`) and create the needed `secrets`.

>Note: the `deploy_nextcloud.sh` script assumes that the `nextcloud` folder is located in the `/root/home` directory. If you copied the folder to a different location, you need to update the script accordingly.

Specifically, the script will deploy the *Nextcloud* instance using the `Helm` package manager: the *Nextcloud* chart is installed with the custom values defined in the `values.yaml` file.

>Note: the installation of the `MetalLB` load balancer has been done following the instructions in the official documentation.

### Accessing Nextcloud

You can access the *Nextcloud* instance from your host machine web browser by port-forwarding the *Nextcloud* service, that the `Helm` chart has previously created, to the host machine itself.

First check that the *Nextcloud* service exists by running the following command on the VM:

``` bash

kubectl get svc -n nextcloud

```

You should have an output similar to the following one, with the load balancer service running with an IP given by `MetalLB`:

``` bash

NAME                                TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)          AGE
nextcloud-advanced                  LoadBalancer   10.104.87.11    192.168.121.200   8080:31250/TCP   4d

```

Then, you can port-forward the service to your host machine by running the following command on the VM:

``` bash

tmux new-session -d -s nextcloud-portforward "kubectl port-forward service/nextcloud-advanced 8080:8080 --address 0.0.0.0 -n nextcloud"

```

Finally, run the following command on your host machine:

``` bash

ssh root@<VM_IP> -L 8080:localhost:8080

```

You can now access the *Nextcloud* instance from your host machine by opening a web browser and navigating to `http://localhost:8080`. You should see the *Nextcloud* login page, where you can create a new account and start using the service.
