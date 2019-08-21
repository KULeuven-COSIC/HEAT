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
foreach ip [glob $origin_dir/src/hdl/ip_cores/*] {
    set ipname [file tail $ip]
    set filename "$ip/$ipname.xci"
    lappend ips [file normalize "$filename"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $ips

# # Add lift_shoup ip files
set ls_ips []
foreach ip [glob $origin_dir/src/hdl/lift_shoup/ip_cores/*] {
    set ipname [file tail $ip]
    set filename "$ip/$ipname.xci"
    lappend ls_ips [file normalize "$filename"]
    # lappend ls_ips [file normalize "$ip"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $ls_ips

set files [list \
    [file normalize $origin_dir/src/hdl/top.v                                                                            ] \
    [file normalize $origin_dir/src/hdl/ntt_rom.v                                                                        ] \
    [file normalize $origin_dir/src/hdl/memory/memory_group.v                                                            ] \
    [file normalize $origin_dir/src/hdl/memory/memory_block.v                                                            ] \
    [file normalize $origin_dir/src/hdl/memory/memory.v                                                                  ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_add_convolution_control.v                     ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath                                      ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_ntt_control.v                                 ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part.v                                             ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor.v                                                  ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_top.v                                                        ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/address_dp.v                         ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_add_mod.v                   ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_coefficient_multiplier.v    ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_crt_rom.v                   ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_sub_mod.v                   ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath.v                           ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_window_reduction60bit.v     ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/message_encoder.v                    ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/multiplexers.v                       ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/top.v                                ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/adder_93bit.v                                                         ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/bram_addr_gen.v                                                       ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/din_buff.v                                                            ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/dout_buff.v                                                           ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/final_subtraction.v                                                   ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/ip_cores                                                              ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift2_sop.v                                                           ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_big.v                                                            ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_control_1core.v                                                  ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_core.v                                                           ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_eq2.v                                                            ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_ext_cntrl.v                                                      ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_small.v                                                          ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/mult_const_blift.v                                                    ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/scale_a_shares.v                                                      ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/sop_mod_qi.v                                                          ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/sum_fixedpt_blift.v                                                   ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/sum_fixedpt.v                                                         ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/v_x_q_mod_pi.v                                                        ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/windowed_reduction60bit_q_select.v                                    ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/windowed_reduction63bit_q_select.v                                    ] ]

add_files -norecurse -fileset [get_filesets sources_1] $files

###################################################################

# Add lift_shoup testbenches files
# set ls_rtl_tb []
# foreach rtl [glob $origin_dir/src/src_lift_shoup_rtl_tb/*] {
#         lappend ls_rtl_tb [file normalize "$rtl"]
#     }
# add_files -norecurse -fileset [get_filesets sim_1] $ls_rtl_tb

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