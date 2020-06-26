
################################################################
# This is a generated script based on design: cl
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source cl_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# homenc_coprocessor, homenc_coprocessor, homenc_coprocessor, homenc_coprocessor, interfacer, interfacer, interfacer, interfacer

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu9p-flgb2104-2-i
   set_property BOARD_PART xilinx.com:f1_cl:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name cl

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   # set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:aws:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
homenc_coprocessor\
homenc_coprocessor\
homenc_coprocessor\
homenc_coprocessor\
interfacer\
interfacer\
interfacer\
interfacer\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
#   set S_SH [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aws_f1_sh1_rtl:1.0 S_SH ]

  # Create ports

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_bram_ctrl_2, and set properties
  set axi_bram_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_2 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_2

  # Create instance: axi_bram_ctrl_3, and set properties
  set axi_bram_ctrl_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_3 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_3

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_1

  # Create instance: axi_gpio_2, and set properties
  set axi_gpio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2 ]
  set_property -dict [ list \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_2

  # Create instance: axi_gpio_3, and set properties
  set axi_gpio_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_3 ]
  set_property -dict [ list \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_3

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.M04_HAS_REGSLICE {4} \
   CONFIG.M05_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {4} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {2} \
   CONFIG.XBAR_DATA_WIDTH {64} \
 ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.M04_HAS_REGSLICE {4} \
   CONFIG.M05_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {4} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {2} \
   CONFIG.XBAR_DATA_WIDTH {64} \
 ] $axi_interconnect_1

  # Create instance: f1_inst, and set properties
