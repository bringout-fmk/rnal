#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik atributa grupa
// -----------------------------------------
function s_e_gr_att(cId, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol
private GetList:={}

nTArea := SELECT()

cHeader := "Elementi - grupe atributi /"

select e_gr_att
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_E_GR_ATT, 1, 10, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(e_gr_at_id)}, "e_gr_at_id", {|| _inc_id(@we_gr_at_id, "E_GR_AT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Elem.grupa", 10), {|| g_e_gr_desc(e_gr_id)}, "e_gr_id", {|| .t.}, {|| s_e_groups(@we_gr_id) }})
AADD(aImeKol, {PADC("Opis", 40), {|| PADR(e_gr_at_desc, 40)}, "e_gr_at_desc"})

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
// convert e_gr_at_id to string
// -------------------------------
function e_gr_at_str(nId)
return STR(nId, 10)


// ----------------------------------
// get e_gr_at_desc by e_gr_att_id
// ----------------------------------
function g_gr_at_desc(nE_gr_att_id)
local cEGrAttDesc := "?????"
local nTArea := SELECT()

O_E_GR_ATT
select e_gr_att
set order to tag "1"
go top
seek e_gr_at_str(nE_gr_att_id)

if FOUND()
	if !EMPTY(field->e_gr_at_desc)
		cEGrAttDesc := ALLTRIM(field->e_gr_at_desc)
	endif
endif

select (nTArea)

return cEGrAttDesc



