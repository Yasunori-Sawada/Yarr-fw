#! /bin/bash

#Change directory where Yarr-fw is located.
cd `dirname $0`

#Making a vivado project for Yarr on KC705.
vivado -mode batch -source create_yarr_RD53A_kc705_project.tcl

echo ""
echo "Project made at "`exec pwd`"/yarr"
