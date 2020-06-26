AWS_INCLUDES = -I$(SDK_DIR)/userspace/include
AWS_LDFLAGS = -lfpga_mgmt -lrt -lpthread

CFLAGS  ?= $(AWS_INCLUDES)
LDFLAGS ?= -fopenmp -lgmp $(AWS_LDFLAGS)

all: clean test

test: main.c
	gcc $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f test