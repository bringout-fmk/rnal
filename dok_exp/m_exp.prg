#include "rnal.ch"



// --------------------------------------------------------
// meni exporta
// --------------------------------------------------------
function m_export( nDoc_no, aDocList, lTemp, lWriteRel )
local mX := m_x
local mY := m_y
private opc := {}
private opcexe := {}
private izbor := 1

AADD( opc, "1. rnal -> GPS.opt (Lisec)         ")
AADD( opcexe, {|| exp_2_lisec( nDoc_no, lTemp, lWriteRel ), izbor := 0 } )
AADD( opc, "2. rnal -> FMK    ")
AADD( opcexe, {|| exp_2_fmk( lTemp, nDoc_no, aDocList ), izbor := 0 } )
AADD( opc, "3. rnal -> FMK (zadnja otpremnica) ")
AADD( opcexe, {|| exp_2_fmk( lTemp, nDoc_no, aDocList, .t. ), izbor := 0 } )

Menu_SC("export")

m_x := mX
m_y := mY

return



