#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------------
// prelged sifrarnika grupa
// ------------------------------------------------
function p_rgrupe(cId, dx, dy)
local nTArea
local nArea
local cHeader

cHeader := "Lista: grupe artikala "
nTArea := SELECT()

Private Kol
Private ImeKol

O_S_GRUPE
nArea := F_S_GRUPE

select (nTArea)

set_a_kol( @Kol, @ImeKol)
return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
       @cId, dx, dy, ;
	{|Ch| k_handler(Ch)} )
	

// ---------------------------------------------------
// kolone tabele
// ---------------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"ID"   , {|| id}   , "id"   , {|| .t.}, {|| .t.} })
add_mcode(@aImeKol)
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"K1", {|| k_1}, "k_1", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"K2", {|| k_2}, "k_2", {|| .t.}, {|| .t.} })

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


