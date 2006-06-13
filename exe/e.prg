#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */

EXTERNAL DESCEND
EXTERNAL RIGHT

#ifndef LIB

function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
MainRNal(cKorisn, cSifra, p3, p4, p5, p6, p7)
return

#endif


function MainRNal(cKorisn, cSifra, p3, p4, p5, p6, p7)
local oRNal
local cModul

PUBLIC gKonvertPath:="D"
oRNal:=TRNalModNew()
cModul:="RNAL"

PUBLIC goModul

goModul:=oRNal
oRNal:init(NIL, cModul, D_RN_VERZIJA, D_RN_PERIOD , cKorisn, cSifra, p3, p4, p5, p6, p7)

oRNal:run()

return


