#include "\dev\fmk\rnal\rnal.ch"


static _tb_direkt


// ------------------------------------------------
// otvara sifrarnik dodatnih operacija, atributa
// ------------------------------------------------
function s_aops_att(cId, nAop_id, cAop_desc, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

_tb_direkt := gTBDir
_mod_tb_direkt( _tb_direkt )

if nAop_id == nil
	nAop_id := -1
endif

if cAop_desc == nil
	cAop_desc := ""
endif

nTArea := SELECT()
cHeader := "Dodatne operacije, atributi /"

select aops_att
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
aop_filter(nAop_id, cAop_desc)
	
cRet := PostojiSifra(F_AOPS_ATT, 1, 10, 70, cHeader, @cId, dx, dy, {|Ch| key_handler(Ch) })

if VALTYPE(cAop_desc) == "N"
	cAop_desc := STR(cAop_desc, 10)
endif

if nAop_id > 0 .or. cAop_desc <> ""
	set filter to
endif

select (nTArea)

return cRet


// ---------------------------------------------------
// setuje filter na sifraniku
// ---------------------------------------------------
static function aop_filter( nAop_id, cAop_desc )
local cFilter := ""

if nAop_id > 0
	cFilter += 'aop_id == ' + aopid_str(nAop_id)
endif

if !EMPTY(cAop_desc)

	if !EMPTY(cFilter)
		cFilter += ' .and. '
	endif

	cFilter += 'UPPER(aop_att_desc) = ' + cm2str(UPPER(ALLTRIM(cAop_desc))) 
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

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(aop_att_id)}, "aop_att_id", {|| _inc_id(@waop_att_id, "AOP_ATT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADR("Dod.op.ID", 15), {|| PADR(g_aop_desc( aop_id ), 15) }, "aop_id", {|| .t. }, {|| s_aops( @waop_id ), show_it(g_aop_desc(waop_id))  }})
AADD(aImeKol, {PADR("Opis", 40), {|| PADR(aop_att_desc, 40)}, "aop_att_desc"})

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
// convert aop_att_id to string
// -------------------------------
function aop_att_str(nId)
return STR(nId, 10)


// -------------------------------
// get aop_desc by aop_id
// -------------------------------
function g_aop_att_desc(nAop_att_id)
local cAopAttDesc := "?????"
local nTArea := SELECT()

O_AOPS_ATT
select aops_att
set order to tag "1"
go top
seek aop_att_str(nAop_att_id)

if FOUND()
	if !EMPTY(field->aop_att_desc)
		cAopAttDesc := ALLTRIM(field->aop_att_desc)
	endif
endif

select (nTArea)

return cAopAttDesc



