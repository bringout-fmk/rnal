#include "rnal.ch"


// -----------------------------------------------------
// provjera podataka, sta je prebaceno od otpremnica
// -----------------------------------------------------
function m_rpt_check()
local dD_from
local dD_to
local nOper
local cStatus
local nVar := 0

// uslovi izvjestaja
if std_vars( @dD_from, @dD_to, @nOper, @cStatus ) = 0
	return
endif

if Pitanje(,"Prikazati samo naloge koji nisu prebaceni ? (D/N)", "D") == "D"
	nVar := 1
endif

// napravi report
_cre_report( dD_from, dD_to, nOper, cStatus )

// rpt
_gen_rpt( dD_from, dD_to, nOper, nVar )

return



// ------------------------------------------------------
// stampa izvjestaja
// ------------------------------------------------------
static function _gen_rpt( dD_from, dD_to, nOper, nVar )
local cLine

START PRINT CRET

?

P_COND

_rpt_head( @cLine, dD_from, dD_to )

select _tmp1
go top

do while !EOF()

	// samo prikazi one koji nisu prebaceni
	if nVar = 1
		if ALLTRIM( field->fakt_d1 ) + ;
			ALLTRIM( field->pos_d1 ) <> "??"
			
			// preskoci ovaj zapis
			skip
			loop

		endif
	endif

	? field->doc_no
	@ prow(), pcol()+1 SAY PADR( field->customer, 30 )
	@ prow(), pcol()+1 SAY field->doc_date
	@ prow(), pcol()+1 SAY field->dvr_date
	@ prow(), pcol()+1 SAY field->fakt_d1
	//@ prow(), pcol()+1 SAY field->fakt_d2
	@ prow(), pcol()+1 SAY field->pos_d1
	
	skip

enddo

? cLine

FF
END PRINT

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head( cLine, dD_from, dD_to )
local cTxt

? "------------------------------"
? "Dokumenti koji nisu obradjeni:"
? "------------------------------"
? "Datum od " + DTOC(dD_from) + " do " + DTOC(dD_to)

cLine := REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 6)

cTxt := PADR("Broj nal.", 10)
cTxt += SPACE(1)
cTxt += PADR("Kupac", 30)
cTxt += SPACE(1)
cTxt += PADR("Datum", 8)
cTxt += SPACE(1)
cTxt += PADR("Ispor.", 8)
cTxt += SPACE(1)
cTxt += PADR("FAKT", 10)
cTxt += SPACE(1)
cTxt += PADR("POS", 6 )

? cLine 
? cTxt
? cLine

return




// ---------------------------------------------------------------
// glavna funkcija za kreiranje pomocne tabele
// ---------------------------------------------------------------
static function _cre_report( dD_f, dD_t, nOper, cStatus )
local aField
local cValue := ""
local aValue := {}
local nDoc_no
local aFmk
local cSep := ";"
local i
local cFFirma := "10"
local cFTipDok := "12"
local cPFirma := ""
local cPTipDok := ""

// kreiraj tmp tabelu
aField := _rpt_fields()

cre_tmp1( aField )
O__TMP1
index on STR( doc_no, 10) tag "1"

// napravi linkove sa fakt-om i pos-om
select (240)
use ( ALLTRIM(gFaKumDir) + "DOKS" ) alias "f_dok"
set order to tag "1"
select (241)
use ( ALLTRIM(gPoKumDir) + "DOKSRC" ) alias "p_dok"
set order to tag "1"

// otvori potrebne tabele
o_tables( .f. )

_main_filter( dD_f, dD_t, nOper, cStatus )

Box(, 1, 50 )

