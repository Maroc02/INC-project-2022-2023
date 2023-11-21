# simulate.sh: Project simulation and synthesis using GHDL
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

GHDL="ghdl"
GHDLFLAGS="-fsynopsys -fexplicit --workdir=$SIM_DIR"
SYNTH_FILE="$SIM_DIR/synth.vhd"
SIM1_FILE="$SIM_DIR/test1_sim.ghw"
SIM2_FILE="$SIM_DIR/test2_sim.ghw"

echo "Simulating project:"
mkdir $SIM_DIR

echo -n "--> synthesis                           "
echo "########## ANALYSIS ##########" >$LOG_DIR/sim.log
for src in $WORK_DIR/uart_rx_fsm.vhd $WORK_DIR/uart_rx.vhd; do
    $GHDL -a $GHDLFLAGS $src >>$LOG_DIR/sim.log 2>&1
    if [ $? -ne 0 ]; then
        echo "Analysis of $src ended with error!" >>$LOG_DIR/sim.log
        echo "[Failed]"
        exit 1
    fi
done
echo >>$LOG_DIR/sim.log
echo "########## SYNTHESIS ##########" >>$LOG_DIR/sim.log
$GHDL synth $GHDLFLAGS uart_rx >$SYNTH_FILE 2>>$LOG_DIR/sim.log
if [ $? -ne 0 ]; then
    echo "Synthesis ended with error!" >>$LOG_DIR/sim.log
    echo "[Failed]"
    exit 1
fi
echo >>$LOG_DIR/sim.log
echo "[Done]"

echo -n "--> basic tests                         "
echo "########## SIMULATION1 ##########" >>$LOG_DIR/sim.log
$GHDL -a $GHDLFLAGS $TEST1_DIR/testbench.vhd >>$LOG_DIR/sim.log 2>&1
$GHDL -c $GHDLFLAGS -r testbench1 --wave=$SIM1_FILE --stop-time=1000ms >>$LOG_DIR/sim.log 2>&1
if [ $? -ne 0 ]; then
    echo "Simulation ended with error!" >>$LOG_DIR/sim.log
    echo "[Failed]"
    exit 1
fi
echo >>$LOG_DIR/sim.log
echo "[Done]"

echo -n "--> advanced tests                      "
if [ -d $TEST2_DIR ]; then
    echo "########## SIMULATION2 ##########" >>$LOG_DIR/sim.log
    $GHDL -a $GHDLFLAGS $TEST2_DIR/testbench.vhd >>$LOG_DIR/sim.log 2>&1
    $GHDL -c $GHDLFLAGS -r testbench2 --wave=$SIM2_FILE --stop-time=1000ms >>$LOG_DIR/sim.log 2>&1
    if [ $? -ne 0 ]; then
        echo "Simulation ended with error!" >>$LOG_DIR/sim.log
        echo "[Failed]"
        exit 1
    fi
    echo "[Done]"
else
    echo "[Skipped]"
fi
