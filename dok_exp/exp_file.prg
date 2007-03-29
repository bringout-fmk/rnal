#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// set exp.fajl
// -------------------------------------------
function set_exp_location( cLocation )
cLocation := SPACE(200)
return



// -------------------------------------------
// vraca naziv fajla
// -------------------------------------------
static function g_exp_file( nDoc_no, cLocat )
local aDir
local cFMask := "TRF"
local cFileName := ""

AddBS(@cLocat)

cFileName := "LISEC"
cFileName += ALLTRIM(STR(nDoc_no)) 
cFileName += "." 
cFileName += cFMask

return cFileName


// -------------------------------------------
// kreiraj fajl za export....
// -------------------------------------------
function cre_exp_file( nDoc_no, cLocation, cFileName, nH )

// daj naziv fajla
cFileName := g_exp_file( nDoc_no , cLocation )

nH := FCreate( cLocation + cFileName )

if nH == -1
	msgbeep("greska pri kreiranju fajla")
endif

return



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



