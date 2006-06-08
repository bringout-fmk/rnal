#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------
// lista azuriranih naloga
// ------------------------------
function frm_lst_nalog()

o_rnal(.f.)

if tbl_lista() == 1
	return
else
	MsgBeep("report: lista naloga...")
	//rpt_lista()
endif

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_lista()
local cFooter
local nArea
local cFilter 

if lst_uslovi( @cFilter ) == 2
	return 2
endif

private ImeKol
private Kol

cFooter := "Pregled azuriranih naloga..."
nArea := F_RNAL

Box(, 20, 77)
@ m_x + 19, m_y + 2 SAY "<ENT> Stampa naloga   | <O> Stampa otpremnice  | ??? "
@ m_x + 20, m_y + 2 SAY "<a-P> Povrat naloga   | ???                    | ??? "

select (nArea)
set order to tag "br_nal"
go top

set_a_kol(@ImeKol, @Kol)

ObjDbedit("lstnal", 20, 77, {|| k_handler(cFilter) }, "", cFooter, , , , , 2)

BoxC()

close all
return 1



// -------------------------------------------------
// otvori formu sa uslovima te postavi filtere
// -------------------------------------------------
static function lst_uslovi( cFilter )
local nX := 2
local dDatOd := CToD("")
local dDatDo := DATE()
local cPartNaz := SPACE(40)
local cPartSif := SPACE(40)
local cTblLista := "D"
local nRet := 1

Box( ,10, 60)
	
@ m_x + nX, m_y + 2 SAY "Datum od " GET dDatOd
@ m_x + nX, col() + 2 SAY "do" GET dDatDo

nX += 2

@ m_x + nX, m_y + 2 SAY "Ime partnera pocinje sa (prazno svi) " GET cPartNaz PICT "@S20"

nX += 1

@ m_x + nX, m_y + 2 SAY "Uslov po sifri partnera (prazno svi) " GET cPartSif PICT "@S20"

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

gen_filter(@cFilter, dDatOd, dDatDo, cPartNaz, cPartSif)

set_f_kol(cFilter)

return nRet



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter(cFilter, dDatOd, dDatDo, cPartNaz, cPartSif)

cFilter := "r_br = 1"

if !EMPTY(dDatOd)
	cFilter += " .and. datnal >= " + Cm2Str(dDatOd)
endif
if !Empty(dDatDo)
	cFilter += " .and. datnal <= " + Cm2Str(dDatDo)
endif

return



// ------------------------------------------------
// setovanje filtera prema uslovima
// ------------------------------------------------
static function set_f_kol(cFilter)
select rnal
set order to tag "br_nal"
set filter to &cFilter
go top

return



// ---------------------------------------------
// pregled - key handler
// ---------------------------------------------
static function k_handler(cFilter)
local nBr_nal

do case

	case (Ch == K_ENTER)
		if Pitanje(, "Stampati nalog (D/N) ?", "D") == "D"
			nBr_nal := rnal->br_nal
			nTRec := RecNo()
			stamp_nalog( .t., nBr_nal )
			SELECT RNAL
			set_f_kol(cFilter)
			GO (nTRec)
			return DE_REFRESH
		endif
		SELECT RNAL
		return DE_CONT
			
	case ( UPPER(CHR(Ch)) == "O")
		MsgBeep("stampa otpremnice")
		RETURN DE_CONT
	
	case (Ch == K_ALT_P)
		if Pitanje(, "Nalog povuci u pripremu ?", "N") == "D"
			nTRec := RecNo()
			nBr_nal := rnal->br_nal
			set filter to
			if pov_nalog(nBr_nal) == 1
				MsgBeep("Nalog se nalazi u pripremi !")
			endif
			SELECT RNAL
			set_f_kol(cFilter)
			GO (nTRec)
			RETURN DE_REFRESH
		endif
		SELECT RNAL
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


