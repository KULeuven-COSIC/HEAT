AWS_INCLUDES = -I$(SDK_DIR)/userspace/include
AWS_LDFLAGS = -lfpga_mgmt -lrt -lpthread

CFLAGS  ?= -std=c++11 -funroll-loops -O3 -w -g -I.. -I/home/centos/bin/nfllib/include $(AWS_INCLUDES)
LDFLAGS ?= -L/home/centos/bin/nfllib/lib -lnfllib -lmpfr -lgmpxx -lgmp -larmadillo $(AWS_LDFLAGS)

all: clean gmdh

gmdh: gmdh.cpp
	g++ $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f gmdh


# AWS_SRC = ./aws/hw/homomorphy.c
# AWS_INCLUDES = -I$(SDK_DIR)/userspace/include
# AWS_CC = gcc
# AWS_CFLAGS = -DCONFIG_LOGLEVEL=4 -std=gnu99 -Wall -Werror $(AWS_INCLUDES)
# AWS_LDFLAGS = -lfpga_mgmt -lrt -lpthread

# CFLAGS  ?= -std=c++11 -funroll-loops -O3 -w -g -I.. -I/home/centos/bin/nfllib/include $(AWS_CFLAGS)
# LDFLAGS ?= -L/home/centos/bin/nfllib/lib -lnfllib -lmpfr -lgmpxx -lgmp -larmadillo $(AWS_LDFLAGS)

# all: clean gmdh

# lib: $(AWS_SRC)
# 	gcc $(AWS_CFLAGS) -c -O $^ $(AWS_LDFLAGS)
# 	gcc -shared -o libhomomorphy.so homomorphy.o

# gmdh: gmdh.cpp
# 	g++ $(CFLAGS) $^ -o $@ homomorphy.o $(LDFLAGS)

# clean:
# 	rm -f gmdh

