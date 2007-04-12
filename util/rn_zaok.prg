#include "\dev\fmk\rnal\rnal.ch"


static BEZ_ZAOKR := 99
static GN_ZAOKR := 1
static PROF_ZAOKR := 2
static S3M_ZAOKR := 3


// ----------------------------------------
// obracunski list zaokruzenje
// ----------------------------------------
function obrl_zaok( nVal, aArr )
local nElCount 
local i
local nTickness
local nSeek
local nZaok := 1
local xZaok := 0

// uzmi broj elemenata stakla
nElCount := aArr[ LEN(aArr), 1 ]

if nElCount == 1
	
	// debljina stakla 1
	nTickness := g_gl_tickness( aArr, 1 )

	// uzmi tip stakla
	cType := g_gl_type( aArr, 1 )

	if nTickness <= 3

		nZaok := 3
	
	endif
	
	if cType == "PR" 
	
		nZaok := 2
	
	endif

	// zaokruzi
	xZaok := dim_zaokruzi( nVal, nTickness, nZaok )
	

elseif nElCount > 1
	
	// ako je vise stavki....
	xZaok := dim_zaokruzi( nVal, 4, nZaok )
	
endif

return xZaok



// ----------------------------------------
// obracunski list neto
// ----------------------------------------
function obrl_neto( nM2, aArr )
local nElCount 
local i
local nTickness
local nSeek
local xNeto

// uzmi broj elemenata stakla
nElCount := aArr[ LEN(aArr), 1 ]

if nElCount == 1
	
	nTickness := g_gl_tickness( aArr, 1 )

	// neto za jednu stavku je....
	xNeto := 2.5 * nTickness * nM2 
	

elseif nElCount > 1

	nTickness := g_gl_tickness( aArr )
	
	// ako je vise stavki.... dodaj jos 3%
	xNeto := ( 2.5 * nTickness * nM2 ) * ( 1 + (3 / 100) )
	
endif

return xNeto



// ---------------------------------------------
// vraca tip stakla
// ---------------------------------------------
function g_gl_type( aArr, nGlass )
local nSeek 
local cType := ""

if nGlass == nil
	nGlass := 0
endif

nSeek := ASCAN( aArr, {|xVal| IF(nGlass>0,xVal[1] == nGlass, .t.) .and. ;
		xVal[2] == "G" .and. ;
		xVal[4] == "<G_TYPE>"} )

cType := aArr[ nSeek, 5 ]

return cType


// ------------------------------------------
// vraca debljinu stakla
// ------------------------------------------
function g_gl_tickness( aArr, nGlass )
local xRet := 0
local i

if nGlass == nil
	nGlass := 0
endif

for i:=1 to LEN( aArr )

	if aArr[i, 2] == "G" .and. aArr[i, 4] == "<G_TICK>" .and. IF(nGlass > 0, aArr[i, 1] == nGlass , .t.)
		xRet += VAL( aArr[ i, 5 ] )
	endif
	
next

return xRet



// -------------------------------------
// zaokruzi xVal po GNU tabeli
// -------------------------------------
function dim_zaokruzi(xVal, nDebljina, nTipZaok)

// ako je bez zaokruzenja
if nTipZaok == BEZ_ZAOKR
	return xVal
endif

// ako je debljina do 3mm uvijek zaokruzi na 3mm zaokr.
if nDebljina <= 3
	return z_3mm_staklo(xVal)
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
	if nPom%260 == 0
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
	if nPom%20 == 0
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

for i:=210 to 2400 step 30
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






