# rpi-k8s-cluster
My HA Kubernetes cluster on Raspberry Pi

![](docs/rpi-cluster.jpg)

<!-- TOC -->

- [rpi-k8s-cluster](#rpi-k8s-cluster)
  - [Architecture](#architecture)
  - [Materials](#materials)
  - [Step 1: Prepare SD cards with the Ubuntu Server OS](#step-1-prepare-sd-cards-with-the-ubuntu-server-os)
    - [1.1. Install the Ubuntu 20.04.4 LTS 64 using the Raspberry Imager tool](#11-install-the-ubuntu-20044-lts-64-using-the-raspberry-imager-tool)
    - [1.2. Change the password for all nodes](#12-change-the-password-for-all-nodes)
  - [Step 2: Configure the cluster](#step-2-configure-the-cluster)
    - [2.1. Configure the `cluster.yml` file](#21-configure-the-clusteryml-file)
    - [2.2. Check all hosts are accessible via SSH](#22-check-all-hosts-are-accessible-via-ssh)
    - [2.3. Update and upgrade OS](#23-update-and-upgrade-os)
    - [2.4. Overclocking all RPI nodes](#24-overclocking-all-rpi-nodes)
  - [Manage the Kubernetes (K8S) cluster](#manage-the-kubernetes-k8s-cluster)
    - [Create the K8S cluster](#create-the-k8s-cluster)
    - [Upgrade the K8S cluster](#upgrade-the-k8s-cluster)
    - [Destroy the K8S cluster](#destroy-the-k8s-cluster)

<!-- /TOC -->

## Architecture


## Materials

* 6 Raspberry PI 4B for the Kubernetes (K8S) cluster
  - 3 RPI 4B 4Go for master nodes
  - 3 RPI 4B 8Go for worker nodes
* 1 Raspberry PI 3B+ for the load balancer (LBA) node
* 7 SD cards
  - 1 => 32G (for LBA)
  - 6 => 128G (for K8S cluster)
* 1 Ethernet Network Switch with 8 ports
- 1 Wireless Portable/Travel router
* 1 USB charger 60W with 8 usb ports
- 1 Raspberry PI cluster case
- 6 USB-C cables for RPI 4B
- 2 USB-A cables (LBA and Wifi router)
- 8 RJ45 cables Cat. 6

## Step 1: Prepare SD cards with the Ubuntu Server OS

### 1.1. Install the Ubuntu 20.04.4 LTS 64 using the [Raspberry Imager](https://www.raspberrypi.com/software/) tool

![](docs/rpi-imager-2.png)


### 1.2. Change the password for all nodes

The default password of the ubuntu user is `ubuntu`.

```
ssh ssh ubuntu@10.11.13.21

...
...
...

New password:
Retype new password:
passwd: password updated successfully
Connection to 10.11.13.23 closed.
```

Set the new password and reconnect with ssh.



## Step 2: Configure the cluster
### 2.1. Configure the `cluster.yml` file

In this step, i will configure the Ansible inventory file ([cluster.yml](cluster.yml)) to match with my RPI cluster.

```yaml
all:
  vars:
    ansible_connection: ssh
    ansible_user: ubuntu
    ansible_ssh_pass: raspberry
    ansible_become: true
    ansible_become_user: root
    ansible_python_interpreter: /usr/bin/python3
  hosts:
    rpi-k8s-lba-01:
      ansible_host: 10.11.13.20
    rpi-k8s-master-01:
      ansible_host: 10.11.13.21
    rpi-k8s-master-02:
      ansible_host: 10.11.13.22
    rpi-k8s-master-03:
      ansible_host: 10.11.13.23
    rpi-k8s-worker-01:
      ansible_host: 10.11.13.31
    rpi-k8s-worker-02:
      ansible_host: 10.11.13.32
    rpi-k8s-worker-03:
      ansible_host: 10.11.13.33
  children:
    load_balancer:
      hosts:
        rpi-k8s-lba-01:
      vars:
        node: "lba"
        # List of backend servers.
        backend_servers:
          - name: rpi-k8s-master-01
            address: 10.11.13.21
          - name: rpi-k8s-master-02
            address: 10.11.13.22
          - name: rpi-k8s-master-03
            address: 10.11.13.23
    master:
      hosts:
        rpi-k8s-master-01:
          primary_master: true
          lba_ip: 10.11.13.20
        rpi-k8s-master-02:
        rpi-k8s-master-03:
      vars:
        node: "master"
    worker:
      hosts:
        rpi-k8s-worker-01:
        rpi-k8s-worker-02:
        rpi-k8s-worker-03:
      vars:
        node: "worker"
...
```

### 2.2. Check all hosts are accessible via SSH

I use the ansible playbook `check.yml` to check all the cluster hosts.

```
ansible-playbook -i cluster.yml ansible/playbooks/check.yml

...
rpi-k8s-lba-01             : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-k8s-master-01          : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-k8s-master-02          : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-k8s-master-03          : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-k8s-worker-01          : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-k8s-worker-02          : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-k8s-worker-03          : ok=15   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
``` 

All the cluster nodes are OK ;)

### 2.3. Update and upgrade OS

Now, i use the ansible playbook `upgrade.yml` to upgrade OS before creating the Kubernetes cluster.

```
ansible-playbook -i cluster.yml ansible/playbooks/upgrade.yml
```

It takes a few minutes to upgrade all the cluster nodes.

### 2.4. Overclocking all RPI nodes

I overclock all the RPI nodes with the ansible playbook `overclock.yml`.

```
ansible-playbook -i cluster.yml ansible/playbooks/overclock.yml
```

## Manage the Kubernetes (K8S) cluster

### Create the K8S cluster

```
ansible-playbook -i cluster.yml ansible/site.yml
```

### Upgrade the K8S cluster



### Destroy the K8S cluster