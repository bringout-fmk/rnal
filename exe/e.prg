/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "rnal.ch"

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


