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

AADD(opc, "1. unos/dorada naloga za proizvodnju  ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "EDIT"))
	AADD(opcexe, {|| ed_rnal()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. lista otvorenih naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "DOKLSTO"))
	AADD(opcexe, {|| frm_lst_nalog(1)})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. lista zatorenih naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "DOKLSTZ"))
	AADD(opcexe, {|| frm_lst_nalog(2)})
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

if (ImaPravoPristupa(goModul:oDataBase:cName, "PARAM", "ALL"))
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

public gFirma := "10"
public gNFirma := SPACE(20)
public gPicVrijednost := "9999999.99"

// rnal - specif params section
// firma podaci
public gFNaziv:=SPACE(40)
public gFAdresa:=SPACE(40)
public gFIdBroj:=SPACE(13)
public gFTelefon:=SPACE(40)
public gFEmail:=SPACE(40)
public gFBanka1:=SPACE(50)
public gFBanka2:=SPACE(50)
public gFBanka3:=SPACE(50)
public gFBanka4:=SPACE(50)
public gFBanka5:=SPACE(50)
public gFPrRed1:=SPACE(50)
public gFPrRed2:=SPACE(50)

// izgled dokumenta
public gDl_margina := 5
public gDd_redovi := 11
public gDg_margina := 0

::super:setTGVars()

O_PARAMS
Rpar("ff",@gFirma)
Rpar("fn",@gNFirma)
Rpar("p1",@gPicVrijednost)

if Empty(gNFirma)
	Beep(1)
	Box(,1,50)
		@ m_x+1, m_y+2 SAY "Unesi naziv firme:" GET gNFirma PICT "@!"
		read
	BoxC()
	Wpar("fn", gNFirma)
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


