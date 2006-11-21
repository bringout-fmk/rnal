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

if _fnd_par_get() == 0
	return DE_CONT
endif

// setuj i postavi filter....
nRet := _srch_art()

return nRet



// ---------------------------------------------
// pretraga artikla pomoæu tabele _FND_PAR
//
// ---------------------------------------------
static function _srch_art()
local nRet := 0

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

// gen description filter
nRet += _set_desc_filter( _gen_desc_filter() )

// gen m_code filter...
nRet += _set_mc_filter( _gen_mc_filter() )

// gen atribut filter ...
nRet += _set_att_filter( _gen_att_filter() )

// gen aops filter...
nRet += _set_aop_filter( _gen_aop_filter() )

select articles
go top

if nRet > 0

	set relation to STR(articles->art_id, 10) into _art_tmp
	set filter to _art_tmp->(art_marker) == '*'
	go top

endif

return nRet



// --------------------------------------------
// FILTER.GEN. att_filter
// --------------------------------------------
static function _gen_att_filter()
local cUsl := ""
local nTArea := SELECT()
local cFilt := ""

altd()

select _fnd_par
set order to tag "1"
go top

do while !EOF()

	if ALLTRIM( field->fnd_par_type ) <> "ATT"
		skip
		loop
	endif

	if !EMPTY(field->fnd_val)
		cUsl += ALLTRIM( fnd_val ) + "#"
	endif
	
	skip
enddo

if !EMPTY(cUsl)

	cUsl := "#" + cUsl

	cFilt := "'#' + ALLTRIM(STR(E_ATT->e_gr_vl_id)) + '#' $ " + cm2str( cUsl )

endif

select (nTArea)

return cFilt



// ---------------------------------------------------
// setuje filter za atribute elemenata
// ---------------------------------------------------
static function _set_att_filter( cFilter ) 
local nTArea := SELECT()
local nEl_id := 0
local nArt_id := 0
local nCount := 0

altD()

// ako nema filtera nemoj nista raditi
if cFilter == ""
	return nCount
endif

select e_att
set filter to &cFilter
go top

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
		seek artid_str( nArt_id )
		
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

	++ nCount
	
enddo

select e_att
set filter to

select (nTArea)

return nCount


// --------------------------------------------
// FILTER.GEN. art_description
// --------------------------------------------
static function _gen_desc_filter()
local nTArea := SELECT()
local cFilt := ""

select _fnd_par
set order to tag "1"
go top

do while !EOF()

	if ALLTRIM( field->fnd_par_type ) <> "DESC"
		skip
		loop
	endif

	if !EMPTY(cFilt)
		cFilt += " .or. "
	endif
	
	cFilt += " art_desc = " + cm2str( ALLTRIM(field->fnd_val) )

	skip
enddo

select (nTArea)

return cFilt



// ---------------------------------------------------
// setuje filter za opis artikla
// ---------------------------------------------------
static function _set_desc_filter( cFilter ) 
local nTArea := SELECT()
local nCount := 0

// ako nema filtera nemoj nista raditi
if cFilter == ""
	return nCount
endif

select articles
set filter to &cFilter
go top

do while !EOF()
	
	nArt_id := field->art_id

	select _art_tmp
	set order to tag "1"
	go top
	seek artid_str( nArt_id )
		
	if !FOUND()
		append blank
		Scatter()
		_art_id := nArt_id
		_art_marker := "*"
		Gather()
	endif
	
	select articles
	skip

	++ nCount
enddo

select articles
set filter to

select (nTArea)

return nCount


// --------------------------------------------
// FILTER.GEN. match_code artikla
// --------------------------------------------
static function _gen_mc_filter()
local nTArea := SELECT()
local cFilt := ""

select _fnd_par
set order to tag "1"
go top

do while !EOF()

	if ALLTRIM( field->fnd_par_type ) <> "MC"
		skip
		loop
	endif

	if !EMPTY(cFilt)
		cFilt += " .or. "
	endif
	
	cFilt += " match_code = " + cm2str( ALLTRIM(field->fnd_val) )

	skip
enddo

select (nTArea)

return cFilt



// ---------------------------------------------------
// setuje filter za match_code artikla
// ---------------------------------------------------
static function _set_mc_filter( cFilter ) 
local nTArea := SELECT()
local nCount := 0

// ako nema filtera nemoj nista raditi
if cFilter == ""
	return nCount
endif

select articles
set filter to &cFilter
go top

do while !EOF()
	
	nArt_id := field->art_id

	select _art_tmp
	set order to tag "1"
	go top
	seek artid_str( nArt_id )
		
	if !FOUND()
		append blank
		Scatter()
		_art_id := nArt_id
		_art_marker := "*"
		Gather()
	endif
	
	select articles
	skip

	++ nCount
	
enddo

select articles
set filter to

select (nTArea)

return nCount



// --------------------------------------------
// FILTER.GEN. dodatne operacije
// --------------------------------------------
static function _gen_aop_filter()
local cUsl := ""
local cUsl2 := ""
local nTArea := SELECT()
local cFilt := ""

select _fnd_par
set order to tag "1"
go top

do while !EOF()

	if ALLTRIM( field->fnd_par_type ) <> "AOP"
		skip
		loop
	endif

	if !EMPTY(field->fnd_val)
		
		cUsl += ALLTRIM( fnd_val ) + "#"
	
	endif
	
	skip
enddo

if !EMPTY(cUsl)

	cUsl := "#" + cUsl
	
	cFilt := "'#' + ALLTRIM(STR(E_AOPS->aop_id)) + '#' $ " + cm2str( cUsl )

endif

select (nTArea)

return cFilt



// ---------------------------------------------------
// setuje filter za dodatne operacije elemenata
// ---------------------------------------------------
static function _set_aop_filter( cFilter ) 
local nTArea := SELECT()
local nEl_id := 0
local nArt_id := 0
local nCount := 0

// ako nema filtera nemoj nista raditi
if cFilter == ""
	return nCount
endif

select e_aops
set filter to &cFilter
go top

do while !EOF()

	nEl_id := e_aops->el_id
	
	select elements
	set order to tag "1"
	go top
	seek elid_str(nEl_id)

	if FOUND()
		
		nArt_id := elements->art_id
		
		select _art_tmp
		set order to tag "1"
		go top
		seek artid_str( nArt_id )
		
		if !FOUND()
			append blank
			Scatter()
			_art_id := nArt_id
			_art_marker := "*"
			Gather()
		endif
	endif
	
	select e_aops
	skip

	++ nCount
	
enddo

select e_aops
set filter to

select (nTArea)

return nCount


