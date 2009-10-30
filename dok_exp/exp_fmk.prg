#include "rnal.ch"


// ---------------------------------------------
// export grupe naloga u FMK otpremnicu
// ---------------------------------------------
function m_gr_expfmk()
local nCustomer
local dDateFrom
local dDateTo
local cGens
local lSumirati
local cTBFilt := ""
local lFilterAll := .f.

private GetList := {}

private ImeKol
private Kol

private _exp_dfrom
private _exp_dto
private _exp_customer

o_tables( .f. )

// setuj uslove generacije
if _g_vars( @nCustomer, @dDateFrom, @dDateTo, @cGens, @lSumirati ) == .f.
	return
endif

if cGens == "D"
	lFilterAll := .t.
endif

Box(, 18, 77 )

@ m_x + 17, m_y + 2 SAY "<SPACE> markiraj za generisanje"

_exp_dto := dDateTo
_exp_dfrom := dDateFrom
_exp_customer := nCustomer

select docs
set order to tag "1"

// setovanje kolona browse-a
set_a_cols( @ImeKol, @Kol )

// setuj filter....
set_t_filter( lFilterAll )

ObjDbedit("expnal", 18, 77, {|| _key_hand( ) }, "", "", , , , , 2)

BoxC()

if LastKey() == K_ESC

	if Pitanje(, "Formirati otpremnicu na osnovu markiranih naloga?", "N" ) == "N"
		return
	endif

	go top
	
	do while !EOF() .and. doc_in_fmk == 9
		
		// prebaci u FAKT

		exp_2_fmk( doc_no, .f. , .f., lSumirati  )		
		
		select docs
		
		skip
		
	enddo

endif


return



// ----------------------------------------------
// key handler
// ----------------------------------------------
static function _key_hand(  )

do case
	// markiranje stavke....
	case Ch == ASC(" ") .or. Ch==K_ENTER
		
		beep(1)
		
		if doc_in_fmk == 0 .or. doc_in_fmk == 1
			
			replace doc_in_fmk with 9
			
		else
			
			replace doc_in_fmk with 0
			
		endif
		
		return DE_REFRESH
		
endcase

return DE_CONT




// ------------------------------------------
// setovanje filtera
// ------------------------------------------
static function set_t_filter( lAllDocs )
local cFilter := ""

if lAllDocs == nil
	lAllDocs := .f.
endif

// doc_in_fmk = 0 - nije prenesen
// doc_in_fmk = 1 - prenesen je
// doc_in_fmk = 9 - marker / treba prenjeti

cFilter += "( doc_date >= " + cm2str( _exp_dfrom )
cFilter += " .and. "
cFilter += "doc_date <= " + cm2str( _exp_dto  )
cFilter += " ) .and. "
cFilter += "cust_id == _exp_customer "

if lAllDocs == .f.
	cFilter += " .and. "
	cFilter += "doc_in_fmk <> 1 "
endif

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
AADD( aImeKol, { "kontakt / opis naloga", {|| PADR(g_cont_desc( cont_id ), 10) + "/" + PADR( doc_sh_desc, 15) + "/" + PADR( doc_desc, 15 ) + ".." }, "doc_sh_desc" })
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
elseif nMark == 1
	xRet := "prenesen"
else
	xRet := "*"
endif

return xRet

// ---------------------------------------------
// uslovi za generaciju
// ---------------------------------------------
static function _g_vars( nCustomer, dDateFrom, dDateTo, cGens, lSumirati )
local nX := 1

nCustomer := 0
cCustomer := SPACE(10)
dDateFrom := DATE()-31
dDateTo := DATE()
cGens := "N"
lSumirati := .t.
cSumirati := "D"

Box(, 10, 70 )
	
	@ m_x + nX, m_y + 2 SAY "Narucioc:" GET cCustomer VALID {|| s_customers( @cCustomer, cCustomer), set_var(@nCustomer, @cCustomer),  show_it( g_cust_desc(nCustomer) ) }

	nX += 2

	@ m_x + nX, m_y + 2 SAY "obuhvatiti naloge iz perioda...."
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "od:" GET dDateFrom
	@ m_x + nX, col() + 1 SAY "do:" GET dDateTo
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Uzeti u obzir vec prenesene dokumente ?" GET cGens VALID cGens $ "DN" PICT "@!"
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "Sumirati iste artikle sa naloga ?" GET cSumirati VALID cSumirati $ "DN" PICT "@!"
	

	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

if cSumirati == "N"
	lSumirati := .f.
endif


return .t.


// -----------------------------------------
// box za upit sumiranja
// -----------------------------------------
static function _g_sumbox( lReturn )

