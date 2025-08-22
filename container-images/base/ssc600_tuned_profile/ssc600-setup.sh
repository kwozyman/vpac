#!/usr/bin/bash

# include generic tuned functions
. /usr/lib/tuned/functions

# include SSC600 specific variables
if [[ -f /etc/default/ssc600 ]]; then
	. /etc/default/ssc600
else
	return 1
fi

intel_cat() {
	echo "Partitioning the cache"
	pqos -e "llc:0=$NON_RT_CACHE;llc:1=$RT_CACHE"
	pqos -a "llc:1=$RT_CORES"
}

process_bus() {
	echo "Configuring network card interrupts and threads"
	for nic in $NICS
	do
		echo "Disabling NIC power management"
		ethtool --set-eee $nic eee off || echo EEE failed or not supported
		ethtool --change $nic wol d
		echo on > /sys/class/net/$nic/power/control
		IRQS=$(grep $nic /proc/interrupts | cut -d':' -f1)
		for irq in $IRQS
		do
		echo $CPUMASK | tee /proc/irq/$irq/smp_affinity
		tasks=$(ps axo pid,command | grep -e "irq/$irq-" | grep -v grep | awk '{print $1}')
		for pid in $tasks
		do
		 taskset -p "0x$CPUMASK" $pid
		done
		done
	done
}

start() {
	# Disable swap
	swapoff -a
	intel_cat
	process_bus
	return 0
}

stop() {
    return 0
}

process $@

