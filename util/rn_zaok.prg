#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

static BEZ_ZAOKR := 99
static GN_ZAOKR := 1
static PROF_ZAOKR := 2
static S3M_ZAOKR := 3



// -------------------------------------
// zaokruzi xVal po GNU tabeli
// -------------------------------------
function dim_zaokruzi(xVal, nTipZaok)

// ako je bez zaokruzenja
if nTipZaok == BEZ_ZAOKR
	return xVal
endif

// zaokruzenje profilit staklo
if nTipZaok == PROF_ZAOKR
	return z_prof_staklo(xVal)
endif

// ako je staklo ove debljine idi po GN-u
if nTipZaok == S3M_ZAOKR
	return z_3mm_staklo(xVal)
endif

if nTipZaok == GN_ZAOKR
	return z_po_gn(xVal)
endif

return


// --------------------------------------------
// zaokruzenje stakla profilit
// --------------------------------------------
static function z_prof_staklo(nDimenzija)
local nPom
local xRet
nPom := nDimenzija
do while .t.
	if nPom%26 == 0
		xRet := nPom
		exit
	endif
	++ nPom
enddo
return xRet


// --------------------------------------------
// zaokruzenje stakla promjera do 3mm
// --------------------------------------------
static function z_3mm_staklo(nDimenzija)
local nPom
local xRet
nPom := nDimenzija
do while .t.
	++ nPom
	if nPom%2 == 0
		xRet := nPom
		exit
	endif
enddo
return xRet




// -------------------------------------------
// zaokruzenje po GN tabeli
// -------------------------------------------
static function z_po_gn(nDimenzija)
local aGN := {}
local nRet := 0

// definisi matricu GN-a
aGN := arr_gn()

// zaokruzi vrijednost nDimenzija
nRet := seek_gn(aGN, nDimenzija)

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
static function seek_gn(aGN, nVal)
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






