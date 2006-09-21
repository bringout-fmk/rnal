#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------------------------
// prelged sifrarnika tipova
// ------------------------------------------------
function p_rtip(cId, cFilter, dx, dy)
local nTArea
local nArea
local cHeader

cHeader := "Lista: tipovi artikala,    <S> setuj funkcije"
nTArea := SELECT()

if cFilter == nil
	cFilter := ""
endif

Private Kol
Private ImeKol

O_S_TIPOVI
nArea := F_S_TIPOVI

select (nTArea)

if !EMPTY(cFilter)
	set_f_tbl(cFilter)
endif

set_a_kol( @Kol, @ImeKol)
return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
       @cId, dx, dy, ;
	{|Ch| k_handler(Ch)} )
	

// -------------------------------------------
// setovanje filtera na tabeli
// -------------------------------------------
static function set_f_tbl(cFilter)
local nTArea := SELECT()
select s_tipovi
set filter to &cFilter
select (nTArea)
return


// ---------------------------------------------------
// kolone tabele
// ---------------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"ID"   , {|| id}   , "id"   , {|| .t.}, {|| .t.} })
add_mcode(@aImeKol)
AADD(aImeKol, {"Grupa", {|| grupa}, "grupa", {|| .t.}, {|| p_rgrupe(@wgrupa)} })
AADD(aImeKol, {"Naziv", {|| PADR(naziv, 40)}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Oznaka", {|| vrsta}, "vrsta", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Funkcija", {|| funkcija }, "funkcija", {|| .t. }, {|| fld_get_func( @wfunkcija ) } })
AADD(aImeKol, {"Zaokruzenje", {|| tip_zaok }, "tip_zaok", {|| .t. }, {|| v_zaokr( @wtip_zaok ) } ,, "99" })
AADD(aImeKol, {"Neto koef.", {|| neto_koef }, "neto_koef", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Neto proc.", {|| neto_proc }, "neto_proc", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// ------------------------------------
// keyboard handler
// ------------------------------------
static function k_handler(Ch)

do case
	case Ch == K_CTRL_T
		// provjeri da li smijes brisati sifru
		if !chk_del_item( field->id )
			MsgBeep("Ovu sifru vec koristi neki od artikala !!!")
			return DE_CONT
		endif
	case UPPER(CHR(Ch)) == "S"
		fld_funkcija()
		return 7
endcase

return DE_CONT


// ---------------------------------------
// setovanje polja FUNKCIJA, opcija "S"
// ---------------------------------------
static function fld_funkcija()
local aStdVals 
local aRet

// standardne vrijednosti
aStdVals := g_aFunction()

aRet := get_hash_field( funkcija, aStdVals)

scatter()
set_hash_field( @_funkcija , aRet)
gather()

return 


// ----------------------------------------------
// setovanje polja funkcija iz browse-a
// ----------------------------------------------
static function fld_get_funkcija( cFunc )
local aStdVals 
local aRet
local lSilent := .t.
local nLenField

nLenField := LEN(cFunc)

// standardne vrijednosti
aStdVals := g_aFunction()

aRet := get_hash_field( cFunc, aStdVals)

set_hash_field( @cFunc , aRet, nil, lSilent )

cFunc := PADR(cFunc, nLenField )

return .t.



// --------------------------------------
// provjeri da li smijes brisati stavku
// --------------------------------------
static function chk_del_item(cTip)
local nTArea := SELECT()
local lRet := .t.

O_ROBA
select roba
set order to tag "ID"
go top
do while !EOF()
	if field->roba_tip == cTip
		lRet := .f.
		exit
	endif
	skip
enddo

select (nTArea)
return lRet


// -------------------------------
// vraca tip zaokruzenja
// -------------------------------
function g_rtip_params( cId, cVrsta, nZaokr, nNetoKoef, nNetoProc )
local nTArea
nTArea := SELECT()

select s_tipovi
set order to tag "id"
go top
seek cId

if Found()
	cVrsta := field->vrsta
	nZaokr := field->tip_zaok
	nNetoKoef := field->neto_koef
	nNetoProc := field->neto_proc
endif

select (nTArea)
return


// -------------------------------
// vraca vrstu artikla
// -------------------------------
function g_rvrsta( cId )
local cRet:=""
local nTArea
nTArea := SELECT()

select s_tipovi
set order to tag "id"
go top
seek cId

if Found()
	cRet := ALLTRIM(field->vrsta)
endif

select (nTArea)
return cRet

// -------------------------------------------------------
// validacija polja zaokruzenja, meni sa dosupnim opcijama
// -------------------------------------------------------
function v_zaokr( nZaok )
private opc:={}
private opcexe:={}
private izbor:=1

if nZaok == 0

	AADD(opc, "1 - tabela GN                  ")
 	AADD(opcexe, {|| nZaok := 1, Izbor := 0 })
 
 	AADD(opc, "2 - profilit zaokruzenje ")
 	AADD(opcexe, {|| nZaok := 2, Izbor := 0 })
 
 	AADD(opc, "3 - staklo debljine do 3mm  ")
 	AADD(opcexe, {|| nZaok := 3, Izbor := 0 })
 
 	AADD(opc, "99 - bez zaokruzenja  ")
 	AADD(opcexe, {|| nZaok := 99, Izbor := 0 })
 
 	Menu_SC("mzk")
endif

return .t.

// ------------------------------------
// odabir funkcije stakla
// ------------------------------------
function v_funkcija(nFunc)
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
	
	AADD(opc, "3 - Zvucno zastitno")
 	AADD(opcexe, {|| nFunc := 3, Izbor := 0 })
	
	AADD(opc, "4 - Sigurnosno")
 	AADD(opcexe, {|| nFunc := 4, Izbor := 0 })

	AADD(opc, "5 - Dekorativno")
 	AADD(opcexe, {|| nFunc := 5, Izbor := 0 })

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

cFunc := PADL(ALLTRIM(cFunc), 2)

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
AADD(aFunc, { 3, "Zvucno zastitno"})
AADD(aFunc, { 4, "Sigurnosno"})
AADD(aFunc, { 5, "Dekorativno"})

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



// generisi filter za tabelu tipova
function gen_tip_filter(cFunkcija, cRobaGrupa)
local cFilt:=".t."

if !EMPTY(cFunkcija) .or. (cFunkcija <> "99")
	cFilt += " .and. " + cm2str(ALLTRIM(cFunkcija)) + " $ funkcija"
endif

if !EMPTY(cRobaGrupa)
	cFilt += " .and. grupa ==" + cm2str(cRobaGrupa)
endif

if cFilt == ".t."
	cFilt := ""
endif

return cFilt


