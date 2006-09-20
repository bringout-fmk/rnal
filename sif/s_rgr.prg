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

if !EMPTY(cFunc) .and. (cFunc <> "99")
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
set filter to
set filter to &cFilter

return

// ------------------------------------
// keyboard handler
// ------------------------------------
static function k_handler(Ch)

do case
	case Ch == K_CTRL_T
		//
		// do_something()
	
endcase

return DE_CONT

// ------------------------------------
// odabir funkcije stakla
// ------------------------------------
static function v_funkcija(nFunc)
local nSX
local nSY
private opc:={}
private opcexe:={}
private izbor:=1

nSX := m_x
nSY := m_y

if nFunc == 0

	AADD(opc, "1 - Toplotno zastitno             ")
 	AADD(opcexe, {|| nFunc := 1, Izbor := 0 })
	
	AADD(opc, "2 - Suncano zastitno")
 	AADD(opcexe, {|| nFunc := 2, Izbor := 0 })
	
	AADD(opc, "3 - Multifunkcionalno")
 	AADD(opcexe, {|| nFunc := 3, Izbor := 0 })
	
	AADD(opc, "4 - Zvucno zastitno")
 	AADD(opcexe, {|| nFunc := 4, Izbor := 0 })
	
	AADD(opc, "5 - Sigurnosno")
 	AADD(opcexe, {|| nFunc := 5, Izbor := 0 })

	AADD(opc, "6 - Dekorativno")
 	AADD(opcexe, {|| nFunc := 6, Izbor := 0 })

	AADD(opc, "99 - nista od ponudjenog ")
	AADD(opcexe, {|| nFunc := 99, izbor := 0 })
 
  	Menu_SC("func")
endif

if LastKey() == K_ESC
	nFunc := 99
endif

m_x := nSX
m_y := nSY

return .t.



// -------------------------------------
// vrati funkciju
// -------------------------------------
function get_funkcija(cFunc)
local nFunc := 0

if EMPTY(cFunc)

	v_funkcija(@nFunc)

	cFunc := STR(nFunc, 2, 0)

endif

return .t.



// -------------------------------
// vraca opis funkcije
// -------------------------------
function g_func_opis(nFunc)
local xRet
local aFunc 

aFunc := g_aFunction()

if ( nFunc == 0 ) .or. ( LEN(aFunc) < nFunc )
	xRet := PADR("---", 20)
else
	xRet := PADR(aFunc[nFunc, 2], 20)
endif

return xRet



// ----------------------------------------
// matrica sa dostupnim funkcijama
// ----------------------------------------
static function g_aFunction()
local aFunc := {}

AADD(aFunc, { 1, "Toplotno zastitno"})
AADD(aFunc, { 2, "Suncano zastitno"})
AADD(aFunc, { 3, "Multifunkcionalno"})
AADD(aFunc, { 4, "Zvucno zastitno"})
AADD(aFunc, { 5, "Sigurnosno"})
AADD(aFunc, { 6, "Dekorativno"})

return aFunc


// ---------------------------------------------
// prikazuje opis funkcije na kordinatama nX, nY
// ---------------------------------------------
function sh_function(cFunc, nX, nY)
local nFunc
local cOpis

nFunc := VAL(cFunc)

cOpis := g_func_opis(nFunc)

@ m_x + nX, m_y + nY SAY cOpis

return .t.


// ------------------------------------
// vraca funkciju odredjene grupe
// ------------------------------------
function g_func_from_grupa(cGrupa)
local nFunc := 99
local nTArea := SELECT()

if !EMPTY(cGrupa)
	select s_grupe
	set order to tag "ID"
	seek cGrupa
	if FOUND()
		nFunc := field->funkcija
	endif
endif

select (nTArea)
return nFunc

