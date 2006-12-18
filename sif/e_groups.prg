#include "\dev\fmk\rnal\rnal.ch"


static _wo_id


// -----------------------------------------
// otvara sifrarnik artikala
// -----------------------------------------
function s_e_groups(cId, lwo_ID, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol
private GetList:={}

nTArea := SELECT()

cHeader := "Elementi - grupe /"
cHeader += SPACE(5)
cHeader += "'A' - pregled atributa grupe"

if lwo_ID == nil
	_wo_id := .f.
endif

select e_groups
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_E_GROUPS, 1, 8, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

if _wo_id == .f.

	AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(e_gr_id)}, "e_gr_id", {|| _inc_id(@we_gr_id, "E_GR_ID"), .f.}, {|| .t.}})

endif

AADD(aImeKol, {PADC("Naziv", 40), {|| PADR(e_gr_desc, 40)}, "e_gr_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
local nTRec := RecNo()
local nE_gr_id := field->e_gr_id

do case

	case UPPER(CHR(Ch)) == "A"
		// pregled atributa
		s_e_gr_att(nil, nE_gr_id)
		go (nTRec)
		return DE_CONT

	case Ch == K_CTRL_N .or. Ch == K_F4
	
		_wo_id := .f.
		set_a_kol(@ImeKol, @Kol)
		return DE_CONT
		
endcase

return DE_CONT


// -------------------------------
// convert e_gr_id to string
// -------------------------------
function e_gr_id_str(nId)
return STR(nId, 10)


// -------------------------------
// get e_gr_desc by e_gr_id
// -------------------------------
function g_e_gr_desc(nE_gr_id, lEmpty)
local cEGrDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cEGrDesc := ""
endif

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

if !EMPTY(cEGrDesc)
	cEGrDesc := PADR(cEGrDesc, 6)
endif

return cEGrDesc



