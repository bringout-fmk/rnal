#include "rnal.ch"


// variables
static l_open_dbedit
static par_count
static _art_id
static l_auto_find
static l_quick_find
static __art_sep
// article separator
static __mc_sep
// match code separator
static __qf_cond
// quick find condition
static __aop_sep
// addops separator



// ------------------------------------------------
// otvara sifrarnik artikala
// cId - artikal id
// ------------------------------------------------
function s_articles( cId, lAutoFind, lQuickFind )
local nBoxX := 22
local nBoxY := 77
local nTArea
local cHeader
local cFooter
local cOptions := ""
local cTag := "1"
local GetList:={}
private ImeKol
private Kol

par_count := PCOUNT()
l_open_dbedit := .t.

__art_sep := "_"
__aop_sep := "-"
__mc_sep := "_"
__qf_cond := SPACE(200)

if lAutoFind == nil
	lAutoFind := .f.
endif

if lQuickFind == nil
	lQuickFind := .f.
endif

l_auto_find := lAutoFind
l_quick_find := lQuickFind 

if l_auto_find == .t.
	l_quick_find := .f.
endif

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

// id: sort by art_id
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

	cOptions += "cN-novi "
	cOptions += "cT-brisi "
	cOptions += "F2-ispr. "
	cOptions += "F3-isp.naz. "
	cOptions += "F4-dupl. "
	cOptions += "aF-trazi "
	cOptions += "Q-br.traz"

	Box(, nBoxX, nBoxY, .t.)
	
	@ m_x + nBoxX + 1, m_y + 2 SAY cOptions

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

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(art_id)}, "art_id", {|| _inc_id(@wart_id, "ART_ID"), .f.}, {|| .t.}})
AADD(aImeKol, { "sifra :: puni naziv", {|| ALLTRIM(art_desc) + " :: " + UPPER(art_full_desc) }, "art_desc" })
AADD(aImeKol, { "labela opis", {|| ALLTRIM(art_lab_desc) }, "art_desc" })

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
local nArt_type := 0
local cSchema := SPACE(20)
local nTRec := RecNO()
local nRet

// prikazi box preview
box_preview( 17, 1, 77 )

do case
	
	// ako je iz auto pretrage sortiraj artikle
	case l_auto_find == .t.
		
		// odaberi artikle po filteru
		pick_articles()
		
		l_auto_find := .f.
		
		Tb:RefreshAll()
     		
		while !TB:stabilize()
		end
		
		return DE_CONT

	case l_quick_find == .t.

		_quick_find()
		
		l_quick_find := .f.
		
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
		
		// prvo mi reci koji artikal zelis praviti...
		_g_art_type( @nArt_type, @cSchema )
		
		if s_elements( nArt_id, .t., nArt_Type, cSchema ) == 1
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
			set order to tag "1"
			go (nTRec)
			
			return DE_REFRESH
		
		endif
		
		select articles
		set order to tag "1"
		go (nTRec)
		
		return DE_CONT
	
	case Ch == K_F3

		if art_ed_desc( field->art_id ) == 1
			return DE_REFRESH
		endif
		
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
			set order to tag "1"
			go (nTRec)
		
			return DE_REFRESH
		endif
		
		select articles
		set order to tag "1"
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
		
	case UPPER(CHR(Ch)) == "Q"

		// quick find...
		if _quick_find() == 1
			return DE_REFRESH
		endif
		
		return DE_CONT
	
endcase
return DE_CONT



// ---------------------------------------------
// vraca tip artikla koji zelimo praviti
// ---------------------------------------------
static function _g_art_type( nType, cSchema )
local nX := 1
private GetList := {}

cSchema := SPACE(20)
nType := 0

