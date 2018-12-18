all: 
	@echo "Valid make targets are:"
	@echo " open   - to open the created project"
	@echo " build  - to create the project"	
	@echo " clean  - to delete the created project"
	
open:
	xsdk -workspace ./project_sw &
	
build:
	xsdk -batch -source tcl/build_sdk.tcl

clean:
	rm -rf vivado.* vivado_* .Xil/ webtalk* project_sw