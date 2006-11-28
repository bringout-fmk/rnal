#include "\dev\fmk\rnal\rnal.ch"


// -----------------------------------------------------
// kalkulise kvadratne metre
// nDim1, nDim2 u mm
// -----------------------------------------------------
function c_ukvadrat(nKol, nDim1, nDim2)
local xRet
xRet := ( nDim1 / 1000 ) * ( nDim2 / 1000 )
xRet := nKol * xRet
return xRet



// -------------------------------------
// kalkulise netto stakla
// nDebljina - debljina stakla
// nU_m2 - ukupno kvadratnih metara
// cRobaVrsta - vrsta robe
// -------------------------------------
function c_netto(nDebljina, nU_m2, cRobaVrsta, nNetoKoef, nNetoProc)
local xRet

xRet := nNetoKoef * nDebljina * nU_m2

if ALLTRIM(cRobaVrsta) == "IZO"
	xRet := xRet * (1 + (nNetoProc / 100))
endif

return xRet


// ------------------------------------------
// pretvara iznos u cent. u milimetr.
// ------------------------------------------
function cm_2_mm(nVal)
return nVal * 100



