#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik artikala
// -----------------------------------------
function s_e_groups(cId, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Elementi - grupe /"

select e_groups
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_E_GROUPS, 1, 10, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(e_gr_id)}, "e_gr_id", {|| _inc_id(@we_gr_id, "E_GR_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 40), {|| PADR(e_gr_desc, 40)}, "e_gr_desc"})

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
// convert e_gr_id to string
// -------------------------------
function e_gr_id_str(nId)
return STR(nId, 10)


// -------------------------------
// get e_gr_desc by e_gr_id
// -------------------------------
function g_e_gr_desc(nE_gr_id)
local cEGrDesc := "?????"
local nTArea := SELECT()

O_E_GROUPS
select e_groups
set order to tag "1"
go top
seek e_gr_id_str(nE_gr_id)

if FOUND()
	if !EMPTY(field->e_gr_desc)
		cEGrDesc := ALLTRIM(field->e_gr_desc)
	endif
endif

select (nTArea)

return cEGrDesc


