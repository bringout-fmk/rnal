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

altd()


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

	altd()
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

altd()

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
		
		_set_sif_id(@nArt_id, "ART_ID")
		
		if s_elements( nArt_id, .t. ) == 1
			
			select articles
			return DE_REFRESH
			
		endif
		
		select articles
		go (nTRec)
		
		return DE_CONT
		
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

		// brisanje sifre...
		if art_delete( field->art_id ) == 1
			
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


// ---------------------------------------------
// brisanje sifre iz sifrarnika
// nArt_id - artikal id
// lSilent - tihi nacin rada, bez pitanja .t.
// ---------------------------------------------
static function art_delete( nArt_id, lSilent )
local nEl_id 

if lSilent == nil
	lSilent := .f.
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
// ----------------------------------------------
function _art_set_descr( nArt_id )
local cArt_desc := ""
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
		
		cArt_desc += cE_gr_val

		if "deblj" $ cE_gr_att
			
			cArt_desc += "mm"
			
		endif
		
		cArt_desc += " "
		
		lE_Att := .t.
		
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

		if !EMPTY(cAop_desc) .or. cAop_desc <> "?????"
			cArt_desc += cAop_desc 
			cArt_desc += " "
		endif

		if !EMPTY(cAop_att_desc) .or. cAop_att_desc <> "?????"
			cArt_desc += cAop_att_desc
			cArt_desc += " "
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
	if !EMPTY(cArt_desc) .and. lE_att == .t.
	
		if EMPTY(field->art_desc) .or. (!EMPTY(field->art_desc) .and. Pitanje(, "Definisati naziv artikla (D/N) ?", "D") == "D")
			Scatter()
			_art_desc := cArt_desc
			Gather()
			return 1
		endif
		
	else
		
		// izbrisi tu stavku....
		art_delete(nArt_id, .t.)
		return 0
		
	endif
endif

return 0



