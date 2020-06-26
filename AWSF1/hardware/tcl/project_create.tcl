set script_dir    [file dirname [info script]]
set origin_dir    "$script_dir/.."
set project_name  [lindex $argv 0]
set project_dir   [lindex $argv 1]

puts "Project name $project_name"
puts "Project dir  $project_dir"

# Open GUI
# start_gui

# Create project
create_project $project_name $project_dir/$project_name

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
    }
add_files -norecurse -fileset [get_filesets sources_1] $ls_ips

set files [list \
    [file normalize $origin_dir/src/hdl/interfacer.v                                                                  ] \
    [file normalize $origin_dir/src/hdl/homenc_coprocessor.v                                                          ] \
    [file normalize $origin_dir/src/hdl/ntt_rom.v                                                                     ] \
    [file normalize $origin_dir/src/hdl/memory/memory_group.v                                                         ] \
    [file normalize $origin_dir/src/hdl/memory/memory_block.v                                                         ] \
    [file normalize $origin_dir/src/hdl/memory/memory.v                                                               ] \
    [file normalize $origin_dir/src/hdl/memory/uram1024.v                                                             ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_add_convolution_control.v                  ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath                                   ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_ntt_control.v                              ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part.v                                          ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor.v                                               ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_top.v                                                     ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/address_dp.v                      ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_add_mod.v                ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_coefficient_multiplier.v ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_crt_rom.v                ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_sub_mod.v                ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath.v                        ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/datapath_window_reduction60bit.v  ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/message_encoder.v                 ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/multiplexers.v                    ] \
    [file normalize $origin_dir/src/hdl/rlwe_processor/rlwe_processor_part_datapath/top.v                             ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/adder_93bit.v                                                      ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/bram_addr_gen.v                                                    ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/din_buff.v                                                         ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/dout_buff.v                                                        ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/final_subtraction.v                                                ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/ip_cores                                                           ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift2_sop.v                                                        ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_big.v                                                         ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_control_1core.v                                               ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_core.v                                                        ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_eq2.v                                                         ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_ext_cntrl.v                                                   ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/lift_small.v                                                       ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/mult_const_blift.v                                                 ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/scale_a_shares.v                                                   ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/sop_mod_qi.v                                                       ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/sum_fixedpt_blift.v                                                ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/sum_fixedpt.v                                                      ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/v_x_q_mod_pi.v                                                     ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/windowed_reduction60bit_q_select.v                                 ] \
    [file normalize $origin_dir/src/hdl/lift_shoup/windowed_reduction63bit_q_select.v                                 ] ]

add_files -norecurse -fileset [get_filesets sources_1] $files


set files [list \
    [file normalize $origin_dir/src/hdl_tb/tb_interfacer.sv     ] \
    [file normalize $origin_dir/src/hdl_tb/tb_memory.sv         ] ]

add_files -norecurse -fileset [get_filesets sim_1] $files

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Convert it to Amazon IPI Project
aws::make_ipi

update_compile_order -fileset sources_1

# Update the default cl.bd
source ./tcl/cl.tcl
regenerate_bd_layout
save_bd_design
set_property top cl_top [current_fileset]