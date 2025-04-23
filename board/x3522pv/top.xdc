set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable    [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE           [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0          [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup         [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes       [current_design]

# 300MHz User Clock
set_property -dict {LOC AL23 IOSTANDARD LVDS} [get_ports clk_user_clk_n]
set_property -dict {LOC AK23 IOSTANDARD LVDS} [get_ports clk_user_clk_p]

# PCIe
create_clock -name sys_clk -period 10 [get_ports pcie_refclk_clk_p]
set_false_path -from [get_ports pcie_perstn]
set_property PULLUP true [get_ports pcie_perstn]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_perstn]
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *_PERSTN0_65}] [get_ports pcie_perstn]
set_property PACKAGE_PIN AK18 [get_ports pcie_perstn]
set_property PACKAGE_PIN AL10 [get_ports {pcie_refclk_clk_p}]

#################################################################################
#
#  DDR4 Interface
#
#################################################################################
#  300MHz DDR4 Clock 
set_property PACKAGE_PIN AN27              [get_ports "default_300mhz_clk0_clk_p"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L13P_T2L_N0_GC_QBC_66_AN27
set_property IOSTANDARD LVDS               [get_ports "default_300mhz_clk0_clk_p"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L13P_T2L_N0_GC_QBC_66_AN27
set_property PACKAGE_PIN AN28              [get_ports "default_300mhz_clk0_clk_n"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L13N_T2L_N1_GC_QBC_66_AN28
set_property IOSTANDARD LVDS               [get_ports "default_300mhz_clk0_clk_n"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L13N_T2L_N1_GC_QBC_66_AN28
#
#  DDR4 Active High Output from Ultrascale+ Device to hold all External DDR4 interfaces in Self refresh.
#                  This output disconnects the memory interface reset and holds it in active and pulls the clock enables signal on the memory interfaces.
#
#set_property PACKAGE_PIN AN18              [get_ports "DDR4_C0_RESET_GATE"]    ;#  Bank  65 VCCO - +1V8_SYS
#set_property IOSTANDARD LVCMOS18           [get_ports "DDR4_C0_RESET_GATE"]    ;#  Bank  65 VCCO - +1V8_SYS

#
#  DDR4 RDIMM Controller 0, 72-bit Data Interface, x5  Components, Single Rank
#     Banks 66, 67, 68 (1.2V)
#     Part Number MT40A1G16KD-062E
#
set_property PACKAGE_PIN AM30              [get_ports "ddr4_sdram_c0_adr[0]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L2P_T0L_N2_66_AM30
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[0]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L2P_T0L_N2_66_AM30
set_property PACKAGE_PIN AR31              [get_ports "ddr4_sdram_c0_adr[1]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L5P_T0U_N8_AD14P_66_AR31
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[1]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L5P_T0U_N8_AD14P_66_AR31
set_property PACKAGE_PIN AN29              [get_ports "ddr4_sdram_c0_adr[10]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L3P_T0L_N4_AD15P_66_AN29
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[10]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L3P_T0L_N4_AD15P_66_AN29
set_property PACKAGE_PIN AR28              [get_ports "ddr4_sdram_c0_adr[11]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L8P_T1L_N2_AD5P_66_AR28
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[11]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L8P_T1L_N2_AD5P_66_AR28
set_property PACKAGE_PIN AP30              [get_ports "ddr4_sdram_c0_adr[12]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L4N_T0U_N7_DBC_AD7N_66_AP30
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[12]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L4N_T0U_N7_DBC_AD7N_66_AP30
set_property PACKAGE_PIN AU25              [get_ports "ddr4_sdram_c0_adr[13]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_T1U_N12_66_AU25
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[13]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_T1U_N12_66_AU25
set_property PACKAGE_PIN AP29              [get_ports "ddr4_sdram_c0_adr[2]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L4P_T0U_N6_DBC_AD7P_66_AP29
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[2]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L4P_T0U_N6_DBC_AD7P_66_AP29
set_property PACKAGE_PIN AT30              [get_ports "ddr4_sdram_c0_adr[3]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L6N_T0U_N11_AD6N_66_AT30
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[3]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L6N_T0U_N11_AD6N_66_AT30
set_property PACKAGE_PIN AL30              [get_ports "ddr4_sdram_c0_adr[4]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L1P_T0L_N0_DBC_66_AL30
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[4]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L1P_T0L_N0_DBC_66_AL30
set_property PACKAGE_PIN AT26              [get_ports "ddr4_sdram_c0_adr[5]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L10P_T1U_N6_QBC_AD4P_66_AT26
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[5]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L10P_T1U_N6_QBC_AD4P_66_AT26
set_property PACKAGE_PIN AL31              [get_ports "ddr4_sdram_c0_adr[6]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L1N_T0L_N1_DBC_66_AL31
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[6]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L1N_T0L_N1_DBC_66_AL31
set_property PACKAGE_PIN AU26              [get_ports "ddr4_sdram_c0_adr[7]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L10N_T1U_N7_QBC_AD4N_66_AU26
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[7]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L10N_T1U_N7_QBC_AD4N_66_AU26
set_property PACKAGE_PIN AT28              [get_ports "ddr4_sdram_c0_adr[8]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L8N_T1L_N3_AD5N_66_AT28
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[8]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L8N_T1L_N3_AD5N_66_AT28
set_property PACKAGE_PIN AR29              [get_ports "ddr4_sdram_c0_adr[9]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L6P_T0U_N10_AD6P_66_AR29
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[9]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L6P_T0U_N10_AD6P_66_AR29
set_property PACKAGE_PIN AM27              [get_ports "ddr4_sdram_c0_act_n"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L15N_T2L_N5_AD11N_66_AM27
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_act_n"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L15N_T2L_N5_AD11N_66_AM27
set_property PACKAGE_PIN AN30              [get_ports "ddr4_sdram_c0_ba[0]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L3N_T0L_N5_AD15N_66_AN30
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_ba[0]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L3N_T0L_N5_AD15N_66_AN30
set_property PACKAGE_PIN AU27              [get_ports "ddr4_sdram_c0_ba[1]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L9P_T1L_N4_AD12P_66_AU27
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_ba[1]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L9P_T1L_N4_AD12P_66_AU27
set_property PACKAGE_PIN AK26              [get_ports "ddr4_sdram_c0_bg[0]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L16P_T2U_N6_QBC_AD3P_66_AK26
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_bg[0]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L16P_T2U_N6_QBC_AD3P_66_AK26
set_property PACKAGE_PIN AR27              [get_ports "ddr4_sdram_c0_adr[15]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L11N_T1U_N9_GC_66_AR27
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[15]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L11N_T1U_N9_GC_66_AR27
set_property PACKAGE_PIN AU30              [get_ports "ddr4_sdram_c0_ck_c"]          ;#  Bank  66 VCCO - 1V2_VCCO - IO_L7N_T1L_N1_QBC_AD13N_66_AU30
set_property IOSTANDARD DIFF_SSTL12_DCI    [get_ports "ddr4_sdram_c0_ck_c"]          ;#  Bank  66 VCCO - 1V2_VCCO - IO_L7N_T1L_N1_QBC_AD13N_66_AU30
set_property PACKAGE_PIN AT29              [get_ports "ddr4_sdram_c0_ck_t"]          ;#  Bank  66 VCCO - 1V2_VCCO - IO_L7P_T1L_N0_QBC_AD13P_66_AT29
set_property IOSTANDARD DIFF_SSTL12_DCI    [get_ports "ddr4_sdram_c0_ck_t"]          ;#  Bank  66 VCCO - 1V2_VCCO - IO_L7P_T1L_N0_QBC_AD13P_66_AT29
set_property PACKAGE_PIN AL26              [get_ports "ddr4_sdram_c0_cke"]           ;#  Bank  66 VCCO - 1V2_VCCO - IO_L16N_T2U_N7_QBC_AD3N_66_AL26
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_cke"]           ;#  Bank  66 VCCO - 1V2_VCCO - IO_L16N_T2U_N7_QBC_AD3N_66_AL26
set_property PACKAGE_PIN AM31              [get_ports "ddr4_sdram_c0_cs_n"]          ;#  Bank  66 VCCO - 1V2_VCCO - IO_L2N_T0L_N3_66_AM31
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_cs_n"]          ;#  Bank  66 VCCO - 1V2_VCCO - IO_L2N_T0L_N3_66_AM31
set_property PACKAGE_PIN AN37              [get_ports "ddr4_sdram_c0_dm_n[0]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L7P_T1L_N0_QBC_AD13P_67_AN37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[0]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L7P_T1L_N0_QBC_AD13P_67_AN37
set_property PACKAGE_PIN AK29              [get_ports "ddr4_sdram_c0_dm_n[1]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L19P_T3L_N0_DBC_AD9P_66_AK29#
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[1]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L19P_T3L_N0_DBC_AD9P_66_AK29
set_property PACKAGE_PIN Y33               [get_ports "ddr4_sdram_c0_dm_n[2]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L19P_T3L_N0_DBC_AD9P_68_Y33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[2]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L19P_T3L_N0_DBC_AD9P_68_Y33
set_property PACKAGE_PIN AB36              [get_ports "ddr4_sdram_c0_dm_n[3]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L1P_T0L_N0_DBC_68_AB36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[3]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L1P_T0L_N0_DBC_68_AB36
set_property PACKAGE_PIN AM36              [get_ports "ddr4_sdram_c0_dm_n[4]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L13P_T2L_N0_GC_QBC_67_AM36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[4]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L13P_T2L_N0_GC_QBC_67_AM36
set_property PACKAGE_PIN AH37              [get_ports "ddr4_sdram_c0_dm_n[5]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L19P_T3L_N0_DBC_AD9P_67_AH37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[5]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L19P_T3L_N0_DBC_AD9P_67_AH37
set_property PACKAGE_PIN AC37              [get_ports "ddr4_sdram_c0_dm_n[6]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L7P_T1L_N0_QBC_AD13P_68_AC37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[6]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L7P_T1L_N0_QBC_AD13P_68_AC37
set_property PACKAGE_PIN AE32              [get_ports "ddr4_sdram_c0_dm_n[7]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L13P_T2L_N0_GC_QBC_68_AE32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[7]"]       ;#  Bank  68 VCCO - 1V2_VCCO - IO_L13P_T2L_N0_GC_QBC_68_AE32
set_property PACKAGE_PIN AU31              [get_ports "ddr4_sdram_c0_dm_n[8]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L1P_T0L_N0_DBC_67_AU31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dm_n[8]"]       ;#  Bank  67 VCCO - 1V2_VCCO - IO_L1P_T0L_N0_DBC_67_AU31
set_property PACKAGE_PIN AM35              [get_ports "ddr4_sdram_c0_dq[0]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L12P_T1U_N10_GC_67_AM35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[0]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L12P_T1U_N10_GC_67_AM35
set_property PACKAGE_PIN AP34              [get_ports "ddr4_sdram_c0_dq[1]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L9N_T1L_N5_AD12N_67_AP34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[1]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L9N_T1L_N5_AD12N_67_AP34
set_property PACKAGE_PIN AJ31              [get_ports "ddr4_sdram_c0_dq[10]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L20N_T3L_N3_AD1N_66_AJ31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[10]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L20N_T3L_N3_AD1N_66_AJ31
set_property PACKAGE_PIN AG31              [get_ports "ddr4_sdram_c0_dq[11]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L24N_T3U_N11_66_AG31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[11]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L24N_T3U_N11_66_AG31
set_property PACKAGE_PIN AH29              [get_ports "ddr4_sdram_c0_dq[12]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L21P_T3L_N4_AD8P_66_AH29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[12]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L21P_T3L_N4_AD8P_66_AH29
set_property PACKAGE_PIN AF30              [get_ports "ddr4_sdram_c0_dq[13]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L23N_T3U_N9_66_AF30
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[13]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L23N_T3U_N9_66_AF30
set_property PACKAGE_PIN AJ30              [get_ports "ddr4_sdram_c0_dq[14]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L20P_T3L_N2_AD1P_66_AJ30
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[14]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L20P_T3L_N2_AD1P_66_AJ30
set_property PACKAGE_PIN AF29              [get_ports "ddr4_sdram_c0_dq[15]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L23P_T3U_N8_66_AF29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[15]"]        ;#  Bank  66 VCCO - 1V2_VCCO - IO_L23P_T3U_N8_66_AF29
set_property PACKAGE_PIN AB32              [get_ports "ddr4_sdram_c0_dq[16]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L21N_T3L_N5_AD8N_68_AB32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[16]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L21N_T3L_N5_AD8N_68_AB32
set_property PACKAGE_PIN Y32               [get_ports "ddr4_sdram_c0_dq[17]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L20N_T3L_N3_AD1N_68_Y32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[17]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L20N_T3L_N3_AD1N_68_Y32
set_property PACKAGE_PIN W32               [get_ports "ddr4_sdram_c0_dq[18]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L20P_T3L_N2_AD1P_68_W32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[18]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L20P_T3L_N2_AD1P_68_W32
set_property PACKAGE_PIN W31               [get_ports "ddr4_sdram_c0_dq[19]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L23N_T3U_N9_68_W31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[19]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L23N_T3U_N9_68_W31
set_property PACKAGE_PIN AN33              [get_ports "ddr4_sdram_c0_dq[2]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L9P_T1L_N4_AD12P_67_AN33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[2]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L9P_T1L_N4_AD12P_67_AN33
set_property PACKAGE_PIN AB31              [get_ports "ddr4_sdram_c0_dq[20]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L21P_T3L_N4_AD8P_68_AB31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[20]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L21P_T3L_N4_AD8P_68_AB31
set_property PACKAGE_PIN W30               [get_ports "ddr4_sdram_c0_dq[21]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L23P_T3U_N8_68_W30
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[21]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L23P_T3U_N8_68_W30
set_property PACKAGE_PIN AA29              [get_ports "ddr4_sdram_c0_dq[22]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L24N_T3U_N11_68_AA29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[22]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L24N_T3U_N11_68_AA29
set_property PACKAGE_PIN Y29               [get_ports "ddr4_sdram_c0_dq[23]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L24P_T3U_N10_68_Y29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[23]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L24P_T3U_N10_68_Y29
set_property PACKAGE_PIN Y34               [get_ports "ddr4_sdram_c0_dq[24]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L5P_T0U_N8_AD14P_68_Y34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[24]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L5P_T0U_N8_AD14P_68_Y34
set_property PACKAGE_PIN AA35              [get_ports "ddr4_sdram_c0_dq[25]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L5N_T0U_N9_AD14N_68_AA35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[25]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L5N_T0U_N9_AD14N_68_AA35
set_property PACKAGE_PIN W36               [get_ports "ddr4_sdram_c0_dq[26]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L3P_T0L_N4_AD15P_68_W36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[26]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L3P_T0L_N4_AD15P_68_W36
set_property PACKAGE_PIN AA34              [get_ports "ddr4_sdram_c0_dq[27]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L6P_T0U_N10_AD6P_68_AA34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[27]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L6P_T0U_N10_AD6P_68_AA34
set_property PACKAGE_PIN AA36              [get_ports "ddr4_sdram_c0_dq[28]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L2N_T0L_N3_68_AA36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[28]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L2N_T0L_N3_68_AA36
set_property PACKAGE_PIN W37               [get_ports "ddr4_sdram_c0_dq[29]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L3N_T0L_N5_AD15N_68_W37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[29]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L3N_T0L_N5_AD15N_68_W37
set_property PACKAGE_PIN AN34              [get_ports "ddr4_sdram_c0_dq[3]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L11N_T1U_N9_GC_67_AN34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[3]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L11N_T1U_N9_GC_67_AN34
set_property PACKAGE_PIN Y36               [get_ports "ddr4_sdram_c0_dq[30]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L2P_T0L_N2_68_Y36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[30]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L2P_T0L_N2_68_Y36
set_property PACKAGE_PIN AB35              [get_ports "ddr4_sdram_c0_dq[31]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L6N_T0U_N11_AD6N_68_AB35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[31]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L6N_T0U_N11_AD6N_68_AB35
set_property PACKAGE_PIN AL34              [get_ports "ddr4_sdram_c0_dq[32]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L15N_T2L_N5_AD11N_67_AL34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[32]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L15N_T2L_N5_AD11N_67_AL34
set_property PACKAGE_PIN AL36              [get_ports "ddr4_sdram_c0_dq[33]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L14N_T2L_N3_GC_67_AL36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[33]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L14N_T2L_N3_GC_67_AL36
set_property PACKAGE_PIN AL35              [get_ports "ddr4_sdram_c0_dq[34]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L14P_T2L_N2_GC_67_AL35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[34]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L14P_T2L_N2_GC_67_AL35
set_property PACKAGE_PIN AK36              [get_ports "ddr4_sdram_c0_dq[35]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L17P_T2U_N8_AD10P_67_AK36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[35]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L17P_T2U_N8_AD10P_67_AK36
set_property PACKAGE_PIN AL33              [get_ports "ddr4_sdram_c0_dq[36]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L15P_T2L_N4_AD11P_67_AL33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[36]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L15P_T2L_N4_AD11P_67_AL33
set_property PACKAGE_PIN AK37              [get_ports "ddr4_sdram_c0_dq[37]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L17N_T2U_N9_AD10N_67_AK37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[37]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L17N_T2U_N9_AD10N_67_AK37
set_property PACKAGE_PIN AJ36              [get_ports "ddr4_sdram_c0_dq[38]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L18N_T2U_N11_AD2N_67_AJ36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[38]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L18N_T2U_N11_AD2N_67_AJ36
set_property PACKAGE_PIN AJ35              [get_ports "ddr4_sdram_c0_dq[39]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L18P_T2U_N10_AD2P_67_AJ35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[39]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L18P_T2U_N10_AD2P_67_AJ35
set_property PACKAGE_PIN AM33              [get_ports "ddr4_sdram_c0_dq[4]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L11P_T1U_N8_GC_67_AM33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[4]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L11P_T1U_N8_GC_67_AM33
set_property PACKAGE_PIN AG35              [get_ports "ddr4_sdram_c0_dq[40]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L23P_T3U_N8_67_AG35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[40]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L23P_T3U_N8_67_AG35
set_property PACKAGE_PIN AH32              [get_ports "ddr4_sdram_c0_dq[41]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L21P_T3L_N4_AD8P_67_AH32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[41]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L21P_T3L_N4_AD8P_67_AH32
set_property PACKAGE_PIN AH35              [get_ports "ddr4_sdram_c0_dq[42]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L23N_T3U_N9_67_AH35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[42]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L23N_T3U_N9_67_AH35
set_property PACKAGE_PIN AG37              [get_ports "ddr4_sdram_c0_dq[43]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L24N_T3U_N11_67_AG37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[43]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L24N_T3U_N11_67_AG37
set_property PACKAGE_PIN AH34              [get_ports "ddr4_sdram_c0_dq[44]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L20P_T3L_N2_AD1P_67_AH34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[44]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L20P_T3L_N2_AD1P_67_AH34
set_property PACKAGE_PIN AJ32              [get_ports "ddr4_sdram_c0_dq[45]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L21N_T3L_N5_AD8N_67_AJ32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[45]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L21N_T3L_N5_AD8N_67_AJ32
set_property PACKAGE_PIN AJ34              [get_ports "ddr4_sdram_c0_dq[46]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L20N_T3L_N3_AD1N_67_AJ34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[46]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L20N_T3L_N3_AD1N_67_AJ34
set_property PACKAGE_PIN AG36              [get_ports "ddr4_sdram_c0_dq[47]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L24P_T3U_N10_67_AG36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[47]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L24P_T3U_N10_67_AG36
set_property PACKAGE_PIN AE36              [get_ports "ddr4_sdram_c0_dq[48]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L9P_T1L_N4_AD12P_68_AE36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[48]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L9P_T1L_N4_AD12P_68_AE36
set_property PACKAGE_PIN AC34              [get_ports "ddr4_sdram_c0_dq[49]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L11P_T1U_N8_GC_68_AC34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[49]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L11P_T1U_N8_GC_68_AC34
set_property PACKAGE_PIN AR37              [get_ports "ddr4_sdram_c0_dq[5]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L8N_T1L_N3_AD5N_67_AR37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[5]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L8N_T1L_N3_AD5N_67_AR37
set_property PACKAGE_PIN AD36              [get_ports "ddr4_sdram_c0_dq[50]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L8P_T1L_N2_AD5P_68_AD36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[50]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L8P_T1L_N2_AD5P_68_AD36
set_property PACKAGE_PIN AD34              [get_ports "ddr4_sdram_c0_dq[51]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L11N_T1U_N9_GC_68_AD34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[51]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L11N_T1U_N9_GC_68_AD34
set_property PACKAGE_PIN AE37              [get_ports "ddr4_sdram_c0_dq[52]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L8N_T1L_N3_AD5N_68_AE37
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[52]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L8N_T1L_N3_AD5N_68_AE37
set_property PACKAGE_PIN AE34              [get_ports "ddr4_sdram_c0_dq[53]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L12P_T1U_N10_GC_68_AE34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[53]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L12P_T1U_N10_GC_68_AE34
set_property PACKAGE_PIN AF36              [get_ports "ddr4_sdram_c0_dq[54]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L9N_T1L_N5_AD12N_68_AF36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[54]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L9N_T1L_N5_AD12N_68_AF36
set_property PACKAGE_PIN AF34              [get_ports "ddr4_sdram_c0_dq[55]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L12N_T1U_N11_GC_68_AF34
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[55]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L12N_T1U_N11_GC_68_AF34
set_property PACKAGE_PIN AB33              [get_ports "ddr4_sdram_c0_dq[56]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L18P_T2U_N10_AD2P_68_AB33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[56]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L18P_T2U_N10_AD2P_68_AB33
set_property PACKAGE_PIN AD30              [get_ports "ddr4_sdram_c0_dq[57]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L14P_T2L_N2_GC_68_AD30
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[57]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L14P_T2L_N2_GC_68_AD30
set_property PACKAGE_PIN AC33              [get_ports "ddr4_sdram_c0_dq[58]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L18N_T2U_N11_AD2N_68_AC33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[58]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L18N_T2U_N11_AD2N_68_AC33
set_property PACKAGE_PIN AC32              [get_ports "ddr4_sdram_c0_dq[59]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L17P_T2U_N8_AD10P_68_AC32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[59]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L17P_T2U_N8_AD10P_68_AC32
set_property PACKAGE_PIN AN35              [get_ports "ddr4_sdram_c0_dq[6]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L12N_T1U_N11_GC_67_AN35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[6]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L12N_T1U_N11_GC_67_AN35
set_property PACKAGE_PIN AD32              [get_ports "ddr4_sdram_c0_dq[60]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L17N_T2U_N9_AD10N_68_AD32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[60]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L17N_T2U_N9_AD10N_68_AD32
set_property PACKAGE_PIN AC29              [get_ports "ddr4_sdram_c0_dq[61]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L15P_T2L_N4_AD11P_68_AC29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[61]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L15P_T2L_N4_AD11P_68_AC29
set_property PACKAGE_PIN AE31              [get_ports "ddr4_sdram_c0_dq[62]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L14N_T2L_N3_GC_68_AE31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[62]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L14N_T2L_N3_GC_68_AE31
set_property PACKAGE_PIN AD29              [get_ports "ddr4_sdram_c0_dq[63]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L15N_T2L_N5_AD11N_68_AD29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[63]"]        ;#  Bank  68 VCCO - 1V2_VCCO - IO_L15N_T2L_N5_AD11N_68_AD29
set_property PACKAGE_PIN AU33              [get_ports "ddr4_sdram_c0_dq[64]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L2N_T0L_N3_67_AU33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[64]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L2N_T0L_N3_67_AU33
set_property PACKAGE_PIN AT36              [get_ports "ddr4_sdram_c0_dq[65]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L5N_T0U_N9_AD14N_67_AT36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[65]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L5N_T0U_N9_AD14N_67_AT36
set_property PACKAGE_PIN AT33              [get_ports "ddr4_sdram_c0_dq[66]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L2P_T0L_N2_67_AT33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[66]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L2P_T0L_N2_67_AT33
set_property PACKAGE_PIN AR36              [get_ports "ddr4_sdram_c0_dq[67]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L6N_T0U_N11_AD6N_67_AR36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[67]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L6N_T0U_N11_AD6N_67_AR36
set_property PACKAGE_PIN AR32              [get_ports "ddr4_sdram_c0_dq[68]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L3P_T0L_N4_AD15P_67_AR32
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[68]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L3P_T0L_N4_AD15P_67_AR32
set_property PACKAGE_PIN AP35              [get_ports "ddr4_sdram_c0_dq[69]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L6P_T0U_N10_AD6P_67_AP35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[69]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L6P_T0U_N10_AD6P_67_AP35
set_property PACKAGE_PIN AP36              [get_ports "ddr4_sdram_c0_dq[7]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L8P_T1L_N2_AD5P_67_AP36
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[7]"]         ;#  Bank  67 VCCO - 1V2_VCCO - IO_L8P_T1L_N2_AD5P_67_AP36
set_property PACKAGE_PIN AT35              [get_ports "ddr4_sdram_c0_dq[70]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L5P_T0U_N8_AD14P_67_AT35
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[70]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L5P_T0U_N8_AD14P_67_AT35
set_property PACKAGE_PIN AR33              [get_ports "ddr4_sdram_c0_dq[71]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L3N_T0L_N5_AD15N_67_AR33
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[71]"]        ;#  Bank  67 VCCO - 1V2_VCCO - IO_L3N_T0L_N5_AD15N_67_AR33
set_property PACKAGE_PIN AJ29              [get_ports "ddr4_sdram_c0_dq[8]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L21N_T3L_N5_AD8N_66_AJ29
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[8]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L21N_T3L_N5_AD8N_66_AJ29
set_property PACKAGE_PIN AF31              [get_ports "ddr4_sdram_c0_dq[9]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L24P_T3U_N10_66_AF31
set_property IOSTANDARD POD12_DCI          [get_ports "ddr4_sdram_c0_dq[9]"]         ;#  Bank  66 VCCO - 1V2_VCCO - IO_L24P_T3U_N10_66_AF31
set_property PACKAGE_PIN AN32              [get_ports "ddr4_sdram_c0_dqs_c[0]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L10N_T1U_N7_QBC_AD4N_67_AN32
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[0]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L10N_T1U_N7_QBC_AD4N_67_AN32
set_property PACKAGE_PIN AH30              [get_ports "ddr4_sdram_c0_dqs_c[1]"]      ;#  Bank  66 VCCO - 1V2_VCCO - IO_L22N_T3U_N7_DBC_AD0N_66_AH30
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[1]"]      ;#  Bank  66 VCCO - 1V2_VCCO - IO_L22N_T3U_N7_DBC_AD0N_66_AH30
set_property PACKAGE_PIN AA31              [get_ports "ddr4_sdram_c0_dqs_c[2]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L22N_T3U_N7_DBC_AD0N_68_AA31
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[2]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L22N_T3U_N7_DBC_AD0N_68_AA31
set_property PACKAGE_PIN W35               [get_ports "ddr4_sdram_c0_dqs_c[3]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L4N_T0U_N7_DBC_AD7N_68_W35
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[3]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L4N_T0U_N7_DBC_AD7N_68_W35
set_property PACKAGE_PIN AK34              [get_ports "ddr4_sdram_c0_dqs_c[4]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L16N_T2U_N7_QBC_AD3N_67_AK34
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[4]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L16N_T2U_N7_QBC_AD3N_67_AK34
set_property PACKAGE_PIN AG33              [get_ports "ddr4_sdram_c0_dqs_c[5]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L22N_T3U_N7_DBC_AD0N_67_AG33
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[5]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L22N_T3U_N7_DBC_AD0N_67_AG33
set_property PACKAGE_PIN AD35              [get_ports "ddr4_sdram_c0_dqs_c[6]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L10N_T1U_N7_QBC_AD4N_68_AD35
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[6]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L10N_T1U_N7_QBC_AD4N_68_AD35
set_property PACKAGE_PIN AD31              [get_ports "ddr4_sdram_c0_dqs_c[7]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L16N_T2U_N7_QBC_AD3N_68_AD31
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[7]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L16N_T2U_N7_QBC_AD3N_68_AD31
set_property PACKAGE_PIN AU35              [get_ports "ddr4_sdram_c0_dqs_c[8]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L4N_T0U_N7_DBC_AD7N_67_AU35
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_c[8]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L4N_T0U_N7_DBC_AD7N_67_AU35
set_property PACKAGE_PIN AM32              [get_ports "ddr4_sdram_c0_dqs_t[0]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L10P_T1U_N6_QBC_AD4P_67_AM32
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[0]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L10P_T1U_N6_QBC_AD4P_67_AM32
set_property PACKAGE_PIN AG30              [get_ports "ddr4_sdram_c0_dqs_t[1]"]      ;#  Bank  66 VCCO - 1V2_VCCO - IO_L22P_T3U_N6_DBC_AD0P_66_AG30
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[1]"]      ;#  Bank  66 VCCO - 1V2_VCCO - IO_L22P_T3U_N6_DBC_AD0P_66_AG30
set_property PACKAGE_PIN Y31               [get_ports "ddr4_sdram_c0_dqs_t[2]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L22P_T3U_N6_DBC_AD0P_68_Y31
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[2]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L22P_T3U_N6_DBC_AD0P_68_Y31
set_property PACKAGE_PIN W34               [get_ports "ddr4_sdram_c0_dqs_t[3]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L4P_T0U_N6_DBC_AD7P_68_W34
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[3]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L4P_T0U_N6_DBC_AD7P_68_W34
set_property PACKAGE_PIN AK33              [get_ports "ddr4_sdram_c0_dqs_t[4]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L16P_T2U_N6_QBC_AD3P_67_AK33
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[4]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L16P_T2U_N6_QBC_AD3P_67_AK33
set_property PACKAGE_PIN AF33              [get_ports "ddr4_sdram_c0_dqs_t[5]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L22P_T3U_N6_DBC_AD0P_67_AF33
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[5]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L22P_T3U_N6_DBC_AD0P_67_AF33
set_property PACKAGE_PIN AC35              [get_ports "ddr4_sdram_c0_dqs_t[6]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L10P_T1U_N6_QBC_AD4P_68_AC35
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[6]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L10P_T1U_N6_QBC_AD4P_68_AC35
set_property PACKAGE_PIN AC30              [get_ports "ddr4_sdram_c0_dqs_t[7]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L16P_T2U_N6_QBC_AD3P_68_AC30
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[7]"]      ;#  Bank  68 VCCO - 1V2_VCCO - IO_L16P_T2U_N6_QBC_AD3P_68_AC30
set_property PACKAGE_PIN AT34              [get_ports "ddr4_sdram_c0_dqs_t[8]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L4P_T0U_N6_DBC_AD7P_67_AT34
set_property IOSTANDARD DIFF_POD12_DCI     [get_ports "ddr4_sdram_c0_dqs_t[8]"]      ;#  Bank  67 VCCO - 1V2_VCCO - IO_L4P_T0U_N6_DBC_AD7P_67_AT34
set_property PACKAGE_PIN AP27              [get_ports "ddr4_sdram_c0_odt"]           ;#  Bank  66 VCCO - 1V2_VCCO - IO_L12N_T1U_N11_GC_66_AP27
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_odt"]           ;#  Bank  66 VCCO - 1V2_VCCO - IO_L12N_T1U_N11_GC_66_AP27
set_property PACKAGE_PIN AU28              [get_ports "ddr4_sdram_c0_adr[16]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L9N_T1L_N5_AD12N_66_AU28
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[16]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L9N_T1L_N5_AD12N_66_AU28
set_property PACKAGE_PIN AR26              [get_ports "ddr4_sdram_c0_adr[14]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L11P_T1U_N8_GC_66_AR26
set_property IOSTANDARD SSTL12_DCI         [get_ports "ddr4_sdram_c0_adr[14]"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_L11P_T1U_N8_GC_66_AR26
set_property PACKAGE_PIN AK31              [get_ports "ddr4_sdram_c0_reset_n"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_T3U_N12_66_AK31
set_property IOSTANDARD LVCMOS12           [get_ports "ddr4_sdram_c0_reset_n"]       ;#  Bank  66 VCCO - 1V2_VCCO - IO_T3U_N12_66_AK31
