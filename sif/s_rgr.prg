#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------------
// prelged sifrarnika grupa
// ------------------------------------------------
function p_rgrupe(cId, cFunc, dx, dy)
local nTArea
local nArea
local cHeader

if cFunc == nil
	cFunc := ""
endif

cHeader := "Lista: grupe artikala "
nTArea := SELECT()

Private Kol
Private ImeKol

O_S_GRUPE
nArea := F_S_GRUPE

select (nTArea)

if !EMPTY(cFunc)
	set_f_tbl(cFunc)
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

AADD(aImeKol, {"ID"   , {|| id}   , "id"   , {|| .t.}, {|| .t.} })
add_mcode(@aImeKol)
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Funkcija", {|| g_func_opis(funkcija)}, "funkcija", {|| .t.}, {|| v_funkcija(@wfunkcija)},, "99" })
AADD(aImeKol, {"K1", {|| k1}, "k1", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"K2", {|| k2}, "k2", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// ---------------------------------------
// postavi filter po funkciji
// ---------------------------------------
static function set_f_tbl(cFunc)
local cFilter

cFilter := "funkcija == " + cFunc

select s_grupe
set filter to &cFilter

return

// ------------------------------------
// keyboard handler
// ------------------------------------
static function k_handler(Ch)
return DE_CONT

// ------------------------------------
// odabir funkcije stakla
// ------------------------------------
static function v_funkcija(nFunc)
private opc:={}
private opcexe:={}
private izbor:=1

if nFunc == 0

	AADD(opc, "1 - Toplotno zastitno               ")
 	AADD(opcexe, {|| nFunc := 1, Izbor := 0 })
 
 	AADD(opc, "2 - Suncano zastitno ")
 	AADD(opcexe, {|| nFunc := 2, Izbor := 0 })
 
 	AADD(opc, "3 - Multifunkcionalna  ")
 	AADD(opcexe, {|| nFunc := 3, Izbor := 0 })
 	
	AADD(opc, "4 - Zvucno zastitno  ")
 	AADD(opcexe, {|| nFunc := 4, Izbor := 0 })
 	
	AADD(opc, "5 - Sigurnosna  ")
 	AADD(opcexe, {|| nFunc := 5, Izbor := 0 })
 
 	AADD(opc, "6 - Dekorativna  ")
 	AADD(opcexe, {|| nFunc := 6, Izbor := 0 })
 
 	AADD(opc, "99 - nista od ponudjenog  ")
 	AADD(opcexe, {|| nFunc := 99, Izbor := 0 })
 
 	Menu_SC("func")
endif

return .t.



// -------------------------------------
// vrati funkciju
// -------------------------------------
function get_funkcija(cFunc)
local nFunc := 0

v_funkcija(@nFunc)

cFunc := STR(nFunc, 2, 0)

return .t.



// -------------------------------
// vraca opis funkcije
// -------------------------------
static function g_func_opis(nFunc)
local xRet

do case
	case nFunc == 1
		xRet := "Toplotno zastitno"
	case nFunc == 2
		xRet := "Suncano zastitno"
	case nFunc == 3
		xRet := "Multifunkcinalno"
	case nFunc == 4
		xRet := "Zvucno zastitno"
	case nFunc == 5
		xRet := "Sigurnosno"
	case nFunc == 6
		xRet := "Dekoratino"
	otherwise
		xRet := "----"
endcase

xRet := PADR(xRet, 18)

return xRet



