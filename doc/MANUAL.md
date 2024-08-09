## Introduction

This repo demonstrates the ability to load two Linux guest VM's simultaneously with serial I/O to both of them via the means of a switch. The target board for this repo is the Maaxboard. This project makes use of [Libvmm](https://github.com/au-ts/libvmm/tree/main) and has reworked the following examples in the below repo to work with the Maaxboard:

## Project environment
This [Docker environment](https://github.com/sel4devkit/sel4devkit-maaxboard-microkit-docker-dev-env) must be used to build this project and to build U-Boot.

Clone the above repository and run the following commands (replacing the arguments for "make run" with actual paths):

```
make pull IMAGE=sdk
make build IMAGE=user-me
make run IMAGE=user-me HOST_PATH=/path/to/selected/host/ HOME_PATH=/path/to/home
```
For U-Boot clone and build this [repository](https://github.com/sel4-cap/sel4devkit-maaxboard-bootloader-u-boot ) in the above Docker environment. 

For information on how to set up a development environment see our [guide](https://sel4devkit.github.io/)

## Building the project

To build the project:

```make all```

Then copy the out/main.img to the Maaxboard.

## Running the project

Both VM's are loaded simultaneously, so output from both VM's will be seen at the same time. A prompt will ask for the password which is 'root'.

To switch between the VMs type @ followed by 1, or 0. You will see output from both VM's but only be able to interact with one at a time.