lReturn := Pitanje(,"Sumirati stavke sa naloga (D/N)","D") = "D"

return



// ------------------------------------------
// export u FMK
// ------------------------------------------
function exp_2_fmk( nDoc_no, lTemp, lOneByOne, lSumirati )
local nTArea := SELECT()
local nADOCS := F_DOCS
local nADOC_IT := F_DOC_IT
local nADOC_OP := F_DOC_OPS
local cFmkDoc
local nCust_id
local i

if lOneByOne == nil
	lOneByOne := .t.
endif

if lSumirati == nil
	// sumirati stavke da ili ne
	_g_sumbox( @lSumirati )
endif

if Pitanje(,"Promjeniti podatke isporuke ?", "N") == "D"
	
	// napuni pripremu
	st_pripr( lTemp, nDoc_no )
	// selektuj stavke
	sel_items()

endif

if !FILE(ALLTRIM(gFaPrivDir) + "PRIPR.DBF")
	msgbeep("Nije podesena lokacija FAKT ???")
	select (nTarea)
	return
endif

// select pripreme fakt
select (245)
use ( ALLTRIM(gFaPrivDir) + "PRIPR" ) alias X_TBL

if lOneByOne == .t. .and. RECCOUNT2() > 0
	
	msgbeep("priprema fakt nije prazna !")
	select (245)
	use
	select (nTArea)
	return
		
endif

if lTemp == nil
	lTemp := .f.
endif

if lTemp == .t.
	nADOCS := F__DOCS
	nADOC_IT := F__DOC_IT
	nADOC_OP := F__DOC_OPS
endif

select (nADOCS)
set order to tag "1"
seek docno_str( nDoc_no )

nCust_id := field->cust_id
nCont_id := field->cont_id

cCust_desc := g_cust_desc( nCust_id )
cCont_desc := g_cont_desc( nCont_id )

O_T_DOCIT
	
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
cCtrlNo := "22"
cBrDok := fa_new_doc( "10", cCtrlNo )

cFmkDoc := cIdVd + "-" + ALLTRIM(cBrdok)

select (nADOC_IT)
set order to tag "3"
seek docno_str( nDoc_no )

nRbr := 0

do while !EOF() .and. field->doc_no == nDoc_no

	nArt_id := field->art_id
	cIdRoba := g_rel_val("1", "ARTICLES", "ROBA", ALLTRIM(STR(nArt_id)) )
	
	// uzmi cijenu robe iz sifrarnika robe
	nPrice := g_art_price( cIdRoba )

	// uzmi opis artikla
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

		// probaj izvuci podatak sa obracunskog lista ...
		nDoc_it_no := field->doc_it_no
		
		select t_docit
		go top
		seek docno_str( nDoc_no ) + docit_str( nDoc_it_no )
		
		nDeliver := 0
		if FOUND() .and. field->art_id == nArt_id
			nDeliver := field->deliver
		endif
		
		select (nADOC_IT)

		// kolicina
		nQty := field->doc_it_qtty

		if nDeliver <> 0
			nQty := nDeliver
		endif
		
		// visina u mm
		nHeig := field->doc_it_height
		// sirina u mm
		nWidt := field->doc_it_width

		nH2 := field->doc_it_h2
		nW2 := field->doc_it_w2
		
		// pa zaokruziti po GN-u ?????
		
		nZHeig := 0
		nZWidt := 0
		nZ2Heig := 0
		nZ2Widt := 0
	
		lBezZaokr := .f.

		if lBezZaokr == .f.
			// da li je kaljeno ? kod kaljenog nema zaokruzenja
			lBezZaokr := is_kaljeno( aZpoGN, field->doc_no, field->doc_it_no )
		endif

		if lBezZaokr == .f.
			// da li je emajlirano ? isto nema zaokruzenja
			lBezZaokr := is_emajl(aZpoGN, field->doc_no, field->doc_it_no )
		endif

		if lBezZaokr == .f.
			// da li je vatroglas ? isto nema zaokruzenja
			lBezZaokr := is_vglass( aZpoGN )
		endif

		if lBezZaokr == .f.
			// da li je plexiglas ? isto nema zaokruzenja
			lBezZaokr := is_plex( aZpoGN )	
		endif

		nZHeig := obrl_zaok( nHeig, aZpoGN, lBezZaokr )
		nZWidt := obrl_zaok( nWidt, aZpoGN, lBezZaokr )
		
		nZ2Heig := obrl_zaok( nH2, aZpoGN, lBezZaokr )
		nZ2Widt := obrl_zaok( nW2, aZpoGN, lBezZaokr )
	
		// izracunaj kvadrate
		nM2 += ROUND( c_ukvadrat( nQty, nZHeig, nZWidt, ;
			nZ2Heig, nZ2Widt ) , 2)
		
		skip
		
	enddo
	
	select X_TBL
	
	go bottom
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
	// veza, broj naloga
	_idpm := "RN-" + ALLTRIM(STR( nDoc_No ))

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


