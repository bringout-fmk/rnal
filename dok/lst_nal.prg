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

set_a_kol(@ImeKol, @Kol, nStatus)

ObjDbedit("lstnal", 20, 77, {|| k_handler(nStatus) }, "", cFooter, , , , , 2)

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
local cOpcSep := "| "

cLine1 := PADR("<D> Dorada naloga", nOpcLen)
cLine1 += cOpcSep

if ( nStatus == 1 )
	cLine1 += PADR("<Z> Zatvori nalog", nOpcLen)
	cLine1 += cOpcSep
	cLine1 += PADR("<P> Promjene", nOpcLen)
endif

// druga linija je zajednicka
cLine2 := PADR("<c-P> Stampa naloga", nOpcLen)
cLine2 += cOpcSep
cLine2 += PADR("<c-O> Stampa otpremnice", nOpcLen)
cLine2 += cOpcSep
cLine2 += PADR("<L> Lista promjena", nOpcLen)

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
local cTblLista := "D"
local nRet := 1
local cFilter

Box( ,10, 70)
	
@ m_x + nX, m_y + 2 SAY "Datum od " GET dDatOd
@ m_x + nX, col() + 2 SAY "do" GET dDatDo

nX += 2

@ m_x + nX, m_y + 2 SAY "Naziv partnera pocinje sa (prazno svi) " GET cPartNaz PICT "@S20"

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

cFilter := gen_filter(nStatus, dDatOd, dDatDo, cPartNaz)

set_f_kol(cFilter)

return nRet



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter(nStatus, dDatOd, dDatDo, cPartNaz)
local cZatvStatus := "Z"

cFilter := "r_br = 1"
cFilter += " .and. "
cFilter += "rec_zak <> " + Cm2Str("Z")
cFilter += " .and. "

if nStatus == 1
	// samo otvoreni nalozi
	cFilter += "rn_status <> " + Cm2Str(cZatvStatus)
else
	// samo zatvoreni nalozi
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
static function k_handler(nStatus)
local nBr_nal
local cNal_real
local cTblFilt
local cLOG_opis
	
if ( nStatus == 2 )
	if ( UPPER(CHR(Ch)) $ "ZP")
		return DE_CONT
	endif
endif
	
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
		
	// otvaranje naloga za doradu
	case (UPPER(CHR(Ch)) == "D")
		// provjeri marker
		if get_p_marker() == "P"
			// vec neko radi povrat
			MsgBeep("Nalog vec doradjuje drugi operater!#Dorada naloga onemogucena!")
			SELECT RNAL
			return DE_CONT
		endif
		
		if Pitanje(, "Otvoriti nalog radi dorade (D/N) ?", "N") == "D"
			
			nTRec := RecNo()
			nBr_nal := rnal->br_nal
			cTblFilt := DBFilter()
			set filter to
			
			if pov_nalog(nBr_nal) == 1
				MsgBeep("Nalog otvoren!")
			endif
			
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			// otvori i obradi pripremu
			ed_rnal(.t.)
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			RETURN DE_REFRESH
		endif
		
		SELECT RNAL
		RETURN DE_CONT

	// zatvaranje naloga
	case (UPPER(CHR(Ch)) == "Z")
		
		if get_p_marker() == "P"
			MsgBeep("Neko doradjuje ovaj nalog! #Zatvaranje onemoguceno!")
			select RNAL
			return DE_CONT
		endif
			
		if Pitanje(, "Zatvoriti nalog (D/N) ?", "N") == "D"
					
			g_nal_status(@cNal_real)
			nTRec := RecNo()
			nBr_nal := rnal->br_nal
			cTblFilt := DBFilter()
			set filter to
			if z_rnal(nBr_nal, "", cNal_real) == 1
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
		nBr_nal := rnal->br_nal
		frm_lst_rnlog(nBr_nal)
		RETURN DE_CONT

	// promjene na nalogu
	case (UPPER(CHR(Ch)) == "P" )
		if get_p_marker() == "P"
			MsgBeep("Neko vec doradjuje ovaj nalog!#Promjene onemogucene!")
			return DE_CONT
		endif
		
		nBr_nal := rnal->br_nal
		m_prom(nBr_nal)
		select rnal
		return DE_CONT

endcase

return DE_CONT


// ------------------------------------------------
// setuj status naloga realizovan, ponisten
// ------------------------------------------------
static function g_nal_status(cNalStatus)
cNalStatus := "R"
Beep(2)
Box(,4, 50)
	@ m_x + 1, m_y + 2 SAY "Trenutni status naloga je:"
	@ m_x + 2, m_y + 2 SAY "   - realizovan (R)"
	@ m_x + 3, m_y + 2 SAY "   -   ponisten (X)"
	@ m_x + 4, m_y + 2 SAY "postavi trenutni status na:" GET cNalStatus VALID val_kunos(cNalStatus, "RX") PICT "@!"
	read
BoxC()

return


// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol, nStatus)
aImeKol := {}

AADD(aImeKol, {"Nalog br.", {|| br_nal }, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Partner", {|| PADR(s_partner(idpartner), 30) }, "idpartner", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Datum", {|| datnal }, "datnal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp." , {|| datisp }, "datisp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp." , {|| vr_isp }, "vr_isp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Placanje" , {|| PADR(s_placanje(vr_plac),10) }, "vr_plac", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Hitnost" , {|| PADR(s_hitnost(hitnost),10) }, "hitnost", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return





