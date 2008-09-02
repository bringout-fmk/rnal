#include "rnal.ch"


// --------------------------------------------------
// posalji report emailom pomocu ruby skripte
// --------------------------------------------------
function send_eml()
local cRbScr

private cCmd

// uzmi parametre za slanje
_get_vars( @cCmd )

// snimi sliku i ocisti ekran
save screen to cRbScr
clear screen

? "sending report via email ... please wait ..."
// pokreni komandu
run &cCmd

Sleep(3)
// vrati staro stanje ekrana
restore screen from cRbScr

return


// -------------------------------------------
// vraca cmd line za slanje emailom
// -------------------------------------------
static function _get_vars( cCmd )
local cScript := IzFmkIni("Ruby","Err2Mail","c:\sigma\err2mail.rb", EXEPATH)
local cRptFile := PRIVPATH + "outf.txt"

cCmd := cScript + " " + cRptFile

return



