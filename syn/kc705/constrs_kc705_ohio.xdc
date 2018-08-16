###########################################################
# RD53A signals
###########################################################
#la31_p (DPA0_p)
#la31_n (DPA0_n)
set_property PACKAGE_PIN AD29 [get_ports {fe_data_p[0]}]
set_property PACKAGE_PIN AE29 [get_ports {fe_data_n[0]}]
#la32_p (DPA1_p)
#la32_n (DPA1_n)
set_property PACKAGE_PIN Y30  [get_ports {fe_data_p[1]}]
set_property PACKAGE_PIN AA30 [get_ports {fe_data_n[1]}]
#la30_p (DPA2_p)
#la30_n (DPA2_n)
set_property PACKAGE_PIN AB29 [get_ports {fe_data_p[2]}]
set_property PACKAGE_PIN AB30 [get_ports {fe_data_n[2]}]
#la28_p (DPA3_p)
#la28_n (DPA3_n)
set_property PACKAGE_PIN AE30 [get_ports {fe_data_p[3]}]
set_property PACKAGE_PIN AF30 [get_ports {fe_data_n[3]}]
#la33_p (DPA4_p)
#la33_n (DPA4_n)
set_property PACKAGE_PIN AC29 [get_ports {fe_cmd_p[0]}]
set_property PACKAGE_PIN AC30 [get_ports {fe_cmd_n[0]}]

#la21_p (DPB0_p)
#la21_n (DPB0_n)
set_property PACKAGE_PIN AG27 [get_ports {fe_data_p[4]}]
set_property PACKAGE_PIN AG28 [get_ports {fe_data_n[4]}]
#la29_p (DPB1_p)
#la29_n (DPB1_n)
set_property PACKAGE_PIN AE28 [get_ports {fe_data_p[5]}]
set_property PACKAGE_PIN AF28 [get_ports {fe_data_n[5]}]
#la25_p (DPB2_p)
#la25_n (DPB2_n)
set_property PACKAGE_PIN AC26 [get_ports {fe_data_p[6]}]
set_property PACKAGE_PIN AD26 [get_ports {fe_data_n[6]}]
#la22_p (DPB3_p)
#la22_n (DPB3_n)
set_property PACKAGE_PIN AJ27 [get_ports {fe_data_p[7]}]
set_property PACKAGE_PIN AK28 [get_ports {fe_data_n[7]}]
#la24_p (DPB4_p)
#la24_n (DPB4_n)
set_property PACKAGE_PIN AG30 [get_ports {fe_cmd_p[1]}]
set_property PACKAGE_PIN AH30 [get_ports {fe_cmd_n[1]}]

#la12_p (DPC0_p)
#la12_n (DPC0_n)
set_property PACKAGE_PIN AA20 [get_ports {fe_data_p[8]}]
set_property PACKAGE_PIN AB20 [get_ports {fe_data_n[8]}]
#la15_p (DPC1_p)
#la15_n (DPC1_n)
set_property PACKAGE_PIN AC24 [get_ports {fe_data_p[9]}]
set_property PACKAGE_PIN AD24 [get_ports {fe_data_n[9]}]
#la11_p (DPC2_p)
#la11_n (DPC2_n)
set_property PACKAGE_PIN AE25 [get_ports {fe_data_p[10]}]
set_property PACKAGE_PIN AF25 [get_ports {fe_data_n[10]}]
#la07_p (DPC3_p)
#la07_n (DPC3_n)
set_property PACKAGE_PIN AG25 [get_ports {fe_data_p[11]}]
set_property PACKAGE_PIN AH25 [get_ports {fe_data_n[11]}]
#la16_p (DPC4_p)
#la16_n (DPC4_n)
set_property PACKAGE_PIN AC22 [get_ports {fe_cmd_p[2]}]
set_property PACKAGE_PIN AD22 [get_ports {fe_cmd_n[2]}]

#la02_p (DPD0_p)
#la02_n (DPD0_n)
set_property PACKAGE_PIN AF20 [get_ports {fe_data_p[12]}]
set_property PACKAGE_PIN AF21 [get_ports {fe_data_n[12]}]
#la08_p (DPD1_p)
#la08_n (DPD1_n)
set_property PACKAGE_PIN AJ22 [get_ports {fe_data_p[13]}]
set_property PACKAGE_PIN AJ23 [get_ports {fe_data_n[13]}]
#la03_p (DPD2_p)
#la03_n (DPD2_n)
set_property PACKAGE_PIN AG20 [get_ports {fe_data_p[14]}]
set_property PACKAGE_PIN AH20 [get_ports {fe_data_n[14]}]
#la00_cc_p (DPD3_p)
#la00_cc_n (DPD3_n)
set_property PACKAGE_PIN AD23 [get_ports {fe_data_p[15]}]
set_property PACKAGE_PIN AE24 [get_ports {fe_data_n[15]}]
#la04_p (DPD4_p)
#la04_n (DPD4_n)
set_property PACKAGE_PIN AH21 [get_ports {fe_cmd_p[3]}]
set_property PACKAGE_PIN AJ21 [get_ports {fe_cmd_n[3]}]

#Output standard for fe_data*
set_property IOSTANDARD LVDS_25 [get_ports fe_data_*]
set_property DIFF_TERM TRUE [get_ports fe_data_*]
set_property IBUF_LOW_PWR FALSE [get_ports fe_data_*]

