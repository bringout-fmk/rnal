#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------------------------
// prelged sifrarnika operacija
// ------------------------------------------------
function p_rnop(cId, dx, dy)
local nTArea
local cHeader

cHeader := "Lista: operacije "
nTArea := SELECT()

private Kol
private ImeKol

O_S_RNOP

set_a_kol( @Kol, @ImeKol)

select (nTArea)

return PostojiSifra( F_S_RNOP, 1, 10, 75, cHeader, ;
       @cId, dx, dy, ;
	{|Ch| k_handler(Ch)} )
	

// ---------------------------------------------------
// kolone tabele
// ---------------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"ID", {|| id}, "id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Relacija", {|| PADR(relacija,20)}, "relacija", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Opis", {|| PADR(opis,20)}, "opis", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Tip stakla", {|| tip_stakla}, "tip_stakla", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// ------------------------------------
// keyboard handler
// ------------------------------------
static function k_handler(Ch)
return DE_CONT

// ------------------------------------------
// prikazi operaciju
// lBrowse - iz browsa
// ------------------------------------------
function s_operacija(cIdOper, lBrowse)
local cRet
local nTArea

if (lBrowse == nil)
	lBrowse := .f.
endif

nTArea := SELECT()

select s_rnop
set order to tag "id"
go top
seek cIdOper

if Found()
	cRet := ALLTRIM(field->naziv)
	if (lBrowse .and. LEN(cRet) > 8)
		cRet := PADR(cRet, 8) + ".."
	endif
else
	cRet := cIdOper
endif

select (nTArea)

return cRet



// -----------------------------------
// vraca id operacije, kroz box unos
// -----------------------------------
function get_oper(cOper)
Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Unesi dodatnu operaciju:" GET cOper VALID !EMPTY(cOper) .and. p_rnop(@cOper)
	read
BoxC()

ESC_RETURN 0

return 1

