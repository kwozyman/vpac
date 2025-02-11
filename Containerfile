# Define the base image for the second stage

FROM registry.redhat.io/rhel9/rhel-bootc:latest

ARG EXTRA_RPM_PACKAGES="ansible-core"

RUN dnf autoremove -y

RUN mv /etc/selinux /etc/selinux.tmp && \
  dnf install -y ${EXTRA_RPM_PACKAGES} \
  # && dnf -y upgrade \
  && dnf clean all \
  && mv /etc/selinux.tmp /etc/selinux \
  && ln -s ../cloud-init.target /usr/lib/systemd/system/default.target.wants # Enable cloud-init

RUN mkdir -p /root/vpac/ || echo Exists

ADD . /root/vpac/

RUN ansible-playbook --connection=local -i localhost, /root/vpac/setup.yaml || echo "Some failures appeared"

# Setup /usr/lib/containers/storage as an additional store for images.
# Remove once the base images have this set by default.
RUN grep -q /usr/lib/containers/storage /etc/containers/storage.conf || \
  sed -i -e '/additionalimage.*/a "/usr/lib/containers/storage",' \
  /etc/containers/storage.conf


# Added for running as an OCI Container to prevent Overlay on Overlay issues.
VOLUME /var/lib/containers
