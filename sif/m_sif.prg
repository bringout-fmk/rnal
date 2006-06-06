#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------
// meni sifranici
// ------------------------------
function m_sif()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. partneri                    ")
AADD(opcexe, {|| p_firma()})
AADD(opc, "2. roba")
AADD(opcexe, {|| p_roba()})
AADD(opc, "3. tarife")
AADD(opcexe, {|| p_tarifa()})
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "K. karakteristike")
AADD(opcexe, {|| p_rnka()})
AADD(opc, "O. operacije")
AADD(opcexe, {|| p_rnop()})
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "S. sifk")
AADD(opcexe, {|| p_sifk()})

Menu_SC("sif")

return



