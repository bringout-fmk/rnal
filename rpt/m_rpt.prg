#include "\dev\fmk\rnal\rnal.ch"
/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------
// ------------------------------
function m_rpt()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. stampa liste radnih naloga     ")
AADD(opcexe, {|| notimp() })

Menu_SC("rpt")

return


