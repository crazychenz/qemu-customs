FROM ubuntu:22.04

# If libterm-readline-gnu-perl is installed and the following is not set,
# a docker build will ask for input. Also, apt-get build-dep ignores this.
ENV DEBIAN_FRONTEND=noninteractive

# Optionally set debian configuration for noninteractive.
#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# - Install tzdata first to prevent noninteractive from occuring later in 
#   docker build process.
# - Install apt-utils to squlech warnings.
# - Install sudo for limited root access from user.
RUN apt-get update && apt-get install -y apt-utils tzdata sudo

# Enable the source repositories so we can fetch debian qemu source deps.
RUN sed -i 's/^# deb-src /deb-src /' /etc/apt/sources.list

# - The long apt-cache showsrc subshell command is dynamically fetching the
#   dependencies to build debian's build of qemu-6. If we use 
#   `apt-get build-dep` we run the risk of it ignoring DEBIAN_FRONTEND.
# - Installing devscripts gives us `debuild`.
RUN apt-get update && apt-get install -y \
    $(apt-cache showsrc qemu | grep Build-Depends | sed 's/, /\n/g' | grep -v Build-Depends | cut -d ' ' -f1 | tr '\n' ' ') \
    devscripts
RUN apt-get install -y libsdl2-dev libsdl2-image-dev zlib1g-dev libfdt-dev \
    libbz2-dev libp11-kit-dev libunistring-dev valgrind libcapstone-dev \
    gobjc-11 acpica-tools genisoimage

# # RUN apt-get update && apt-get install -y \
# #     gcc g++ libc6-dev make dpkg-dev libncurses5-dev bison flex \
# #     rsync python3 sudo \
# #     ninja-build pkg-config libglib2.0-dev libpixman-1-dev libsdl2-dev \
# #     libsdl2-image-dev zlib1g-dev libfdt-dev libaio-dev libbluetooth-dev \
# #     libbrlapi-dev libbz2-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev \
# #     libibverbs-dev libjpeg8-dev libncurses5-dev libnuma-dev librbd-dev \
# #     librdmacm-dev libsasl2-dev libsdl2-dev libseccomp-dev libsnappy-dev \
# #     libssh-dev libvde-dev libvdeplug-dev libvte-2.91-dev libxen-dev 
# #     liblzo2-dev valgrind xfslibs-dev curl libnfs-dev libiscsi-dev \
# #     libfuse-dev libdaxctl-dev libpmem-dev libzstd-dev libusb-1.0-0-dev \    
# #     librbd-dev libspice-protocol-dev libbpf-dev ibverbs-providers rdma-core \
# #     liburing-dev libbrlapi-dev libjack-dev libmptcpd3-dev \
# #     libvirglrenderer-dev libpam0g-dev libgcrypt20-dev ibcrypto++-dev \
# #     libkcapi-dev nettle-dev libfuse3-dev liblz4-dev libgbm-dev \
# #     libusbredirparser-dev libusb-dev libspice-server-dev nmap rbd-nbd \
# #     opensc-pkcs11 libpam-pkcs11 pcscd libp11-kit-dev libunistring-dev

# # --build=binary --unsigned-source --unsigned-changes --no-sign

# Allow sudoers to sudo without passwords.
RUN sed -i 's/ALL=(ALL:ALL) ALL/ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# User defaults, ideally setup to match existing user's info with `whoami` and `id`.
ARG uid=1000
ARG gid=1000
ARG username=user
ARG groupname=user
ARG groups=user

# Create and change ownership of /opt to user.
WORKDIR /opt
RUN chown -R ${uid}:${gid} /opt

RUN addgroup --gid ${gid} ${groupname}
RUN adduser --home /opt --system --disabled-password --uid ${uid} --gid ${gid} ${username}
RUN adduser ${username} sudo

USER ${uid}:${gid}

# libudev 