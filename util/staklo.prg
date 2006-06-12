#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

// staklo jedinice mjere
static ST_JMJ_STR := "#M2#"

// vrsta stakla
static IZO_ST_STR := "#22#33#"
static OB_ST_STR := "#1#2#3#"

// dodatne karakteristike
static DK_ARMIRANO := "A"
static DK_OGLEDALO := "OG"

// kilaza stakla, koeficienti, procenti
static NETTO_KOEF := 2.5
static NETTO_IZO_PROC := 3



// -----------------------------------------
// otvara box sa dostupnim tipovima stakla
// -----------------------------------------
function box_tip_stakla(nReturn)
local nSaveX
local nSaveY
private opc:={}
private opcexe:={}
private Izbor:=1


nSaveX := m_x
nSaveY := m_y

if ( nReturn <> 0 )
	return .t.
endif

AADD(opc, "1 - obicno staklo              ")
AADD(opcexe, {|| nReturn := Izbor, Izbor := 0 })
AADD(opc, "2 - termo-izolaciono staklo    ")
AADD(opcexe, {|| nReturn := Izbor, Izbor := 0 })
AADD(opc, "3 - PROFILIT staklo            ")
AADD(opcexe, {|| nReturn := Izbor, Izbor := 0 })
AADD(opc, "4 - LAMISTAL staklo            ")
AADD(opcexe, {|| nReturn := Izbor, Izbor := 0 })

Menu_SC("ts")

if LastKey() == K_ESC
	MsgBeep("Unos tipa stakla obavezan!")
	m_x := nSaveX
	m_y := nSaveY
	return .f.
endif

m_x := nSaveX
m_y := nSaveY

return .t.


// ---------------------------------------
// provjerava da li je roba staklo 
// ---------------------------------------
function is_staklo(cId)
local nTArea
local cJmj
local cPom

nTArea := SELECT()
select roba
seek cId
select (nTArea)

cJmj := UPPER(ALLTRIM(roba->jmj))
cPom := "#" + cJmj + "#"

if cPom $ ST_JMJ_STR
	return .t.
endif

return .f.


// -----------------------------------------------------
// kalkulise kvadratne metre
// nDim1, nDim2 u cm
// -----------------------------------------------------
function c_ukvadrat(nKol, nDim1, nDim2)
local xRet
xRet := ( nDim1 / 100 ) * (nDim2 / 100)
xRet := nKol * xRet
return xRet


// -------------------------------------
// kalkulise netto stakla
// nDebljina - debljina stakla
// nU_m2 - ukupno kvadratnih metara
// lIZO - da li je IZO staklo
// -------------------------------------
function c_netto(nDebljina, nU_m2, lIZO)
local xRet
xRet := NETTO_KOEF * nDebljina * nU_m2
if lIZO
	// ako je IZO dodaj procenat 3%
	xRet := xRet * (1 + (NETTO_IZO_PROC / 100))
endif
return xRet



// ----------------------------------------
// da li staklo izo 
// ----------------------------------------
function izo_staklo(cSifra)
local cPom
cPom := g_vrsta_stakla(cSifra)
if is_izo_staklo(cPom)
	return .t.
endif
return .f.



// --------------------------------------------
// vraca vrstu stakla
// --------------------------------------------
function g_vrsta_stakla(cSifra)
local cPom
local nIZOleft := 2
local nOBleft := 1

cSifra := ALLTRIM(cSifra)

// prvo provjeri da li je IZO
cPom := LEFT(cSifra, nIZOleft)

if is_izo_staklo(cPom)
	return cPom
endif

cPom := LEFT(cSifra, nOBleft)

return cPom


// da li je staklo izo
static function is_izo_staklo( cKarakt )
cKarakt := "#" + cKarakt + "#"
if cKarakt $ IZO_ST_STR
	return .t.
endif
return .f.



// vraca dodatne karaketeristike stakla
function g_dodk_stakla(cSifra)
local cPom
local cRet:=""
local nDK_arm := 1
local nDK_ogl := 2

cSifra := ALLTRIM(cSifra)

// da li je armirano
cPom := RIGHT(cSifra, nDK_arm)

// da li je armirano
if is_armirano(cPom)
	return DK_ARMIRANO
endif

cPom := RIGHT(cSifra, nDK_ogl)

// da li je ogledalo
if is_ogledalo(cPom)
	return DK_OGLEDALO
endif

return cRet



// da li je staklo armirano
static function is_armirano(xVal)
if xVal == DK_ARMIRANO
	return .t.
endif
return .f.


// da li je staklo ogledalo
static function is_ogledalo(xVal)
if xVal == DK_OGLEDALO
	return .t.
endif
return .f.


// vraca opis tipa stakla
function g_ts_opis( nType )
local xRet:=""
do case
	case nType == 1
		xRet := "obicno staklo"	
	case nType == 2
		xRet := "termo-izolaciono staklo"
	case nType == 3
		xRet := "PROFILIT staklo"
	case nType == 4
		xRet := "LAMISTAL staklo"
	
endcase
return xRet


// vraca opis vrste stakla
function g_vs_opis( cType )
local xRet:=""
do case 
	case cType == "1"
		xRet := "za dalju prodaju bez dorada"
	case cType == "2"
		xRet := "sa eventualnim doradama"
	case cType == "3"
		xRet := "sa eventualnim doradama i ugradnjom"
	case cType == "22"
		xRet := "IZO"
	case cType == "33"
		xRet := "IZO sa ugradnjom"
endcase
return xRet


// vraca opis tipa stakla
function g_dk_opis( cType )
local xRet:=""
do case
	case cType == "A"
		xRet := "armirano"	
	case cType == "OG"
		xRet := "ogledalo"
endcase
return xRet




