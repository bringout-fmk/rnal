#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

function TRNalModNew()
local oObj

oObj:=TRNalMod():new()

oObj:self:=oObj
return oObj


#include "class(y).ch"
CREATE CLASS TRNalMod INHERIT TAppMod
	EXPORTED: 
	var oSqlLog
	method dummy
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS


method dummy()
return


method initdb()
::oDatabase:=TDBRNalNew()
return NIL


method mMenu()

PID("START")
close all

SETKEY(K_SH_F1,{|| Calc()})

CheckROnly(KUMPATH + "\RNAL.DBF")

O_RNAL
select rnal
TrebaRegistrovati(3)
use

close all

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

s_params()

::mMenuStandard()

::quit()

return nil


method mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

say_fmk_ver()

AADD(opc, "1. radni nalog unos/ispravka           ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","EDIT"))
	AADD(opcexe, {|| ed_rnal()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. izvjestaji")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","IZVJ"))
	AADD(opcexe, {|| m_rpt()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. pregled naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","DOKLST"))
	AADD(opcexe, {|| m_lst_rnal()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe, {|| notimp()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "S. sifrarnici")
AADD(opcexe, {|| m_sif()})

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "9. administracija baze podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DB", "ADMIN"))
	AADD(opcexe, {|| m_adm()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})


AADD(opc, "X. parametri")

if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","ALL"))
	AADD(opcexe, {|| m_par()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("grn",.t., .f.)

return



method sRegg()
sreg("RNAL","RNAL")
return


method srv()
return


method setGVars()

SetFmkSGVars()
SetFmkRGVars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gFirma:="10"
public gNFirma:=space(20)  
public gPicVrijednost := "9999999.99"

::super:setTGVars()

O_PARAMS
Rpar("ff",@gFirma)
Rpar("fn",@gNFirma)
Rpar("p1",@gPicVrijednost)

if empty(gNFirma)
	Beep(1)
  	Box(,1,50)
    		@ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
    		read
  	BoxC()
  	WPar("fn",gNFirma)
endif
select (F_PARAMS)

use

public gModul
public gTema
public gGlBaza

gModul:="RNAL"
gTema:="OSN_MENI"
gGlBaza:="RNAL.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

return


