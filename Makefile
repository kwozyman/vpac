PODMAN ?= /usr/bin/podman
PODMAN_ARGS ?= 
BASE_CONTAINER_IMAGE ?= quay.io/cgament/vpac:base

default: help

help:
	@echo "Make system for Red Hat VPAC"
	@echo "Available targets:"
	@echo "  * help: show this help text"
	@echo "  * container-base: build base container"
	@echo "  * container-base-push: push base container to registry"
	@echo "  * entitle-host: add required Red Hat entitlements to the build host"
	@echo "  * unentitle-host: remove required Red Hat entitlements from the build host"

container-base:
	sudo podman build --file container-images/base/Containerfile \
		--volume /etc/yum.repos.d/:/etc/yum.repos.d/:ro,z --volume /etc/pki/entitlement/:/etc/pki/entitlement/:ro,z \
		--tag $(BASE_CONTAINER_IMAGE)

container-base-push:
	podman push $(BASE_CONTAINER_IMAGE)

entitle-host:
	sudo subscription-manager repos --enable rhel-10-for-x86_64-rt-rpms
	sudo subscription-manager repos --enable rhel-10-for-x86_64-nfv-rpms

unentitle-host:
	sudo subscription-manager repos --disable rhel-10-for-x86_64-rt-rpms
	sudo subscription-manager repos --disable rhel-10-for-x86_64-nfv-rpms


.PHONY: container-base container-base-push entitle-host unentitle-host
