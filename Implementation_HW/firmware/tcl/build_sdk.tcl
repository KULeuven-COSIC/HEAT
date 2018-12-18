sdk setws project_sw
sdk createhw  -name hw_platform -hwspec systemblk_wrapper.hdf

sdk createbsp -name ntw_bsp     -hwproject hw_platform -proc psu_cortexa53_0 -os standalone
sdk createapp -name ntw_design  -hwproject hw_platform -proc psu_cortexa53_0 -os standalone -lang C -app {Empty Application} -bsp ntw_bsp
sdk importsources -name ntw_design -path ./src_ntw -linker-script

sdk createbsp -name app0_bsp    -hwproject hw_platform -proc psu_cortexa53_1 -os standalone
sdk createapp -name app0_design -hwproject hw_platform -proc psu_cortexa53_1 -os standalone -lang C -app {Empty Application} -bsp app0_bsp
sdk importsources -name app0_design -path ./src_app0 -linker-script

sdk createbsp -name app1_bsp    -hwproject hw_platform -proc psu_cortexa53_2 -os standalone
sdk createapp -name app1_design -hwproject hw_platform -proc psu_cortexa53_2 -os standalone -lang C -app {Empty Application} -bsp app1_bsp
sdk importsources -name app1_design -path ./src_app1 -linker-script