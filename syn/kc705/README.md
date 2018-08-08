# Xilinx Kintex-7 FPGA KC705

<span style="display: inline-block;">

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [How-to-Use](#howto)
4. [Licence](#licence)

<a name="overview"></a>

## Overview

This project is the fork of YARR for testing communication using KC705 Evaluation board.

<a name="requirements"></a>

## Requirement

Target Device:
- [Kintex-7 KC705 Evaluation Platform](https://www.xilinx.com/products/boards-and-kits/ek-k7-kc705-g.html)

Firmware:
- Langurage : VHDL

- Xilinx Vivado 2016.2 (or later versions)

    Xilinx IP cores
    - [Clocking Wizard](https://japan.xilinx.com/products/intellectual-property/clocking_wizard.html)
    - [AXI4-Stream Data FIFO](https://japan.xilinx.com/products/intellectual-property/axi_fifo.html)
    - [FIFO Generator](https://japan.xilinx.com/products/intellectual-property/fifo_generator.html)
    - [Memory Interface Generator (MIG 7 Series)](https://japan.xilinx.com/products/intellectual-property/mig.html)
    - [7 Series Integrated Block for PCI Express](https://japan.xilinx.com/products/intellectual-property/7_series_pci_express_block.html)
    - [ILA (Integrated Logic Analyzer)](https://japan.xilinx.com/products/intellectual-property/ila.html)

<a name="howto"></a>

## How-to-Use

Two ways.

- Configure ready_to_test .bit or .mcs.
    - bram_fei4_octa_revA
        - FMC-LPC supports [VHDCI_to_8xRJ45_FE_I4_Rev_A](https://twiki.cern.ch/twiki/bin/view/Main/TimonHeim?forceShow=1#VHDCI_to_8xRJ45_FE_I4_Rev_A)
    - ddr3_fei4_octa_revA
        - Same as above but using DDR3 for an internal buffer. Experimental. Only providing a .bit file.
    - bram_fei4_single_osaka
        - FMC-LPC attached with TB-FMCL-PH with the custom Osaka single chip adapter (contact hirose@champ.hep.sci.osaka-u.ac.jp).

- Rebuild your vivado project.
    - Execute mkproject.sh in your desired version among above.

<a name="licence"></a>

## Licence

The license conforms to the parent project.
