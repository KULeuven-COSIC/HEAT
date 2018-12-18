# FPGA-based High-Performance Parallel Architecture for Homomorphic Computing on Encrypted Data

Homomorphic Encryption (HE) is a tool that enables computation on encrypted data and thus has applications in privacy-preserving cloud computing. Though conceptually amazing, implementation of homomorphic encryption is very challenging and typically software implementations on general purpose computers are extremely slow. Hereby, we present our year long effort to design a domain specific architecture in a heterogeneous Arm+FPGA platform to accelerate homomorphic computing on encrypted data. We design a custom co-processor for the computationally expensive operations of the well-known Fan-Vercauteren (FV) homomorphic encryption scheme on the FPGA, and make the Arm processor a server for executing different homomorphic applications in the cloud, using this FPGA-based co-processor. We use the most recent arithmetic and algorithmic optimization techniques and perform design-space exploration on different levels of the implementation hierarchy. In particular we apply circuit-level and block-level pipeline strategies to boost the clock frequency and increase the throughput respectively. To reduce computation latency, we use parallel processing at all levels. Starting from the highly optimized building blocks, we gradually build our multi-core multi-processor architecture for computing on encrypted data. We implemented and tested our optimized domain specific programmable architecture on a single Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit. At 200 MHz FPGA-clock, our implementation achieves over 13x speedup with respect to a highly optimized software implementation of the FV homomorphic encryption scheme on an Intel i5 processor running at 1.8 GHz.

## Hardware Implementation

The sources files of the design are provided in `src` folder. They do not only consist of HDL files, but also ipcores, e.g. for block RAMs and DSP multipliers. The top level homomorphic computation hardware module' name is `PROCESSOR_POLY`.

A block design is provided to instantiate two copies of the processor module and implement an interface between Arm cores of the Zynq platform and the homomorphic computation processors. An AXI DMA IP Core is used to transfer input and output data between software accessible DDR memory and the processors' BRAMs. Provided `ipcore_interfacer` implements a custom AXI IP Core handling the handshaking signals of these transfers and abstracting them from the processor's design.

## Software Implementation

The software code is divided to three Arm cores. One core is allocated for networking to run a server side code. It receives encrypted input data from clients, executes homomorphic operations on them, and later transfers the results back to the clients. The other two cores, independently from each other, communicate with an instance of the processor module, and enable concurrent handling two computation jobs. The access control of these two cores to shared hardware resources, e.g. DMA, is managed with mutexs, the pyhsical implementation of which can be found in the hardware block design.

**Note:** In this commit, a testvector input provided in the `data0.c` and `data1.c` are processor, but the server-client communication has been omitted. It will be provided soon in addition to a tool to generate new testvectors.

---

## Building the Project

The hardware implementation and its software counterpart are provided in two separate directories. A Makefile is provided in both directories to open, build and clean the Vivado and XSDK projects respectively for hardware and software implementations of the project with the targets shown below.

```
make open   - to open the created project
make build  - to create the project
make clean  - to delete the created project
```

The TCL scripts to manage the project build of this commit has been tested on Vivado 2018.3.

**Note:** The HDF (Hardware Definition File) input of the XSDK project is `src/systemblk_wrapper.hdf`. In case, a change is made in the hardware implementation, a new HDF (including bitstream) should be generated and replaced with this one.


<!-- *In addition to Makefile for building the project from sources directly, a -newly- built project folders are committed, as an extra resource. When this project will be visited in the future, a Vivado version mismatch may happen, causing the build scipts to fail if the Vivado supported TCL commands change. In such a case, the already built project can be handy as Vivado should open projects of previous versions in read-only mode and allow upgrading them.* -->
