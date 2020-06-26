AWS_INCLUDES = -I$(SDK_DIR)/userspace/include
AWS_LDFLAGS = -lfpga_mgmt -lrt -lpthread

CFLAGS  ?= -std=c++11 -funroll-loops -O3 -w -g -I.. -I/home/centos/bin/nfllib/include $(AWS_INCLUDES)
LDFLAGS ?= -L/home/centos/bin/nfllib/lib -lnfllib -lmpfr -lgmpxx -lgmp -larmadillo $(AWS_LDFLAGS)

all: clean gmdh

gmdh: gmdh.cpp
	g++ $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f gmdh
