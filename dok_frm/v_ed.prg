#include "sc.ch"


// ----------------------------------------
// validacija partnera
// ----------------------------------------
function val_partner(cId, nX, nY)
// partner ne moze biti prazno
if Empty(cId)
	MsgBeep("Unos narucioca obavezan !")
	return .f.
endif

// iz sifrarnika
p_firma(@cId)

if ( nX <> nil )
	s_part_box(cId, nX, nY)
endif

return .t.


// -------------------------------------------
// validacija robe te prikaz info-a
// -------------------------------------------
function val_roba(cId, nX, nY)

// iz sifrarnika
get_artikal(@cId)

// prikazi naziv robe
s_roba_naz(cId, nX, nY)
	
return .t.


// -------------------------------------------
// validacija sastavnice te prikaz info-a
// -------------------------------------------
function val_sast(cId, cFilt, nX, nY)

if ALLTRIM(cId) == "-staklo-" .or. ALLTRIM(cId) == "-distanc.-"
	cId := SPACE(10)
endif

if EMPTY(cId)
	get_artikal(@cId, cFilt)
else
	// iz sifrarnika
	get_artikal(@cId)
endif

// prikazi naziv robe
s_roba_naz(cId, nX, nY)
	
return .t.


// ------------------------------------
// validacija polja tip artikla
// ------------------------------------
function val_rtip(cId)
if EMPTY(cId)
	MsgBeep("Unos tipa artikla obavezan!")
	return .f.
endif

p_rtip(@cId)

s_rtip_naz(cId)

return .t.



// -----------------------------
// validacija kolicine
// -----------------------------
function val_kolicina(xVal)
if ( xVal <> 0 )
	return .t.
endif
MsgBeep("Kolicina mora biti <> 0 !!!")
return .f.


// -----------------------------
// validacija dimenzije visina
// -----------------------------
function val_dim_visina(xVal)
//if ( xVal <> 0 )
	if xVal > MAX_VISINA()
		MsgBeep("Max. visina = " + ALLTRIM(STR(MAX_VISINA())))
		return .f.
	endif
	if xVal < MIN_VISINA()
		MsgBeep("Min. visina = " + ALLTRIM(STR(MIN_VISINA())))
		return .f.
	endif
	
	//return .t.
//endif
//MsgBeep("Visina mora biti <> 0 !!!")
return .t.


// -----------------------------
// validacija dimenzije sirina
// -----------------------------
function val_dim_sirina(xVal)
//if ( xVal <> 0 )
	if xVal > MAX_SIRINA()
		MsgBeep("Max. sirina = " + ALLTRIM(STR(MAX_SIRINA())))
		return .f.
	endif
	if xVal < MIN_SIRINA()
		MsgBeep("Min. sirina = " + ALLTRIM(STR(MIN_SIRINA())))
		return .f.
	endif

	//return .t.
//endif
//MsgBeep("Sirina mora biti <> 0 !!!")
return .t.



// -----------------------------
// validacija debljine
// -----------------------------
function val_debljina(xVal)
if ( xVal <> 0 )
	if xVal > MAX_DEBLJINA()
		MsgBeep("Max. debljina = " + ALLTRIM(STR(MAX_DEBLJINA())))
		return .f.
	endif
	if xVal < MIN_DEBLJINA()
		MsgBeep("Min. debljina = " + ALLTRIM(STR(MIN_DEBLJINA())))
		return .f.
	endif

	return .t.
endif
MsgBeep("Debljina mora biti <> 0 !!!")
return .f.




// -----------------------------
// validacija D/N
// -----------------------------
function val_d_n(xVal)
local cOdg := "DN"

if !EMPTY(xVal)
	if xVal $ cOdg
		return .t.
	endif
endif
MsgBeep("Unjeti D ili N !!!")

return .f.


// -----------------------------
// validacija unosa karaketera
// -----------------------------
function val_kunos(xVal, cKeys)

if !EMPTY(xVal) .and. !EMPTY(cKeys)
	if xVal $ cKeys
		return .t.
	endif
elseif EMPTY(cKeys) 
	// ako je valid uslov prazan - nista
	return .t.
endif
MsgBeep("Moguce unjeti nesto od sljedeceg: " + cKeys + " !!!")

return .f.

// -----------------------------------------
// validacija instrukcije 
// -----------------------------------------
function val_instr(cRn_ka, xVal)
local nArea
local cValid

nArea := SELECT()
select s_rnka
set order to tag "id"
seek cRn_ka

if Found()
	cValid := ALLTRIM(field->ka_val)
else
	select (nArea)
	return .t.
endif
select (nArea)

return val_kunos(ALLTRIM(xVal), cValid)


// ------------------------------------
// validacija polja placanje
// ------------------------------------
function val_plac(cPlac)
local nSaveX
local nSaveY
private opc:={}
private opcexe:={}
private izbor:=1

nSaveX := m_x
nSaveY := m_y

if cPlac == " "

	AADD(opc, "ziro racun")
 	AADD(opcexe, {|| cPlac := "1", Izbor := 0 })
 
 	AADD(opc, "kes")
 	AADD(opcexe, {|| cPlac := "2", Izbor := 0 })
 
 	Menu_SC("placanje")

	if lastkey() == K_ESC
		cPlac := "1"
	endif
endif

m_x := nSaveX
m_y := nSaveY

return .t.



// ------------------------------------
// validacija polja prioritet
// ------------------------------------
function val_priority(cPrior)
local nSaveX
local nSaveY
private opc:={}
private opcexe:={}
private izbor:=1

nSaveX := m_x
nSaveY := m_y

if cPrior == " "

	AADD(opc, "Low priority    ")
 	AADD(opcexe, {|| cPrior := "1", Izbor := 0 })
 
 	AADD(opc, "Normal priority ")
 	AADD(opcexe, {|| cPrior := "2", Izbor := 0 })
 
 	AADD(opc, "High priority ")
 	AADD(opcexe, {|| cPrior := "3", Izbor := 0 })
 
 	Menu_SC("priority")

	if lastkey() == K_ESC
		cPrior := "2"
	endif
endif

m_x := nSaveX
m_y := nSaveY

return .t.

