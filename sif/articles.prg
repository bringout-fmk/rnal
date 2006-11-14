#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik artikala
// -----------------------------------------
function s_articles(cId, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Artikli /"

select customs
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_ARTICLES, 1, 12, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(art_id)}, "art_id", {|| _inc_id(@wart_id, "ART_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 40), {|| PADR(art_desc, 40)}, "art_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
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



