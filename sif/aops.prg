#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik dodatnih operacija
// -----------------------------------------
function s_aops(cId, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Dodatne operacije /"

select aops
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_AOPS, 1, 10, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(aop_id)}, "aop_id", {|| _inc_id(@waop_id, "AOP_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 40), {|| PADR(aop_desc, 40)}, "aop_desc"})

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
// convert aop_id to string
// -------------------------------
function aopid_str(nId)
return STR(nId, 10)


// -------------------------------
// get aop_desc by aop_id
// -------------------------------
function g_aop_desc(nAop_id)
local cAopDesc := "?????"
local nTArea := SELECT()

O_AOPS
select aops
set order to tag "1"
go top
seek aopid_str(nAop_id)

if FOUND()
	if !EMPTY(field->aop_desc)
		cAopDesc := ALLTRIM(field->aop_desc)
	endif
endif

select (nTArea)

return cAopDesc