Box(, 10, 50)
	
	@ m_x + nX, m_y + 2 SAY "Odabir vrste artikla"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "   (1) jednostruko staklo"
	
	++nX
	
	@ m_x + nX, m_y + 2 SAY "   (2) dvostruko staklo"
	
	++nX
	
	@ m_x + nX, m_y + 2 SAY "   (3) trostruko/visestruko staklo"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "   (0) ostalo"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY " selekcija:" GET nType VALID nType >= 0 .and. nType <= 3 PICT "9"
	
	read

	if nType <> 0
		@ m_x + nX, m_y + 18 SAY "shema:" GET cSchema VALID __g_sch( @cSchema , nType )
	endif
	
	read
	
BoxC()


return


// ---------------------------------------
// odabir shema
// ---------------------------------------
static function __g_sch( cSchema, nType )
local aSch 
local i
local nSelect := 0

private opc := {}
private opcexe := {}
private izbor := 1

aSch := r_el_schema( nType )

if LEN(aSch) == 0
	
	msgbeep("ne postoje definisane sheme, koristim default")
	
	if nType == 1
		
		cSchema := "G"
	
	elseif nType == 2
		
		cSchema := "G-F-G"
		
	elseif nType == 3
	
		cSchema := "G-F-G-F-G"
	
	endif
	
	return .t.
	
endif


for i := 1 to LEN( aSch )

	cPom := PADR( aSch[i, 1], 30 )
	
	AADD( opc, cPom )
	AADD( opcexe, {|| nSelect := izbor, izbor := 0 })

next

Menu_SC("schema")

cSchema := ALLTRIM( aSch[ nSelect, 1 ] )

return .t.


// -----------------------------------------
// brza pretraga artikala
// -----------------------------------------
static function _quick_find()
local cFilt := ".t."

// box q.find
if _box_qfind() == 0
	return 0
endif

// generisi q.f. filter
if _g_qf_filt( @cFilt ) == 0
	return 0
endif

select articles 
set filter to 
go top

if cFilt == ".t."
	
	set filter to
	go top
	nRet := 0

else
	
	MsgO("Vrsim selekciju artikala... sacekajte trenutak....")
	
	cFilt := STRTRAN( cFilt, ".t. .and.", "") 
	
	set filter to &cFilt
	set order to tag "2"

	go top
	
	MsgC()
	nRet := 1

endif

return nRet



// -------------------------------------------------
// generisi filter na osnovu __qf_cond
// -------------------------------------------------
static function _g_qf_filt( cFilter )
local nRet := 0
local aTmp := {}
local aArtTmp := {}
local i
local nCnt

if EMPTY( __qf_cond )
	return nRet
endif

cCond := ALLTRIM( __qf_cond )

// 
// F4*F4;F2*F4; => aTmp[1] = F4*F4
//              => aTmp[2] = F2*F4

aTmp := TokToNiz( cCond, ";" )

// prodji kroz matricu aTmp
for i := 1 to LEN( aTmp )

	if ( i == 1 )
	
		cFilter += " .and. "
	
	else
	
		cFilter += " .or. "
	
	endif

	
	if "*" $ aTmp[ i ]

		aCountTmp := TokToNiz( cCond, "*" )
		nCount := LEN(aCountTmp)
		
		// "*F4"
		
		if LEFT( aTmp[i] , 1 ) == "*" .and. nCount == 1
	
			cTmp := UPPER(ALLTRIM( aCountTmp[ 1 ] ))
	
			cFilter += cm2str( "_" + cTmp ) 
			cFilter += " $ "
			cFilter += "ALLTRIM(UPPER(art_desc))"
		
	
		// "F4*"
		
		elseif RIGHT( aTmp[i], 1 ) == "*" .and. nCount == 1

			cTmp := UPPER(ALLTRIM( aCountTmp[ i ] ))
			nTmp := LEN(cTmp)
	
			cFilter += "LEFT(ALLTRIM(UPPER(art_desc)), " + ALLTRIM(STR(nTmp))+ ")"
			cFilter += " = "
			cFilter += cm2str( cTmp )
		

		elseif nCount > 1

			aArtTmp := TokToNiz( aTmp[i], "*" )
			
			for iii := 1 to LEN( aArtTmp )
				
				if iii == 1
			
					cTmp := UPPER( ALLTRIM( aArtTmp[ iii ] ))
					nTmp := LEN(cTmp)
	
					cFilter += " ( "
					cFilter += "LEFT(ALLTRIM(UPPER(art_desc)), " + ALLTRIM(STR(nTmp))+ ")"
					cFilter += " = "
					cFilter += cm2str( cTmp )
			
				elseif iii > 1
				
					cTmp := UPPER( ALLTRIM( aArtTmp[ iii ] ))
					cFilter += " .and. " + cm2str("_" + cTmp)
					cFilter += " $ "
					cFilter += "ALLTRIM(UPPER(art_desc))"
				
				endif

				if iii == LEN( aArtTmp )
					cFilter += " ) "
				endif
			next
		
		else

		endif
		
	else

		// cisi unos, gleda se samo LEFT( nnn )
		
		cTmp := ALLTRIM( aTmp[ i ] )
		nTmp := LEN(cTmp)
	
		cFilter += "LEFT(ALLTRIM(UPPER(art_desc)), " + ALLTRIM(STR(nTmp))+ ")"
		cFilter += " = "
		cFilter += cm2str(UPPER(cTmp))
		
	endif
	
