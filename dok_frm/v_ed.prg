#include "sc.ch"

// --------------------------
// validacija
// --------------------------


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

s_part_box(cId, nX)

return .t.


// -------------------------------------------
// validacija robe te prikaz info-a
// -------------------------------------------
function val_roba(cId, nX, nY)

if Empty(cId)
	MsgBeep("Unos artikla obavezan!")
	return .f.
endif

// iz sifrarnika
p_roba(@cId)

// provjeri da li je rijec o staklu
if is_staklo(cId)
	// ispisi odmah pored naziv artikla
	s_roba_naz(cId, nX, nY)
	
	// ispod ispisi opis stakla
	// hm... ovo ne treba...
	//nX += 1
	//s_staklo_info(_idroba, nX )
	return .t.
else
	MsgBeep("Uneseni artikal ne pripada kategoriji stakla!")
	return .f.
endif

return .f.


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
// validacija dimenzije
// -----------------------------
function val_dimenzija(xVal)
if ( xVal <> 0 )
	return .t.
endif
MsgBeep("Dimenzija mora biti <> 0 !!!")
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


