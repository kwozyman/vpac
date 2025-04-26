TAG ?= quay.io/cgament/vpac:bootc

default: build

build:
	podman build --file Containerfile \
			     --tag $(TAG)

push:
	podman push $(TAG)

