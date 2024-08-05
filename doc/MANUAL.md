## Introduction

This repo demonstrates the ability to load two linux guest VM's simaltaneously with serial I/O to both of them via the means of a switch. The target board for this repo is the maaxboard. This project makes use of libvmm and has reowrked the following examples in the below repo to work with the maaxboard:

https://github.com/au-ts/libvmm/tree/main

## Project environment

The following docker envrionment must be used to build this project and to build U-Boot.
[https://github.com/sel4-cap/sel4devkit-maaxboard-docker-dev-env](https://github.com/sel4devkit/sel4devkit-maaxboard-microkit-docker-dev-env)

Clone the above repository and run the following commands (replacing the arguments for "make run" with actual paths):

```
make pull IMAGE=sdk
make build IMAGE=user-me
make run IMAGE=user-me HOST_PATH=/path/to/selected/host/ HOME_PATH=/path/to/home
```
For U-Boot, build this repo using the above docker environment:

https://github.com/sel4-cap/sel4devkit-maaxboard-bootloader-u-boot 

For information on how to set up a development environment for the Maaxboard, see:

https://github.com/sel4-cap/dev-kit-doc

## Building the project

To build the project:

```make all```

Then copy the out/main.img to the maaxboard.

## Running the project

Both VM's are loaded simultaneously, so output from both VM's will be seen at the same time. A prompt will ask for the password which is 'root'.

To switch between the VMs type @ followed by 1, or 0. You will see output from both VM's but only be able to interact with one at a time.