next

if cFilter == ".t."
	nRet := 0
else
	nRet := 1
endif

return nRet


// ---------------------------------------------
// box za uslov....
// ---------------------------------------------
static function _box_qfind()
local nBoxX := 6
local nBoxY := 70
local nX := 1
private GetList:={}


Box(, nBoxX, nBoxY)

	@ m_x + nX, m_y + 2 SAY "===>>> Brza pretraga artikala ===>>>"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "uslov:" GET __qf_cond VALID _vl_cond( __qf_cond ) PICT "@S60!" 
	
	read
BoxC()

ESC_RETURN 0

return 1


// ----------------------------------------------
// validacija uslova na boxu
// ----------------------------------------------
static function _vl_cond( cCond )
local lRet := .t.

if EMPTY(cCond)
	lRet := .f.
endif

if lRet == .f. .and. EMPTY(cCond)
	MsgBeep("Uslov mora biti unesen !!!")
endif

return lRet







// ---------------------------------------------
// ispravka opisa artikla
// ---------------------------------------------
static function art_ed_desc( nArt_id )
local cArt_desc := PADR(field->art_desc, 100)
local cArt_mcode := PADR(field->match_code, 10)
local cArt_full_desc := PADR(field->art_full_desc, 250)
local cArt_lab_desc := PADR(field->art_lab_desc, 200)
local cDBFilter := DBFILTER()
local nTRec := RECNO()
local nRet := 0

if _box_art_desc( @cArt_desc, @cArt_full_desc, @cArt_lab_desc, ;
		@cArt_mcode ) == 1
	
	set filter to
	set order to tag "1"
	go top
	
	seek artid_str( nArt_id )
	
	Scatter()
	
	_art_desc := cArt_desc
	_art_full_desc := cArt_full_desc
	_art_lab_desc := cArt_lab_desc
	_match_code := cArt_mcode
	
	Gather()

	set order to tag "1"
	set filter to &cDBFilter
	go (nTRec)
	
	nRet := 1
endif

return nRet


// ----------------------------------------
// prikazi info artikla u box preview
// ----------------------------------------
static function box_preview(nX, nY, nLen)
local aDesc := {}
local i

aDesc := TokToNiz( articles->art_full_desc, ";" )

@ nX, nY SAY PADR("ID: " + artid_str(articles->art_id) + SPACE(3) + "MATCH CODE: " + articles->match_code, nLen) COLOR "GR+/G" 

for i:=1 to 6
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
function g_art_desc(nArt_id, lEmpty, lFullDesc )
local cArtDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cArtDesc := ""
endif

if lFullDesc == nil
	lFullDesc := .t.
endif

O_ARTICLES
select articles
set order to tag "1"
go top
seek artid_str(nArt_id)

