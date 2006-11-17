#include "\dev\fmk\rnal\rnal.ch"

// variables
static _el_gr
static sif_pict


// --------------------------------------------
// kreira pomocnu tabelu u privpath-u...
// --------------------------------------------
static function _cre_art_tmp()
local aArtDbf := {}
local cArtTbl := "_ART_TMP"

select 230
if USED()
	close _art_tmp
endif

AADD(aArtDbf, {"art_id", "N", 10, 0})
AADD(aArtDbf, {"art_marker", "C", 1, 0})

// brisi dbf i cdx
if FILE(PRIVPATH + cArtTbl + ".DBF")
	FERASE(PRIVPATH + cArtTbl + ".DBF")
	FERASE(PRIVPATH + cArtTbl + ".CDX")
endif

// kreiraj tabelu
if !FILE(PRIVPATH + cArtTbl + ".DBF")
	DBcreate2(PRIVPATH + cArtTbl + ".DBF", aArtDbf)
endif

select 230
if !USED() 
	use (PRIVPATH + cArtTbl)
endif
index on STR(art_id, 10) tag "1"
set order to tag "1"

return



// -------------------------------------------
// funkcija za odabir artikala...
// -------------------------------------------
function pick_articles()
local aAtt := {}
local nRet := 0

if art_src_box(@aAtt) == 0
	return DE_CONT
endif

// setuj i postavi filter....
nRet := _srch_art( aAtt )

return nRet



// --------------------------------------
// search box article
// --------------------------------------
static function art_src_box(aAtt)
local GetList := {}
local nX := 1
local i
local nAtt_1 := 0
local nAtt_v1_1 := 0
local nAtt_v1_2 := 0
local nAtt_2 := 0
local nAtt_v2_1 := 0
local nAtt_v2_2 := 0
local nAtt_3 := 0
local nAtt_v3_1 := 0
local nAtt_v3_2 := 0
local cFiltDN := "D"

_el_gr := VAL(STR(0, 10))
sif_pict := "9999999999"

Box(, 10, 77, .f.)

	@ m_x + nX, m_y + 2 SAY "grupa" GET _el_gr VALID {|| s_e_groups(@_el_gr), show_it( g_e_gr_desc( _el_gr ) ) }	
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "atr.1" GET nAtt_1 VALID {|| nAtt_1 == 0 .or. s_e_gr_att(@nAtt_1, _el_gr), show_it( g_gr_at_desc( nAtt_1 ) ) } PICT sif_pict
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "val.1.1" GET nAtt_v1_1 VALID {|| nAtt_v1_1 == 0 .or. s_e_gr_val(@nAtt_v1_1, nAtt_1), show_it( g_e_gr_vl_desc( nAtt_v1_1 ) ) }	
	
	@ m_x + nX, m_y + 35 SAY "val.1.2" GET nAtt_v1_2 VALID {|| nAtt_v2_1 == 0 .or. s_e_gr_val(@nAtt_v2_1, nAtt_1), show_it( g_e_gr_vl_desc( nAtt_v2_1 ) ) }	
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "atr.2" GET nAtt_2 VALID {|| nAtt_2 == 0 .or. s_e_gr_att(@nAtt_2, _el_gr), show_it( g_gr_at_desc( nAtt_2 ) ) } PICT sif_pict
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "val.2.1" GET nAtt_v2_1 VALID {|| nAtt_v2_1 == 0 .or. s_e_gr_val(@nAtt_v2_1, nAtt_2), show_it( g_e_gr_vl_desc( nAtt_v2_1 ) ) }	
	
	@ m_x + nX, m_y + 35 SAY "val.2.2" GET nAtt_v2_2 VALID {|| nAtt_v2_2 == 0 .or. s_e_gr_val(@nAtt_v2_2, nAtt_2), show_it( g_e_gr_vl_desc( nAtt_v2_2 ) ) }	

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "atr.3" GET nAtt_3 VALID {|| nAtt_3 == 0 .or. s_e_gr_att(@nAtt_3, _el_gr), show_it( g_gr_at_desc( nAtt_3 ) ) } PICT sif_pict
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "val.3.1" GET nAtt_v3_1 VALID {|| nAtt_v3_1 == 0 .or. s_e_gr_val(@nAtt_v3_1, nAtt_3), show_it( g_e_gr_vl_desc( nAtt_v3_1 ) ) }	
	
	@ m_x + nX, m_y + 35 SAY "val.3.2" GET nAtt_v3_2 VALID {|| nAtt_v3_2 == 0 .or. s_e_gr_val(@nAtt_v3_2, nAtt_3), show_it( g_e_gr_vl_desc( nAtt_v3_2 ) ) }	


	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Postaviti filter prema kriteriju ?" GET cFiltDN VALID cFiltDN $ "DN" PICT "@!"	

	read
	
BoxC()

ESC_RETURN 0

if cFiltDN == "D"
	AADD(aAtt, {"ATT", nAtt_1, nAtt_v1_1, nAtt_v1_2 })
	AADD(aAtt, {"ATT", nAtt_2, nAtt_v2_1, nAtt_v2_2 })
	AADD(aAtt, {"ATT", nAtt_3, nAtt_v3_1, nAtt_v3_2 })
endif

return 1


// ---------------------------------------------
// pretraga artikla po atributima aAttr
//
// aAttr - matrica sa atributima
//
// ---------------------------------------------
static function _srch_art( aAttr )
local cFilter := ".t."
local aArtDbf := {}
local cArtTbl := "_ART_TMP"
local nRet := 1

if LEN(aAttr) == 0
	nRet := 0
	return nRet
endif

select articles
set relation to
set filter to
select elements 
set filter to
select e_att
set filter to
select e_aops
set filter to

// kreiraj pomocnu tabelu _ART_TMP i otvori je
_cre_art_tmp()

// atribut filter ...
_gen_att_filter( aAttr, @cFilter )

select e_att

if cFilter == ".t."
	set filter to
	go top
else
	set filter to &cFilter
	go top
endif

do while !EOF()

	nEl_id := e_att->el_id
	select elements
	set order to tag "1"
	go top
	seek elid_str(nEl_id)

	if FOUND()
		
		nArt_id := elements->art_id
		
		select _art_tmp
		set order to tag "1"
		go top
		seek artid_str(nArt_id)
		
		if !FOUND()
			append blank
			Scatter()
			_art_id := nArt_id
			_art_marker := "*"
			Gather()
		endif
		
	endif
	
	select e_att
	skip
enddo

select articles
go top

set relation to STR(articles->art_id, 10) into _art_tmp
set filter to _art_tmp->(art_marker) == '*'
go top

return nRet

// --------------------------------------------
// generise filter za pretragu...
// --------------------------------------------
static function _gen_att_filter( aAttr, cFilt )
local i
local nAttr := 0
local nVal1 := 0
local nVal2 := 0
local cUsl := "#"

for i:=1 to LEN(aAttr)
	
	nVal1 := aAttr[i, 3]
	nVal2 := aAttr[i, 4]
	
	if nVal1 <> 0
		cUsl += ALLTRIM(STR(nVal1)) + "#"
	endif
	if nVal2 <> 0
		cUsl += ALLTRIM(STR(nVal2)) + "#"
	endif
next

cFilt += " .and. '#' + ALLTRIM(STR(E_ATT->e_gr_vl_id)) + '#' $ " + cm2str(cUsl)

return