#   set f1_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:aws:1.0 f1_inst ]
  set f1_inst [ get_bd_cells f1_inst]
  set_property -dict [ list \
   CONFIG.CLOCK_A0_FREQ {250000000} \
   CONFIG.CLOCK_A1_FREQ {125000000} \
   CONFIG.CLOCK_A2_FREQ {375000000} \
   CONFIG.CLOCK_A3_FREQ {500000000} \
   CONFIG.CLOCK_A_RECIPE {1} \
   CONFIG.CLOCK_B0_FREQ {450000000} \
   CONFIG.CLOCK_B1_FREQ {225000000} \
   CONFIG.CLOCK_B_RECIPE {2} \
   CONFIG.CLOCK_C0_FREQ {500000000} \
   CONFIG.CLOCK_C1_FREQ {400000000} \
   CONFIG.CLOCK_C_RECIPE {0} \
   CONFIG.DEVICE_ID {0xF000} \
   CONFIG.NUM_A_CLOCKS {1} \
   CONFIG.NUM_B_CLOCKS {2} \
   CONFIG.NUM_C_CLOCKS {0} \
   CONFIG.OCL_PRESENT {1} \
   CONFIG.PCIM_PRESENT {0} \
   CONFIG.PCIS_PRESENT {1} \
 ] $f1_inst

  # Create instance: homenc_coprocessor_0, and set properties
  set block_name homenc_coprocessor
  set block_cell_name homenc_coprocessor_0
  if { [catch {set homenc_coprocessor_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $homenc_coprocessor_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: homenc_coprocessor_1, and set properties
  set block_name homenc_coprocessor
  set block_cell_name homenc_coprocessor_1
  if { [catch {set homenc_coprocessor_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $homenc_coprocessor_1 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: homenc_coprocessor_2, and set properties
  set block_name homenc_coprocessor
  set block_cell_name homenc_coprocessor_2
  if { [catch {set homenc_coprocessor_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $homenc_coprocessor_2 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: homenc_coprocessor_3, and set properties
  set block_name homenc_coprocessor
  set block_cell_name homenc_coprocessor_3
  if { [catch {set homenc_coprocessor_3 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $homenc_coprocessor_3 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: interfacer_0, and set properties
  set block_name interfacer
  set block_cell_name interfacer_0
  if { [catch {set interfacer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interfacer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: interfacer_1, and set properties
  set block_name interfacer
  set block_cell_name interfacer_1
  if { [catch {set interfacer_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interfacer_1 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: interfacer_2, and set properties
  set block_name interfacer
  set block_cell_name interfacer_2
  if { [catch {set interfacer_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interfacer_2 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: interfacer_3, and set properties
  set block_name interfacer
  set block_cell_name interfacer_3
  if { [catch {set interfacer_3 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interfacer_3 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins f1_inst/M_AXI_OCL]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_bram_ctrl_2/S_AXI] [get_bd_intf_pins axi_interconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_bram_ctrl_3/S_AXI] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins axi_gpio_1/S_AXI] [get_bd_intf_pins axi_interconnect_1/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M02_AXI [get_bd_intf_pins axi_gpio_2/S_AXI] [get_bd_intf_pins axi_interconnect_1/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M03_AXI [get_bd_intf_pins axi_gpio_3/S_AXI] [get_bd_intf_pins axi_interconnect_1/M03_AXI]
  connect_bd_intf_net -intf_net f1_inst_M_AXI_PCIS [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins f1_inst/M_AXI_PCIS]
  connect_bd_intf_net -intf_net f1_inst_S_SH [get_bd_intf_ports S_SH] [get_bd_intf_pins f1_inst/S_SH]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net axi_bram_ctrl_0_bram_addr_a [get_bd_pins axi_bram_ctrl_0/bram_addr_a] [get_bd_pins interfacer_0/bram_addr_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_clk_a [get_bd_pins axi_bram_ctrl_0/bram_clk_a] [get_bd_pins interfacer_0/bram_clk_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_en_a [get_bd_pins axi_bram_ctrl_0/bram_en_a] [get_bd_pins interfacer_0/bram_en_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_rst_a [get_bd_pins axi_bram_ctrl_0/bram_rst_a] [get_bd_pins interfacer_0/bram_rst_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_we_a [get_bd_pins axi_bram_ctrl_0/bram_we_a] [get_bd_pins interfacer_0/bram_we_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_wrdata_a [get_bd_pins axi_bram_ctrl_0/bram_wrdata_a] [get_bd_pins interfacer_0/bram_wrdata_a]
  connect_bd_net -net axi_bram_ctrl_1_bram_addr_a [get_bd_pins axi_bram_ctrl_1/bram_addr_a] [get_bd_pins interfacer_1/bram_addr_a]
  connect_bd_net -net axi_bram_ctrl_1_bram_clk_a [get_bd_pins axi_bram_ctrl_1/bram_clk_a] [get_bd_pins interfacer_1/bram_clk_a]
  connect_bd_net -net axi_bram_ctrl_1_bram_en_a [get_bd_pins axi_bram_ctrl_1/bram_en_a] [get_bd_pins interfacer_1/bram_en_a]
  connect_bd_net -net axi_bram_ctrl_1_bram_rst_a [get_bd_pins axi_bram_ctrl_1/bram_rst_a] [get_bd_pins interfacer_1/bram_rst_a]
  connect_bd_net -net axi_bram_ctrl_1_bram_we_a [get_bd_pins axi_bram_ctrl_1/bram_we_a] [get_bd_pins interfacer_1/bram_we_a]
  connect_bd_net -net axi_bram_ctrl_1_bram_wrdata_a [get_bd_pins axi_bram_ctrl_1/bram_wrdata_a] [get_bd_pins interfacer_1/bram_wrdata_a]
  connect_bd_net -net axi_bram_ctrl_2_bram_addr_a [get_bd_pins axi_bram_ctrl_2/bram_addr_a] [get_bd_pins interfacer_2/bram_addr_a]
  connect_bd_net -net axi_bram_ctrl_2_bram_clk_a [get_bd_pins axi_bram_ctrl_2/bram_clk_a] [get_bd_pins interfacer_2/bram_clk_a]
  connect_bd_net -net axi_bram_ctrl_2_bram_en_a [get_bd_pins axi_bram_ctrl_2/bram_en_a] [get_bd_pins interfacer_2/bram_en_a]
  connect_bd_net -net axi_bram_ctrl_2_bram_rst_a [get_bd_pins axi_bram_ctrl_2/bram_rst_a] [get_bd_pins interfacer_2/bram_rst_a]
  connect_bd_net -net axi_bram_ctrl_2_bram_we_a [get_bd_pins axi_bram_ctrl_2/bram_we_a] [get_bd_pins interfacer_2/bram_we_a]
  connect_bd_net -net axi_bram_ctrl_2_bram_wrdata_a [get_bd_pins axi_bram_ctrl_2/bram_wrdata_a] [get_bd_pins interfacer_2/bram_wrdata_a]
  connect_bd_net -net axi_bram_ctrl_3_bram_addr_a [get_bd_pins axi_bram_ctrl_3/bram_addr_a] [get_bd_pins interfacer_3/bram_addr_a]
  connect_bd_net -net axi_bram_ctrl_3_bram_clk_a [get_bd_pins axi_bram_ctrl_3/bram_clk_a] [get_bd_pins interfacer_3/bram_clk_a]
  connect_bd_net -net axi_bram_ctrl_3_bram_en_a [get_bd_pins axi_bram_ctrl_3/bram_en_a] [get_bd_pins interfacer_3/bram_en_a]
  connect_bd_net -net axi_bram_ctrl_3_bram_rst_a [get_bd_pins axi_bram_ctrl_3/bram_rst_a] [get_bd_pins interfacer_3/bram_rst_a]
  connect_bd_net -net axi_bram_ctrl_3_bram_we_a [get_bd_pins axi_bram_ctrl_3/bram_we_a] [get_bd_pins interfacer_3/bram_we_a]
  connect_bd_net -net axi_bram_ctrl_3_bram_wrdata_a [get_bd_pins axi_bram_ctrl_3/bram_wrdata_a] [get_bd_pins interfacer_3/bram_wrdata_a]
  connect_bd_net -net axi_gpio_1_gpio2_io_o [get_bd_pins axi_gpio_1/gpio2_io_o] [get_bd_pins interfacer_1/io32_1_in]
  connect_bd_net -net axi_gpio_1_gpio_io_o [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins interfacer_1/io32_0_in]
  connect_bd_net -net axi_gpio_2_gpio2_io_o [get_bd_pins axi_gpio_2/gpio2_io_o] [get_bd_pins interfacer_2/io32_1_in]
  connect_bd_net -net axi_gpio_2_gpio_io_o [get_bd_pins axi_gpio_2/gpio_io_o] [get_bd_pins interfacer_2/io32_0_in]
  connect_bd_net -net axi_gpio_3_gpio2_io_o [get_bd_pins axi_gpio_3/gpio2_io_o] [get_bd_pins interfacer_3/io32_1_in]
  connect_bd_net -net axi_gpio_3_gpio_io_o [get_bd_pins axi_gpio_3/gpio_io_o] [get_bd_pins interfacer_3/io32_0_in]
  connect_bd_net -net f1_inst_clk_extra_b1_out [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_bram_ctrl_2/s_axi_aclk] [get_bd_pins axi_bram_ctrl_3/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_gpio_2/s_axi_aclk] [get_bd_pins axi_gpio_3/s_axi_aclk] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/M02_ACLK] [get_bd_pins axi_interconnect_1/M03_ACLK] [get_bd_pins f1_inst/clk_extra_b1_out] [get_bd_pins homenc_coprocessor_0/clk] [get_bd_pins homenc_coprocessor_1/clk] [get_bd_pins homenc_coprocessor_2/clk] [get_bd_pins homenc_coprocessor_3/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net f1_inst_clk_main_a0_out1 [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins f1_inst/clk_main_a0_out]
  connect_bd_net -net f1_inst_rst_main_n_out [get_bd_pins f1_inst/rst_main_n_out] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net homenc_coprocessor_0_cpu_mem_rd_data [get_bd_pins homenc_coprocessor_0/cpu_mem_rd_data] [get_bd_pins interfacer_0/cpu_mem_rd_data]
  connect_bd_net -net homenc_coprocessor_0_done [get_bd_pins homenc_coprocessor_0/done] [get_bd_pins interfacer_0/done]
  connect_bd_net -net homenc_coprocessor_1_cpu_mem_rd_data [get_bd_pins homenc_coprocessor_1/cpu_mem_rd_data] [get_bd_pins interfacer_1/cpu_mem_rd_data]
  connect_bd_net -net homenc_coprocessor_1_done [get_bd_pins homenc_coprocessor_1/done] [get_bd_pins interfacer_1/done]
  connect_bd_net -net homenc_coprocessor_2_cpu_mem_rd_data [get_bd_pins homenc_coprocessor_2/cpu_mem_rd_data] [get_bd_pins interfacer_2/cpu_mem_rd_data]
  connect_bd_net -net homenc_coprocessor_2_done [get_bd_pins homenc_coprocessor_2/done] [get_bd_pins interfacer_2/done]
  connect_bd_net -net homenc_coprocessor_3_cpu_mem_rd_data [get_bd_pins homenc_coprocessor_3/cpu_mem_rd_data] [get_bd_pins interfacer_3/cpu_mem_rd_data]
  connect_bd_net -net homenc_coprocessor_3_done [get_bd_pins homenc_coprocessor_3/done] [get_bd_pins interfacer_3/done]
  connect_bd_net -net interfacer_0_bram_rddata_a [get_bd_pins axi_bram_ctrl_0/bram_rddata_a] [get_bd_pins interfacer_0/bram_rddata_a]
  connect_bd_net -net interfacer_0_cpu_interrupt [get_bd_pins homenc_coprocessor_0/cpu_interrupt] [get_bd_pins interfacer_0/cpu_interrupt]
  connect_bd_net -net interfacer_0_cpu_mb_all [get_bd_pins homenc_coprocessor_0/cpu_mb_all] [get_bd_pins interfacer_0/cpu_mb_all]
  connect_bd_net -net interfacer_0_cpu_mb_strobe [get_bd_pins homenc_coprocessor_0/cpu_mb_strobe] [get_bd_pins interfacer_0/cpu_mb_strobe]
  connect_bd_net -net interfacer_0_cpu_mem_addr [get_bd_pins homenc_coprocessor_0/cpu_mem_addr] [get_bd_pins interfacer_0/cpu_mem_addr]
  connect_bd_net -net interfacer_0_cpu_mem_sel [get_bd_pins homenc_coprocessor_0/cpu_mem_sel] [get_bd_pins interfacer_0/cpu_mem_sel]
  connect_bd_net -net interfacer_0_cpu_mem_wr_data [get_bd_pins homenc_coprocessor_0/cpu_mem_wr_data] [get_bd_pins interfacer_0/cpu_mem_wr_data]
  connect_bd_net -net interfacer_0_cpu_mem_wr_en [get_bd_pins homenc_coprocessor_0/cpu_mem_wr_en] [get_bd_pins interfacer_0/cpu_mem_wr_en]
  connect_bd_net -net interfacer_0_instruction [get_bd_pins homenc_coprocessor_0/instruction] [get_bd_pins interfacer_0/instruction]
  connect_bd_net -net interfacer_0_io32_0_in [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins interfacer_0/io32_0_in]
  connect_bd_net -net interfacer_0_io32_0_out [get_bd_pins axi_gpio_0/gpio_io_i] [get_bd_pins interfacer_0/io32_0_out]
  connect_bd_net -net interfacer_0_io32_1_in [get_bd_pins axi_gpio_0/gpio2_io_o] [get_bd_pins interfacer_0/io32_1_in]
  connect_bd_net -net interfacer_0_io32_1_out [get_bd_pins axi_gpio_0/gpio2_io_i] [get_bd_pins interfacer_0/io32_1_out]
  connect_bd_net -net interfacer_0_modulus_sel [get_bd_pins homenc_coprocessor_0/modulus_sel] [get_bd_pins interfacer_0/modulus_sel]
  connect_bd_net -net interfacer_0_rdM0 [get_bd_pins homenc_coprocessor_0/rdM0] [get_bd_pins interfacer_0/rdM0]
  connect_bd_net -net interfacer_0_rdM1 [get_bd_pins homenc_coprocessor_0/rdM1] [get_bd_pins interfacer_0/rdM1]
  connect_bd_net -net interfacer_0_wtM0 [get_bd_pins homenc_coprocessor_0/wtM0] [get_bd_pins interfacer_0/wtM0]
  connect_bd_net -net interfacer_0_wtM1 [get_bd_pins homenc_coprocessor_0/wtM1] [get_bd_pins interfacer_0/wtM1]
  connect_bd_net -net interfacer_1_bram_rddata_a [get_bd_pins axi_bram_ctrl_1/bram_rddata_a] [get_bd_pins interfacer_1/bram_rddata_a]
  connect_bd_net -net interfacer_1_cpu_interrupt [get_bd_pins homenc_coprocessor_1/cpu_interrupt] [get_bd_pins interfacer_1/cpu_interrupt]
  connect_bd_net -net interfacer_1_cpu_mb_all [get_bd_pins homenc_coprocessor_1/cpu_mb_all] [get_bd_pins interfacer_1/cpu_mb_all]
  connect_bd_net -net interfacer_1_cpu_mb_strobe [get_bd_pins homenc_coprocessor_1/cpu_mb_strobe] [get_bd_pins interfacer_1/cpu_mb_strobe]
  connect_bd_net -net interfacer_1_cpu_mem_addr [get_bd_pins homenc_coprocessor_1/cpu_mem_addr] [get_bd_pins interfacer_1/cpu_mem_addr]
  connect_bd_net -net interfacer_1_cpu_mem_sel [get_bd_pins homenc_coprocessor_1/cpu_mem_sel] [get_bd_pins interfacer_1/cpu_mem_sel]
  connect_bd_net -net interfacer_1_cpu_mem_wr_data [get_bd_pins homenc_coprocessor_1/cpu_mem_wr_data] [get_bd_pins interfacer_1/cpu_mem_wr_data]
  connect_bd_net -net interfacer_1_cpu_mem_wr_en [get_bd_pins homenc_coprocessor_1/cpu_mem_wr_en] [get_bd_pins interfacer_1/cpu_mem_wr_en]
  connect_bd_net -net interfacer_1_instruction [get_bd_pins homenc_coprocessor_1/instruction] [get_bd_pins interfacer_1/instruction]
  connect_bd_net -net interfacer_1_io32_0_out [get_bd_pins axi_gpio_1/gpio_io_i] [get_bd_pins interfacer_1/io32_0_out]
  connect_bd_net -net interfacer_1_io32_1_out [get_bd_pins axi_gpio_1/gpio2_io_i] [get_bd_pins interfacer_1/io32_1_out]
  connect_bd_net -net interfacer_1_modulus_sel [get_bd_pins homenc_coprocessor_1/modulus_sel] [get_bd_pins interfacer_1/modulus_sel]
  connect_bd_net -net interfacer_1_rdM0 [get_bd_pins homenc_coprocessor_1/rdM0] [get_bd_pins interfacer_1/rdM0]
  connect_bd_net -net interfacer_1_rdM1 [get_bd_pins homenc_coprocessor_1/rdM1] [get_bd_pins interfacer_1/rdM1]
  connect_bd_net -net interfacer_1_wtM0 [get_bd_pins homenc_coprocessor_1/wtM0] [get_bd_pins interfacer_1/wtM0]
  connect_bd_net -net interfacer_1_wtM1 [get_bd_pins homenc_coprocessor_1/wtM1] [get_bd_pins interfacer_1/wtM1]
  connect_bd_net -net interfacer_2_bram_rddata_a [get_bd_pins axi_bram_ctrl_2/bram_rddata_a] [get_bd_pins interfacer_2/bram_rddata_a]
  connect_bd_net -net interfacer_2_cpu_interrupt [get_bd_pins homenc_coprocessor_2/cpu_interrupt] [get_bd_pins interfacer_2/cpu_interrupt]
  connect_bd_net -net interfacer_2_cpu_mb_all [get_bd_pins homenc_coprocessor_2/cpu_mb_all] [get_bd_pins interfacer_2/cpu_mb_all]
  connect_bd_net -net interfacer_2_cpu_mb_strobe [get_bd_pins homenc_coprocessor_2/cpu_mb_strobe] [get_bd_pins interfacer_2/cpu_mb_strobe]
  connect_bd_net -net interfacer_2_cpu_mem_addr [get_bd_pins homenc_coprocessor_2/cpu_mem_addr] [get_bd_pins interfacer_2/cpu_mem_addr]
  connect_bd_net -net interfacer_2_cpu_mem_sel [get_bd_pins homenc_coprocessor_2/cpu_mem_sel] [get_bd_pins interfacer_2/cpu_mem_sel]
  connect_bd_net -net interfacer_2_cpu_mem_wr_data [get_bd_pins homenc_coprocessor_2/cpu_mem_wr_data] [get_bd_pins interfacer_2/cpu_mem_wr_data]
  connect_bd_net -net interfacer_2_cpu_mem_wr_en [get_bd_pins homenc_coprocessor_2/cpu_mem_wr_en] [get_bd_pins interfacer_2/cpu_mem_wr_en]
  connect_bd_net -net interfacer_2_instruction [get_bd_pins homenc_coprocessor_2/instruction] [get_bd_pins interfacer_2/instruction]
  connect_bd_net -net interfacer_2_io32_0_out [get_bd_pins axi_gpio_2/gpio_io_i] [get_bd_pins interfacer_2/io32_0_out]
  connect_bd_net -net interfacer_2_io32_1_out [get_bd_pins axi_gpio_2/gpio2_io_i] [get_bd_pins interfacer_2/io32_1_out]
  connect_bd_net -net interfacer_2_modulus_sel [get_bd_pins homenc_coprocessor_2/modulus_sel] [get_bd_pins interfacer_2/modulus_sel]
  connect_bd_net -net interfacer_2_rdM0 [get_bd_pins homenc_coprocessor_2/rdM0] [get_bd_pins interfacer_2/rdM0]
  connect_bd_net -net interfacer_2_rdM1 [get_bd_pins homenc_coprocessor_2/rdM1] [get_bd_pins interfacer_2/rdM1]
  connect_bd_net -net interfacer_2_wtM0 [get_bd_pins homenc_coprocessor_2/wtM0] [get_bd_pins interfacer_2/wtM0]
  connect_bd_net -net interfacer_2_wtM1 [get_bd_pins homenc_coprocessor_2/wtM1] [get_bd_pins interfacer_2/wtM1]
  connect_bd_net -net interfacer_3_bram_rddata_a [get_bd_pins axi_bram_ctrl_3/bram_rddata_a] [get_bd_pins interfacer_3/bram_rddata_a]
  connect_bd_net -net interfacer_3_cpu_interrupt [get_bd_pins homenc_coprocessor_3/cpu_interrupt] [get_bd_pins interfacer_3/cpu_interrupt]
  connect_bd_net -net interfacer_3_cpu_mb_all [get_bd_pins homenc_coprocessor_3/cpu_mb_all] [get_bd_pins interfacer_3/cpu_mb_all]
  connect_bd_net -net interfacer_3_cpu_mb_strobe [get_bd_pins homenc_coprocessor_3/cpu_mb_strobe] [get_bd_pins interfacer_3/cpu_mb_strobe]
  connect_bd_net -net interfacer_3_cpu_mem_addr [get_bd_pins homenc_coprocessor_3/cpu_mem_addr] [get_bd_pins interfacer_3/cpu_mem_addr]
  connect_bd_net -net interfacer_3_cpu_mem_sel [get_bd_pins homenc_coprocessor_3/cpu_mem_sel] [get_bd_pins interfacer_3/cpu_mem_sel]
  connect_bd_net -net interfacer_3_cpu_mem_wr_data [get_bd_pins homenc_coprocessor_3/cpu_mem_wr_data] [get_bd_pins interfacer_3/cpu_mem_wr_data]
  connect_bd_net -net interfacer_3_cpu_mem_wr_en [get_bd_pins homenc_coprocessor_3/cpu_mem_wr_en] [get_bd_pins interfacer_3/cpu_mem_wr_en]
  connect_bd_net -net interfacer_3_instruction [get_bd_pins homenc_coprocessor_3/instruction] [get_bd_pins interfacer_3/instruction]
  connect_bd_net -net interfacer_3_io32_0_out [get_bd_pins axi_gpio_3/gpio_io_i] [get_bd_pins interfacer_3/io32_0_out]
  connect_bd_net -net interfacer_3_io32_1_out [get_bd_pins axi_gpio_3/gpio2_io_i] [get_bd_pins interfacer_3/io32_1_out]
  connect_bd_net -net interfacer_3_modulus_sel [get_bd_pins homenc_coprocessor_3/modulus_sel] [get_bd_pins interfacer_3/modulus_sel]
  connect_bd_net -net interfacer_3_rdM0 [get_bd_pins homenc_coprocessor_3/rdM0] [get_bd_pins interfacer_3/rdM0]
  connect_bd_net -net interfacer_3_rdM1 [get_bd_pins homenc_coprocessor_3/rdM1] [get_bd_pins interfacer_3/rdM1]
  connect_bd_net -net interfacer_3_wtM0 [get_bd_pins homenc_coprocessor_3/wtM0] [get_bd_pins interfacer_3/wtM0]
  connect_bd_net -net interfacer_3_wtM1 [get_bd_pins homenc_coprocessor_3/wtM1] [get_bd_pins interfacer_3/wtM1]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_2/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_3/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_gpio_2/s_axi_aresetn] [get_bd_pins axi_gpio_3/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/M02_ARESETN] [get_bd_pins axi_interconnect_1/M03_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x00020000 -offset 0xC0000000 [get_bd_addr_spaces f1_inst/M_AXI_PCIS] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00020000 -offset 0xC2000000 [get_bd_addr_spaces f1_inst/M_AXI_PCIS] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x00020000 -offset 0xC4000000 [get_bd_addr_spaces f1_inst/M_AXI_PCIS] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x00020000 -offset 0xC6000000 [get_bd_addr_spaces f1_inst/M_AXI_PCIS] [get_bd_addr_segs axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x00000000 [get_bd_addr_spaces f1_inst/M_AXI_OCL] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x00001000 [get_bd_addr_spaces f1_inst/M_AXI_OCL] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x00002000 [get_bd_addr_spaces f1_inst/M_AXI_OCL] [get_bd_addr_segs axi_gpio_2/S_AXI/Reg] SEG_axi_gpio_2_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x00003000 [get_bd_addr_spaces f1_inst/M_AXI_OCL] [get_bd_addr_segs axi_gpio_3/S_AXI/Reg] SEG_axi_gpio_3_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


