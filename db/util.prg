#include "\dev\fmk\rnal\rnal.ch"

// u RNAL modulu ne trebamo kreirati tabele rabata
function crerabdb()
return

function crefmkpi()
return


// ------------------------------------------------
// otvori tabele potrebne za rad sa RNAL
// lTemporary - .t. i pripremne tabele
// ------------------------------------------------
function o_tables(lTemporary)

if lTemporary == nil
	lTemporary := .f.
endif

// otvori sifrarnike
o_sif_tables()

select F_DOCS
if !used()
	O_DOCS
endif

select F_DOC_IT
if !used()
	O_DOC_IT
endif

select F_DOC_OPS
if !used()
	O_DOC_OPS
endif

select F_DOC_LOG
if !used()
	O_DOC_LOG
endif

select F_DOC_LIT
if !used()
	O_DOC_LIT
endif

if lTemporary == .t.

	SELECT (F__DOCS)
	if !used()
		O__DOCS
	endif

	SELECT (F__DOC_IT)
	if !used()
		O__DOC_IT
	endif

	SELECT (F__DOC_OPS)
	if !used()
		O__DOC_OPS
	endif

	SELECT (F__FND_PAR)
	if !used()
		O__FND_PAR
	endif
	
endif

return

// -----------------------------------------
// otvara tabele sifrarnika 
// -----------------------------------------
function o_sif_tables()

select F_E_GROUPS
if !used()
	O_E_GROUPS
endif

select F_E_GR_ATT
if !used()
	O_E_GR_ATT
endif

select F_E_GR_VAL
if !used()
	O_E_GR_VAL
endif

select F_ARTICLES
if !used()
	O_ARTICLES
endif

select F_ELEMENTS
if !used()
	O_ELEMENTS
endif

select F_E_AOPS
if !used()
	O_E_AOPS
endif

select F_E_ATT
if !used()
	O_E_ATT
endif

select F_CUSTOMS
if !used()
	O_CUSTOMS
endif

select F_CONTACTS
if !used()
	O_CONTACTS
endif

select F_AOPS
if !used()
	O_AOPS
endif

select F_AOPS_ATT
if !used()
	O_AOPS_ATT
endif

return



// -------------------------------------------
// setuje novi zapis u tabeli sifrarnika
// nId - id sifrarnika
// cIdField - naziv id polja....
// -------------------------------------------
function _set_sif_id(nId, cIdField)
local nTArea := SELECT()
local nTime

go top

if !(FLOCK())
	
	nTime := 80     
	
	// daj mu 10 sekundi
      	
	do while nTime > 0
        	
		InkeySc(.125)
         	
		nTime --
         	
		if FLOCK()
            		exit
         	endif
      	enddo
	
      	if nTime == 0 .AND. !(FLOCK())
        	Beep (4)
         	Msg ("Dodavanje nove stavke onemoguceno !!!# POKUSAJTE PONOVO")
         	return 0
      	endif
endif

_inc_id(@nId, cIdField)

appblank2(.f., .f.)   

cIdField := "_" + cIdField

&cIdField := nId

Gather2()
DBUnlock()

select (nTArea)

return 1


