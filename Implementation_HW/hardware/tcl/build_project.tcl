set script_dir [file dirname [info script]]
set origin_dir "$script_dir/.."
set project_name "project_hw"

# Create project
create_project $project_name $origin_dir/$project_name -part xczu9eg-ffvb1156-2-e
# set_property board_part xilinx.com:zcu102:part0:3.2 [current_project]

# Set IP repository paths
set_property ip_repo_paths "[file normalize $origin_dir/project_ipcores] [file normalize $origin_dir/project_ipcores]" [get_filesets sources_1]

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog

# Add ip files
set ips []
foreach ip [glob $origin_dir/src/ip/*] {
    set ipname [file tail $ip]
    set filename "$ip/$ipname.xci"
    lappend ips [file normalize "$filename"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $ips

# Add lift_shoup ip files
set ls_ips []
foreach ip [glob $origin_dir/src/src_lift_shoup_ip/*] {
    set ipname [file tail $ip]
    set filename "$ip/$ipname.xci"
    lappend ls_ips [file normalize "$filename"]
    # lappend ls_ips [file normalize "$ip"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $ls_ips

# Add lift_shoup rtl files
set ls_rtls []
foreach rtl [glob $origin_dir/src/src_lift_shoup_rtl/*] {
    lappend ls_rtls [file normalize "$rtl"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $ls_rtls

# Add rtl files
set rtls []
foreach rtl [glob $origin_dir/src/rtl/*] {
    lappend rtls [file normalize "$rtl"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $rtls

###################################################################

# Add lift_shoup testbenches files
set ls_rtl_tb []
foreach rtl [glob $origin_dir/src/src_lift_shoup_rtl_tb/*] {
        lappend ls_rtl_tb [file normalize "$rtl"]
    }
add_files -norecurse -fileset [get_filesets sim_1] $ls_rtl_tb

###################################################################

# Create block design
source $origin_dir/src/bd/systemblk.tcl
regenerate_bd_layout

# Generate the wrapper
make_wrapper -files [get_files [file normalize "$origin_dir/$project_name/$project_name.srcs/sources_1/bd/systemblk/systemblk.bd"]] -top
add_files -norecurse [file normalize "$origin_dir/$project_name/$project_name.srcs/sources_1/bd/systemblk/hdl/systemblk_wrapper.v"]
set_property top systemblk_wrapper [current_fileset]


###################################################################

update_compile_order -fileset sim_1
update_compile_order -fileset sources_1

# Create block design
# source $origin_dir/tcl/project_bd.tcl
# regenerate_bd_layout

# Generate the wrapper
# set design_name [get_bd_designs]
# make_wrapper -files [get_files $design_name.bd] -top -import



# Add Constraints
# add_files -fileset constrs_1 -norecurse $origin_dir/tcl/constraints.tcl

# # Add Waveform Files
# add_files -fileset sim_1 -norecurse $origin_dir/src/wcfg/tb_accelerator_wrapper_behav.wcfg
# set_property xsim.view $origin_dir/src/wcfg/tb_accelerator_wrapper_behav.wcfg [get_filesets sim_1]

# update_compile_order -fileset sim_1
# update_compile_order -fileset sources_1