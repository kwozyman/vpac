# vPAC ABB SSC600 setup

These scripts will setup a virtual machine running ABB SSC600 on a single hypervisor.

## Prerequisites

### Hardware setup

First step is to make sure the hypervisor has the correct BIOS settings:

  * Disable Hyperthreading
  * Disable all power management
  * Disable Turbo Boost
  * Enable virtualization support (VMX/VT-X)

### OS initial deployment

You will need to manually install the hypervisor OS. Recommended install is `Red Hat 9.5 minimal`. OS deployment is out of scope for this document.

Make sure you can access the OS via ssh as root.

### Local setup

All the following steps are to be run on your local machine that should be able to connect to the hypervisor via ssh.

Make sure you can access the OS via ssh as root and setup your ssh key:

```
$ ssh-copy-id root@hypervisor
```

Make sure you have Ansible installed (this step varies with your distribution, example for Fedora/RHEL):

```
$ dnf install -y ansible-core
```

Install required Ansible roles:

```
$ ansible-galaxy role install linux-system-roles.bootloader linux-system-roles.kernel_settings linux-system-roles.timesync linux-system-roles.tuned
```

Clone this repo and change dir:

```
$ git clone git@github.com:kwozyman/vpac.git
$ cd vpac
```

## Setup variables based on your environment

You need to setup your own configuration values based on your environment. An example file is present in `vars/kalkitech.yaml` and it should be used as your starting point. First, copy this file in a different location:

```
$ cp vars/kalkitech.yaml vars.yaml
```

Next, edit the file `vars.yaml` and update the following variables:

  * `vpac_network` -> the static network configuration for the station (management) network
  * `rt_config` - options related to the RT core assignment and config
    * `non_rt_cores_cat` -> Non-RT cores _mask_
    * `rt_cores` -> RT cores _list_
    * `non_rt_cache_cat` -> IntelCAT config for Non-RT cores
    * `rt_cache` -> IntelCAT RT cores config
    * `cpumask` -> CPU Cores _mask_ to use for virtual network processes
    * `nic` -> The network interface to use for process (real-time) network
  * `tuned.rt_cores` -> _list_ of cores to isolate
  * `ssc600_ptp` - options related to the PTP config
    * `status_dir` -> directory to contain PTP status text file
    * `socket` -> PTP socket
    * `ptp4l_options` -> PTP4L options
  * `ssc600_vm` - options related to SSC600 vm
    * `name` -> vm name, should be in the form `ssc600-[1-9]`
    * `path` -> image directory path
    * `core[0-3]` -> vm core assignment. These should be fully inside the range defined in `tuned.rt_cores`
    * `core_qemu` -> cores to use for emulator. These should be fully inside the range defined in `tuned.rt_cores`
    * `rt_nic` -> the network interface to use for process bus (realtime). Generally it should be the same as `rt_config.nic`
  * `ssc600_bundle` - options about the ABB SSC600 archive
  * `timesync*` - `timemaster` service options. Generally should not be changed -- documentation available in `linux-system-roles.timesync` system role
  * `timesync_ntp_servers.hostname` -> local NTP server

## Download or copy bundle

ABB SSC600 archive should be downloaded or copied over to the hypervisor and the archive path set in `ssc600_bundle.path` variable. Refer to ABB website for download instructions.

## Run setup scripts

At this point, you should be able to run the automated scripts with a command similar to the following:

```
$ ansible-playbook -i hypervisor, vpac.yaml -e @vars.yaml
```
