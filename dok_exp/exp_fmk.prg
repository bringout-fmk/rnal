#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// export grupe naloga u FMK otpremnicu
// ---------------------------------------------
function m_gr_expfmk()
local nCustomer
local dDateFrom
local dDateTo
local cTBFilt := ""

private GetList := {}

private ImeKol
private Kol

private _exp_dfrom
private _exp_dto
private _exp_customer

o_tables( .f. )

// setuj uslove generacije
if _g_vars( @nCustomer, @dDateFrom, @dDateTo ) == .f.
	return
endif


Box(, 20, 74 )

_exp_dto := dDateTo
_exp_dfrom := dDateFrom
_exp_customer := nCustomer

select docs
set order to tag "1"

// setovanje kolona browse-a
set_a_cols( @ImeKol, @Kol )

// setuj filter....
set_t_filter()

ObjDbedit("expnal", 20, 73, {|| _key_hand( ) }, "", "", , , , , 2)

BoxC()

if LastKey() == K_ESC

	if Pitanje(, "Formirati otpremnicu na osnovu markiranih naloga?", "N" ) == "N"
		return
	endif

	go top
	
	do while !EOF() .and. doc_in_fmk == 1
		
		// prebaci u FAKT

		exp_2_fmk( doc_no, .f. , .f.  )		
		
		select docs
		
		skip
		
	enddo

endif


return



// ----------------------------------------------
// key handler
// ----------------------------------------------
static function _key_hand(  )

altd()

do case
	// markiranje stavke....
	case Ch == ASC(" ") .or. Ch==K_ENTER
		
		beep(1)
		
		if doc_in_fmk == 0
			
			replace doc_in_fmk with 1
			
		else
			
			replace doc_in_fmk with 0
			
		endif
		
		return DE_REFRESH
		
endcase

return DE_CONT




// ------------------------------------------
// setovanje filtera
// ------------------------------------------
static function set_t_filter()
local cFilter := ""

// doc_in_fmk = 0 - nije prenesen
// doc_in_fmk = 1 - prenesen je

cFilter += "( doc_date >= " + cm2str( _exp_dfrom )
cFilter += " .and. "
cFilter += "doc_date <= " + cm2str( _exp_dto  )
cFilter += " ) .and. "
cFilter += "cust_id == _exp_customer "
cFilter += " .and. "
cFilter += "doc_in_fmk == 0 "

if !EMPTY( cFilter )
	select docs
	set filter to &cFilter
	go top
else
	select docs
	set filter to
	go top
endif

return


// -----------------------------------------------------
// setovanje kolone pregleda dokumenata za prenos
// -----------------------------------------------------
static function set_a_cols( aImeKol, aKol )
local i

aImeKol := {}
aKol := {}

AADD( aImeKol, { "Br.nal", {|| doc_no }, "doc_no" })
AADD( aImeKol, { "Dat.nal", {|| doc_date }, "doc_date" })
AADD( aImeKol, { "Opis naloga", {|| PADR( doc_sh_desc, 40) }, "doc_sh_desc" })
AADD( aImeKol, { "Marker", {|| _s_mark( doc_in_fmk ) }, "doc_in_fmk" })

for i:=1 to LEN( aImeKol )
	AADD( aKol, i )
next

return


// -------------------------------------------
// prikaz markera.... na browse-u
// -------------------------------------------
static function _s_mark( nMark )
local xRet := " "

if nMark == 0
	xRet := " "
else
	xRet := "*"
endif

return xRet

// ---------------------------------------------
// uslovi za generaciju
// ---------------------------------------------
static function _g_vars( nCustomer, dDateFrom, dDateTo )
local nX := 1

nCustomer := 0
cCustomer := SPACE(10)
dDateFrom := DATE()-31
dDateTo := DATE()

Box(, 10, 70 )
	
	@ m_x + nX, m_y + 2 SAY "Narucioc:" GET cCustomer VALID {|| s_customers( @cCustomer, cCustomer), set_var(@nCustomer, @cCustomer),  show_it( g_cust_desc(nCustomer) ) }

	nX += 1

	@ m_x + nX, m_y + 2 SAY "obuhvatiti naloge iz perioda...."
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "od:" GET dDateFrom
	@ m_x + nX, col() + 1 SAY "do:" GET dDateTo
	
	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.




