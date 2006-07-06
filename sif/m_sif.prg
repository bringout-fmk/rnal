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
private opc:={}
private opcexe:={}
private Izbor:=1

o_rn_sif()

AADD(opc, "1. partneri                    ")
AADD(opcexe, {|| p_firma()})
AADD(opc, "2. roba")
AADD(opcexe, {|| p_roba()})
AADD(opc, "3. sastavnice")
AADD(opcexe, {|| p_sast()})
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "O. operacije")
AADD(opcexe, {|| p_rnop()})
AADD(opc, "K. karakteristike")
AADD(opcexe, {|| p_rnka()})
AADD(opc, "T. tipovi artikala ")
AADD(opcexe, {|| p_rtip()})
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "S. sifk")
AADD(opcexe, {|| p_sifk()})

Izbor := 1

gMeniSif:=.t.
Menu_SC("rsif")
gMeniSif:=.f.

return



