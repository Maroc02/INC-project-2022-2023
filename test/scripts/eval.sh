# eval.sh: Project evaluation
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

echo -n "Results evaluation                      "

if [ -f "$WORK_DIR/sim/synth.vhd" ] && [ $(wc -c "$WORK_DIR/sim/synth.vhd" | awk '{print $1}') -gt 1000 ]; then
    echo "Synthesis seems OK." >$LOG_DIR/eval.log
    echo >>$LOG_DIR/eval.log
else
    echo "[Failed]"
    echo "Error: Synthesis failed, see work/log/sim.log file and check work/sim/synth.vhd."
    exit 1
fi

if [ -f "$WORK_DIR/sim/test1_output.txt" ]; then
    echo "Simulation test1 performed, diff with expected results:" >>$LOG_DIR/eval.log
else
    echo "Simulation test1 results missing." >>$LOG_DIR/eval.log
    echo "[Failed]"
    echo "Error: Simulation failed, see work/log/sim.log file."
    exit 1
fi
diff $TEST1_DIR/input.txt $SIM_DIR/test1_output.txt >>$LOG_DIR/eval.log 2>&1
if [ "$?" -ne 0 ]; then
    echo "[Failed]"
    echo "Error: Simulation result miscompare, see work/log/eval.log file and check work/sim/test1_sim.ghw."
    exit 1
fi   
echo >>$LOG_DIR/eval.log

if [ -d $TEST2_DIR ]; then
    if [ -f "$WORK_DIR/sim/test2_output.txt" ]; then
        echo "Simulation test2 performed, diff with expected results:" >>$LOG_DIR/eval.log
    else
        echo "Simulation test2 results missing." >>$LOG_DIR/eval.log
        echo "[Failed]"
        echo "Error: Simulation failed, see work/log/sim.log file."
        exit 1
    fi
    diff $TEST2_DIR/input.txt $SIM_DIR/test2_output.txt >>$LOG_DIR/eval.log 2>&1
    if [ "$?" -ne 0 ]; then
        echo "[Failed]"
        echo "Error: Simulation result miscompare, see work/log/eval.log file and check work/sim/test2_sim.ghw."
        exit 1
    fi
else
    echo "Simulation test2 skipped." >>$LOG_DIR/eval.log
fi

echo "[Done]"
