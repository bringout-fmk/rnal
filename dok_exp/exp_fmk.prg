#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// export u FMK
// ------------------------------------------
function exp_2_fmk( nDoc_no, lTemp )
local nTArea := SELECT()
local nADOCS := F_DOCS
local nADOC_IT := F_DOC_IT
local nCust_id

// select pripreme fakt
select (245)
use ( ALLTRIM(gFaPrivDir) + "PRIPR" ) alias X_TBL

if RECCOUNT2() > 0
	
	msgbeep("priprema fakt nije prazna !")
	select (nTArea)
	return
		
endif

if lTemp == nil
	lTemp := .f.
endif

if lTemp == .t.
	nADOCS := F__DOCS
	nADOC_IT := F__DOC_IT
endif

select (nADOCS)
set order to tag "1"
seek docno_str( nDoc_no )

nCust_id := field->cust_id
cCust_desc := g_cust_desc( nCust_id )

select (nADOCS)

dDatDok := field->doc_date

cPartn := PADR( g_rel_val("1", "CUSTOMS", "PARTN", ALLTRIM(STR(nCust_id)) ), 6 )

// ako je partner prazno
if EMPTY( cPartn )

	// probaj naci partnera iz PARTN
	if fnd_partn( @cPartn, nCust_id, cCust_desc ) == 1 
		add_to_relation( "CUSTOMS", "PARTN", ;
			ALLTRIM(STR(nCust_id)) , cPartn )
	else
		select (nTArea)
		msgbeep("Operacija prekinuta !!!")
		return
	endif
	
endif

cIdVd := "12"
cBrDok := fa_new_doc( "10", cIdVd )

select (nADOC_IT)
set order to tag "3"
seek docno_str( nDoc_no )

nRbr := 0

do while !EOF() .and. field->doc_no == nDoc_no

	nArt_id := field->art_id
	cIdRoba := g_rel_val("1", "ARTICLES", "ROBA", ALLTRIM(STR(nArt_id)) )
	
	// uzmi cijenu robe iz sifrarnika robe
	nPrice := g_art_price( cIdRoba )
	
	cArt_desc := g_art_desc( nArt_id )
	

	aZpoGN := {}
	
	// zaokruzi vrijednosti....
	_art_set_descr( nArt_id, nil, nil, @aZpoGN, .t. )
	
	select (nADOC_IT)

	if EMPTY(cIdRoba)
		
		if fnd_roba( @cIdRoba, nArt_id, cArt_desc ) == 1
		
			add_to_relation( "ARTICLES", "ROBA", ;
				ALLTRIM(STR(nArt_id)), cIdRoba )
		
		
		else
			msgbeep("Neki artikli nemaju definisani u tabeli relacija#Prekidam operaciju !")	
			select (nTArea)
			return
		endif
	endif

	nM2 := 0

	// sracunaj m2
	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->art_id == nArt_id

		// kolicina
		nQty := field->doc_it_qtty
		
		// visina u mm
		nHeig := field->doc_it_height
		// sirina u mm
		nWidt := field->doc_it_width
		
		// pa zaokruziti po GN-u ?????
		
		nZHeig := 0
		nZWidt := 0
	
		nZHeig := obrl_zaok( nHeig, aZpoGN )
		nZWidt := obrl_zaok( nWidt, aZpoGN )
		
		// izracunaj kvadrate
		nM2 += ROUND( c_ukvadrat( nQty, nZHeig, nZWidt ) , 2)
		
		skip
		
	enddo
	
	
	select X_TBL
	append blank

	scatter()

	_txt := ""
	_rbr := STR( ++nRbr, 3 )
	_idpartner := cPartn
	_idfirma := "10"
	_brdok := cBrDok
	_idtipdok := cIdVd
	_datdok := dDatDok
	_idroba := cIdRoba
	_cijena := nPrice
	_kolicina := nM2
	_dindem := "KM "
	_zaokr := 2

	// roba tip U - nista
	a_to_txt( "", .t. )
	// dodatni tekst otpremnice - nista
	a_to_txt( "", .t. )
	// naziv partnera
	a_to_txt( _g_pfmk_desc( cPartn ) , .t. )
	// adresa
	a_to_txt( _g_pfmk_addr( cPartn ) , .t. )
	// ptt i mjesto
	a_to_txt( _g_pfmk_place( cPartn ) , .t. )
	// broj otpremnice
	a_to_txt( cBrDok , .t. )
	// datum  otpremnice
	a_to_txt( DTOC( dDatDok ) , .t. )
	
	// broj ugovora - nista
	a_to_txt( "", .t. )
	
	// datum isporuke - nista
	a_to_txt( "", .t. )
	
	// datum valute - nista
	a_to_txt( "", .t. )

	gather()

	select (nADOC_IT)
	
