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



// ------------------------------------------
// pretvara iznos u cent. u milimetr.
// ------------------------------------------
function cm_2_mm(nVal)
return nVal * 10

// ------------------------------------------
// pretvara iznos iz mm u cm
// ------------------------------------------
function mm_2_cm(nVal)
return nVal / 10



