#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */


// ------------------------------------------
// provjerava da li je zadata vrsta staklo
// ------------------------------------------
function is_staklo(cVrsta)
if ALLTRIM(cVrsta) == "S"
	return .t.
endif
return .f.


// -----------------------------------------------------
// kalkulise kvadratne metre
// nDim1, nDim2 u cm
// -----------------------------------------------------
function c_ukvadrat(nKol, nDim1, nDim2)
local xRet
xRet := ( nDim1 / 100 ) * (nDim2 / 100)
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






