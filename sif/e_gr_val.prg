#include "\dev\fmk\rnal\rnal.ch"



// -----------------------------------------
// otvara sifrarnik artikala
// -----------------------------------------
function s_e_gr_val(cId, nE_gr_at_id, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol
private GetList:={}

nTArea := SELECT()

cHeader := "Elementi - atributi, vrijednosti atributa /"

if nE_gr_at_id == nil
	nE_gr_at_id := -1
endif

select e_gr_val
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
gr_att_filter(nE_gr_at_id)
	
cRet := PostojiSifra(F_E_GR_VAL, 1, 16, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| PADR(sif_idmc(e_gr_vl_id),10)}, "e_gr_vl_id", {|| _inc_id(@we_gr_vl_id, "E_GR_VL_ID"), .f.}, {|| .t.}})

AADD(aImeKol, {PADC("Grupa/atribut", 15), {|| "(" + ALLTRIM(g_egr_by_att(e_gr_at_id)) + ") / " + PADR(g_gr_at_desc(e_gr_at_id), 15)}, "e_gr_at_id", {|| .t.}, {|| s_e_gr_att( @we_gr_at_id ), show_it( g_gr_at_desc( we_gr_at_id ) ) }})

AADD(aImeKol, {PADC("Vrijednost", 20), {|| PADR(e_gr_vl_desc, 20) + ".." }, "e_gr_vl_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



// --------------------------------------------------
// filter po polju e_gr_at_id
// --------------------------------------------------
static function gr_att_filter(nE_gr_at_id)
local cFilter

if nE_gr_at_id > 0
	cFilter := "e_gr_at_id == " + e_gr_at_str(nE_gr_at_id)
	set filter to &cFilter
else
	set filter to
endif

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
return DE_CONT


// -------------------------------
// convert e_gr_val_id to string
// -------------------------------
function e_gr_vl_str(nId)
return STR(nId, 10)


// -------------------------------
// get e_gr_desc by e_gr_id
// -------------------------------
function g_e_gr_vl_desc(nE_gr_vl_id)
local cEGrValDesc := "?????"
local nTArea := SELECT()

O_E_GR_VAL
select e_gr_val
set order to tag "1"
go top
seek e_gr_vl_str(nE_gr_vl_id)

if FOUND()
	if !EMPTY(field->e_gr_vl_desc)
		cEGrValDesc := ALLTRIM(field->e_gr_vl_desc)
	endif
endif

select (nTArea)

return cEGrValDesc


// --------------------------------------------------
// vraæa grupu elementa po vrijednosti atributa
// --------------------------------------------------
function g_egr_by_att(nE_gr_att)
local cGr := "????"
local nTArea := SELECT()
local nTRec := RecNo()

select e_gr_att
set order to tag "1"
go top
seek e_gr_at_str(nE_gr_att)

if FOUND()
	cGr := ALLTRIM( g_e_gr_desc(field->e_gr_id) )
endif

select (nTArea)
go (nTRec)

return cGr



// -------------------------------------------------
// vraca atribut grupe elementa iz tabele e_gr_val 
// -------------------------------------------------
function g_gr_att_val( nE_gr_val )
local nE_gr_att := 0
local nTArea := SELECT()

select e_gr_val
set order to tag "1"
go top
seek e_gr_vl_str(nE_gr_val)

if FOUND()
	nE_gr_att := field->e_gr_at_id
endif

select (nTArea)
return nE_gr_att




