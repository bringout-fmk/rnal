#include "rnal.ch"


// -------------------------------
// menij izvjestaji
// -------------------------------

function m_rpt()
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. lista naloga otvorenih na tekuci dan          ")
AADD(opcexe, {|| lst_tek_dan() })

AADD(opc, "2. nalozi prispjeli za realizaciju ")
AADD(opcexe, {|| lst_real_tek_dan() })

AADD(opc, "3. nalozi van roka na tekuci dan ")
AADD(opcexe, {|| lst_vrok_tek_dan() })

AADD(opc, "4. lista naloga >= od proizvoljnog datuma ")
AADD(opcexe, {|| lst_ch_date() })

AADD(opc, "------------------------------------------- ")
AADD(opcexe, {|| nil })

AADD(opc, "S. specifikacija naloga za poslovodje  ")
AADD(opcexe, {|| m_get_spec( 1 ) })

AADD(opc, "R. pregled utroska RAL sirovina  ")
AADD(opcexe, {|| rpt_ral_calc( ) })

AADD(opc, "O. pregled ucinka operatera  ")
AADD(opcexe, {|| r_op_docs( ) })

AADD(opc, "P. pregled ucinka proizvodnje  ")
AADD(opcexe, {|| m_get_rpro( ) })

AADD(opc, "------------------------------------------- ")
AADD(opcexe, {|| nil })

AADD(opc, "K. kontrola prebacenih dokumenata  ")
AADD(opcexe, {|| m_rpt_check( ) })

AADD(opc, "T. pretraga naloga po uslovima  ")
AADD(opcexe, {|| r_fnd_docs() })

Menu_SC("rpt_rnal")

return







