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
add_mcode(@aImeKol)
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



