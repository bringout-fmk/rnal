#include "\dev\fmk\rnal\rnal.ch"


// --------------------------------------------------
// prikazi info 99 - otvori sifrarnik
// --------------------------------------------------
function info_0_sif( nPadR )
local cTxt := "/ 0 - otvori sifrarnik /"
show_it( cTxt, nPadR )
return


// --------------------------------------------------
// prikazi info 99 - otvori sifrarnik
// --------------------------------------------------
function info_99_sif( nPadR )
local cTxt := "/ 99 - otvori sifrarnik /"
show_it( cTxt, nPadR )
return


// --------------------------------------------------
// prikazi pay types
// --------------------------------------------------
function info_pay( nPadR )
local cTxt := "/ 1 - z.racun / 2 - gotovina /"
show_it( cTxt, nPadR )
return


// --------------------------------------------------
// prikazi prioritet 
// --------------------------------------------------
function info_priority( nPadR )
local cTxt := "/ 1 - high / 2 - normal / 3 - low /"
show_it( cTxt, nPadR )
return




