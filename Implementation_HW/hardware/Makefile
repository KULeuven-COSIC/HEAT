all:
	@echo "Valid make targets are:"
	@echo " open   - to open the created project"
	@echo " build  - to create the project"	
	@echo " clean  - to delete the created project"

build: ipcore project

ipcore:
	vivado -mode batch -source tcl/build_ipcore_interfacer.tcl
	
project:
	vivado -mode batch -source tcl/build_project.tcl

open:
	vivado project_hw/project_hw.xpr -tempDir /tmp &

clean:
	rm -rf vivado.* vivado_* .Xil/ webtalk* -f
	rm -rf project_hw project_ipcores ip_repo
	find src/ip -mindepth 2 -not -name '*.xci' -not -name '*.xml' -exec rm -rf {} +
	find src/src_lift_shoup_ip -mindepth 2 -not -name '*.xci' -not -name '*.xml' -exec rm -rf {} +