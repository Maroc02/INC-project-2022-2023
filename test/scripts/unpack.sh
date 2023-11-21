# unpack.sh: Project unzip and file check
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

echo -n "Unpack archive                          "
mkdir $WORK_DIR
mkdir $LOG_DIR
if [ -f $LOGIN.zip ]; then
    echo "Archive $LOGIN.zip found, unpacking:" >$LOG_DIR/unpack.log
else
    echo "Error: Archive $LOGIN.zip is missing!" >$LOG_DIR/unpack.log
    echo "[Failed]"
    exit 1
fi
unzip $LOGIN.zip -d $WORK_DIR >>$LOG_DIR/unpack.log 2>&1
if [ $? -ne 0 ]; then
    echo "[Failed]"
    exit 1
fi
echo "Missing files:" >>$LOG_DIR/unpack.log
EOK=1
for f in uart_rx_fsm.vhd uart_rx.vhd zprava.pdf; do
    if [ ! -f "$WORK_DIR/$f" ]; then
        echo $f >>$LOG_DIR/unpack.log
        EOK=0
    fi
done
if [ $EOK -ne 1 ]; then
    echo "[Failed]"
    exit 1
fi 
echo "[Done]"
 