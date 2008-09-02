#include "rnal.ch"


// -------------------------------------------
// get exp.fajl
// -------------------------------------------
function g_exp_location( cLocation )
local nRet := 1

cLocation := ALLTRIM(gExpOutDir)

if EMPTY( cLocation ) 
	msgbeep( "Nije podesen export direktorij!#Parametri -> 4. parametri exporta" )
	nRet := 0
endif

// dodaj bs ako ne postoji
AddBS( @cLocation )

return nRet



// -------------------------------------------
// vraca naziv fajla
// -------------------------------------------
static function g_exp_file( nDoc_no, cLocat )
local aDir
local cFExt := "TRF"
local cFileName := ""

cFileName := "E"
cFileName += PADL( ALLTRIM(STR(nDoc_no)), 7, "0" )
cFileName += "." 
cFileName += cFExt

return cFileName


// -------------------------------------------
// kreiraj fajl za export....
// -------------------------------------------
function cre_exp_file( nDoc_no, cLocation, cFileName, nH )

// daj naziv fajla
cFileName := g_exp_file( nDoc_no , cLocation )

// da li vec postoji ????
// gExpAlwOvWrite - export file uvijek overwrite
if gExpAlwOvWrite == "N" .and. FILE( cLocation + cFileName )
	
	if pitanje( , "Fajl " + cFileName + " vec postoji, pobrisati ga ?", "D" ) == "N"
		return 0
	endif
	
endif

// pobrisi fajl
FERASE( cLocation + cFileName )

nH := FCREATE( cLocation + cFileName )

if nH == -1
	msgbeep("greska pri kreiranju fajla")
endif

return 1



// ----------------------------------------------------
// zatvori fajl
// ----------------------------------------------------
function close_exp_file( cFileName )
FCLOSE( cFileName )
return


// ----------------------------------------------------
// upisi tekst u fajl
// ----------------------------------------------------
function write2file( nH, cText, lNewRow )
#DEFINE NROW CHR(13) + CHR(10)

if lNewRow == .t.
	FWRITE( nH, cText + NROW )
else
	FWRITE( nH, cText )
endif

return



