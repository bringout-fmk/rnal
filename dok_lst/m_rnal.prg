#include "\dev\fmk\rnal\rnal.ch"

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

AADD(opc, "1. lista azuriranih naloga                ")
AADD(opcexe, {|| frm_lst_nalog() })

Menu_SC("rpt")

return


