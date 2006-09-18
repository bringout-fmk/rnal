#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------------------------
// prelged sifrarnika tipova
// ------------------------------------------------
function p_rtip(cId, cGrupa, dx, dy)
*{
local nTArea
local nArea
local cHeader

cHeader := "Lista: tipovi artikala "
nTArea := SELECT()

if cGrupa == nil
	cGrupa := ""
endif

Private Kol
Private ImeKol

O_S_TIPOVI
nArea := F_S_TIPOVI

select (nTArea)

if !EMPTY(cGrupa)
	set_f_tbl(cGrupa)
endif

set_a_kol( @Kol, @ImeKol)
return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
       @cId, dx, dy, ;
	{|Ch| k_handler(Ch)} )
	

// -------------------------------------------
// setovanje filtera po grupaciji
// -------------------------------------------
static function set_f_tbl(cGrupa)
local cFilter
local nTArea := SELECT()
cFilter := "grupa == " + cm2str(cGrupa)
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
AADD(aImeKol, {"Grupacija", {|| grupa}, "grupa", {|| .t.}, {|| p_rgrupe(@wgrupa)} })
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Oznaka", {|| vrsta}, "vrsta", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Zaokruzenje", {|| tip_zaok }, "tip_zaok", {|| .t.}, {|| v_zaokr( @wtip_zaok ) } ,, "99" })
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
return DE_CONT


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

AADD(opc, "0 - bez zaokruzenja           ")
AADD(opcexe, {|| nZaok := 0, Izbor := 0 })
AADD(opc, "1 - tabela GN  ")
AADD(opcexe, {|| nZaok := 1, Izbor := 0 })
AADD(opc, "2 - profilit zaokruzenje ")
AADD(opcexe, {|| nZaok := 2, Izbor := 0 })
AADD(opc, "3 - staklo debljine do 3mm  ")
AADD(opcexe, {|| nZaok := 3, Izbor := 0 })

Menu_SC("mzk")

return .t.


