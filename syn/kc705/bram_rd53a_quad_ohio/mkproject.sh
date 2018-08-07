#! /bin/bash

#Change directory where Yarr-fw is located.
cd `dirname $0`

#Making necessary modifications to work on KC705
cd ../
echo 'Making necessary modifications to work on KC705...'
./convert_xpressk7toKC705.sh

#Making a vivado project for Yarr on KC705.
cd -
vivado -mode batch -source create_yarr_RD53A_kc705_project.tcl

echo ""
echo "Project made at "`exec pwd`"/yarr"
