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
local nTArea
local cHeader
local cFooter
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

	Box(, 16, 77, .t.)
	
	@ m_x + 16, m_y + 2 SAY "<c-N> Novi | <c-T> Brisi | <F2> Ispravi ..."

	ObjDbedit(, 16, 77, {|| key_handler(Ch)}, cHeader, cFooter , .t.,,,,1)

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
AADD(aImeKol, {PADC("Naziv", 40), {|| PADR(art_desc, 40)}, "art_desc"})

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
		
		// dodijeli i zauzmi novu sifru...
		select articles
		set filter to
		set relation to
		nTRec := RECNO()
		
		_set_sif_id(@nArt_id, "ART_ID")
		
		if s_elements( nArt_id, .t. ) == 1
			
			select articles
			go (nTRec)
			return DE_REFRESH
			
		endif
		
		select articles
		go (nTRec)
		
		return DE_REFRESH
		
	case Ch == K_F2
		
		// ispravka sifre
		
		if s_elements( field->art_id ) == 1
			
			select articles
			return DE_REFRESH
		
		endif
		
		select articles
		go (nTRec)
		
		return DE_CONT
		
	case Ch == K_CTRL_T

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



// -------------------------------------------
// poruka artikal zauzet
// -------------------------------------------
static function msg_art_busy()
MsgBeep("Neko vrsi ispravku artikla#Pregled onemogucen")
return


// -------------------------------------------
// da li je artikal zauzet
// -------------------------------------------
static function is_art_busy()
local lRet := .f.
if field->art_status == 3
	lRet := .t.
endif
return lRet

// -------------------------------------------
// setuje status artikla
// -------------------------------------------
static function set_art_status( nStatus )
Scatter()
_art_status := nStatus
Gather()
return


// -------------------------------
// convert art_id to string
// -------------------------------
function artid_str(nId)
return STR(nId, 10)


// -------------------------------
// get art_desc by art_id
// -------------------------------
function g_art_desc(nArt_id)
local cArtDesc := "?????"
local nTArea := SELECT()

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
local lE_att := .f.

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
		cArt_desc += ";"
	endif

	// grupa_naziv, npr: staklo
	cArt_desc += ALLTRIM( g_e_gr_desc( nEl_gr_id) )
	cArt_desc += " "

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
	
		// generisi samo za tip i debljinu...
		if "tip" $ cE_gr_att .or.  ;
			"deblj" $ cE_gr_att
	
			cArt_desc += cE_gr_val
			
			if "tip" $ cE_gr_att
				cArt_mcode += UPPER(LEFT(cE_gr_val, 3))
			endif
			
			if "deblj" $ cE_gr_att
			
				cArt_desc += "mm"
				cArt_mcode += cE_gr_val
				
			endif
		
			cArt_desc += " "
		
			lE_Att := .t.
			
		endif
		
		// vrsta sirovine
		if "vrsta" $ cE_gr_att
		
			if cE_gr_val $ "kupac#narucioc"
			
				cArt_desc += "(" + cE_gr_val + ")"
				cArt_mcode += UPPER(LEFT(cE_gr_val, 3))
				
			endif
			
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

		if !EMPTY(cAop_desc) .and. cAop_desc <> "?????"
			cArt_desc += " "
			cArt_desc += cAop_desc 
			cArt_mcode += UPPER(LEFT(cAop_desc, 3))
		endif

		if !EMPTY(cAop_att_desc) .and. cAop_att_desc <> "?????"
			cArt_desc += " "
			cArt_desc += cAop_att_desc
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

	if !EMPTY(cArt_desc) .and. lE_att == .t. ;
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
		
	// izbrisi tu stavku....
	art_delete( nArt_id, .t. , .t. )
	
endif

return 0


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

ESC_RETURN 0

return 1



// ------------------------------------
// vraca string STR(3)
// ------------------------------------
static function art_busy()
return STR(3,1)



// ------------------------------------------------
// napuni matricu aElem sa elementima artikla
// aElem - matrica sa elementima
// nArt_id - id artikla
// 
// aElem = { tip, naz, mc, e_gr_at_id, e_gr_vl_id }
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

nEl_id := field->el_id
	
// atributi
select e_att
set order to tag "1"
go top
seek artid_str( nEl_id )
	
do while !EOF() .and. field->el_id == nEl_id

	AADD(aElem, { "ATT",  cArt_desc, cArt_mc, field->e_gr_at_id, field->e_gr_vl_id })
	skip

enddo
	
// operacije
select e_aops
set order to tag "1"
go top
seek artid_str( nEl_id )

do while !EOF() .and. field->el_id == nEl_id
	AADD(aElem, { "AOP",  cArt_desc, cArt_mc, field->aop_id, field->aop_att_id })
	skip
enddo
	
select (nTArea)
return


