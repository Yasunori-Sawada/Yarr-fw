#la32_n
#la32_p
set_property PACKAGE_PIN Y30 [get_ports {fe_data_p[1]}]
set_property PACKAGE_PIN AA30 [get_ports {fe_data_n[1]}]
#la30_n
#la30_p
set_property PACKAGE_PIN AB29 [get_ports {fe_data_p[2]}]
set_property PACKAGE_PIN AB30 [get_ports {fe_data_n[2]}]
#la28_n
#la28_p
set_property PACKAGE_PIN AE30 [get_ports {fe_data_p[3]}]
set_property PACKAGE_PIN AF30 [get_ports {fe_data_n[3]}]
#la26_n
#la26_p
#set_property PACKAGE_PIN J13 [get_ports {fe_clk_p[3]}]
#set_property PACKAGE_PIN H13 [get_ports {fe_clk_n[3]}]
#la00_cc_n
#la00_cc_p
#set_property PACKAGE_PIN R22 [get_ports {fe_data_p[1]}]
#set_property PACKAGE_PIN R23 [get_ports {fe_data_n[1]}]
#la01_cc_n
#la01_cc_p
#set_property PACKAGE_PIN P23 [get_ports {fe_cmd_p[0]}]
#set_property PACKAGE_PIN N23 [get_ports {fe_cmd_n[0]}]
#la02_n
#la02_p
#set_property PACKAGE_PIN AF21 [get_ports {fe_data_p[0]}]
#set_property PACKAGE_PIN AF20 [get_ports {fe_data_n[0]}]
#la03_n
#la03_p
set_property PACKAGE_PIN AG20 [get_ports {fe_clk_p[0]}]
set_property PACKAGE_PIN AH20 [get_ports {fe_clk_n[0]}]
#la04_n
#la04_p
#set_property PACKAGE_PIN W25 [get_ports {fe_data_p[3]}]
#set_property PACKAGE_PIN W26 [get_ports {fe_data_n[3]}]
#la06_n
#la06_p
#set_property PACKAGE_PIN W20 [get_ports {fe_data_p[2]}]
#set_property PACKAGE_PIN Y21 [get_ports {fe_data_n[2]}]
#la33_n
#la33_p
set_property PACKAGE_PIN AC29 [get_ports {fe_cmd_p[0]}]
set_property PACKAGE_PIN AC30 [get_ports {fe_cmd_n[0]}]
#la05_n
#la05_p
set_property PACKAGE_PIN AG22 [get_ports {latch_o}]  
set_property PACKAGE_PIN AH22 [get_ports {sdi_i}]    




#la31_n
#la31_p
set_property PACKAGE_PIN AD29 [get_ports {fe_data_p[0]}]
set_property PACKAGE_PIN AE29 [get_ports {fe_data_n[0]}]
#la29_n
#la29_p
#set_property PACKAGE_PIN E11 [get_ports {fe_cmd_p[2]}]
#set_property PACKAGE_PIN D11 [get_ports {fe_cmd_n[2]}]
#la27_n
#la27_p
#set_property PACKAGE_PIN B15 [get_ports {fe_cmd_p[3]}]
#set_property PACKAGE_PIN A15 [get_ports {fe_cmd_n[3]}]
#la07_n
#la07_p
#set_property PACKAGE_PIN V23 [get_ports {fe_cmd_p[7]}]
#set_property PACKAGE_PIN V24 [get_ports {fe_cmd_n[7]}]



