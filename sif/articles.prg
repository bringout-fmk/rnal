#include "\dev\fmk\rnal\rnal.ch"


// variables
static l_open_dbedit
static par_count
static _art_id
static l_auto_find

// ------------------------------------------------
// otvara sifrarnik artikala
// cId - artikal id
// ------------------------------------------------
function s_articles(cId, lAutoFind)
local nBoxX := 22
local nBoxY := 77
local nTArea
local cHeader
local cFooter
local cOptions := ""
local GetList:={}
private ImeKol
private Kol

par_count := PCOUNT()
l_open_dbedit := .t.

if lAutoFind == nil
	lAutoFind := .f.
endif

l_auto_find := lAutoFind

if ( par_count > 0 )
	if lAutoFind == .f.
		l_open_dbedit := .f.
	endif
	if cId <> VAL(artid_str(0)) .and. lAutoFind == .t.
		l_open_dbedit := .f.
		lAutoFind := .f.
	endif
endif

nTArea := SELECT()

cHeader := "Artikli /"
cFooter := ""

select articles
set relation to
set filter to
set order to tag "1"
go top

if !l_open_dbedit
	
	seek artid_str(cId)
	
	if !FOUND()
		l_open_dbedit := .t.
		go top
	endif

endif

if l_open_dbedit
	
	set_a_kol(@ImeKol, @Kol)

	cOptions += "<c-N> novi "
	cOptions += "<c-T> brisi "
	cOptions += "<F2> ispravi "
	cOptions += "<F4> dupliciraj "

	Box(, nBoxX, nBoxY, .t.)
	
	@ m_x + nBoxX, m_y + 2 SAY cOptions

	ObjDbedit(, nBoxX, nBoxY, {|| key_handler(Ch)}, cHeader, cFooter , .t.,,,,7)

	BoxC()

endif

cId := field->art_id

select (nTArea)

return 



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

altd()
AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(art_id)}, "art_id", {|| _inc_id(@wart_id, "ART_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 60), {|| PADR(art_desc, 60)}, "art_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler()
local nArt_id := 0
local cArt_desc := ""
local nTRec := RecNO()
local nRet

// prikazi box preview
box_preview( 17, 1, 77 )

do case
	
	case l_auto_find == .t.

		pick_articles()
		
		l_auto_find := .f.
		
		Tb:RefreshAll()
     		
		while !TB:stabilize()
		end
		
		return DE_CONT
	
	case Ch == K_CTRL_N
		
		// novi artikal...
		
		if !ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "ARTNEW")
			
			MsgBeep( cZabrana )
			select articles
			
			return DE_CONT
		endif
		
		// dodijeli i zauzmi novu sifru...
		select articles
		set filter to
		set relation to
		
		if _set_sif_id(@nArt_id, "ART_ID") == 0
			return DE_CONT
		endif
			
		if s_elements( nArt_id, .t. ) == 1
			select articles
			go bottom
		else
			select articles
			go (nTRec)
		endif
		
		return DE_REFRESH
		
	case Ch == K_F2
		
		// ispravka sifre
		
		if !ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "ARTEDIT")
			
			MsgBeep( cZabrana )
			select articles
			return DE_CONT
			
		endif
		
		if s_elements( field->art_id ) == 1
			
			select articles
			return DE_REFRESH
		
		endif
		
		select articles
		go (nTRec)
		
		return DE_CONT
	
	case Ch == K_F4

		// ima li pravo pristupa...
		if !ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "ARTDUPLI")
			
			Msgbeep( cZabrana )
			select articles
			return DE_CONT
			
		endif
		
		// dupliciranje (kloniranje) artikla....
		select articles

		nArt_new := clone_article( articles->art_id ) 
		
		if nArt_new > 0 .and. s_elements( nArt_new, .t. ) == 1
		
			select articles
			go (nTRec)
		
			return DE_REFRESH
		endif
		
		select articles
		go (nTRec)
		return DE_REFRESH
	
	case Ch == K_CTRL_T

		if !ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "ARTNEW")
			msgbeep( cZabrana )
			select articles
			return DE_CONT
		endif
		
		if art_delete( field->art_id, .t. ) == 1
			
			return DE_REFRESH
		
		endif
		
		return DE_CONT

	
	case Ch == K_ENTER

		// izaberi sifru....
		if par_count > 0
			return DE_ABORT
		endif

	case Ch == K_ALT_F

		// selekcija artikala....
		if pick_articles() == 1
			return DE_REFRESH
		endif
		return DE_CONT
		
		
endcase
return DE_CONT


// ----------------------------------------
// prikazi info artikla u box preview
// ----------------------------------------
static function box_preview(nX, nY, nLen)
local aDesc := {}
local i

aDesc := TokToNiz( articles->art_desc, ";" )

