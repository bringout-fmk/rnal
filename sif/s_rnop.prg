#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------------------------
// prelged sifrarnika operacija
// ------------------------------------------------
function p_rnop(cTabela, cId, dx, dy)
*{
local nArea
local cHeader

cHeader := "Lista: operacije "
cHeader += cTabela

Private Kol
Private ImeKol

nArea := F_S_RNOP

SELECT (F_SIFK)
if !used()
	O_SIFK
endif

SELECT (F_SIFV)
if !used()
	O_SIFV
endif

SELECT (nArea)

if !used()
	if (cTabela == "S_RNOP")
		O_S_RNOP
	endif
endif	

set_a_kol( @Kol, @ImeKol)
return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
       @cId, dx, dy, ;
	{|Ch| k_handler(Ch)} )
	

// ---------------------------------------------------
// kolone tabele
// ---------------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"ID", {|| id}, "id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Opis", {|| opis}, "opis", {|| .t.}, {|| .t.} })
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