#Output standard for fe_cmd*
set_property IOSTANDARD LVDS_25 [get_ports fe_cmd_*]
#set_property SLEW FAST [get_ports fe_cmd*]

###########################################################
# fe_clk_* is instantiated but not actuary used for RD53A
# connected to harmless ports...
###########################################################
#la20_p
#la20_n
set_property PACKAGE_PIN AF26 [get_ports {fe_clk_p[0]}]
set_property PACKAGE_PIN AF27 [get_ports {fe_clk_n[0]}]
#la23_p
#la23_n
set_property PACKAGE_PIN AH26 [get_ports {fe_clk_p[1]}]
set_property PACKAGE_PIN AH27 [get_ports {fe_clk_n[1]}]
#la26_p
#la26_n
set_property PACKAGE_PIN AK29 [get_ports {fe_clk_p[2]}]
set_property PACKAGE_PIN AK30 [get_ports {fe_clk_n[2]}]
#la27_p
#la27_n
set_property PACKAGE_PIN AJ28 [get_ports {fe_clk_p[3]}]
set_property PACKAGE_PIN AJ29 [get_ports {fe_clk_n[3]}]

#Output standard for fe_clk*
set_property IOSTANDARD LVDS_25 [get_ports fe_clk_*]
#set_property SLEW FAST [get_ports fe_clk*]

###########################################################
# Other control signals
###########################################################
#la05_p
set_property PACKAGE_PIN AG22 [get_ports {latch_o}]
#la05_n
set_property PACKAGE_PIN AH22 [get_ports {sdi_i}]
#la13_p
set_property PACKAGE_PIN AB24 [get_ports {sda_o}]
#la13_n
set_property PACKAGE_PIN AC25 [get_ports {scl_o}]
#la17_cc_p
set_property PACKAGE_PIN AB27 [get_ports {sda_io}]
#la17_cc_n
set_property PACKAGE_PIN AC27 [get_ports {scl_io}]

#Output standard for above signals
set_property IOSTANDARD LVCMOS25 [get_ports {latch_o}]
set_property IOSTANDARD LVCMOS25 [get_ports {sdi_i}]
set_property IOSTANDARD LVCMOS25 [get_ports {sda_o}]
set_property IOSTANDARD LVCMOS25 [get_ports {scl_o}]
set_property IOSTANDARD LVCMOS25 [get_ports {sda_io}]
set_property IOSTANDARD LVCMOS25 [get_ports {scl_io}]

##########################
# Fix below for KC705!!
##########################
#la01_cc_p
#la01_cc_n
set_property PACKAGE_PIN AE23 [get_ports {ext_trig_i_p[0]}]
set_property PACKAGE_PIN AF23 [get_ports {ext_trig_i_n[0]}]
#la06_p
#la06_n
set_property PACKAGE_PIN AK20 [get_ports {ext_trig_i_p[1]}]
set_property PACKAGE_PIN AK21 [get_ports {ext_trig_i_n[1]}]
#la09_p
#la09_n
set_property PACKAGE_PIN AK23 [get_ports {ext_trig_i_p[2]}]
set_property PACKAGE_PIN AK24 [get_ports {ext_trig_i_n[2]}]
#la10_p
#la10_n
set_property PACKAGE_PIN AJ24 [get_ports {ext_trig_i_p[3]}]
set_property PACKAGE_PIN AK25 [get_ports {ext_trig_i_n[3]}]
#la14_p
#la14_n
set_property PACKAGE_PIN AD21 [get_ports {eudet_trig_p}]
set_property PACKAGE_PIN AE21 [get_ports {eudet_trig_n}]
#la18_p
#la18_n
set_property PACKAGE_PIN AD27 [get_ports {eudet_busy_p}]
set_property PACKAGE_PIN AD28 [get_ports {eudet_busy_n}]
#la19_p
#la19_n
set_property PACKAGE_PIN AJ26 [get_ports {eudet_clk_p}]
set_property PACKAGE_PIN AK26 [get_ports {eudet_clk_n}]

set_property IOSTANDARD LVDS_25 [get_ports ext_trig_*]
set_property IOSTANDARD LVDS_25 [get_ports eudet_*]

#  Rising Edge Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Max Skew Case:
#  The skew requirements for FPGA are known from system level analysis.
#
# forwarded                _____________        
# clock        ___________|             |_________
#                         |                        
#                 bre_skew|are_skew          
#                 <------>|<------>        
#           ______        |        ____________    
# data      ______XXXXXXXXXXXXXXXXX____________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	  

set fwclk           clk_160_s; # forwarded clock name (generated using create_generated_clock at output clock port)
set fwclk_period    6.25;      # forwarded clock period
set bre_skew        -0.050;    # skew requirement before rising edge
set are_skew        0.050;     # skew requirement after rising edge
set output_ports    fe_cmd_*;  # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $fwclk_period - $are_skew] [get_ports $output_ports];
set_output_delay -clock $fwclk -min $bre_skew                        [get_ports $output_ports];

# Report Timing Template
# report_timing -to [get_ports $output_ports] -max_paths 20 -nworst 1 -delay_type min_max -name src_sync_pos_out -file src_sync_pos_out.txt;