@ nX, nY SAY PADR("ID: " + artid_str(articles->art_id) + SPACE(3) + "MATCH CODE: " + articles->match_code, nLen) COLOR "GR+/G" 

for i:=1 to 5
	@ nX + i, nY SAY PADR("", nLen) COLOR "BG+/B"
next

for i:=1 to LEN(aDesc)

	@ nX + i, nY SAY PADR( " * " + ALLTRIM(aDesc[i]), nLen ) COLOR "BG+/B"

next

return


// -------------------------------
// convert art_id to string
// -------------------------------
function artid_str(nId)
return STR(nId, 10)


// -------------------------------
// get art_desc by art_id
// -------------------------------
function g_art_desc(nArt_id, lEmpty)
local cArtDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cArtDesc := ""
endif

O_ARTICLES
select articles
set order to tag "1"
go top
seek artid_str(nArt_id)

if FOUND()
	if !EMPTY(field->art_desc)
		cArtDesc := ALLTRIM(field->art_desc)
	endif
endif

select (nTArea)

return cArtDesc



// -------------------------------------------------------
// brisanje sifre iz sifrarnika
// nArt_id - artikal id
// lSilent - tihi nacin rada, bez pitanja .t.
// lChkKum - check kumulativ...
// -------------------------------------------------------
static function art_delete( nArt_id, lChkKum, lSilent )
local nEl_id 

if lSilent == nil
	lSilent := .f.
endif

if lChkKum == nil
	lChkKum := .f.
endif

if lChkKum == .t.
	O_DOC_IT
	select doc_it
	set order to tag "2"
	go top
	
	seek artid_str( nArt_id )
	
	if FOUND()
		
		MsgBeep("Artikal vec postoji u dokumentima!#Brisanje onemoguceno")
		select articles
		return 0	
		
	endif
endif

select articles
set order to tag "1"
go top
seek artid_str( nArt_id )

if FOUND()
	
	if !lSilent .and. Pitanje(, "Izbrisati zapis (D/N) ???", "N") == "N"
		return 0
	endif
	
	delete

	select elements
	set order to tag "1"
	go top
	seek artid_str( nArt_id )

	do while !EOF() .and. field->art_id == nArt_id
		
		nEl_id := field->el_id
		
		select e_att
		set order to tag "1"
		go top
		seek elid_str( nEl_id )
		
		do while !EOF() .and. field->el_id == nEl_id
			delete
			skip
		enddo

		select e_aops
		set order to tag "1"
		go top
		seek elid_str( nEl_id )
	
		do while !EOF() .and. field->el_id == nEl_id
			delete
			skip
		enddo
		
		select elements
		
		delete
		skip
	
	enddo
	
endif

select articles

return 1

// ----------------------------------------------
// kloniranje artikla
// ----------------------------------------------
static function clone_article( nArt_id )
local nArtNewid
local nElRecno
local nOldEl_id
local nElGr_id
local nElNewid := 0

if Pitanje(, "Duplicirati artikal (D/N)?", "D") == "N"
	return -1
endif

select articles
set filter to
set relation to

if _set_sif_id( @nArtNewid, "ART_ID" ) == 0
	return -1
endif

// ELEMENTS
select elements
set order to tag "1"
go top
seek artid_str( nArt_id ) 

do while !EOF() .and. field->art_id == nArt_id

	nOldEl_id := field->el_id
	nElGr_id := field->e_gr_id

	skip 1
	nElRecno := RECNO()
	skip -1
	
	// daj mi novi element
	_set_sif_id( @nElNewid, "EL_ID" )
	
	Scatter("w")
	
	wart_id := nArtNewid
	we_gr_id := nElGr_id
	
	Gather("w")

	// atributi...
	_clone_att( nOldEl_id, nElNewid )

	// operacije...
	_clone_aops( nOldEl_id, nElNewid )

	select elements
	go (nElRecno)
	
enddo

return nArtNewid


// ------------------------------------------------
// kloniranje atributa prema elementu
// nOldEl_id - stari element id
// nNewEl_id - novi element id
// ------------------------------------------------
static function _clone_att( nOldEl_id, nNewEl_id )
local nElRecno
local nNewAttId

select e_att
set order to tag "1"
go top

seek elid_str( nOldEl_id )

do while !EOF() .and. field->el_id == nOldEl_id
	
	skip 1
	nElRecno := RECNO()
	skip -1
	
	Scatter("w")
	
	_set_sif_id( @nNewAttId, "EL_ATT_ID" )
	
	Scatter()

	wel_att_id := nNewAttId
	wel_id := nNewEl_id
	
	Gather("w")
	
	select e_att
	go (nElRecno)
	
enddo

return


