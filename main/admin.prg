#include "\dev\fmk\rnal\rnal.ch"


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


