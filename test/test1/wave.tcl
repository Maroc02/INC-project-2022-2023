# wave.tcl: TCL script for GTKWave simulator with signal definitions 
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

gtkwave::/Edit/Insert_Comment "Main Interface"
gtkwave::addSignalsFromList [list clk rst]
gtkwave::addSignalsFromList [list din_state]
gtkwave::/Edit/Color_Format/Blue
gtkwave::addSignalsFromList [list din dout dout_vld]
gtkwave::addSignalsFromList [list dout_exp dout_error]
gtkwave::/Edit/Color_Format/Blue
gtkwave::/Edit/Insert_Blank

gtkwave::/Edit/Insert_Comment "Other Signals"

gtkwave::/Edit/UnHighlight_All
gtkwave::/Time/Zoom/Zoom_Best_Fit
