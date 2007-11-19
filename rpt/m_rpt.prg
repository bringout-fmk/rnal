#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------
// menij izvjestaji
// -------------------------------

function m_rpt()
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. lista naloga otvorenih na tekuci dan          ")
AADD(opcexe, {|| lst_tek_dan() })

AADD(opc, "2. nalozi prispjeli za realizaciju na tekuci dan ")
AADD(opcexe, {|| lst_real_tek_dan() })

AADD(opc, "3. nalozi van roka na tekuci dan ")
AADD(opcexe, {|| lst_vrok_tek_dan() })

AADD(opc, "4. lista naloga >= od proizvoljnog datuma ")
AADD(opcexe, {|| lst_ch_date() })

AADD(opc, "------------------------------------------- ")
AADD(opcexe, {|| nil })

AADD(opc, "P. specifikacija naloga za poslovodje  ")
AADD(opcexe, {|| m_get_spec( 1 ) })

AADD(opc, "T. test  ")
AADD(opcexe, {|| glass_config() })



Menu_SC("rpt_rnal")

return







