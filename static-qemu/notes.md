
## Overview

- We want to emulate firmware X.

  - To emulate firmware we'll need the ability to build qemu cleanly.
    - We want to build qemu, so we can add machines and peripherals.
    - We want to build qemu statically so that we don't have to deal with containerization complexity.
    - To build qemu repeatably, we use a docker container for a standard environment.
    - To build qemu statically, we need to:

      - Build a static toolchain and static libc.
      - Build a number of static libraries (e.g. libudev).
      - Disable/Defer all the features we don't have static libraries for.
  
  - To emulate firmware userspace:

    - To build the kernel for a static userspace:

      - Kernel needs to be 'static' ... no loadable module support.
      - Kernel version needs to be at least as older as original kernel.
      - Toolchain must provide compiler that is old enough to build kernel.
    
    - To build userspace tools for firmware userspace:

      - Toolchain must provide static libc.
      - Toolchain's libc must provide 'old enough' kernel headers.
  
  - To emulate firmware userspace in linux versions < 3.10:

    - Need to use VM or container with qemu to emulate:

      - Build everything with old kernel (2.4, 2.2, non-Linux).
      - Build everything with non-host arch (i386, sparc).

- Obstacles and things we want to avoid:

  - Patching upstream code.
  - Upstream code without static build targets.

    - May _eventually_ need patching.


## Notes


`tar -xf qemu-7.0.0.tar.xz`

`cd qemu-7.0.0`

`./configure --prefix=/opt/qemu`

```sh
./configure --prefix=/opt/qemu --static \
  --cross-prefix=x86_64-static_multilib-linux-gnu- \
  --target-list=mipsel-linux-user,mipsel-softmmu \
  --disable-gtk --disable-alsa --disable-libdaxctl --disable-smartcard \
  --disable-sdl --disable-sdl-image --disable-slirp --disable-usb-redir \
  --disable-gnutls --disable-curl --disable-libusb --disable-glusterfs \
  --disable-spice --disable-xkbcommon --disable-opengl \
  --disable-virglrenderer --disable-pa --disable-brlapi
```

# qemu passes cross prefix to pkg-config too
```sh
mkdir native-xtools ; pushd native-xtools
ln -s /usr/bin/pkg-config x86_64-static_multilib-linux-gnu-pkg-config
popd ; export PATH=$PATH:$(pwd)/native-xtools
```

```sh
OUR_TC_PREFIX=/opt/x-tools
OUR_TC_PREFIX=${OUR_TC_PREFIX}/binutils-2.32-gcc-8.3.0-linux-4.20.8-glibc-2.28
OUR_TC_PREFIX=${OUR_TC_PREFIX}/x86_64-static_multilib-linux-gnu
OUR_TC_PREFIX=${OUR_TC_PREFIX}/x86_64-static_multilib-linux-gnu
OUR_TC_LIB64=${OUR_TC_PREFIX}/sysroot/usr/lib64
OUR_TC_INC=${OUR_TC_PREFIX}/sysroot/usr/include
HOST_TC_LIB64=/usr/lib/x86_64-linux-gnu
HOST_TC_INC=/usr/include
HOST_ARCH_INC=/usr/include/x86_64-linux-gnu

./configure --prefix=/opt/qemu --static \
  --extra-cflags="-I${OUR_TC_INC} -I${HOST_TC_INC} -I${HOST_ARCH_INC}" \
  --extra-ldflags="-L${OUR_TC_LIB64} -L${HOST_TC_LIB64}" \
  --cross-prefix=x86_64-static_multilib-linux-gnu- \
  --target-list=mipsel-linux-user,mipsel-softmmu \
  --disable-gtk --disable-alsa --disable-libdaxctl --disable-smartcard \
  --disable-sdl --disable-sdl-image --disable-slirp --disable-usb-redir \
  --disable-gnutls --disable-curl --disable-libusb --disable-glusterfs \
  --disable-spice --disable-xkbcommon --disable-opengl \
  --disable-virglrenderer --disable-pa --disable-brlapi
```

# Need gcc-7.4 to build qemu


`git clone https://github.com/systemd/systemd.git`
`cd systemd`

For systemd:
gperf libcap-dev

`meson setup build`
`meson compile -C build version.h`
`meson compile -C build udev:static_library`


export PKG_CONFIG_PATH=/opt/pkgs


```
# /opt/pkgs/libudev.pc
prefix=/opt/systemd/
exec_prefix=/opt/systemd/build/
libdir=/opt/systemd/build/
includedir=/opt/systemd/src/libudev/

Name: libudev
Description: Library to access udev device information
Version: main
Libs: -L${libdir} -ludev
Libs.private: -lrt -pthread
Cflags: -I${includedir}
```

./build/libudev.a
./src/libudev/libudev.h

# !! Note: usbredir has no upstream static target. !!
git clone https://gitlab.freedesktop.org/spice/usbredir.git

# !! Note: libslirp has no upstream static target. !!
# for libslirp
`git clone https://gitlab.freedesktop.org/slirp/libslirp.git`
cd libslirp
meson setup build

