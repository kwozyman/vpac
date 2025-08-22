PODMAN ?= /usr/bin/podman
PODMAN_ARGS ?= 
BASE_CONTAINER_IMAGE ?= quay.io/cgament/vpac:base
BIB_CONTAINER_IMAGE ?= registry.redhat.io/rhel10/bootc-image-builder:latest

default: help

help:
	@echo "Make system for Red Hat VPAC"
	@echo "Available targets:"
	@echo "  * help: show this help text"
	@echo "  * container-base: build base container"
	@echo "  * container-base-push: push base container to registry"
	@echo "  * entitle-host: add required Red Hat entitlements to the build host"
	@echo "  * unentitle-host: remove required Red Hat entitlements from the build host"
	@echo "  * build-iso: build a bootable ISO file from the base container image"

container-base:
	sudo $(PODMAN) build --file container-images/base/Containerfile \
		--volume /etc/yum.repos.d/:/etc/yum.repos.d/:ro,z --volume /etc/pki/entitlement/:/etc/pki/entitlement/:ro,z \
		--tag $(BASE_CONTAINER_IMAGE) $(PODMAN_ARGS)

container-base-push:
	podman push $(BASE_CONTAINER_IMAGE)

entitle-host:
	sudo subscription-manager repos --enable rhel-10-for-x86_64-rt-rpms
	sudo subscription-manager repos --enable rhel-10-for-x86_64-nfv-rpms

unentitle-host:
	sudo subscription-manager repos --disable rhel-10-for-x86_64-rt-rpms
	sudo subscription-manager repos --disable rhel-10-for-x86_64-nfv-rpms

build-iso:
	mkdir -p iso/
	sudo $(PODMAN) run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t \
		--volume $(PWD)/iso-config.toml:/config.toml:ro \
		--volume /var/lib/containers/storage:/var/lib/containers/storage \
		--volume $(PWD)/iso:/output \
		$(BIB_CONTAINER_IMAGE) \
			--type iso $(BASE_CONTAINER_IMAGE)
	@echo Generated file in iso/bootiso/install.iso

.PHONY: container-base container-base-push entitle-host unentitle-host build-iso
