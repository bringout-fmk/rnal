#include "\dev\fmk\rnal\rnal.ch"

static _tb_direkt
static __wo_id


// -----------------------------------------
// otvara sifrarnik dodatnih operacija
// -----------------------------------------
function s_aops(cId, cDesc, lwo_ID, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

nTArea := SELECT()
cHeader := "Dodatne operacije /  'A' - pregled atributa"

if cDesc == nil
	cDesc := ""
endif

if lwo_ID == nil
	lwo_ID := .f.
endif

__wo_id := lwo_ID

select aops
set order to tag "1"

set_a_kol(@ImeKol, @Kol)

if VALTYPE(cId) == "C"
	//try to validate
	if VAL(cId) <> 0
		
		cId := VAL(cId)
		cDesc := ""
		
	endif
endif

set_f_kol(cDesc)

private gTBDir := "N"

cRet := PostojiSifra(F_AOPS, 1, 12, 70, cHeader, @cId, dx, dy, {|Ch| key_handler(Ch) } )

if VALTYPE(cDesc) == "N"
	cDesc := STR(cDesc, 10)
endif

if cDesc <> ""
	set filter to
endif

if LastKey() == K_ESC
	cId := 0
endif

select (nTArea)

return cRet


// ---------------------------------------------------
// setuje filter na sifraniku
// ---------------------------------------------------
static function set_f_kol(cDesc)
local cFilter := ""

if !EMPTY(cDesc)

	cFilter += 'ALLTRIM(UPPER(aop_desc)) = ' + cm2str(UPPER(ALLTRIM(cDesc))) 
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

if __wo_id == .f.

	AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(aop_id)}, "aop_id", {|| _inc_id(@waop_id, "AOP_ID"), .f.}, {|| .t.}})

endif

AADD(aImeKol, {PADC("Opis", 40), {|| PADR(aop_full_desc, 40)}, "aop_full_desc"})
AADD(aImeKol, {PADC("Skr.opis", 20), {|| PADR(aop_desc, 20)}, "aop_desc"})
AADD(aImeKol, {PADC("u art.naz ( /*)", 15), {|| PADR(in_art_desc, 15)}, "in_art_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



// -----------------------------------------------
// dodatna operacija u naziv artikla ???
// -----------------------------------------------
function aop_in_desc( nAop_id )
local lRet := .f.
local nTArea := SELECT()

select aops
set order to tag "1"
go top
seek aopid_str( nAop_id )

if FOUND()
	if field->in_art_desc == "*"
		lRet := .t.
	endif
endif

select (nTArea)
return lRet



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

	case Ch == K_CTRL_N .or. Ch == K_F4
		
		__wo_id := .f.
		set_a_kol(@ImeKol, @Kol)
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
function g_aop_desc( nAop_id, lEmpty, lFullDesc )
local cAopDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cAopDesc := ""
endif

if lFullDesc == nil
	lFullDesc := .t.
endif

O_AOPS
select aops
set order to tag "1"
go top
seek aopid_str(nAop_id)

if FOUND()
	if lFullDesc == .t.
		if !EMPTY(field->aop_full_desc)
			cAopDesc := ALLTRIM(field->aop_full_desc)
		endif
	else
		if !EMPTY(field->aop_desc)
			cAopDesc := ALLTRIM(field->aop_desc)
		endif
	endif
endif

select (nTArea)

return cAopDesc



