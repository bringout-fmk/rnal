#include "\dev\fmk\rnal\rnal.ch"

static _tb_direkt


// -----------------------------------------
// otvara sifrarnik dodatnih operacija
// -----------------------------------------
function s_aops(cId, cDesc, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

_tb_direkt := gTBDir
_mod_tb_direkt( _tb_direkt )

nTArea := SELECT()
cHeader := "Dodatne operacije /  'A' - pregled atributa"

if cDesc == nil
	cDesc := ""
endif

select aops
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
set_f_kol(cDesc)

	
cRet := PostojiSifra(F_AOPS, 1, 12, 70, cHeader, @cId, dx, dy, {|Ch| key_handler(Ch) } )

if VALTYPE(cDesc) == "N"
	cDesc := STR(cDesc, 10)
endif

if cDesc <> ""
	set filter to
endif

select (nTArea)

return cRet


// ---------------------------------------------------
// setuje filter na sifraniku
// ---------------------------------------------------
static function set_f_kol(cDesc)
local cFilter := ""

if !EMPTY(cDesc)

	cFilter += 'UPPER(aop_desc) = ' + cm2str(UPPER(ALLTRIM(cDesc))) 
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

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(aop_id)}, "aop_id", {|| _inc_id(@waop_id, "AOP_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Opis", 40), {|| PADR(aop_desc, 40)}, "aop_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
local nAop_id := aops->aop_id
local nTRec := RecNo()

do case
	case UPPER(CHR(Ch)) == "A"
		// pregled atributa
		s_aops_att(nil, nAop_id)
		go (nTRec)
		
		return DE_CONT
endcase
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



