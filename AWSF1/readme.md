# HEAWS - An Accelerator for Homomorphic Encryption on the Amazon AWS FPGA

Homomorphic Encryption makes privacy preserving computing possible in a third party owned cloud by enabling computation on the encrypted data of users. However, software implementations of homomorphic encryption are very slow on general purpose processors. With the emergence of ‘FPGA-as-a-service’, hardware-acceleration of computationally heavy workloads in the cloud are getting popular. In our project we propose HEAWS, a domain-specific coprocessor architecture for accelerating homomorphic function evaluation on the encrypted data using high-performance FPGAs available in the Amazon AWS cloud. To the best of our knowledge, we are the first to report hardware acceleration of homomorphic encryption using Amazon AWS FPGAs.

Utilising the massive size of the AWS FPGAs, we design a high-performance and parallel coprocessor architecture for the FV homomorphic encryption scheme which has become popular for computing exact arithmetic on the encrypted data. We design parallel building blocks and apply pipeline processing at different levels of the implementation hierarchy, and on top of such optimisations we instantiate multiple parallel coprocessors in the FPGA to execute several homomorphic computations simultaneously. While the absolute computation time can be reduced by deploying more computational resources, efficiency of the HW/SW communication interface plays an important role in homomorphic encryption as it is computation as well as data intensive. Our implementation utilises state of the art 512-bit XDMA feature of high bandwidth communication available in the AWS Shell to reduce the overhead of HW/SW data transfer. Moreover, we explore the design-space to identify optimal off-chip data transfer strategy for feeding the parallel coprocessors in a time-shared manner. As a result of these optimisations, our AWS-based accelerator can perform 613 homomorphic multiplications per second for a parameter set that enables homomorphic computations of depth 4. Finally, we benchmark an artificial neural network for privacy-preserving forecasting of energy consumption in a Smart Grid application and observe five times speed up. 

You can check the details of our architecture in our paper:

[HEAWS: An Accelerator for Homomorphic Encryption on the Amazon AWS FPGA - IEEE Journals & Magazine](https://ieeexplore.ieee.org/abstract/document/9072637/)

___

## Testing the Accelerator

### Step 1

Create a 2x large F1 instance, with *FPGA Developer AMI*.

### Step 2

We use the `./aws_access/setup_access.sh` for keyless access and copying sw part of our app. That requires copying the AWS access key to `./aws_access/` directory. If you are not comfortable with this approach, you can scp the following files and folders into your F1 instance, and then login and continue with the following steps.

* `./aws_access/prepare_environment.sh`
* `./software/`
* `./nneval_app/`

### Step 3

Execute `./prepare_environment` script on the F1 instance.  This script will install all the dependencies for compiling the test apps.

This script will also load the accelerator with `afi-0da97a1d59bf1e558` (or `agfi-05bfb2806dd7970d2`). The is made publicly accessible, so that you can use it directly without synthesising the design from scratch just for testing.

### Step 4

A simple test code ie made available in `~/nneval_app/shoup/main.c` code. For a basic test, you can have a look at its `demonstrate_1L_multiplication()`  function. It will encrypt two plaintext number, send it to accelerator, make the accelerator multiply them, get the result of multiplication, decrypt the result and check the correctness. Of course, in a real life app, the encryption and decryption will be handled in users’s local computer, only the ciphertext will be uploaded to the cloud.

```
cd ~/aws-fpga/
source sdk_setup.sh 
cd ~/nneval_app/shoup
make
sudo ./test
```

### Step 5

This app will let you test the following:
* Data transfer between software and hardware
* Low level instructions for the coprocessor
* Homomorphic operations built with these instructions

You can init the polynomial with key 2, send it to FPGA with key 4, execute multiplication or addition with key 7 or 8, receive the result back with key 5, and print the result with key 3. Of course this is an encrypted result, so will look like a garbage.

```
cd ~/aws-fpga/
source sdk_setup.sh 
cd ../software
make
sudo ./application
```

___

## Synthesising Hardware

A makefile is created to build a Vivado project, and and open it.  The corresponding project is prepared with Vivado 2018.3, so it is better to use the same version.

### Step 1

Execute `make create` for building the project. The makefile will execute `/hardware/tcl/project_create.tcl` script. 

**Warning**. Vivado sometimes do not finish the execution of the TCL commands before `source ./tcl/cl.tcl` at line 97, when it starts executing this line. That can result into errors. To overcome this problem, you can comment the last 4 lines of the `project_create.tcl` file, and execute them after the second step.

### Step 2

Use `make open` to open the project created in the previous step. 

Now you can synthesise and implement the design.

___

## Directory Structure

* `aws_access` is the folder to that consists of scripts to setup the AWS F1 instance
* `hardware` contains .rtl files for hardware design, and .tcl files for creating a Vivado project
* `software` contains the test code for verifying low level operation of the coprocessors, i.e. for testing data transfers and for verifying the correctness of coprocessor instructions.
* `software_multicore` involves minor modifications over the above one, for extending the test to multiple coprocessors in the FPGA
* `nneval_app` contains test codes of neural network for privacy-preserving forecasting of energy consumption in a Smart Grid application
* `nneval_app/shoup` contains high level test to verify basic homomorphic arithmetic operations