#la24_n
#la24_p
#set_property PACKAGE_PIN D14 [get_ports {fe_data_p[0]}]
#set_property PACKAGE_PIN D13 [get_ports {fe_data_n[0]}]
#la23_n
#la23_p
#set_property PACKAGE_PIN G17 [get_ports {fe_data_p[1]}]
#set_property PACKAGE_PIN F18 [get_ports {fe_data_n[1]}]
#la11_n
#la11_p
#set_property PACKAGE_PIN T24 [get_ports {fe_data_p[2]}]
#set_property PACKAGE_PIN T25 [get_ports {fe_data_n[2]}]
#la10_n
#la10_p
#set_property PACKAGE_PIN U22 [get_ports {fe_data_p[3]}]
#set_property PACKAGE_PIN V22 [get_ports {fe_data_n[3]}]
#la21_n
#la21_p
#set_property PACKAGE_PIN D15 [get_ports {fe_data_p[4]}]
#set_property PACKAGE_PIN D16 [get_ports {fe_data_n[4]}]
#la22_n
#la22_p 
#set_property PACKAGE_PIN C17 [get_ports {fe_data_p[5]}]
#set_property PACKAGE_PIN C18 [get_ports {fe_data_n[5]}]
#la08_n
#la08_p
#set_property PACKAGE_PIN AJ23 [get_ports {fe_data_p[1]}]
#set_property PACKAGE_PIN AJ22 [get_ports {fe_data_n[1]}]
#la09_n
#la09_p
#set_property PACKAGE_PIN G22 [get_ports {fe_data_p[7]}] 
#set_property PACKAGE_PIN F23 [get_ports {fe_data_n[7]}]
#la13_n
#la13_p
set_property PACKAGE_PIN AB24 [get_ports {sda_o}]    
set_property PACKAGE_PIN AC25 [get_ports {scl_o}]    

#la12_n
#set_property PACKAGE_PIN D24 [get_ports {io[0]}]
#la14_n
#set_property PACKAGE_PIN T19 [get_ports {io[1]}]
#la16_n
#set_property PACKAGE_PIN M20 [get_ports {io[2]}]
 
set_property IOSTANDARD LVDS_25 [get_ports fe_cmd_*]
set_property SLEW FAST [get_ports fe_cmd*]

set_property PACKAGE_PIN AB27 [get_ports {sda_io}]   
set_property PACKAGE_PIN AC27 [get_ports {scl_io}]   

set_property IOSTANDARD LVDS_25 [get_ports fe_data_*]
set_property DIFF_TERM TRUE [get_ports fe_data_*]
set_property IBUF_LOW_PWR FALSE [get_ports fe_data_*]

set_property IOSTANDARD LVDS_25 [get_ports fe_clk_*]
set_property SLEW FAST [get_ports fe_clk*]

set_property IOSTANDARD LVCMOS25 [get_ports {scl_o}]
set_property IOSTANDARD LVCMOS25 [get_ports {sda_o}]
set_property IOSTANDARD LVCMOS25 [get_ports {latch_o}]
set_property IOSTANDARD LVCMOS25 [get_ports {sdi_i}]

set_property IOSTANDARD LVCMOS25 [get_ports {sda_io}]
set_property IOSTANDARD LVCMOS25 [get_ports {scl_io}]

##########################
# Fix below for KC705!!
##########################
set_property PACKAGE_PIN AC24 [get_ports {ext_trig_i_p[0]}]
set_property PACKAGE_PIN AD24 [get_ports {ext_trig_i_n[0]}]

set_property PACKAGE_PIN AB27 [get_ports {ext_trig_i_p[1]}]
set_property PACKAGE_PIN AC27 [get_ports {ext_trig_i_n[1]}]

set_property PACKAGE_PIN AD27 [get_ports {ext_trig_i_p[2]}]
set_property PACKAGE_PIN AD28 [get_ports {ext_trig_i_n[2]}]

set_property PACKAGE_PIN AJ26 [get_ports {ext_trig_i_p[3]}]
set_property PACKAGE_PIN AK26 [get_ports {ext_trig_i_n[3]}]

set_property PACKAGE_PIN AG27 [get_ports {eudet_trig_p}]
set_property PACKAGE_PIN AG28 [get_ports {eudet_trig_n}]

set_property PACKAGE_PIN AJ27 [get_ports {eudet_busy_p}]
set_property PACKAGE_PIN AK28 [get_ports {eudet_busy_n}]

set_property PACKAGE_PIN AH26 [get_ports {eudet_clk_p}]
set_property PACKAGE_PIN AH27 [get_ports {eudet_clk_n}]

set_property IOSTANDARD LVDS_25 [get_ports ext_trig_*]
set_property IOSTANDARD LVDS_25 [get_ports eudet_*]
