#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */


// zaokruzenje dimenzije
// 
function dim_zaok(xVal, cArtikal)
local xRet
local cZaokType 

// odredi vrstu zaokruzenja za odredjeno staklo
cZaokType := g_z_type(cArtikal)


do case
	case cZaokType == "GN"
		// zaokruzenje pomocu tabele "GN"
		xRet := g_z_gn(xVal)
	case cZaokType == "PROFILIT"
		// zaokruzenje profilit stakla
		xRet := g_z_profilit(xVal)
	case cZaokType == "3M"
		// zaokruzenje stakla malog promjera
		xRet := g_z_3m(xVal)
endcase

return xRet


// odredjivanje tipa stakla
function g_z_type(cRoba)
local xRet
do case
	// profilit staklo
	case AT(cRoba, "SPROF") <> 0
		xRet := "PROFILIT"
	otherwise
		xRet := "GN"	
endcase

return xRet


// zaokruzenje po GN tabeli
function g_z_gn(nVal)

return nVal


// zaokruzenje 3m stakla
function g_z_3m(nVal)

return nVal

// zaokruzenje profilit stakla
function g_z_profilit(nVal)

return nVal



