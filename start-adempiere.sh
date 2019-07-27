#!/bin/bash

################################################################################
#  ADempiere start script                                                     ##
#  Starting ADempiere Server                                                  ##
#                                                                             ##
#  E.R.P. Conmsultores y Asociados, C.A                                       ##
#  Yamel Senih                                                                ##
#  ysenih@erpya.com                                                           ##
################################################################################

cd /opt/Adempiere/utils
./RUN_Server2.sh
tail -f /dev/null

exit 0
