# Kalkitech vPAC setup

Dependencies:

```
dnf install ansible-core
ansible-galaxy role install linux-system-roles.bootloader linux-system-roles.timesync
```

Run all the setup:

```
ansible-playbook -i hostname, vpac.yaml
```