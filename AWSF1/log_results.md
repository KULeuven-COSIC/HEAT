# Utilization and Performance Logs

## The first port 

0.9 ms for transferring one polynomial: 
    4096 coefficients at each 8 memory-groups = 32768 x 32-bits
    131072-bytes
    128 KiB
    
### BRAM

The filename is: `he_v0_3_git.19_08_21-151934.Developer_CL.tar`

| Name       | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|------------|----------|----------|--------|------|------|------|
| available  |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|------------|----------|----------|--------|------|------|------|
| top        |   207537 |   240487 |  44892 |  587 |   43 |  211 |
| homenc     |    50789 |          |  10071 |  389 |    0 |  208 |
 

### URAM

The filename is: `he_v0_4_git.19_08_27-142816.Developer_CL.tar`

| Name       | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|------------|----------|----------|--------|------|------|------|
| available  |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|------------|----------|----------|--------|------|------|------|
| top        |   208117 |   240472 |  44368 |  335 |  169 |  211 |
| homenc     |    51397 |          |   9767 |  136 |  126 |  208 |

___

## Working well with new shell

The filename is: `he_v1_1.19_11_26-150717.Developer_CL.tar`

Apparently the new shell uses more BRAM resources.

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   213239 |   236530 |  45120 |  587 |   43 |  211 | 
| homenc       |    58836 |          |  10839 |  388 |    0 |  208 |
|--------------|----------|----------|--------|------|------|------|
| available PL |   895100 |  1790400 |        | 1680 |  800 | 5640 |
| used PL      |    64318 |    30613 |        |  388 |    0 |  208 |

___

## Removed 9th memory

The filename is: `he_v1_2.19_11_26-150717.Developer_CL.tar`

Apparently the new shell uses more BRAM resources.

### BRAM based

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   211808 |   236561 |  45110 |  559 |   43 |  211 | 
| homenc       |    57401 |          |  10777 |  360 |    0 |  208 |
|--------------|----------|----------|--------|------|------|------|
| available PL |   895100 |  1790400 |        | 1680 |  800 | 5640 |
| used PL      |    62897 |    30644 |        |  360 |    0 |  208 |

### URAM based

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   214731 |   236552 |  46305 |  335 |  155 |  211 | 
| homenc       |    60344 |          |  12016 |  136 |  112 |  208 |
|--------------|----------|----------|--------|------|------|------|
| available PL |   895100 |  1790400 |        | 1680 |  800 | 5640 |
| used PL      |    65820 |    30635 |        |  136 |  112 |  208 |

### URAM and BRAM Mix

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   212261 |   236573 |  44520 |  447 |   99 |  211 | 
| homenc       |    57877 |          |  10505 |  249 |   56 |  208 |
|--------------|----------|----------|--------|------|------|------|
| available PL |   895100 |  1790400 |        | 1680 |  800 | 5640 |
| used PL      |    63351 |    30656 |        |  249 |   56 |  208 |


## 4 Parallel Cores

File: he 1.5

### URAM and BRAM Mix

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   392977 |   333275 |  75279 | 1193 |  267 |  835 | 
| homenc       |   ~57877 |          | ~10505 | ~249 |  ~56 | ~208 |
|--------------|----------|----------|--------|------|------|------|
| available PL |   895100 |  1790400 |        | 1680 |  800 | 5640 |
| used PL      |   244066 |   127358 |        |  994 |  224 |  832 |

## 6 Parallel Cores

### URAM and BRAM Mix

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   517960 |   413250 |  98686 | 1704 |  379 | 1251 | 
| homenc       |   ~57877 |          | ~10505 | ~249 |  ~56 | ~208 |
|--------------|----------|----------|--------|------|------|------|
| available PL |   895100 |  1790400 |        | 1680 |  800 | 5640 |
| used PL      |   369049 |   207333 |        | 1506 |  336 | 1248 |

___

## 1 Core

File: he_v1.6

Shell @ 250 Mhz
CL    @ 200 Mhz
AXI XBar 32-bit

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |  2363536 | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   211943 |   236622 |  45100 |  559 |   43 |  211 | 
| homenc       |        ~ |        ~ |      ~ |    ~ |    ~ |    ~ |
|--------------|----------|----------|--------|------|------|------|

### Single multiplication

memalign
Sending inputs took about 0.00022 seconds
Computation took about 0.00435 seconds
Receiving outputs took about 0.00011 seconds

malloc
Sending inputs took about 0.00025 seconds
Computation took about 0.00436 seconds
Receiving outputs took about 0.00011 seconds

### Single addition

Sending inputs took about 0.00024 seconds
Computation took about 0.00000 seconds
Receiving outputs took about 0.00011 seconds

___

## 2 Parallel Cores for AXI XBAR

File: he_v1.8_axi32  - AXI XBAR 32-bit
File: he_v1.8_axi512 - AXI XBAR 512-bit

Shell @ 125 Mhz
CL    @ 125 Mhz

| Name         | CLB LUTs | CLB REGs |    CLB | BRAM | URAM | DSPs |
|--------------|----------|----------|--------|------|------|------|
| available    |  1181768 |          | 147721 | 2160 |  960 | 6840 |
|--------------|----------|----------|--------|------|------|------|
| top          |   277684 |   282047 |  58376 |  921 |   43 |  419 | AXI XBAR 32-bit
| top          |   274331 |   278175 |  58479 |  934 |   43 |  419 | AXI XBAR 512-bit
|--------------|----------|----------|--------|------|------|------|

### A multiplication with 32-bit XBAR
Sending inputs took about 0.00130 seconds
Computation took about 0.01179 seconds
Receiving outputs took about 0.00062 seconds

### A multiplication with 512-bit XBAR
Sending inputs took about 0.00027 seconds
Computation took about 0.00702 seconds
Receiving outputs took about 0.00013 seconds

___