// ------------------------------------------
// export u FMK
// ------------------------------------------
function exp_2_fmk( nDoc_no, lTemp, lOneByOne )
local nTArea := SELECT()
local nADOCS := F_DOCS
local nADOC_IT := F_DOC_IT
local nCust_id

if lOneByOne == nil
	lOneByOne := .t.
endif

// select pripreme fakt
select (245)
use ( ALLTRIM(gFaPrivDir) + "PRIPR" ) alias X_TBL

if lOneByOne == .t. .and. RECCOUNT2() > 0
	
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
nCont_id := field->cont_id

cCust_desc := g_cust_desc( nCust_id )
cCont_desc := g_cont_desc( nCont_id )

select (nADOCS)

dDatDok := field->doc_date

if nCust_id == 1
	// ako je NN kupac u RNAL, dodaj ovo kao contacts....
	cPartn := PADR( g_rel_val("1", "CONTACTS", "PARTN", ALLTRIM(STR(nCont_id)) ), 6 )
else
	// dodaj kao customs
	cPartn := PADR( g_rel_val("1", "CUSTOMS", "PARTN", ALLTRIM(STR(nCust_id)) ), 6 )
endif

// ako je partner prazno
if EMPTY( cPartn )

	if nCust_id == 1
		
		// ako je NN kupac, presvicaj se na CONTACTS
		
		// probaj naci partnera iz PARTN
		if fnd_partn( @cPartn, nCont_id, cCont_desc ) == 1 
		
			add_to_relation( "CONTACTS", "PARTN", ;
				ALLTRIM(STR(nCont_id)) , cPartn )
			
		else
		
			select (245)
			use
			
			select (nTArea)
			msgbeep("Operacija prekinuta !!!")
			return
		
		endif

	else
		// probaj naci partnera iz PARTN
		if fnd_partn( @cPartn, nCust_id, cCust_desc ) == 1 
		
			add_to_relation( "CUSTOMS", "PARTN", ;
				ALLTRIM(STR(nCust_id)) , cPartn )
			
		else
		
			select (245)
			use
			
			select (nTArea)
			msgbeep("Operacija prekinuta !!!")
			return
		
		endif
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
			select (245)
			use
			
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
	
	go bootom
	skip -1

	if !EMPTY( x_tbl->rbr )
		nRbr := VAL( x_tbl->rbr )
	endif
	
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
	a_to_txt( "" , .t. )
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

if lOneByOne == .t.
	msgbeep("export dokumenta zavrsen !")
endif

select (nTArea)
return


// ----------------------------------------------------
// pronadji partnera u PARTN
// ----------------------------------------------------
static function fnd_partn( xPartn, nCustId, cDesc  )
local nTArea := SELECT()
private GetList:={}

O_PARTN

xPartn := SPACE(6)

Box(, 5, 70)
	@ m_x + 1, m_y + 2 SAY "Narucioc: " 
	@ m_x + 1, col() + 1 SAY ALLTRIM(STR(nCustId)) COLOR "I"
	@ m_x + 1, col() + 1 SAY " -> " 
	@ m_x + 1, col() + 1 SAY PADR(cDesc, 50) + ".." COLOR "I"
	@ m_x + 2, m_y + 2 SAY "nije definisan u relacijama, pronadjite njegov par !!!!"
	@ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xPartn VALID p_firma( @xPartn )
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
	@ m_x + 1, m_y + 2 SAY "Artikal:" 
	@ m_x + 1, col() + 1 SAY ALLTRIM(STR(nArtId)) COLOR "I"
	@ m_x + 1, col() + 1 SAY " -> " 
	@ m_x + 1, col() + 1 SAY PADR(cDesc, 50) + ".." COLOR "I"
	@ m_x + 2, m_y + 2 SAY "nije definisan u tabeli relacija, pronadjite njegov par !!!"
	@ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xRoba VALID p_roba( @xRoba )
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


