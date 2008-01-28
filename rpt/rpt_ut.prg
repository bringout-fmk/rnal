#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------
// prikaz informacije na izvjestaju 
// ---------------------------------------
function __rpt_info( nLeft )
local cDesc := ""

if nLeft == nil
	nLeft := pcol() + 1
endif

cDesc := "na dan: " + DTOC(DATE())
cDesc += " "
cDesc += "oper: " + goModul:oDataBase:cUser

@ prow(), nLeft SAY cDesc

return


