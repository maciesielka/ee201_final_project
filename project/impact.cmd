setMode -bs
setCable -port xsvf -file "async_rom_2.mif.xsvf"
addDevice -p 1 -file "../"
Program -p 1 -e -defaultVersion 0
quit
