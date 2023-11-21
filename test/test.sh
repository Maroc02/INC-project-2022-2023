# test.sh: Main project testing script
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

LOGIN=xlogin00

WORK_DIR=work
LOG_DIR=$WORK_DIR/log
SIM_DIR=$WORK_DIR/sim
TEST1_DIR=test1
TEST2_DIR=test2

rm -rf $WORK_DIR
if [ "$1" == 'clean' ] ; then
    exit 0
fi

source ./scripts/unpack.sh
source ./scripts/simulate.sh
source ./scripts/eval.sh

echo
echo "Test successful, results are OK!"
echo