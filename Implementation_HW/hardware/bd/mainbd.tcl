
################################################################
# This is a generated script based on design: mainbd
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
set scripts_vivado_version 2018.1
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
# source mainbd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# PROCESSOR_POLY

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu9eg-ffvb1156-2-e
   set_property BOARD_PART xilinx.com:zcu102:part0:3.2 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name mainbd

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
   set nRet 1
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
user.org:user:eth_ip:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
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
PROCESSOR_POLY\
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

  # Create ports
  set Command0 [ create_bd_port -dir I -from 31 -to 0 Command0 ]
  set M00_AXIS_tdata [ create_bd_port -dir O -from 63 -to 0 M00_AXIS_tdata ]
  set M00_AXIS_tlast [ create_bd_port -dir O M00_AXIS_tlast ]
  set M00_AXIS_tready [ create_bd_port -dir I M00_AXIS_tready ]
  set M00_AXIS_tstrb [ create_bd_port -dir O -from 7 -to 0 M00_AXIS_tstrb ]
  set M00_AXIS_tvalid [ create_bd_port -dir O M00_AXIS_tvalid ]
  set S00_AXIS_tdata [ create_bd_port -dir I -from 63 -to 0 S00_AXIS_tdata ]
  set S00_AXIS_tlast [ create_bd_port -dir I S00_AXIS_tlast ]
  set S00_AXIS_tready [ create_bd_port -dir O S00_AXIS_tready ]
  set S00_AXIS_tstrb [ create_bd_port -dir I -from 7 -to 0 S00_AXIS_tstrb ]
  set S00_AXIS_tvalid [ create_bd_port -dir I S00_AXIS_tvalid ]
  set Status0 [ create_bd_port -dir O -from 31 -to 0 Status0 ]
  set Status1 [ create_bd_port -dir O -from 31 -to 0 Status1 ]
  set ddr_address [ create_bd_port -dir I -from 8 -to 0 ddr_address ]
  set ddr_din [ create_bd_port -dir I -from 239 -to 0 ddr_din ]
  set ddr_dout [ create_bd_port -dir O -from 239 -to 0 ddr_dout ]
  set ddr_interrupt [ create_bd_port -dir I ddr_interrupt ]
  set ddr_we [ create_bd_port -dir I ddr_we ]
  set done [ create_bd_port -dir O done ]
  set instruction [ create_bd_port -dir I -from 7 -to 0 instruction ]
  set modulus_sel [ create_bd_port -dir I modulus_sel ]
  set rdM0 [ create_bd_port -dir I -from 3 -to 0 rdM0 ]
  set rdM1 [ create_bd_port -dir I -from 3 -to 0 rdM1 ]
  set s00_axis_aclk [ create_bd_port -dir I -type clk s00_axis_aclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
 ] $s00_axis_aclk
  set s00_axis_aresetn [ create_bd_port -dir I -type rst s00_axis_aresetn ]
  set wtM0 [ create_bd_port -dir I -from 3 -to 0 wtM0 ]
  set wtM1 [ create_bd_port -dir I -from 3 -to 0 wtM1 ]

  # Create instance: PROCESSOR_POLY_0, and set properties
  set block_name PROCESSOR_POLY
  set block_cell_name PROCESSOR_POLY_0
  if { [catch {set PROCESSOR_POLY_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PROCESSOR_POLY_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: eth_ip_0, and set properties
  set eth_ip_0 [ create_bd_cell -type ip -vlnv user.org:user:eth_ip:1.0 eth_ip_0 ]
  set_property -dict [ list \
   CONFIG.NUMBER_OF_WORDS {128} \
 ] $eth_ip_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {1} \
   CONFIG.IN1_WIDTH {7} \
   CONFIG.IN2_WIDTH {1} \
   CONFIG.IN3_WIDTH {7} \
   CONFIG.IN4_WIDTH {8} \
   CONFIG.IN5_WIDTH {8} \
   CONFIG.NUM_PORTS {6} \
 ] $xlconcat_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {8} \
 ] $xlconstant_0

  # Create port connections
  connect_bd_net -net Command0_1 [get_bd_ports Command0] [get_bd_pins eth_ip_0/Command0]
  connect_bd_net -net M00_AXIS_tready_1 [get_bd_ports M00_AXIS_tready] [get_bd_pins eth_ip_0/m00_axis_tready]
  connect_bd_net -net PROCESSOR_POLY_0_ddr_dout [get_bd_ports ddr_dout] [get_bd_pins PROCESSOR_POLY_0/ddr_dout]
  connect_bd_net -net PROCESSOR_POLY_0_done [get_bd_ports done] [get_bd_pins PROCESSOR_POLY_0/done] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net PROCESSOR_POLY_0_doutb_eth [get_bd_pins PROCESSOR_POLY_0/doutb_eth] [get_bd_pins eth_ip_0/eth_from_proc_data]
  connect_bd_net -net S00_AXIS_tdata_1 [get_bd_ports S00_AXIS_tdata] [get_bd_pins eth_ip_0/s00_axis_tdata]
  connect_bd_net -net S00_AXIS_tlast_1 [get_bd_ports S00_AXIS_tlast] [get_bd_pins eth_ip_0/s00_axis_tlast]
  connect_bd_net -net S00_AXIS_tstrb_1 [get_bd_ports S00_AXIS_tstrb] [get_bd_pins eth_ip_0/s00_axis_tstrb]
  connect_bd_net -net S00_AXIS_tvalid_1 [get_bd_ports S00_AXIS_tvalid] [get_bd_pins eth_ip_0/s00_axis_tvalid]
  connect_bd_net -net ddr_address_1 [get_bd_ports ddr_address] [get_bd_pins PROCESSOR_POLY_0/ddr_address]
  connect_bd_net -net ddr_din_1 [get_bd_ports ddr_din] [get_bd_pins PROCESSOR_POLY_0/ddr_din]
  connect_bd_net -net ddr_interrupt_1 [get_bd_ports ddr_interrupt] [get_bd_pins PROCESSOR_POLY_0/ddr_interrupt]
  connect_bd_net -net ddr_we_1 [get_bd_ports ddr_we] [get_bd_pins PROCESSOR_POLY_0/ddr_we]
  connect_bd_net -net eth_ip_0_Status0 [get_bd_ports Status0] [get_bd_pins eth_ip_0/Status0]
  connect_bd_net -net eth_ip_0_eth_addr [get_bd_pins PROCESSOR_POLY_0/address_eth] [get_bd_pins eth_ip_0/eth_addr]
  connect_bd_net -net eth_ip_0_eth_dinb [get_bd_pins PROCESSOR_POLY_0/dinb_eth] [get_bd_pins eth_ip_0/eth_to_proc_data]
  connect_bd_net -net eth_ip_0_eth_intr [get_bd_pins PROCESSOR_POLY_0/interrupt_eth] [get_bd_pins eth_ip_0/eth_intr] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net eth_ip_0_eth_mem_sel [get_bd_pins PROCESSOR_POLY_0/top_mem_sel] [get_bd_pins eth_ip_0/eth_mem_sel]
  connect_bd_net -net eth_ip_0_eth_proc_sel [get_bd_pins PROCESSOR_POLY_0/processor_sel] [get_bd_pins eth_ip_0/eth_proc_sel]
  connect_bd_net -net eth_ip_0_eth_we [get_bd_pins PROCESSOR_POLY_0/web_eth] [get_bd_pins eth_ip_0/eth_to_proc_we]
  connect_bd_net -net eth_ip_0_m00_axis_tdata [get_bd_ports M00_AXIS_tdata] [get_bd_pins eth_ip_0/m00_axis_tdata]
  connect_bd_net -net eth_ip_0_m00_axis_tlast [get_bd_ports M00_AXIS_tlast] [get_bd_pins eth_ip_0/m00_axis_tlast]
  connect_bd_net -net eth_ip_0_m00_axis_tstrb [get_bd_ports M00_AXIS_tstrb] [get_bd_pins eth_ip_0/m00_axis_tstrb]
  connect_bd_net -net eth_ip_0_m00_axis_tvalid [get_bd_ports M00_AXIS_tvalid] [get_bd_pins eth_ip_0/m00_axis_tvalid]
  connect_bd_net -net eth_ip_0_s00_axis_tready [get_bd_ports S00_AXIS_tready] [get_bd_pins eth_ip_0/s00_axis_tready]
  connect_bd_net -net instruction_1 [get_bd_ports instruction] [get_bd_pins PROCESSOR_POLY_0/instruction] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net modulus_sel_1 [get_bd_ports modulus_sel] [get_bd_pins PROCESSOR_POLY_0/modulus_sel]
  connect_bd_net -net rdM0_1 [get_bd_ports rdM0] [get_bd_pins PROCESSOR_POLY_0/rdM0]
  connect_bd_net -net rdM1_1 [get_bd_ports rdM1] [get_bd_pins PROCESSOR_POLY_0/rdM1]
  connect_bd_net -net s00_axis_aclk_1 [get_bd_ports s00_axis_aclk] [get_bd_pins PROCESSOR_POLY_0/clk] [get_bd_pins eth_ip_0/m00_axis_aclk] [get_bd_pins eth_ip_0/s00_axis_aclk]
  connect_bd_net -net s00_axis_aresetn_1 [get_bd_ports s00_axis_aresetn] [get_bd_pins eth_ip_0/m00_axis_aresetn] [get_bd_pins eth_ip_0/s00_axis_aresetn]
  connect_bd_net -net wtM0_1 [get_bd_ports wtM0] [get_bd_pins PROCESSOR_POLY_0/wtM0]
  connect_bd_net -net wtM1_1 [get_bd_ports wtM1] [get_bd_pins PROCESSOR_POLY_0/wtM1]
  connect_bd_net -net xlconcat_0_dout [get_bd_ports Status1] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconcat_0/In1] [get_bd_pins xlconcat_0/In3] [get_bd_pins xlconcat_0/In5] [get_bd_pins xlconstant_0/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

