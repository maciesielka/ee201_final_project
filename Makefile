 ##############################################################################
#Auther: Chris Eerry (christnb@usc.edu)
#Date: January 20, 2013
#Description: This makefile programs Nexys3 board from a bit 
#of a Nexys3 board with an Xilinx xc6slx16 FPGAa. Xilinx ISE 14.7 and FPGALink
#should be installed in the /opt dir for the paths listed here to work.

#####
directory := $(firstword $(wildcard $(dir)*))
bitfile   := $(firstword $(shell find ${directory} -type f -name '*.bit'))
##

dummy: 
	echo "\tNo default target, type 'make help' for list of options"

project: Makefile
	mkdir -p project

project/impact.cmd: project
	@echo "setMode -bs" > project/impact.cmd
	@echo "setCable -port xsvf -file \"${directory}.xsvf\"" >> project/impact.cmd
	@echo "addDevice -p 1 -file \"../${bitfile}\"" >> project/impact.cmd
	@echo "Program -p 1 -e -defaultVersion 0" >> project/impact.cmd
	@echo "quit" >> project/impact.cmd

project/$(directory).xsvf: $(bitfile) project/impact.cmd
ifeq ($(strip $(bitfile)),)
	$(error MESSAGE: No bitfile found in ${directory})
else
	cd project && /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/impact -batch impact.cmd
endif

.PHONY: cleanall clean help
.SILENT: help dummy

prog: project/$(directory).xsvf
	cd project && /opt/libfpgalink/linux.x86_64/rel/flcli -i 1443:0007 -v 1443:0007 -x $(directory).xsvf
	@echo ""
	@echo "Program Nexys3 using ${bitfile} -> ${directory}.xsvf file completed"
	@echo ""

clean: 
	rm -rf project/*.log

cleanall: clean
	rm -rf project

help:
	echo ""
	echo "Usage: make prog dir=[DIRECTORY]"
	echo ""
	echo "This makefile has the following options:"
	echo "  help:           print this message"
	echo "  project:        create the required Xilinx project dir/files"
	echo "  prog:           program the board. Use dir= to control bitfile"
	echo "  dir=[directory] pattern to control which dir to search for *.bit file"
	echo "  clean:          remove all log files"
	echo "  cleanall:       remove all log files and project dir "
	echo ""
	echo " --- DEBUG INFO ---"
	echo "  dir                               : ${dir}"
	echo "  directory chosen from dir pattern : ${directory}"
	echo "  bit file                          : ${bitfile}"


