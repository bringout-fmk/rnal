#include "\dev\fmk\rnal\rnal.ch"



// --------------------------------------
// stampa azuriranog naloga
// --------------------------------------
function stamp_nalog( lAzur, nBr_nal )

if ( nBr_nal == nil )
	nBr_nal := 0
	if !g_br_nal( @nBr_nal ) 
		return
	endif
endif

// stampa naloga
st_nalog( nBr_nal, lAzur )

return


// --------------------------------------
// stampa naloga
// --------------------------------------
function st_nalog( nBr_nal, lAzur )
local nRNal := F_P_RNAL
local nRNop := F_P_RNOP

// ako je azurirani nalog, promjeni area
if lAzur
	nRNal := F_RNAL
	nRNop := F_RNOP
endif

select (nRNal)
// ......

MsgBeep("stampa naloga....")
return





