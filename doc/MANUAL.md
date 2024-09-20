# Introduction

This Package forms part of the seL4 Developer Kit. It provides a fully
coordinated build of a MaaXBoard Microkit program which leverages BuildRoot
(embedded Linux build facility) and libvmm (virtual machine monitor for the
seL4 microkernel) to provide two virtualised Linux Guests, each interacting
with a virtual UART (virtio-console), being controlled via a switchable
multiplexed UART, connected to the physical UART.

# Usage

Must be invoked inside the following:
* sel4devkit-maaxboard-microkit-docker-dev-env

Show usage instructions:
```
make
```

Build:
```
make get
make all
``` 

Where executed on the MaaXBoard, both Virtualised Linux Guests execute in
parallel. As such, during boot, output from both Linux Guests will be
presented at the same time, which can look muddled. Once booted and stable,
each Linux Guest may be interacted with as desired. To select which Linux
Guest shall receive input, type either "@1" or "@2".

## Retain Previously Built Output 

For consistency and understanding, it is generally desirable to be able to
build from source. However, in this instance, the build process can be
particularly time consuming. As a concession, the build output is prepared in
advance, and retained in the Package. Where this previously built output is
present, it shall block a rebuild. If the previously built output be removed
(`make reset`), then a rebuild may be triggered (`make all`).

The retention of build artefacts is ordinarily avoided, and this is reflected
in the configured set of file types to be ignored. As such, following a
rebuild, to examine and retain the resulting content (including build
artefacts), instruct git as follows:

Examine all files, including any that are ordinarily ignored:
```
git status --ignored
```

Force the addition of files, even if they ordinarily ignored:
```
git add --force <Path Files>
```