// sada obradi i sve operacije ovog dokumenta
select (nADOC_OP)
set order to tag "1"
go top

// pretrazi po broju naloga
seek docno_str(nDoc_no)

nRbr := 0

do while !EOF() .and. field->doc_no == nDoc_no

	// uzmi joker atributa operacije, ako postoji
	cJoker := ALLTRIM( g_aatt_joker( field->aop_att_id ) )

	if EMPTY(cJoker) .or. AT( "<", cJoker ) == 0

		// ako je prazan ili nema "<" 
		// uzmi joker operacije... 
		// npr: <A_BU>
		
		cJoker := g_aop_joker ( field->aop_id )
	
	endif
	
	select (nADOC_OP)
	
	// uzmi i vrijednost....
	cValue := ALLTRIM( field->aop_value )

	// uzmi podatke broj naloga i broj stavke	
	nDoc_no := field->doc_no
	nDoc_it := field->doc_it_no

	// pronadji ih u stavkama naloga
	select (nADOC_IT)
	set order to tag "1"
	go top
	seek docno_str( nDoc_no ) + docit_str( nDoc_it )

	nArt_id := field->art_id
	nQtty := field->doc_it_qtty
	nWidth := field->doc_it_width
	nHeigh := field->doc_it_heigh
	nW2 := field->doc_it_w2
	nH2 := field->doc_it_h2
	cItType := field->doc_it_type

	select (nADOC_OP)

	cIdRoba := ""
	nPrice := 0
	nKol := 0

	// daj mi vrijednosti za fakt u pom.matricu ....
	aTo_fakt := _g_fakt_values( cJoker, cValue, nArt_id, ;
			nQtty, nWidth, nHeigh, nW2, nH2, cItType )


	// upisi...
	select X_TBL
		
	for i:=1 to LEN( aTo_fakt )
	
		set order to tag "1"
		go bottom
	
		if !EMPTY( x_tbl->rbr )
			nRbr := VAL( x_tbl->rbr )
		endif
	
	   	if lSumirati == .t.
		
			// pronadji sifru...
			set order to tag "3"
			go top

		
			cIdRoba := aTo_fakt[ i, 1 ]
			// pronadji da li ima u pripremi ova stavka pa samo 
			// nadodaj
		
			select x_tbl 
	
			seek "10" + cIdRoba
		
			if FOUND()
			
				scatter()
			
				// samo uvecaj kolicinu...
				_kolicina := _kolicina + aTo_fakt[ i, 2 ]
			
				gather()
			
				loop
		
			endif
	    	endif

		// cijena artikla
		nPrice := g_art_price( PADR( cIdRoba, 10 ) )
	
		select x_tbl
		set order to tag "1"
		go top
		
		append blank
		
		scatter()

		_txt := ""
		_rbr := STR( ++nRbr, 3 )
		_idpartner := cPartn
		_idfirma := "10"
		_brdok := cBrDok
		_idtipdok := cIdVd
		_datdok := dDatDok
		_idroba := aTo_fakt[ i, 1 ]
		
		
		_cijena := nPrice
		_kolicina := aTo_fakt[ i, 2 ]
		_dindem := "KM "
		_zaokr := 2
	
		Gather()

	next

	// idi dalje
	select (nADOC_OP)
	skip

enddo

// setuj da je prenesen u fmk
select (nADocs)
seek docno_str(nDoc_no)
replace doc_in_fmk with 1
replace fmk_doc with cFmkDoc

select (245)
use

if lOneByOne == .t.
	msgbeep("export dokumenta zavrsen !")
endif

select (nTArea)

return




// ---------------------------------------
// daj mi vrijednosti za fakt....
// setuju se varijable:
//    cIdRoba, nPrice, nKol 
// ---------------------------------------
static function _g_fakt_values( cJoker, cValue, nArt_id, nQtty, ;
				nW1, nH1, nW2, nH2, cItType )

local aArr := {}
local aRet := {}
local cQttyType := ""

// standardne dimenzije
local nHeigh1 := nH1
local nWidth1 := nW1
local nHeigh2 := nH2
local nWidth2 := nW2

// skontaj koje su dimenzije u pitanju
if cItType == "R"
	
	// radijus - fi
	nWidth1 := nW1
	nHeigh1 := nH1
	
	if nHeigh1 == 0
		nHeigh1 := nWidth
	endif

elseif cItType == "S"
	
	// shaped 
	nHeigh1 := nH1
	nWidth1 := nW1
	nHeigh2 := nH2
	nWidth2 := nW2
	