if FOUND()
	if lFullDesc == .t.
		if !EMPTY(field->art_full_desc)
			cArtDesc := ALLTRIM(field->art_full_desc)
		endif
	else
		if !EMPTY(field->art_desc)
			cArtDesc := ALLTRIM(field->art_desc)
		endif
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
		
		MsgBeep("Uoceno je da se artikal koristi u nalogu br: " + ALLTRIM(STR(doc_it->doc_no))+ " #!!! BRISANJE ONEMOGUCENO !!!")
		
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



// -------------------------------------------------
// automatska regeneracija opisa artikla
// -------------------------------------------------
function auto_gen_art()
local nBoxX := 4
local nBoxY := 60
local lAuto := .t.
local lNew := .f.
local nCnt := 0
local nRec
private GetList:={}

select articles
set order to tag "1"
go top

Box( , nBoxX, nBoxY )

// prodji sve artikle
do while !EOF()
	
	++ nCnt
	
	nRec := RECNO()
	
	nArt_id := field->art_id
	cArt_desc := PADR( field->art_desc, 20 )
	
	@ m_x + 1, m_y + 2 SAY "****** Artikal: " + artid_str(nArt_id)
	@ m_x + 3, m_y + 2 SAY "-----------------"
	
	@ m_x + 2, m_y + 2 SAY SPACE(nBoxY)
	@ m_x + 2, m_y + 2 SAY "opis <--- " + PADR( field->art_desc, 40 ) + "..."
	
	_art_set_descr( nArt_id, lNew, lAuto )
	
	select articles
	set order to tag "1"
	go (nRec)
	
	@ m_x + 4, m_y + 2 SAY SPACE(nBoxY)
	@ m_x + 4, m_y + 2 SAY "opis ---> " + PADR( field->art_desc, 40 ) + "..."

	skip

enddo

BoxC()

return nCnt




// -----------------------------------------
// filuje matricu aAttr
//
// vars:
// aArr - matrica, proslijedjuje se po ref.
// nElNo - broj elementa artikla
// cGrValCode - kod vrijednosti grupe
// cGrVal - vrijednost grupe (puni opis)
// cAttJoker - joker atributa 
// cAttValCode - kod vrijednosti atributa
// cAttVal - vrijednost atributa (puni opis)
// -----------------------------------------
static function _f_a_attr( aArr, nElNo, cGrValCode, cGrVal, ;
			cAttJoker, cAttValCode, cAttVal )

AADD( aArr, { nElNo, cGrValCode, cGrVal, cAttJoker, cAttValCode, cAttVal })

return


// ----------------------------------------------
// setovanje opisa artikla na osnovu tabela
//   ELEMENTS, E_AOPS, E_ATT
//
//  nArt_id - artikal id
//  lNew - novi artikal
//  lAuto - auto generacija naziva
// ----------------------------------------------
function _art_set_descr( nArt_id, lNew, lAuto, aAttr, lOnlyArr )
// artikal kod
local cArt_code := ""
// artikal puni naziv
local cArt_desc := ""
// artikal match kod
local cArt_mcode := ""
// element id
local nEl_id
// grupa id iz elementa
local nEl_gr_id
// grupa kod
local cGr_code
// grupa puni naziv
local cGr_desc
// atribut grupe ID
local nE_gr_att 
// vrijednost atributa ID
local nE_gr_val
// vrijednost atributa opis
local cAttValCode
// vrijednost atributa grupe opis
local cAttVal
// joker atributa, operacije
local cAttJoker
local cAopJoker
local cAop
local cAopCode
local cAopAtt
local cAopAttCode

// ostale pomocne varijable
local nRet := 0
local nCount := 0
local nElCount := 0

if lOnlyArr == nil
	lOnlyArr := .f.
endif

// matrica sa atributima
if aAttr == nil
	aAttr := {}
endif

// setovanje statickih varijabli

// article code separator
__art_sep := "_"
// puni naziv separator
__mc_sep := ";"
// add ops separator
__aop_sep := "-"

