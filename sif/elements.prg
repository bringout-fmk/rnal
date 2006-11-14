#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik elemenata
// -----------------------------------------
function s_elements(cId, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Elementi /"

select elements
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_ELEMENTS, 1, 12, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(el_id)}, "el_id", {|| _inc_id(@wel_id, "EL_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Artikal", 10), {|| g_art_desc(art_id) }, "art_id"})
AADD(aImeKol, {PADC("El.grupa", 10), {|| el_gr_id }, "el_gr_id"})

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
// convert el_id to string
// -------------------------------
function elid_str(nId)
return STR(nId, 10)



