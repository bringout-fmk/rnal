#include "\dev\fmk\rnal\rnal.ch"
/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------
// meni parametara
// ------------------------------
function m_par()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. podaci firme                 ")
AADD(opcexe, {|| notimp() })
AADD(opc, "2. zaokruzenja, format prikaza  ")
AADD(opcexe, {|| ed_zf_params() } )

Menu_SC("par")

return