if lAuto == nil
	lAuto := .f.
endif

// ukini filtere
select elements
set filter to
select e_att
set filter to
select e_aops
set filter to
select aops
set filter to
select aops_att
set filter to

// elementi...
select elements
set order to tag "1"
go top
seek artid_str( nArt_id )

do while !EOF() .and. field->art_id == nArt_id
	
	// brojac elementa, 1, 2, 3
	++ nElCount
	
	// ID element
	nEl_id := field->el_id
	// ID grupa na osnovu elementa
	nEl_gr_id := field->e_gr_id
	
	// grupa kod
	cGr_code := ALLTRIM( g_e_gr_desc(nEl_gr_id, nil, .f.) )	
	// grupa puni opis
	cGr_desc := ALLTRIM( g_e_gr_desc( nEl_gr_id ) )	
	
	// .... predji na atribute elemenata .....
	select e_att
	set order to tag "1"
	go top
	seek elid_str( nEl_id )

	do while !EOF() .and. field->el_id == nEl_id

		
		// vrijednost atributa
		nE_gr_val := field->e_gr_vl_id
		cAttValCode := ALLTRIM(g_e_gr_vl_desc( nE_gr_val, nil, .f. ))
		cAttVal := ALLTRIM(g_e_gr_vl_desc( nE_gr_val ))
		
		// koji je ovo atribut ?????
		nE_gr_att := g_gr_att_val( nE_gr_val)

		// daj njegov opis 
		cAtt_desc := ALLTRIM(g_gr_at_desc( nE_gr_att ))
		
		// joker ovog atributa je ???
		cAttJoker := g_gr_att_joker( nE_gr_att )
		
	
		_f_a_attr( @aAttr, nElCount, cGr_code, cGr_desc, ;
			cAttJoker, cAttValCode, cAttVal )
	
		skip
		
	enddo

	altd()

	// predji na dodatne operacije elemenata....
	select e_aops
	set order to tag "1"
	go top
	seek elid_str( nEl_id )

	do while !EOF() .and. field->el_id == nEl_id
		
		// dodatna operacija ID ...
		nAop_id := field->aop_id
		
		cAopCode := ALLTRIM(g_aop_desc( nAop_id, nil, .f. ))
		cAop := ALLTRIM(g_aop_desc( nAop_id ))
		
		// koji je djoker ????
		cAopJoker := ALLTRIM( g_aop_joker( nAop_id ) )
		
		// atribut...
		nAop_att_id := field->aop_att_id
		cAopAttCode := ALLTRIM( g_aop_att_desc( nAop_att_id, nil, .f. ) )
		if EMPTY( cAopAttCode )
			cAopAttCode := cAopCode
		endif

		cAopAtt := ALLTRIM( g_aop_att_desc( nAop_att_id ) )

		if EMPTY( cAopAtt )
			cAopAtt := cAop
		endif

		// ukini jokere koji se koriste za pozicije pecata i slicno 
		rem_jokers(@cAopAtt)

		_f_a_attr( @aAttr, nElCount, cGr_code, cGr_desc, ;
				cAopJoker, cAopAttCode, ;
				cAopAtt )
		
		skip
	enddo

	// vrati se na elemente i idi dalje...
	select elements
	skip
	
	++ nCount

enddo

if lOnlyArr == .f.

	// sada izvuci nazive iz matrice

	_aset_descr( aAttr, @cArt_code, @cArt_desc, @cArt_mcode )

	// apenduj na artikal

	if lAuto == .t.
		// automatski generisi opsi i mc 
		// bez kontrolnog box-a
		nRet := _art_apnd_auto( nArt_id, cArt_code, cArt_desc, cArt_mcode )
	else
		// generisi opis i match_code
		// otvori kontrolni box
		nRet := _art_apnd( nArt_id, cArt_code, cArt_desc, cArt_mcode, lNew )
	endif

endif

return nRet



