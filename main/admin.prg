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


// ------------------------------------------
// administrativni menij modula RNAL
// ------------------------------------------
function mnu_admin()
private opc := {}
private opcexe := {}
private izbor := 1

AADD(opc, "1. administracija db-a            ")
AADD(opcexe, {|| m_adm() })
AADD(opc, "2. regeneracija naziva artikala   ")
AADD(opcexe, {|| _a_gen_art() })

Menu_SC("administracija")

return



// --------------------------------------------
// automatska generacija naziva artikala
// --------------------------------------------
function _a_gen_art()
local nCnt := 0

if !SigmaSif("ARTGEN")
	msgbeep("!!!!! opcija nedostupna !!!!!")
	return
endif

o_sif_tables()

// obradi sifrarnik...
nCnt := auto_gen_art()

MsgBeep("Obradjeno " + ALLTRIM(STR(nCnt)) + " stavki !")

return