// ------------------------------------------------
// kloniranje operacija prema elementu
// nOldEl_id - stari element id
// nNewEl_id - novi element id
// ------------------------------------------------
static function _clone_aops( nOldEl_id, nNewEl_id )
local nElRecno
local nNewAopId

select e_aops
set order to tag "1"
go top

seek elid_str( nOldEl_id )

do while !EOF() .and. field->el_id == nOldEl_id
	
	skip 1
	nElRecno := RECNO()
	skip -1
	
	Scatter("w")
	
	_set_sif_id( @nNewAopId, "EL_OP_ID" )
	
	Scatter()
	
	wel_op_id := nNewAopid
	wel_id := nNewEl_id
	
	Gather("w")
	
	select e_aops
	go (nElRecno)
	
enddo

return




// ----------------------------------------------
// setovanje opisa artikla na osnovu tabela
//   ELEMENTS, E_AOPS, E_ATT
//
//  nArt_id - artikal id
//  lNew - novi artikal
// ----------------------------------------------
function _art_set_descr( nArt_id, lNew )
local cArt_desc := ""
local cArt_mcode := ""
local nEl_id
local nEl_gr_id
local nCount := 0
local nE_gr_att 
local nE_gr_val
local cE_gr_val
local cE_gr_att
local lAppend := .f.

// ukini filtere
select elements
set filter to
select e_att
set filter to
select e_aops
set filter to

// elementi...
select elements
set order to tag "1"
go top
seek artid_str( nArt_id )

do while !EOF() .and. field->art_id == nArt_id
	
	nEl_id := field->el_id
	nEl_gr_id := field->e_gr_id
	
	if nCount > 0
		__add_to_str( @cArt_desc, ";", .t. )
	endif

	// grupa_naziv, npr: staklo
	
	__add_to_str( @cArt_desc, ALLTRIM( g_e_gr_desc(nEl_gr_id) ))

	// predji na atribute elemenata...
	select e_att
	set order to tag "1"
	go top
	seek elid_str( nEl_id )

	do while !EOF() .and. field->el_id == nEl_id

		// vrijednost atributa
		nE_gr_val := field->e_gr_vl_id
		cE_gr_val := ALLTRIM(g_e_gr_vl_desc( nE_gr_val ))
		
		// atributi...
		nE_gr_att := g_gr_att_val( nE_gr_val )
		cE_gr_att := ALLTRIM(g_gr_at_desc( nE_gr_att ))

		if gr_att_in_desc( nE_gr_att )
		
			// dodaj u art_desc
			
			__add_to_str( @cArt_desc, cE_gr_val )
			
			// samo ako je debljina nastiklaj mm
			if "deblj" $ cE_gr_att
				__add_to_str( @cArt_desc, "mm" )
			endif

			// dodaj u mcode...
			__add_to_str( @cArt_mcode, UPPER(LEFT(cE_gr_val, 2)), .t.)
			
		endif
		
		skip
		
	enddo
	

	// predji na dodatne operacije elemenata....
	select e_aops
	set order to tag "1"
	go top
	seek elid_str( nEl_id )

	do while !EOF() .and. field->el_id == nEl_id
		
		// dodatna operacija...
		nAop_id := field->aop_id
		cAop_desc := ALLTRIM(g_aop_desc( nAop_id ))
		
		// atribut...
		nAop_att_id := field->aop_att_id
		cAop_att_desc := ALLTRIM( g_aop_att_desc( nAop_att_id ) )

		// da li operacija ide u naziv...
		if aop_in_desc( nAop_id )
			
			if !EMPTY(cAop_desc) .and. cAop_desc <> "?????"
				__add_to_str( @cArt_desc, cAop_desc )
				__add_to_str( @cArt_mcode, ;
					UPPER(LEFT(cAop_desc, 1)), .t.)
			endif
			
		endif
		
		// da li atribut ide u naziv...
		if aop_att_in_desc( nAop_att_id )
		
			if !EMPTY(cAop_att_desc) .and. cAop_att_desc <> "?????"
			
				__add_to_str( @cArt_desc, cAop_att_desc )
			
			endif
			
		endif
		
		skip
	enddo

	// vrati se na elemente i idi dalje...
	select elements
	skip
	
	++ nCount
enddo

// update art_desc..
select articles
set order to tag "1"
go top
seek artid_str( nArt_id )

if FOUND()

	if !lNew
		if ALLTRIM(cArt_desc) <> ALLTRIM(articles->art_desc)
			lAppend := .t.
		endif
	else
		lAppend := .t.
	endif

	if !EMPTY(cArt_desc) .and. lAppend == .t. ;
		.and. (!lNew .or. (lNew .and. Pitanje(,"Novi artikal, snimiti promjene ?", "D") == "D"))

		cArt_desc := PADR(cArt_desc, 250)
		cArt_mcode := PADR(cArt_mcode, 10)
		
		// daj box za pregled korekciju
		if _box_art_desc( @cArt_desc, @cArt_mcode ) == 1
			
			Scatter()
			
			_art_desc := cArt_desc
			_match_code := cArt_mcode
			
			Gather()
		
			return 1
		
		endif
		
	endif
		
	if lNew	
		// izbrisi tu stavku....
		art_delete( nArt_id, .t. , .t. )
	endif
	
