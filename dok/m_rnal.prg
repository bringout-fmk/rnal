#include "rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------
// menij pregled naloga
// ------------------------------
function m_lst_rnal()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. lista otvorenih naloga          ")
AADD(opcexe, {|| frm_lst_nalog(1) })

AADD(opc, "2. lista zatvorenih naloga  ")
AADD(opcexe, {|| frm_lst_nalog(2) })

Menu_SC("lst")

return


