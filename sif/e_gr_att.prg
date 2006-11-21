#include "\dev\fmk\rnal\rnal.ch"


static _tb_direkt := "N"


// -------------------------------------------------------
// otvara sifrarnik atributa grupa
// -------------------------------------------------------
function s_e_gr_att(cId, nGr_id, cE_gr_at_desc, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol
private GetList:={}

nTArea := SELECT()

_tb_direkt := gTBDir
_mod_tb_direkt( _tb_direkt )

cHeader := "Elementi - grupe atributi /  'V' - pr.vrijednosti"

altd()


if nGr_id == nil
	nGr_id := -1
endif

if cE_gr_at_desc == nil
	cE_gr_at_desc := ""
endif

select e_gr_att
set order to tag "1"
go top

set_a_kol(@ImeKol, @Kol)
gr_filter(nGr_id, cE_gr_at_desc)
	
cRet := PostojiSifra(F_E_GR_ATT, 1, 10, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

if VALTYPE(cE_gr_at_desc) == "N"
	cE_gr_at_desc := STR(cE_gr_at_desc, 10)
endif

if nGr_id > 0 .or. cE_gr_at_desc <> ""
	set filter to
endif

select (nTArea)

if LastKey() == K_ESC
	cRet := 0
endif

return cRet



// ---------------------------------------------------
// gr_id filter na e_gr_att sifrarniku
// nE_gr_id - grupa id
// ---------------------------------------------------
static function gr_filter(nE_gr_id, cE_gr_at_desc)
local cFilter := ""

if nE_gr_id > 0
	cFilter += 'e_gr_id == ' + e_gr_id_str(nE_gr_id)
endif

if !EMPTY(cE_gr_at_desc)

	if !EMPTY(cFilter)
		cFilter += ' .and. '
	endif

	cFilter += 'UPPER(e_gr_at_de) = ' + cm2str(UPPER(ALLTRIM(cE_gr_at_desc))) 
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(e_gr_at_id)}, "e_gr_at_id", {|| _inc_id(@we_gr_at_id, "E_GR_AT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Elem.grupa", 20), {|| PADR(g_e_gr_desc(e_gr_id), 20)}, "e_gr_id", {|| .t.}, {|| s_e_groups(@we_gr_id), show_it( g_e_gr_desc( we_gr_id ) ) }})
AADD(aImeKol, {PADC("Opis", 35), {|| PADR(e_gr_at_desc, 35)}, "e_gr_at_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
local nE_gr_at_id := field->e_gr_at_id
local nTRec := RecNo()

do case
	case UPPER(CHR(Ch)) == "V"
		s_e_gr_val(nil, nE_gr_at_id)
		go (nTRec)
		return DE_CONT
endcase

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


// ------------------------------------------------------
// napuni matricu aAtt sa atributima grupa
// ------------------------------------------------------
function a_gr_attibs(aAtt, nE_Gr_id)
local nTArea := SELECT()
select e_gr_att
set filter to "e_gr_id == " + gr_id_str(nE_gr_id)
go top

do while !EOF() .and. field->e_gr_id == nE_gr_id
	AADD(aAtt, { field->e_gr_at_id, ALLTRIM(field->e_gr_at_desc), 0, 0, 0 })
	skip
enddo

set filter to

select (nTArea)
return