// ---------------------------------------------------------
// setovanje naziva iz matrice aAttr prema pravilu
// aArr - matrica sa podacima artikla
// cArt_code - sifra artikla
// cArt_desc - opis artikla
// cArt_mcode - match code artikla
// ---------------------------------------------------------
static function _aset_descr( aArr, cArt_code, cArt_desc, cArt_mcode )
local nTotElem := 0
local cElemCode 
local i
local cTmp
local nTmp
local lInsLExtChar := .f.
local cLExtraChar := ""

if LEN(aArr) > 0
	nTotElem := aArr[ LEN(aArr), 1 ]
endif

for i := 1 to nTotElem

	// iscitaj code elementa
	nTmp := ASCAN( aArr, {| xVar | xVar[1] == i })
	cElemCode := aArr[ nTmp, 2 ]

	// uzmi pravilo <GL_TICK>#<GL_TYPE>.....
	cRule := _get_rule( cElemCode )
	// pa ga u matricu ......
	aRule := TokToNiz( cRule, "#" )
	
	for nRule := 1 to LEN( aRule )
	
		// <GL_TICK>
		cRuleDef := ALLTRIM( aRule[ nRule ] )

		if LEFT( cRuleDef, 1 ) <> "<"
		
			cLExtraChar := LEFT( cRuleDef, 1 )
			cRuleDef := STRTRAN( cRuleDef, cLExtraChar, "" )
			
			lInsLExtChar := .t.
			
		endif

		nSeek := ASCAN(aArr, {| xVal | ;
			xVal[1] == i .and. xVal[4] == cRuleDef })
		
		if nSeek > 0
		
			if lInsLExtChar == .t.
				cArt_code += cLExtraChar
				lInsLExtChar := .f.
			endif
	
			cArt_code += ALLTRIM( aArr[ nSeek, 5 ] )

			// dodaj space..... na opis puni
			if !EMPTY(cArt_desc)
				cArt_desc += " "
			endif
				
			cArt_desc += ALLTRIM( aArr[ nSeek, 6 ] )
			
			cArt_mcode += ALLTRIM( ;
				PADR( UPPER(ALLTRIM(aArr[nSeek, 6])), 2) )
				
		endif
	
	next
	
	if i <> nTotElem
		cArt_code += "_"
		cArt_desc += ";"
	endif

next

return


// -------------------------------------------------
// vraca pravilo za pojedinu grupu....
// -------------------------------------------------
static function _get_rule( cCode )
local cRule := ""

// uzmi pravilo iz tabele pravila za "kod" elementa
cRule := r_elem_code( cCode )

if EMPTY(cRule)
	msgbeep("Pravilo za formiranje naziva elementa ne postoji !!!")
endif

return cRule




// -----------------------------------------------------
// provjeri da li vec postoji artikal sa istim cDesc
// -----------------------------------------------------
static function _chk_art_exist( nArt_id, cDesc, nId )
local nTArea := SELECT()
local lRet := .f.

select articles
set order to tag "2"
go top
seek cDesc

if FOUND() .and. field->art_id <> nArt_id .and. ALLTRIM(cDesc) == ALLTRIM(field->art_desc)
	nId := field->art_id
	lRet := .t.
endif

set order to tag "1"

select (nTArea)

return lRet


// --------------------------------------------------
// apend match_code, desc for article w contr.box
// 
// nArt_id - id artikla
// cArt_desc - artikal opis
// cArt_mcode - artikal match_code
// lNew - .t. - novi artikal, .f. postojeci
// --------------------------------------------------
static function _art_apnd( nArt_id, cArt_Desc, cArt_full_desc, cArt_mcode, lNew )
local lAppend := .f.
local lExist := .f.
local nExist_id := 0
local cArt_lab_desc := ""

// provjeri da li vec postoji ovakav artikal
lExist := _chk_art_exist( nArt_id, cArt_desc, @nExist_id )

if lExist == .t.
	msgBeep("UPOZORENJE: vec postoji artikal sa istim opisom !!!#Artikal: " + ALLTRIM(STR( nExist_id )))
