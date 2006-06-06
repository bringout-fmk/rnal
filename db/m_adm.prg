#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// -------------------------------------------
function m_adm()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. install db-a                         ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(opc, "2. security")
AADD(opcexe, {|| MnuSecMain()})

Menu_SC("adm")

return



