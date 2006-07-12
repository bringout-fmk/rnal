#include "\dev\fmk\rnal\rnal.ch"



function get_artikal(cId, cFilter, dx, dy)

if EMPTY(cFilter) .or. cFilter == nil
	g_art(@cId, dx, dy)
else
	g_art_filter(@cId, cFilter, dx, dy)
endif

return


// -----------------------------------------------
// prikazi browse sastavnica/artikala sa filterom
// -----------------------------------------------
function g_art(cId, dx, dy)
local nTArea
private ImeKol
private Kol

nTArea := SELECT()
select roba
set order to tag "id"

// setuj kolone sastavnice tabele
art_a_kol(@ImeKol, @Kol)
	
PostojiSifra(F_ROBA, "ID" , 15, 77, "Lista sastavnica", @cId, dx, dy,,,,,,{"ID"})

select (nTArea)

return


// -----------------------------------------------
// prikazi browse sastavnica/artikala sa filterom
// -----------------------------------------------
function g_art_filter(cId, cFilter, dx, dy)
local cPom := nil
local nTArea
private ImeKol
private Kol

nTArea := SELECT()
select roba
set order to tag "id"

set filter to &cFilter
go top

// setuj kolone sastavnice tabele
art_a_kol(@ImeKol, @Kol)
	
PostojiSifra(F_ROBA, "ID" , 15, 77, "Lista sastavnica", @cPom, dx, dy,,,,,,{"ID"})

cId := cPom

// ukini filter
set filter to

select (nTArea)

return


// ---------------------------------
// setovanje kolona tabele
// ---------------------------------
static function art_a_kol(aImeKol, aKol)

aImeKol := {}
aKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)}})

add_mcode(@aImeKol)

AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(naz,20)}, "naz"})
AADD(aImeKol, {PADC("JMJ", 3), {|| jmj}, "jmj"})

// DEBLJINA i TIP
if roba->(fieldpos("DEBLJINA")) <> 0
	AADD(aImeKol, {PADC("Debljina", 10), {|| transform(debljina, "999999.99")}, "debljina", nil, nil, "999999.99" })
	AADD(aImeKol, {PADC("Roba tip", 10), {|| roba_tip}, "roba_tip", {|| .t.}, {|| .t. } })
endif

AADD(aImeKol, {"Tarifa", {|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa) }})

AADD(aImeKol, {"Tip", {|| " " + Tip + " "}, "Tip", {|| .t.}, {|| .t. }})

for i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
next

return