endif

return 0


// ------------------------------------------------
// dodaj na string cStr string cAdd
// cStr - po referenci string na koji se stikla
// cAdd - dodatak za string
// lNoSpace - .t. - nema razmaka
// ------------------------------------------------
static function __add_to_str( cStr, cAdd, lNoSpace )
local cSpace := SPACE(1)

if lNoSpace == nil
	lNoSpace := .f.
endif

if EMPTY(cStr) .or. lNoSpace == .t.
	cSpace := ""
endif

cStr += cSpace + cAdd

return



// ------------------------------------------------------
// box za unos naziva artikla i match_code-a
// ------------------------------------------------------
static function _box_art_desc( cArt_desc, cArt_mcode )
private GetList:={}

Box(, 4, 70)
	
	@ m_x + 1, m_y + 2 SAY "*** pregled/korekcija podataka artikla"
	
	@ m_x + 3, m_y + 2 SAY "Naziv:" GET cArt_desc PICT "@S60" VALID !EMPTY(cArt_desc)
	
	@ m_x + 4, m_y + 2 SAY "Match code:" GET cArt_mcode
	
	read
	
BoxC()

ESC_RETURN 1

return 1



// ------------------------------------------------
// napuni matricu aElem sa elementima artikla
// aElem - matrica sa elementima
// nArt_id - id artikla
// 
// aElem = { el_id, tip, naz, mc, e_gr_at_id, e_gr_vl_id }
// ------------------------------------------------
function _fill_a_article(aElem, nArt_id)
local nTArea := SELECT()
local cArt_desc := ""
local cArt_mc := ""

aElem := {}

// artikli
select articles
set order to tag "1"
go top
seek artid_str( nArt_id )

if FOUND()
	cArt_desc := ALLTRIM(field->art_desc)
	cArt_mc := ALLTRIM(field->match_code)
endif

// elementi
select elements
set order to tag "1"
go top
seek elid_str( nArt_id )

do while !EOF() .and. field->art_id == nArt_id

	nEl_id := field->el_id

	// atributi
	select e_att
	set order to tag "1"
	go top
	seek artid_str( nEl_id )
	
	do while !EOF() .and. field->el_id == nEl_id

		AADD(aElem, { field->el_id, "ATT",  cArt_desc, cArt_mc, field->e_gr_at_id, field->e_gr_vl_id })
		skip

	enddo
	
	// operacije
	select e_aops
	set order to tag "1"
	go top
	seek artid_str( nEl_id )

	do while !EOF() .and. field->el_id == nEl_id
		AADD(aElem, { field->el_id, "AOP",  cArt_desc, cArt_mc, field->aop_id, field->aop_att_id })
		skip
	enddo
	
	select elements
	skip
	
enddo

select (nTArea)
return



// ------------------------------------------------
// napuni matricu aElem cisto sa elementima artikla
// aElem - matrica sa elementima
// nArt_id - id artikla
// 
// aElem = { el_id, grupa }
// ------------------------------------------------
function _g_art_elements(aElem, nArt_id)
local nTArea := SELECT()
local cPom := ""
local nCnt := 0

aElem := {}

// elementi
select elements
set order to tag "1"
go top
seek elid_str( nArt_id )

do while !EOF() .and. field->art_id == nArt_id

	++ nCnt 
	
	cPom := g_e_gr_desc( field->e_gr_id )
	cPom += " "
	cPom += get_el_desc( field->el_id )

	AADD(aElem, { field->el_id, cPom, nCnt } )
		
	skip

enddo
	
select (nTArea)
return



// -------------------------------------
// get element description 
// -------------------------------------
static function get_el_desc( nEl_id )
local xRet := ""
local nTArea := SELECT()

select e_att
set order to tag "1"
go top
seek elid_str( nEl_id )

do while !EOF() .and. field->el_id == nEl_id
	
	xRet += ALLTRIM(  g_e_gr_vl_desc(field->e_gr_vl_id) ) + " "
	
	skip
enddo

select (nTArea)
return xRet


// ---------------------------------------
// vraca broj elementa artikla
// ---------------------------------------
function _g_elem_no( aElem, nDoc_el_no, nElem_no )
local nTmp
nTmp := ASCAN( aElem, {|xVal| xVal[1] == nDoc_el_no })
nElem_no := aElem[ nTmp, 3 ]
return



