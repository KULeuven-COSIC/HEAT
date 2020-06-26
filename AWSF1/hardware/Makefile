THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT_NAME = project_homenc
PROJECT_DIR  = $(THIS_DIR)

all:
	@echo "Valid make targets are:"
	@echo " open   - to open the created project"
	@echo " create - to create the project"	
	@echo " clean  - to clean the project files"

create:
	vivado -mode batch -nojournal -nolog -source tcl/project_create.tcl -tclargs $(PROJECT_NAME) $(PROJECT_DIR)

open:
	vivado $(PROJECT_DIR)/$(PROJECT_NAME)/$(PROJECT_NAME).xpr -tempDir /tmp -nojournal -nolog  &

clean:
	rm -rf $(PROJECT_NAME)
	rm -rf .Xil/ webtalk* vivado_pid*
	find src/hdl/ip_cores -mindepth 2 -not -name '*.xci' -not -name '*.xml' -exec rm -rf {} +
	find src/hdl/lift_shoup/ip_cores -mindepth 2 -not -name '*.xci' -not -name '*.xml' -exec rm -rf {} +