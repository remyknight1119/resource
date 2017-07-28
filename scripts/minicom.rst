timeout 360
	
send "mmc rescan 0"
gosub WAIT_PROC
send "fatls mmc 0"
gosub WAIT_PROC
send "mw.b 0x81000000 0xFF 0x440000"
gosub WAIT_PROC
send "fatload mmc 0 81000000 uImage"
gosub WAIT_PROC
send "nand erase 0x00280000 0x00440000"
gosub WAIT_PROC
send "nand write 0x81000000 0x00280000 0x00440000"
gosub WAIT_PROC
send "saveenv"
gosub WAIT_PROC

send "mw.b 0x81000000 0xFF 0x4C00000"
gosub WAIT_PROC
send "fatload mmc 0 81000000 ubi.img"
gosub WAIT_PROC
send "nand erase 0x009C0000 0xC820000"
gosub WAIT_PROC
send "nand write 0x81000000 0x009C0000 0x4C00000"
gosub WAIT_PROC
send "setenv bootcmd 'saveenv;nand read 81000000 280000 440000;bootm 81000000'"
gosub WAIT_PROC
send "setenv bootargs 'console=ttyO0,115200n8 noinitrd ip=off mem=256M'"
gosub WAIT_PROC
send "setenv bootargs 'console=ttyO0,115200n8 noinitrd ip=off mem=256M rootwait=1 rw earlyprintk ubi.mtd=4,2048 rootfstype=ubifs root=ubi0:rootfs init=/init vram=20M notifyk.vpssm3_sva=0xBEE00000 stdin=serial ddr_mem=1024M i2c_bus=2,400'"
gosub WAIT_PROC
send "setenv bootdelay 5"
gosub WAIT_PROC
exit
FAIL_EXIT
exit

WAIT_PROC:
    expect {
        "TI8168_EVM#" break
        goto FAIL_EXIT
    }
return
