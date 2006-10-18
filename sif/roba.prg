#include "\dev\fmk\rnal\rnal.ch"


// -----------------------------------------
// vraca artikal po filteru
// -----------------------------------------
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
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(naz,20)}, "naz"})
AADD(aImeKol, {PADC("JMJ", 3), {|| jmj}, "jmj"})

// DEBLJINA i TIP
if roba->(fieldpos("DEBLJINA")) <> 0
	AADD(aImeKol, {PADC("Debljina", 10), {|| transform(debljina, "999999.99")}, "debljina", nil, nil, "999999.99" })
	AADD(aImeKol, {PADC("Roba tip", 10), {|| roba_tip}, "roba_tip", {|| .t.}, {|| p_rtip(@wroba_tip) } })
endif

AADD(aImeKol, {"Tarifa", {|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa) }})

AADD(aImeKol, {"Tip", {|| " " + Tip + " "}, "Tip", {|| .t.}, {|| .t. }})
AADD(aImeKol, {"NC", {|| nc}, "nc", {|| .t.}, {|| .t. }})
AADD(aImeKol, {"VPC", {|| vpc}, "vpc", {|| .t.}, {|| .t. }})

if roba->(fieldpos("BARKOD")) <> 0
	AADD(aImeKol, {"BARKOD", {|| barkod}, "barkod", {|| .t.}, {|| .t. }})
endif

for i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
next

return


// ----------------------------------
// prikazi info o robi
// ----------------------------------
function s_roba_naz(cId, nX, nY)
local nArr
local nRazmak := 2
local nRobaLen := 40
local cPom

nArr := SELECT()
select roba
hseek cId

if Found()
	cPom := ALLTRIM( LEFT(roba->naz,40) )
	cPom += "(" + ALLTRIM(roba->jmj) + ")"
	cPom := PADR(cPom, nRobaLEN)
	@ nX, nY SAY cPom
else
	@ nX, nY SAY SPACE(nRobaLen)
endif

select (nArr)

return .t.


