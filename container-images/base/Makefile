TAG ?= quay.io/cgament/vpac:bootc

default: build

build:
	sudo podman build --file Containerfile \
		--volume /etc/yum.repos.d/:/etc/yum.repos.d/:ro,z --volume /etc/pki/entitlement/:/etc/pki/entitlement/:ro,z \
		--tag $(TAG)

build-iso:
	sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t \
		--volume $(PWD)/iso-config.toml:/config.toml:ro \
		--volume /var/lib/containers/storage:/var/lib/containers/storage \
		--volume $(PWD)/iso:/output \
		registry.redhat.io/rhel10/bootc-image-builder:latest \
			--type iso $(TAG)

entitle-host:
	sudo subscription-manager repos --enable rhel-10-for-x86_64-rt-rpms
	sudo subscription-manager repos --enable rhel-10-for-x86_64-nfv-rpms

unentitle-host:
	sudo subscription-manager repos --disable rhel-10-for-x86_64-rt-rpms
	sudo subscription-manager repos --disable rhel-10-for-x86_64-nfv-rpms

push:
	podman push $(TAG)