do while !EOF()
	
	// uzmi podatke dokumenta da vidis treba li da se generise
	// u izvjestaj ?

	nDoc_no := field->doc_no
	
	@ m_x + 1, m_y + 2 SAY "obradjujem nalog: " + ALLTRIM(STR(nDoc_no))

	dDoc_date := field->doc_date
	dDvr_date := field->doc_dvr_date
	nCust := field->cust_id
	nCont := field->cont_id
	cCustomer := ALLTRIM( g_cust_desc( nCust ) )
	cCustomer += "/" + ALLTRIM( g_cont_desc( nCont ) )
	cFmk_doc := ALLTRIM( field->fmk_doc )

	// idi dalje
	if !EMPTY( cFmk_doc)
		skip
		loop
	endif
	
	// ovaj nema unesene -veze-
	
	// da li ga ima u FAKT-u ?
	
	cDokument := ALLTRIM(STR(nDoc_no)) + ";"
	cF_doc1 := "?"
	cF_doc2 := "?"

	select f_dok
	seek cFFirma + cFTipDok
	do while !EOF() .and. field->idfirma + field->idtipdok == ;
		cFFirma + cFTipDok
			
		if EMPTY( field->dok_veza )
			skip
			loop
		endif

		// tu je !
		if cDokument $ ALLTRIM( field->dok_veza )
			cF_doc1 := field->brdok
			exit
		endif

		skip
	enddo

	// provjeri i fakture
	//cFTipDok := "10"

	//go top
	//seek cFFirma + cFTipDok
	//do while !EOF() .and. field->idfirma + field->idtipdok == ;
	//	cFFirma + cFTipDok
			
	//	if EMPTY( field->dok_veza )
	//		skip
	//		loop
	//	endif

	//	// tu je !
	//	if cDokument $ ALLTRIM( field->dok_veza )
	//		cF_doc2 := field->brdok
	//		exit
	//	endif

	//	skip
	//enddo

	cP_doc1 := "?"
	// ima li ga u POS ?
	select p_dok
	set order to tag "2"
	go top
	seek PADR("KUPAC",10) + PADR(cPFirma, 2) + ;
		PADR(cPTipDok, 2) + PADR( ALLTRIM(STR(nDoc_no)), 8 )

	if FOUND()
		cP_doc1 := field->brdok
	endif
	
	app_to_tmp1( nDoc_no, cCustomer, dDoc_date, dDvr_date, ;
			cF_doc1, cF_doc2, cP_doc1 )

	// idemo dalje...
	select docs
	skip
enddo

BoxC()

return


// -------------------------------------------------
// dodaj u pomocnu tabelu
// -------------------------------------------------
static function app_to_tmp1( nDoc_no, cCustomer, dDate, dDel_date, ;
	cFakt_dok1, cFakt_dok2, cPos_dok1 )
local nTArea := SELECT()

O__TMP1
go top
seek docno_str( nDoc_no )

if !FOUND()
	append blank
	replace field->doc_no with nDoc_no
endif

replace field->customer with cCustomer
replace field->doc_date with dDate
replace field->dvr_date with dDel_date
replace field->fakt_d1 with cFakt_dok1
replace field->fakt_d2 with cFakt_dok2
replace field->pos_d1 with cPos_dok1

select (nTArea)
return



// -----------------------------------------
// polja tabele izvjestaja
// -----------------------------------------
static function _rpt_fields()
local aRet := {}

AADD(aRet, { "doc_no", "N", 10, 0 })
AADD(aRet, { "customer", "C", 50, 0 })
AADD(aRet, { "doc_date", "D", 8, 0 })
AADD(aRet, { "dvr_date", "D", 8, 0 })
AADD(aRet, { "fakt_d1", "C", 10, 0 })
AADD(aRet, { "fakt_d2", "C", 10, 0 })
AADD(aRet, { "pos_d1", "C", 10, 0 })

return aRet


// -------------------------------------------------
// filter 
// -------------------------------------------------
static function _main_filter( dDFrom, dDTo, nOper, cStatus )
local cFilter := ""

select docs

cFilter += "(doc_status == 0 .or. doc_status > 2)"
cFilter += " .and. DTOS(doc_date) >= " + cm2str(DTOS(dDFrom))
cFilter += " .and. DTOS(doc_date) <= " + cm2str(DTOS(dDTo))

if nOper <> 0
	cFilter += ".and. operater_i = " + STR( nOper, 3 )
endif

set filter to &cFilter
go top

return


