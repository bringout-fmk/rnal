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

AADD(opc, "1. podaci firme - zaglavlje            ")
AADD(opcexe, {|| ed_fi_params() })
AADD(opc, "2. izgled dokumenta  ")
AADD(opcexe, {|| ed_doc_params() } )
AADD(opc, "3. zaokruzenja, format prikaza  ")
AADD(opcexe, {|| ed_zf_params() } )
AADD(opc, "4. parametri exporta  ")
AADD(opcexe, {|| ed_ex_params() } )
AADD(opc, "---------------------------------")
AADD(opcexe, {|| nil } )
AADD(opc, "5. ostalo  ")
AADD(opcexe, {|| ed_ost_params() } )

Menu_SC("par")

return

