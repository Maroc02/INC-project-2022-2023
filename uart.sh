# uart.sh: Bash script for GHDL+GTKWave synth and simulation of UART RX
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

GHDL="ghdl"
GHDLFLAGS="-fsynopsys -fexplicit"
GTKW="gtkwave"
SYNTH_FILE="synth.vhd"
SIM_FILE="sim.ghw"

# Clean
rm -rf *.cf $SYNTH_FILE $SIM_FILE
if [ "$1" == 'clean' ] ; then
    exit 0
fi

# Analyze sources and defined entities
echo  "########## ANALYSIS ##########"
for src in uart_rx_fsm.vhd uart_rx.vhd testbench.vhd; do
    $GHDL -a $GHDLFLAGS $src
    if [ $? -ne 0 ]; then
        echo "Analysis of $src ended with error!"
        exit 1
    fi
done
echo 

# Synthesize UART module
echo "########## SYNTHESIS ##########"
$GHDL synth $GHDLFLAGS uart_rx >$SYNTH_FILE
if [ $? -ne 0 ]; then
    echo "Synthesis ended with error!"
    exit 1
fi
echo

# Run UART testbench simulation
echo "########## SIMULATION ##########"
$GHDL -c $GHDLFLAGS -r testbench --wave=$SIM_FILE
if [ $? -ne 0 ]; then
    echo "Simulation ended with error!"
    exit 1
fi
$GTKW $SIM_FILE --script=wave.tcl
