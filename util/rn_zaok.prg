#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */



// -------------------------------------
// zaokruzi xVal po GNU tabeli
// -------------------------------------
function z_po_gnu(nDeb, xVal)
local nRet
local aGN

// ako je staklo debljine manje od 3mm ne zaokruzuj
if nDeb < 3
	return xVal
endif

// definisi matricu GN-a
aGN := arr_gn()
// zaokruzi vrijednost xVal
nRet := seek_gn(aGN, xVal)

return nRet



// --------------------------------------
// napuni matricu sa GNU zaokruzenjima
// 21...240
// --------------------------------------
function arr_gn()
local aGN:={}

for i:=21 to 240 step 3
	AADD(aGN, {i})
next

return aGN


// ---------------------------------------------------
// pretrazi vrijednost u GN matrici i vrati zaokruzenu
// ---------------------------------------------------
function seek_gn(aGN, nVal)
local nRet
local nPom

for i:=1 to LEN(aGN)
	nPom := aGN[i, 1]
	if nPom > nVal
		nRet := nPom
		exit
	endif
next

return nRet



