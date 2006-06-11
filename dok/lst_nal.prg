#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------------------
// lista naloga
//  nStatus - "1" otoreni ili "2" zatvoreni
// ------------------------------------------
function frm_lst_nalog( nStatus )
local nTblRet

o_rnal(.f.)

nTblRet := tbl_lista(nStatus)

if nTblRet == 1
	return
elseif nTblRet == 2
	MsgBeep("report: lista naloga...")
endif

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_lista(nStatus)
local cFooter
local nLstRet

nLstRet := lst_uslovi(nStatus)

if nLstRet == 2
	return 2
elseif nLstRet == 0
	return 0
endif

private ImeKol
private Kol

cFooter := "Pregled azuriranih naloga..."

Box(, 20, 77)

set_box_dno(nStatus)



select rnal
set order to tag "br_nal"
//set relation to idpartner into partn
go top

set_a_kol(@ImeKol, @Kol)

ObjDbedit("lstnal", 20, 77, {|| k_handler() }, "", cFooter, , , , , 2)

BoxC()

close all
return 1

// ------------------------------------------
// setovanje dna boxa
// ------------------------------------------
static function set_box_dno(nStatus)
local cLine1 := ""
local cLine2 := ""
local nOpcLen := 24
local cOpcSep := "|"

// otvoreni nalozi
if nStatus == 1
	cLine1 := PADR("<Z> Zatvori nalog", nOpcLen)
	cLine1 += cOpcSep

	cLine1 := PADR("<L> Lista promjena", nOpcLen)
	cLine1 += cOpcSep
else
	cLine1 := PADR("<O> Otvori zatv.nalog", nOpcLen)
	cLine1 += cOpcSep

	cLine1 := PADR("<L> Lista promjena", nOpcLen)
	cLine1 += cOpcSep
endif

// druga linija je zajednicka
cLine2 := PADR("<c-P> Stampa naloga", nOpcLen)
cLine2 += cOpcSep
cLine2 += PADR("<c-O> Stampa otpremnice", nOpcLen)

@ m_x + 19, m_y + 2 SAY cLine1
@ m_x + 20, m_y + 2 SAY cLine2

return



// -------------------------------------------------
// otvori formu sa uslovima te postavi filtere
// -------------------------------------------------
static function lst_uslovi(nStatus)
local nX := 2
local dDatOd := CToD("")
local dDatDo := DATE()
local cPartNaz := SPACE(40)
local cPartSif := SPACE(40)
local cTblLista := "D"
local nRet := 1
local cFilter

Box( ,10, 70)
	
@ m_x + nX, m_y + 2 SAY "Datum od " GET dDatOd
@ m_x + nX, col() + 2 SAY "do" GET dDatDo

nX += 2

@ m_x + nX, m_y + 2 SAY "Naziv partnera pocinje sa (prazno svi) " GET cPartNaz PICT "@S20"

nX += 1

@ m_x + nX, m_y + 2 SAY "Uslov po sifri partnera   (prazno svi) " GET cPartSif PICT "@S20"

nX += 2

@ m_x + nX, m_y + 2 SAY "Tabelarni pregled (D/N) " GET cTblLista VALID val_d_n( cTblLista )

read

BoxC()

if cTblLista == "N"
	nRet := 2
endif

if LastKey() == K_ESC
	return 0
endif

cPartNaz := ALLTRIM(cPartNaz)
cPartSif := ALLTRIM(cPartSif)

cFilter := gen_filter(nStatus, dDatOd, dDatDo, cPartNaz, cPartSif)

set_f_kol(cFilter)

return nRet



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter(nStatus, dDatOd, dDatDo, cPartNaz, cPartSif)
local cZatvStatus := "Z"

cFilter := "r_br = 1"
cFilter += " .and. "

if nStatus == 1
	cFilter += "rn_status <> " + Cm2Str(cZatvStatus)
else
	cFilter += "rn_status == " + Cm2Str(cZatvStatus)
endif

if !EMPTY(dDatOd)
	cFilter += " .and. datnal >= " + Cm2Str(dDatOd)
endif
if !Empty(dDatDo)
	cFilter += " .and. datnal <= " + Cm2Str(dDatDo)
endif
if !Empty(cPartNaz)
	cFilter += " .and. PARTN->naz = " + Cm2Str(cPartNaz)
endif
if !Empty(cPartSif)
	cFilter += " .and. idpartner = " + Cm2Str(cPartSif)
endif

return cFilter



// ------------------------------------------------
// setovanje filtera prema uslovima
// ------------------------------------------------
static function set_f_kol(cFilter)
select rnal
set order to tag "br_nal"
set filter to &cFilter
set relation to idpartner into partn
go top

return



// ---------------------------------------------
// pregled - key handler
// ---------------------------------------------
static function k_handler()
local nBr_nal
local cTblFilt
		
do case
	// stampa naloga
	case (Ch == K_CTRL_P)
		if Pitanje(, "Stampati nalog (D/N) ?", "D") == "D"
			nBr_nal := rnal->br_nal
			nTRec := RecNo()
			cTblFilt := DBFilter()
			set filter to
			st_nalpr( .f., nBr_nal )
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			return DE_REFRESH
		endif
		SELECT RNAL
		return DE_CONT
	// stampa otpremnice
	case ( Ch == K_CTRL_O )
		if Pitanje(,"Stampati otpremicu (D/N ?)", "D") == "D"
			nBr_nal := rnal->br_nal
			nTRec := RecNo()
			cTblFilt := DBFilter()
			set filter to
			st_otpremnica(.f., nBr_nal)
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			return DE_REFRESH
		endif
		SELECT RNAL
		RETURN DE_CONT
	// otvaranje naloga koji je zatvoren
	case (UPPER(CHR(Ch)) == "O")
		if Pitanje(, "Otvoriti zatvoreni nalog radi dorade ?", "N") == "D"
			nTRec := RecNo()
			nBr_nal := rnal->br_nal
			cTblFilt := DBFilter()
			set filter to
			if pov_nalog(nBr_nal) == 1
				MsgBeep("Nalog opet otvoren !")
			endif
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			RETURN DE_REFRESH
		endif
		SELECT RNAL
		RETURN DE_CONT
	// zatvaranje naloga
	case (UPPER(CHR(Ch)) == "Z")
		if Pitanje(, "Zatvoriti nalog (D/N) ?", "N") == "D"
			nTRec := RecNo()
			nBr_nal := rnal->br_nal
			cTblFilt := DBFilter()
			set filter to
			if z_rnal(nBr_nal) == 1
				MsgBeep("Nalog zatvoren !")
			endif
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			RETURN DE_REFRESH
		endif
		SELECT RNAL
		RETURN DE_CONT
	// lista promjena na nalogu
	case (UPPER(CHR(Ch)) == "L")
		MsgBeep("Lista promjena na nalogu!")
		RETURN DE_CONT

endcase

return DE_CONT



// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}

AADD(aImeKol, {"Nalog br.", {|| br_nal }, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Partner", {|| PADR(s_partner(idpartner), 40) }, "idpartner", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Datum", {|| datnal }, "datnal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Ukupno", {|| TRANSFORM( g_nal_ukupno( br_nal ), PIC_IZN() ) }, "d_ukupno", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp." , {|| datisp }, "datisp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp." , {|| vr_isp }, "vr_isp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Placanje" , {|| PADR(s_placanje(vr_plac),10) }, "vr_plac", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Hitnost" , {|| PADR(s_hitnost(hitnost),10) }, "hitnost", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


