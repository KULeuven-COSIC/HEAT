%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $< $(LDFLAGS) $(LDLIBS)

all: aws

SRC = application.c homomorphy.c

################################################################################
# COMPILE ON AWS

aws: check_env
aws: clean
aws: INCLUDES = -I$(SDK_DIR)/userspace/include
aws: CC = gcc
aws: CFLAGS = -DCONFIG_LOGLEVEL=4 -std=gnu99 -g -Wall -Werror $(INCLUDES)
aws: LDLIBS = -lfpga_mgmt -lrt -lpthread
aws: application

application: $(SRC) coprocessor.c
	${CC} $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LDLIBS)

check_env:
	test -n "$(SDK_DIR)"  # $$SDK_DIR

################################################################################
# COMPILE ON LOCAL MACHINE

local: clean
local: CC = gcc
local: CFLAGS = -Wall -Werror
local: application_local

application_local: $(SRC) coprocessor_local.c
	${CC} $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LDLIBS)

################################################################################
# CLEAN

clean:
	rm -f *.o application application_local

