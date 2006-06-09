#include "sc.ch"

// --------------------------
// validacija
// --------------------------


// validacija robe
function val_roba(xVal)

if !EMPTY(xVal)
	return .t.
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

if !EMPTY(xVal)
	if xVal $ cKeys
		return .t.
	endif
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


