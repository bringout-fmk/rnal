#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik elemenata
// -----------------------------------------
function s_elements(cId, dx, dy)
local nTArea
local cHeader
local cFooter
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Elementi /"
cFooter := ""

select elements
set order to tag "1"

set_a_kol(@ImeKol, @Kol)


Box(,16,36)
m_y -= 40

@ m_x + 16, m_y + 2 SAY "<c-N> Novi | <c-T> Brisi | <F2> Ispravi ..."

ObjDbedit("elem", 16, 70, {|Ch| key_handler(Ch)}, cHeader, cFooter ,,,,,1)

BoxC()

select (nTArea)

return


function s_el_attribs(cId, dx, dy)
local nTArea
local cHeader
local cFooter
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Atributi / "
cFooter := ""

select elements
set order to tag "1"

set_a_kol(@ImeKol, @Kol)


Box(,16,36)
m_y += 40

@ m_x + 16, m_y + 2 SAY "<c-N> Novi | <c-T> Brisi | <F2> Ispravi ..."

ObjDbedit("elem_at", 16, 70, {|Ch| key_handler(Ch)}, cHeader, cFooter ,,,,,1)

BoxC()

select (nTArea)

return



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(el_id)}, "el_id", {|| _inc_id(@wel_id, "EL_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Artikal", 10), {|| g_art_desc(art_id) }, "art_id"})
AADD(aImeKol, {PADC("Grupa", 10), {|| e_gr_id }, "e_gr_id"})

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



