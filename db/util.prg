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



// -----------------------------
// otvori tabelu _TMP1
// -----------------------------
function o_tmp1()
select F__TMP1
if !used()
	O__TMP1
endif
return



// -----------------------------
// otvori tabelu _TMP2
// -----------------------------
function o_tmp2()
select F__TMP2
if !used()
	O__TMP2
endif
return



// -----------------------------------------
// konvert doc_no -> STR(doc_no, 10)
// -----------------------------------------
function docno_str(nId)
return STR(nId, 10)


// -----------------------------------------
// konvert doc_op -> STR(doc_op, 4)
// -----------------------------------------
function docop_str(nId)
return STR(nId, 4)


// -----------------------------------------
// konvert doc_it -> STR(doc_it, 4)
// -----------------------------------------
function docit_str(nId)
return STR(nId, 4)



// -------------------------------------------
// setuje novi zapis u tabeli sifrarnika
// nId - id sifrarnika
// cIdField - naziv id polja....
// -------------------------------------------
function _set_sif_id(nId, cIdField)
local nTArea := SELECT()
local nTime
local cIndex

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
        	Beep (2)
         	MsgBeep("Dodavanje nove stavke onemoguceno !!!#Pokusajte ponovo...")
         	return 0
      	endif
endif

if cIdField == "ART_ID"
	cIndex := "1"
else
	cIndex := "2"
endif

_inc_id(@nId, cIdField, cIndex)

Scatter()

appblank2(.f., .f.)   

cIdField := "_" + cIdField

&cIdField := nId

Gather2()

DBUnlock()

select (nTArea)

return 1


// ------------------------------------------
// kreiranje tabele PRIVPATH + _TMP1
// ------------------------------------------
function cre_tmp1( aFields )
local cTbName := "_TMP1"

if LEN(aFields) == 0
	MsgBeep("Nema definicije polja u matrici!")
	return
endif

_del_tmp( PRIVPATH + cTbName + ".DBF" )  

DBcreate2(PRIVPATH + cTbName + ".DBF", aFields)

return

// ------------------------------------------
// kreiranje tabele PRIVPATH + _TMP1
// ------------------------------------------
function cre_tmp2( aFields )
local cTbName := "_TMP2"

if LEN(aFields) == 0
	MsgBeep("Nema definicije polja u matrici!")
	return
endif

_del_tmp( PRIVPATH + cTbName + ".DBF" )  

DBcreate2(PRIVPATH + cTbName + ".DBF", aFields)

return



// --------------------------------------------
// brisanje fajla 
// --------------------------------------------
static function _del_tmp( cPath )
if FILE( cPath )
	FERASE( cPath )
endif
return


