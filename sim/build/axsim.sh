#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/tools/Xilinx/SharedData/2023.1/data/../lib/lnx64.o:/tools/Xilinx/SharedData/2023.1/data/../lib/lnx64.o/Default:/tools/Xilinx/Vivado/2023.1/data/../lib/lnx64.o:/tools/Xilinx/Vivado/2023.1/data/../lib/lnx64.o/Default

xsim.dir/vga_timing_tb/axsim $@

if [ $? -ne 0 ] ; then
  echo "FATAL ERROR: Simulation exited unexpectantly"
fi
