#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/

// ------------------------------------------------
// prelged sifrarnika karaketeristika
// ------------------------------------------------
function p_rnka(cId, dx, dy)
*{
local nArea
local cHeader

cHeader := "Lista: karakteristike "

Private Kol
Private ImeKol

O_S_RNKA
nArea := F_S_RNKA

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
AADD(aImeKol, {"Operacija", {|| id_rnop}, "id_rnop", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Rbr", {|| r_br}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Opis", {|| opis}, "opis", {|| .t.}, {|| .t.} })

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