endif

// uzmi u matricu artikal i njegove stavke
_art_set_descr( nArt_id, nil, nil, @aArr, .t. )

// broj elemenata...
nElCount := aArr[ LEN( aArr ), 1 ]

// debljina stakla
nTickness := g_gl_tickness( aArr, 1 )

// tip stakla
cType := g_gl_type( aArr, 1 )


// sada isprovjeravaj sve....

// busenje rupa
if cJoker == "<A_BU>"  .and. !EMPTY( cValue ) 

	// vrijednost = "H1=5;H2=6;..."
	// skontaj koliko ima rupa...
	aTmp := {}
	aTmp := TokToNiz( cValue, ":" )
	// prvi dio je sam joker dakle gledamo drugi clan...
	// #H1=15#H2=22# itd...
	cTmp := aTmp[ 2 ]
	aTmp := TokToNiz( cTmp, "#" )
	
	// atmp[1] = H1=15
	// aTmp[2] = H2=25
	
	for i := 1 to LEN( aTmp )
		
		// za svaku rupu odredi koja je sifra .....
		aTmp2 := {}
		aTmp2 := TokToNiz( aTmp[i], "=" )
		
		// debljina rupe
		nHoleTick := VAL( aTmp2[ 2 ] )
		
		// sifra artikla je ?
		cIdRoba := rule_s_fmk( cJoker, nHoleTick, "", "", @cQttyType )
		
		AADD( aRet, { cIdRoba, 1, 0 })
		
	next

elseif cJoker == "<A_B>" .and. !EMPTY( cValue ) 

	// sifra artikla
	cIdRoba := rule_s_fmk( cJoker, nTickness, "", "", @cQttyType )

	// uzmi kolicinu
	_g_kol( cValue, cQttyType, @nKol, nQtty, nHeigh1, nWidth1, nHeigh2, ;
			nWidth2 )
	
	AADD( aRet, { cIdRoba, nKol, 0 })

elseif !EMPTY( cJoker ) .and. !EMPTY( cValue )
	
	// sifra artikla
	cIdRoba := rule_s_fmk( cJoker, nTickness, "", "", @cQttyType )

	// uzmi kolicinu
	_g_kol( cValue, cQttyType, @nKol, nQtty, nHeigh1, nWidth1, ;
			nHeigh2, nWidth2 )
	
	AADD( aRet, { cIdRoba, nKol, 0 })

	
elseif !EMPTY(cJoker) .and. EMPTY( cValue )

	// sifra artikla
	cIdRoba := rule_s_fmk( cJoker, nTickness, "", "", @cQttyType )

	// uzmi kolicinu
	_g_kol( cValue, cQttyType, @nKol, nQtty, nHeigh1, nWidth1, ;
			nHeigh2, nWidth2 )
	
	AADD( aRet, { cIdRoba, nKol, 0 })

	
elseif EMPTY(cJoker) .and. EMPTY( cValue )

	cIdRoba := rule_s_fmk( cJoker, nTickness, cType, "", @cQttyType )

	// kolicina se uzima sa naloga
	
	nKol := nQtty
	
	AADD( aRet, { cIdRoba, nKol, 0 } )
	
endif


return aRet




// ----------------------------------------------------
// sracunaj kolicinu na osnovu vrijednosti polja
// ----------------------------------------------------
static function _g_kol( cValue, cQttyType, nKol, nQtty, ;
		nHeigh1, nWidth1, nHeigh2, nWidth2 )

local nTmp := 0

if nHeigh2 == nil
	nHeigh2 := 0
endif

if nWidth2 == nil
	nWidth2 := 0
endif

// po metru
if cQttyType == "M"	

	// po metru, znaèi uzmi sve stranice stakla
	
	if "#D1#" $ cValue
		nTmp += nWidth1
	endif
	
	if "#D4#" $ cValue
	
		if nWidth2 <> 0
			nTmp += nWidth2
		else
			nTmp += nWidth1
		endif
	
	endif

	if "#D2#" $ cValue
		nTmp += nHeigh1
	endif

	if "#D3#" $ cValue
		if nHeigh2 <> 0
			nTmp += nHeigh2
		else
			nTmp += nHeigh1
		endif
	endif

	// pretvori u metre
	nKol := ( nQtty * nTmp ) / 1000
	
endif

// po m2
if cQttyType == "M2"
	
	nKol := c_ukvadrat( nQtty, nHeigh1, nWidth1 ) 
	
endif

// po komadu
if cQttyType == "KOM"

	nKol := nQtty

endif

if EMPTY( cQttyType )

	nKol := nQtty

endif

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