# !! Note: libdaxctl has no upstream static target. !!
# for libdaxctl
# apt-get install cmake libkmod-dev libjson-c-dev asciidoctor udev libkeyutils-dev libiniparser-dev bash-completion
`git clone https://github.com/pmem/ndctl.git`


    lzo support                  : NO
    snappy support               : NO
    bzip2 support                : NO
    lzfse support                : NO   
    libnfs support               : NO 
    U2F support                  : NO
    rbd support                  : NO
    bpf support                  : NO
    netmap support               : NO
    vde support                  : NO
    brlapi support               : NO
    Multipath support            : NO
    PAM                          : NO
    SDL image support            : NO
    libgcrypt                    : NO
    nettle                       : NO
    AF_ALG support               : NO
    rng-none                     : NO
    Use block whitelist in tools : NO
    TCG plugins                  : NO
    TCG debug enabled            : NO
    KVM support                  : NO
    HAX support                  : NO
    HVF support                  : NO
    WHPX support                 : NO
    NVMM support                 : NO
    avx512f optimization         : NO
    gprof enabled                : NO
    gcov                         : NO
    thread sanitizer             : NO
    CFI support                  : NO
    strip binaries               : NO
    sparse                       : NO
    mingw32 support              : NO

    membarrier                   : NO
    debug stack usage            : NO
    mutex debugging              : NO
    profiler                     : NO
    link-time optimization (LTO) : NO
    D-Bus display                : NO
    QOM debugging                : NO
    module support               : NO
    fuzzing support              : NO

    Program qemu-keymap found: NO

WARNING: Static library 'slirp' not found for dependency 'slirp', may not be statically linked




WARNING: Static library 'usbredirparser' not found for dependency 'libusbredirparser-0.5', may not be statically linked
WARNING: Static library 'udev' not found for dependency 'libusb-1.0', may not be statically linked
WARNING: Static library 'unistring' not found for dependency 'gnutls', may not be statically linked
WARNING: Static library 'p11-kit' not found for dependency 'gnutls', may not be statically linked
WARNING: Static library 'gbm' not found for dependency 'gbm', may not be statically linked
WARNING: Static library 'gfapi' not found for dependency 'glusterfs-api', may not be statically linked
WARNING: Static library 'glusterfs' not found for dependency 'glusterfs-api', may not be statically linked
WARNING: Static library 'gfrpc' not found for dependency 'glusterfs-api', may not be statically linked
WARNING: Static library 'gfxdr' not found for dependency 'glusterfs-api', may not be statically linked
WARNING: Static library 'spice-server' not found for dependency 'spice-server', may not be statically linked


WARNING: Static library 'cacard' not found for dependency 'libcacard', may not be statically linked
WARNING: Static library 'nss3' not found for dependency 'libcacard', may not be statically linked
WARNING: Static library 'nssutil3' not found for dependency 'libcacard', may not be statically linked
WARNING: Static library 'smime3' not found for dependency 'libcacard', may not be statically linked
WARNING: Static library 'ssl3' not found for dependency 'libcacard', may not be statically linked
WARNING: Static library 'pcsclite' not found for dependency 'libcacard', may not be statically linked
WARNING: Static library 'vte-2.91' not found for dependency 'vte-2.91', may not be statically linked
WARNING: Static library 'gtk-3' not found for dependency 'vte-2.91', may not be statically linked
WARNING: Static library 'atk-bridge-2.0' not found for dependency 'vte-2.91', may not be statically linked
WARNING: Static library 'atspi' not found for dependency 'vte-2.91', may not be statically linked
WARNING: Static library 'systemd' not found for dependency 'vte-2.91', may not be statically linked
WARNING: Static library 'gtk-3' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'atk-bridge-2.0' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'atspi' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'systemd' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'gdk-3' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'xkbcommon' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'wayland-cursor' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'wayland-egl' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'wayland-client' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'epoxy' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'GL' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'EGL' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'pangocairo-1.0' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'pangoft2-1.0' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'pango-1.0' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'graphite2' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'atk-1.0' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'gdk_pixbuf-2.0' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'webp' not found for dependency 'gtk+-x11-3.0', may not be statically linked
WARNING: Static library 'mount' not found for dependency 'gtk+-x11-3.0', may not be statically linked

Has header "bzlib.h" : NO
Has header "lzfse.h" : NO


Library rados found: NO

WARNING: Static library 'asound' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'pulse-simple' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'pulse' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'drm' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'gbm' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'wayland-egl' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'wayland-client' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'wayland-cursor' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'xkbcommon' not found for dependency 'sdl2', may not be statically linked
WARNING: Static library 'decor-0' not found for dependency 'sdl2', may not be statically linked

WARNING: Static library 'nghttp2' not found for dependency 'libcurl', may not be statically linked
WARNING: Static library 'rtmp' not found for dependency 'libcurl', may not be statically linked
WARNING: Static library 'psl' not found for dependency 'libcurl', may not be statically linked
WARNING: Static library 'gssapi_krb5' not found for dependency 'libcurl', may not be statically linked
WARNING: Static library 'lber' not found for dependency 'libcurl', may not be statically linked
WARNING: Static library 'ldap' not found for dependency 'libcurl', may not be statically linked

WARNING: Static library 'virglrenderer' not found for dependency 'virglrenderer', may not be statically linked


WARNING: Static library 'asound' not found for dependency 'alsa', may not be statically linked

WARNING: Static library 'pulse' not found for dependency 'libpulse', may not be statically linked
WARNING: Static library 'pulsecommon-15.99' not found for dependency 'libpulse', may not be statically linked

WARNING: Static library 'xkbcommon' not found for dependency 'xkbcommon', may not be statically linked