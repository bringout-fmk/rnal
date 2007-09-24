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
	method mStartUp
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

// security mora biti aktivan
if gSecurity == "N"
	MsgBeep("Security nije aktivan!#Prekidam rad...")
	::quit()
endif

PID("START")
close all

SETKEY(K_SH_F1,{|| Calc()})

CheckROnly(KUMPATH + SLASH + "DOCS.DBF")

O_DOCS
select docs 
TrebaRegistrovati(3)
use

close all

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

s_params()

::mStartUp()
::mMenuStandard()

::quit()

return nil



method mStartUp()

if is_fmkrules()
	// generisi standarne rnal rules
	gen_rnal_rules()
endif

return nil



method mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

say_fmk_ver()

AADD(opc, "1. unos/dorada naloga za proizvodnju  ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKEDIT"))
	AADD(opcexe, {|| ed_document( .t. )})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. lista otvorenih naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKLSTO"))
	AADD(opcexe, {|| frm_lst_docs(1)})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. lista zatorenih naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKLSTZ"))
	AADD(opcexe, {|| frm_lst_docs(2)})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. izvjestaji ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKRPT"))
	AADD(opcexe, {|| m_rpt() })
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. export naloga u fmk ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKEXP"))
	AADD(opcexe, {|| m_gr_expfmk() })
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "S. sifrarnici")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "SIF"))
	AADD(opcexe, {|| m_sif()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "9. administracija")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "ADMIN"))
	AADD(opcexe, {|| mnu_admin()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})


AADD(opc, "X. parametri")

if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "PARAMS"))
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

// ostali parametri
public gFnd_reset := 0
public gMaxHeigh := 1000
public gMaxWidth := 1000


// export parametri
public gExpOutDir := PADR("c:\temp\", 150)
public gExpAlwOvWrite := "N"
public gFaKumDir := PADR( STRTRAN( KUMPATH, "\RNAL\", "\FAKT\" ), 150 )
public gFaPrivDir := PADR( STRTRAN( PRIVPATH, "\RNAL\", "\FAKT\" ), 150 )

// default joker glass type
public gDefGlType
// default joker glass tick
public gDefGlTick
// default joker glass
public gGlassJoker
// default frame joker
public gFrameJoker
// joker glass LAMI
public gGlLamiJoker

// joker brusenje
public gAopBrusenje
// joker kaljenje
public gAopKaljenje


::super:setTGVars()

O_PARAMS

// sekcija "1"
private cSection := "1"
Rpar( "ff", @gFirma )
Rpar( "fn", @gNFirma )

// sekcija "5"
private cSection := "5"
Rpar( "p1", @gPicVrijednost )
Rpar( "a1", @gFnd_reset )

// sekcija "E"
private cSection := "E"
Rpar( "od", @gExpOutDir )
Rpar( "ao", @gExpAlwOvWrite )
Rpar( "pd", @gFaPrivDir )
Rpar( "kd", @gFaKumDir )

private cSection := "1"

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
gGlBaza:="DOCS.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

// rules block i cols
public aRuleSpec := g_rule_cols()
public bRuleBlock := g_rule_block()

return


