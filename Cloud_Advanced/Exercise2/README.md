# MPI service in Kubernetes

This folder contains the solution for the second exercise of the **Cloud Advanced** assignment, which requests to deploy and run the [OSU benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) inside two containers distributed in a two-nodes `kubernetes` cluster.

## Folder Structure

This folder is organized with the following structure:

``` bash

.
├── README.md # This file
├── Dockerfiles_MPI_OSU # Dockerfiles for the OSU benchmark container
│   ├── Dockerfile
│   ├── openmpi-builder.Dockerfile
│   ├── openmpi.Dockerfile
│   └── osu-code-provider.Dockerfile
├── OSU_benchmarks # OSU benchmark manifests and scripts
│   ├── Results # Folder to store the results of the benchmarks
│   │   └── Results.txt
│   ├── latency-one-node.yaml
│   ├── latency-two-nodes.yaml
│   ├── latency_one_node.sh
│   ├── latency_two_nodes.sh
│   ├── plot_results.ipynb # Jupyter notebook to plot the results
│   ├── scatter-one-node.yaml
│   ├── scatter-two-nodes.yaml
│   ├── scatter_one_node.sh
│   └── scatter_two_nodes.sh
├── common_initial_setup.sh # Common setup for both master and worker nodes
├── install_mpi_flannel.sh # Script to install MPI and Flannel on the master node
├── master_node_setup.sh # Script to setup the master node
└── worker_node_setup.sh # Script to setup the worker node

```

## Installation

To deploy and run the OSU benchmark, you first need to create two new virtual machines (VM) with `Kubernetes` and all the necessary components installed. Specifically, we need to build a two-nodes `Kubernetes` cluster.

### VM Setup

You first need to install two new VMs using a [Fedora39](https://fedoraproject.org/server/download) image. I used `UTM` to create the VMs, as my host machine runs on `macOS`, but you can use other virtualization tools like `VirtualBox` if you are using a different operating system. The important thing is to have two VMs with at least 2 CPUs and 2GB of RAM.

When creating the VMs, make sure to enable the root login via `SSH` in order to be able to easily access the VMs from your host machine.

After creating the VMs, you can access them via `SSH` using the following command:

``` bash

ssh root@<VM_IP>

```

### Initial Setup

Once you have access to the VMs, you need to copy the `common_initial_setup.sh` script to both VMs. You can do this by running the following command on your host machine:

``` bash

scp common_initial_setup.sh root@<VM_IP>:/root

```

Then, you can run the script on both VMs; it will install `Kubernetes` and all the necessary components and services on the VMs.

After this step, you have to copy the `Dockerfiles_MPI_OSU` folder to both VMs. You can do this by running the following command on your host machine:

``` bash

scp -r Dockerfiles_MPI_OSU root@<VM_IP>:/root/home

```

### Master Node Setup

After setting up the VMs, you need to choose one of them to be the master node. You can choose the first VM as the master node and the second VM as the worker node.

To setup the master node, you need to copy the `master_node_setup.sh` script to the master node. You can do this by running the following command on your host machine:

``` bash

scp master_node_setup.sh root@<VM_IP>:/root

```

Then, you can run the script on the master node; it will configure the master node of the `Kubernetes` cluster, prepare its environment and build the OSU benchmark container.

### Worker Node Setup

After setting up the master node, you need to copy the `worker_node_setup.sh` script to the worker node (second VM). You can do this by running the following command on your host machine:

``` bash

scp worker_node_setup.sh root@<VM_IP>:/root

```

Then, you can run the script on the worker node; it will configure the worker node of the `Kubernetes` cluster, prepare its environment and build the OSU benchmark container. Moreover, it will join the worker node to the master node to create the two-nodes `Kubernetes` cluster.

### Check the Cluster Status

After setting up the master and worker nodes, you can check the status of the cluster by running the following command on the master node, to see if both nodes are up and running:

``` bash

kubectl get nodes

```

You should see the two nodes of the cluster with the status `Ready`.

### MPI and Flannel Installation

After setting up the master and worker nodes, you need to install `MPI` and `Flannel` on the master node.
The `MPI` installation is required to run the OSU benchmark and the `Flannel` installation is necessary to create a network between the master and worker nodes.

To do so, you need to copy the `install_mpi_flannel.sh` script to the master node. You can do this by running the following command on your host machine:

``` bash

scp install_mpi_flannel.sh root@<VM_IP>:/root

```

Then, you can run the script on the master node; it will install `MPI` and `Flannel` on the master node.

> **Note:** the installation of `MPI` and `Flannel` has been done following the instructions provided in the official documentations.

After this step, you can check the status of the pods running in the cluster by running the following command:

``` bash

kubectl get pods --all-namespaces -o wide

```

Once all the pods are up and running, you should reboot the master node to avoid any issues with the `Flannel` network and apply the changes.

### OSU Benchmark Deployment and Execution

To deploy and run the OSU benchmark, you need to copy the `OSU_benchmarks` folder to the master node. You can do this by running the following command on your host machine:

``` bash

scp -r OSU_benchmarks root@<VM_IP>:/root/home

```

This folder contains the `yaml` manifests and `bash` scripts to run the OSU benchmark in the two-nodes `Kubernetes` cluster. Specifically, you can run the following four *benchmarks*:

- `latency-one-node`: to estimate the point to point latency between two workers running on the same node.
- `latency-two-nodes`: to estimate the point to point latency between two workers running on two different nodes.
- `scatter-one-node`: to estimate the latency of the scatter collective operation, by placing both workers on the same node.
- `scatter-two-nodes`: to estimate the latency of the scatter collective operation, by placing one worker pod on each node.

To run the *benchmarks*, you have to enter the `OSU_benchmarks` folder and execute the corresponding script. For example, to run the `latency-one-node` benchmark, you can run the following commands:

``` bash

cd /root/home/OSU_benchmarks

chmod +x latency_one_node.sh # Make the script executable

./latency_one_node.sh

```

In general, you can run the following commands to run the *benchmarks*:

``` bash

cd /root/home/OSU_benchmarks

chmod +x <script_name>.sh # Make the script executable

./<script_name>.sh

```

The script will deploy the OSU benchmark pods and run the benchmark. After running the benchmark, you can check the results in the `Results` folder: the results are stored in the `Results.txt` file.

### Plotting the Results

I provided a `Jupyter` notebook (`plot_results.ipynb`) to plot the results of the four *benchmarks*, visualize, analyze and compare them.