enddo

select (245)
use

msgbeep("export dokumenta zavrsen !")

select (nTArea)
return


// ----------------------------------------------------
// pronadji partnera u PARTN
// ----------------------------------------------------
static function fnd_partn( xPartn, nCustId, cDesc )
local nTArea := SELECT()
private GetList:={}

O_PARTN

xPartn := SPACE(6)

Box(, 5, 70)
	@ m_x + 1, m_y + 2 SAY "Partner " + ALLTRIM(STR(nCustId)) + "-" + PADR(cDesc, 50) + ".."
	@ m_x + 2, m_y + 2 SAY "nije definisan, pokusajte naci partnera"
	@ m_x + 4, m_y + 2 SAY "sifra =" GET xPartn VALID p_firma( @xPartn )
	read
BoxC()

select (nTArea)

ESC_RETURN 0
return 1


// ----------------------------------------------------
// pronadji robu u ROBA
// ----------------------------------------------------
static function fnd_roba( xRoba, nArtId, cDesc )
local nTArea := SELECT()
private GetList:={}

O_ROBA
O_SIFK
O_SIFV

xRoba := SPACE(10)

Box(, 5, 70)
	@ m_x + 1, m_y + 2 SAY "Artikal " + ALLTRIM(STR(nArtId)) + "-" + PADR(cDesc, 50) + ".."
	@ m_x + 2, m_y + 2 SAY "nije definisan, pokusajte naci artikal"
	@ m_x + 4, m_y + 2 SAY "sifra =" GET xRoba VALID p_roba( @xRoba )
	read
BoxC()

select (nTArea)

ESC_RETURN 0
return 1



// ----------------------------------------
// vraca naziv partnera iz FMK
// ----------------------------------------
static function _g_pfmk_desc( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

altd()

if FOUND()
	xRet := ALLTRIM( partn->naz )
endif

select (nTArea)
return xRet


// ----------------------------------------
// vraca adresu partnera iz FMK
// ----------------------------------------
static function _g_pfmk_addr( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
	xRet := ALLTRIM( partn->adresa )
endif

select (nTArea)
return xRet


// ----------------------------------------
// vraca mjesto i ptt partnera iz FMK
// ----------------------------------------
static function _g_pfmk_place( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
	xRet := ALLTRIM( partn->ptt ) + " " + ALLTRIM( partn->mjesto )
endif

select (nTArea)
return xRet




// ----------------------------------------------
// novi dokument u fakt-u
// ----------------------------------------------
static function fa_new_doc( cFaFirma, cFaTipDok )
local cDokBr := REPLICATE("9", 8)
local nTArea := SELECT()
local cPom
local nPom

select 240
use ( ALLTRIM(gFaKumDir) + "DOKS" ) alias FA_DOKS
set order to tag "1"
go top
seek cFaFirma + cFaTipDok + CHR(254)
skip -1

if field->idfirma == cFaFirma .and. field->idtipdok == cFaTipDok
	cPom := ALLTRIM( field->brdok )
	nPom := VAL( cPom )
else
	nPom := 0
endif

cDokBr := PADL( ALLTRIM(STR( nPom + 1 )), 5, "0" )

select (nTArea)
return cDokBr


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
static function a_to_txt( cVal, lEmpty )
local nTArr
nTArr := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

// ako je prazno nemoj dodavati
if !lEmpty .and. EMPTY(cVal)
	return
endif

_txt += CHR(16) + cVal + CHR(17)

select (nTArr)
return


