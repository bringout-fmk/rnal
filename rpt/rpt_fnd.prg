#include "rnal.ch"


// -----------------------------------------------------
// pretraga naloga po dimenzijama
// -----------------------------------------------------
function r_fnd_docs()
local nHeight
local nWidth

// uslovi izvjestaja
if fnd_vars( @nHeight, @nWidth ) = 0
	return
endif

// napravi report
_cre_report( nHeight, nWidth )

// rpt
_gen_rpt()

return


// --------------------------------------------------
// uslovi izvjestaja
// --------------------------------------------------
static function fnd_vars( nH, nW )

nH := 0
nW := 0

Box(,1,50)

	@ m_x + 1, m_y + 2 SAY "Sirina:" GET nW PICT "9999999.99"
	
	@ m_x + 1, col() + 1 SAY "visina:" GET nH PICT "9999999.99"
	
	read

BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1


// ------------------------------------------------------
// stampa izvjestaja
// ------------------------------------------------------
static function _gen_rpt()
local cLine

START PRINT CRET

?

P_COND

_rpt_head( @cLine )

select _tmp1
go top

do while !EOF()

	nDoc_no := field->doc_no

	? field->doc_no
	@ prow(), pcol()+1 SAY PADR( field->customer, 30 )
	@ prow(), pcol()+1 SAY field->doc_date
	@ prow(), pcol()+1 SAY PADR( GetUserName( field->oper ), 15 )
	@ prow(), pcol()+1 SAY PADR( ALLTRIM(STR(field->width,12,2)) + ;
		" x " + ;
		ALLTRIM(STR(field->height, 12,2)), 25 )
	
	skip

enddo

? cLine

close all

FF
END PRINT

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head( cLine )
local cTxt

? "--------------------------------------------"
? "Lista naloga"
? "--------------------------------------------"

cLine := REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 15)
cLine += SPACE(1)
cLine += REPLICATE("-", 25)

cTxt := PADR("Broj nal.", 10)
cTxt += SPACE(1)
cTxt += PADR("Kupac", 30)
cTxt += SPACE(1)
cTxt += PADR("Datum", 8)
cTxt += SPACE(1)
cTxt += PADR("Operater", 15)
cTxt += SPACE(1)
cTxt += PADR("Dimenzije", 25)

? cLine 
? cTxt
? cLine

return




// ---------------------------------------------------------------
// glavna funkcija za kreiranje pomocne tabele
// ---------------------------------------------------------------
static function _cre_report( nHeight, nWidth )

// kreiraj tmp tabelu
aField := _rpt_fields()

cre_tmp1( aField )
O__TMP1
index on STR( doc_no, 10) tag "1"

// otvori potrebne tabele
o_tables( .f. )

O_DOC_IT
go top

Box(, 1, 50 )

do while !EOF()
	
	nDoc_no := field->doc_no
	
	@ m_x + 1, m_y + 2 SAY "obradjujem nalog: " + ALLTRIM(STR(nDoc_no))

	if ( field->doc_it_height = nHeight ) .or. ;
		( field->doc_it_width = nWidth )
		
		nH := field->doc_it_height
		nW := field->doc_it_width
		
		select docs
		seek docno_str( nDoc_no )

		dDoc_date := field->doc_date
		dDvr_date := field->doc_dvr_date
		nOper := field->operater_id
		nCust := field->cust_id
		nCont := field->cont_id
		cCustomer := ALLTRIM( g_cust_desc( nCust ) )
		cCustomer += "/" + ALLTRIM( g_cont_desc( nCont ) )
		
		select doc_it

		app_to_tmp1( nDoc_no, cCustomer, dDoc_date, nOper, nH, nW )
	endif

	// idemo dalje...
	select doc_it
	skip

enddo

BoxC()

return


// -------------------------------------------------
// dodaj u pomocnu tabelu
// -------------------------------------------------
static function app_to_tmp1( nDoc_no, cCustomer, dDate, nOper, nH, nW )
local nTArea := SELECT()

O__TMP1
go top
seek docno_str( nDoc_no )

append blank
replace field->doc_no with nDoc_no
replace field->customer with cCustomer
replace field->doc_date with dDate
replace field->oper with nOper
replace field->height with nH
replace field->width with nW

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
AADD(aRet, { "oper", "N", 3, 0 })
AADD(aRet, { "height", "N", 12, 2 })
AADD(aRet, { "width", "N", 12, 2 })

return aRet




