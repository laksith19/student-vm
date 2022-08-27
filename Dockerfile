# This configures the OS of the builder, NOT the OS of the actual image.
FROM ubuntu:22.04

ARG VM_NAME=cs162-student-vm
#Ubuntu Version
ARG UBUNTU_VERSION=jammy

WORKDIR /$VM_NAME

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    	curl \
        git \
        qemu-system-x86 \
        qemu-utils \
	cloud-image-utils \
    && rm -rf /var/cache/apt/lists/*

#
# BASE IMAGE.
#

# Dowload Ubuntu cloud image
RUN curl  -L -o "$VM_NAME.qcow2" https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

#
# Generate iso from cloud-init config files
#
COPY cloud-init/user-data user-data
COPY cloud-init/meta-data meta-data
RUN cloud-localds seed.iso user-data meta-data


#
# VM Configuration.
#

# Add 5Gigs of space to the image and run cloud init
RUN qemu-img resize "$VM_NAME.qcow2" +5G \ 
        && qemu-system-x86_64 \
	-smp 4\
        -m 8G\
        -nographic \
        -drive if=virtio,format=qcow2,file="$VM_NAME.qcow2" \
        -cdrom seed.iso 

# Generate OVA from disk image.
COPY ovf.template ovf.template
RUN qemu-img convert -f qcow2 -O vmdk -o subformat=streamOptimized "$VM_NAME.qcow2" "$VM_NAME.vmdk" \
    && sed "\
        s/{{ vm_id }}/$VM_NAME/g;\
        s/{{ disk_size }}/8589934592/g;\
        s/{{ disk_uuid }}/$(uuid)/g;\
    " < ovf.template > "$VM_NAME.ovf" \
    && tar -cv --format=ustar -f "$VM_NAME.ova" "$VM_NAME.ovf" "$VM_NAME.vmdk" \
    && rm -f "$VM_NAME.vmdk"