endif

// update art_desc..
select articles
set order to tag "1"
go top
seek artid_str( nArt_id )

if FOUND()

	if !lNew
		// ako su iste vrijednosti, preskoci...
		if ALLTRIM(cArt_desc) == ALLTRIM(articles->art_desc) ;
			.and. ALLTRIM(cArt_full_desc) == ALLTRIM(articles->art_full_desc)
			lAppend := .f.
		else
			lAppend := .t.
		endif
	else
		lAppend := .t.
	endif

	if !EMPTY(cArt_desc) .and. lAppend == .t. ;
		.and. (!lNew .or. (lNew .and. Pitanje(,"Novi artikal, snimiti promjene ?", "D") == "D"))

		cArt_desc := PADR(cArt_desc, 100)
		cArt_full_desc := PADR(cArt_full_desc, 250)
		cArt_lab_desc := PADR(cArt_lab_desc, 200)
		cArt_mcode := PADR(cArt_mcode, 10)
		
		// daj box za pregled korekciju
		if _box_art_desc( @cArt_desc, @cArt_full_desc, ;
			@cArt_lab_desc, @cArt_mcode ) == 1
			
			Scatter()
			
			_art_desc := cArt_desc
			_match_code := cArt_mcode
			_art_full_desc := cArt_full_desc
			
			Gather()
		
			return 1
		
		endif
		
	endif
		
	if lNew	== .t.
		
		// izbrisi tu stavku....
		art_delete( nArt_id, .t. , .t. )
		
	endif
	
endif

return 0



// --------------------------------------------------
// apend match_code, desc for article wo cont.box
// 
// nArt_id - id artikla
// cArt_desc - artikal opis
// cArt_mcode - artikal match_code
// --------------------------------------------------
static function _art_apnd_auto( nArt_id, cArt_Desc, cArt_full_desc, cArt_mcode )
local lChange := .f.

// ako je vrijednost prazna - 0
if EMPTY( cArt_desc )
	return 0
endif

// update art_desc..
select articles
set order to tag "1"
go top
seek artid_str( nArt_id )

if FOUND()

	// ako su iste vrijednosti, preskoci...
	if ALLTRIM(cArt_desc) == ALLTRIM(articles->art_desc) .and. ;
		ALLTRIM(cArt_full_desc) == ALLTRIM(articles->art_full_desc)
		
		lChange := .f.
		
	else
		lChange := .t.
	endif

endif

if lChange == .t.

	// zamjeni vrijednost....
	
	cArt_desc := PADR(cArt_desc, 100)
	cArt_full_desc := PADR(cArt_full_desc, 100)
	cArt_mcode := PADR(cArt_mcode, 10)
		
	Scatter()
			
	_art_desc := cArt_desc
	_match_code := cArt_mcode
	_art_full_desc := cArt_full_desc
			
	Gather()
		
	return 1
		
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
static function _box_art_desc( cArt_desc, cArt_full_desc, ;
		cArt_lab_desc, cArt_mcode )
private GetList:={}

Box(, 6, 70)
	
	@ m_x + 1, m_y + 2 SAY "*** pregled/korekcija podataka artikla"
	
	@ m_x + 3, m_y + 2 SAY "Puni naziv:" GET cArt_full_desc PICT "@S57" VALID !EMPTY(cArt_full_desc)
	@ m_x + 4, m_y + 2 SAY "Skr. naziv:" GET cArt_desc PICT "@S57" VALID !EMPTY(cArt_desc)
	@ m_x + 5, m_y + 2 SAY "Lab. tekst:" GET cArt_lab_desc PICT "@S57" 
	
	@ m_x + 6, m_y + 2 SAY "Match code:" GET cArt_mcode
	
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
seek artid_str( nArt_id )

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

if nTmp > LEN(aElem) .or. nTmp == 0
	nElem_no := 0
else
	nElem_no := aElem[ nTmp, 3 ]
endif

return









