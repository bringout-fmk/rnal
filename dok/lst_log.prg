#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// lista log tabele za nalog
// nBr_nal - broj naloga
// ------------------------------------------
function frm_lst_rnlog(nBr_nal)
local nTArea

nTArea := SELECT()

o_rnal(.f.)
tbl_lista(nBr_nal)

select (nTArea)

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_lista(nBr_nal)
local cFooter
local cHeader

private ImeKol
private Kol

cHeader := " Nalog broj: " + STR(nBr_nal, 10, 0) + " "
cFooter := " Pregled promjena na nalogu... "

Box(, 20, 77)

//set_box_dno()

select rnlog
set_f_kol(nBr_nal)
set order to tag "br_nal"
go top

set_a_kol(@ImeKol, @Kol)

Beep(2)

ObjDbedit("lstlog", 20, 77, {|| k_handler(nBr_nal) }, cHeader, cFooter, , , , , 5)

BoxC()

return


// ------------------------------------------
// setovanje dna boxa
// ------------------------------------------
static function set_box_dno()
local cLine1 := ""
local cLine2 := ""
local nOpcLen := 24
local cOpcSep := "|"

cLine1 := PADR("<ESC> Izlaz", nOpcLen)
cLine1 += cOpcSep + " "
cLine1 += PADR("<c-P> Stampa liste", nOpcLen)

@ m_x + 20, m_y + 2 SAY cLine1

return


// ------------------------------------------------
// setovanje filtera
// nBr_nal - broj naloga
// ------------------------------------------------
static function set_f_kol(nBr_nal)
local cFilter 

cFilter := "br_nal == " + STR(nBr_nal, 10, 0)
select rnlog
set filter to &cFilter

return



// ---------------------------------------------
// pregled - key handler
// ---------------------------------------------
static function k_handler(nBr_nal)
local nTblFilt

do case
	
	// stampa liste log-a
	case (Ch == K_CTRL_P)
		if Pitanje(, "Stampati liste promjena (D/N) ?", "D") == "D"
			// stampa liste
			return DE_CONT
		endif
		SELECT RNLOG
		return DE_CONT
	
	// info - promjena
	case ( UPPER(CHR(Ch)) == "I" ) 
		pr_log_info()
		SELECT RNLOG
		return DE_CONT
		
endcase

return DE_CONT



// -------------------------------------------------------
// setovanje kolona tabele za pregled log-a
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}

AADD(aImeKol, {"Datum", {|| datum }, "datum", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vrijeme" , {|| PADR(vrijeme, 5) }, "vrijeme", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Tip" , {|| PADR(s_prom_tip(tip), 15) }, "tip", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Operater" , {|| PADR(operater, 20) }, "operater", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Opis" , {|| PADR(opis, 20) }, "opis", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// --------------------------------------------
// prikaz tipa loga
// --------------------------------------------
static function s_prom_tip(cTip)
local xRet:=""
do case
	case cTip == "01"
		xRet := "otvaranje"
	case cTip == "99"
		xRet := "zatvaranje"
	case cTip == "10"
		xRet := "osn.podaci"
	case cTip == "11"
		xRet := "pod.isporuka"
	case cTip == "12"
		xRet := "kontakti"
	case cTip == "20"
		xRet := "artikli"
	case cTip == "30"
		xRet := "instrukcije"
endcase
return xRet


// -------------------------------------------
// prikaz opisa log-a na formi
// -------------------------------------------
static function s_log_opis_on_form()
local aOpisArr:={}
local cRow1
local cRow2
local cRow3
local nLenText:=76
local cOpis

cRow1 := SPACE(nLenText)
cRow2 := SPACE(nLenText)
cRow3 := SPACE(nLenText)

cOpis := g_log_opis( rnlog->br_nal, rnlog->tip )

aOpisArr := SjeciStr(cOpis, nLenText)
if LEN(aOpisArr) > 0
	cRow1 := aOpisArr[1]
	if LEN(aOpisArr) > 1
		cRow2 := aOpisArr[2]
	endif
	if LEN(aOpisArr) > 2
		cRow3 := aOpisArr[3]
	endif
endif

// separator
@ m_x + 16, m_y + 2 SAY SPACE(nLenText)
@ m_x + 16, m_y + 2 SAY PADR(cRow1, nLenText) COLOR "I"
// prvi red
@ m_x + 17, m_y + 2 SAY SPACE(nLenText)
@ m_x + 17, m_y + 2 SAY PADR(cRow2, nLenText) COLOR "I"
// drugi red
@ m_x + 18, m_y + 2 SAY SPACE(nLenText)
@ m_x + 18, m_y + 2 SAY PADR(cRow3, nLenText) COLOR "I"

return


// vraca opisno polje
static function g_log_opis(nBr_nal, cTip)
local cRet := ""
local nTArea := SELECT()
select rnlog

do case
	case cTip == "01"
		cRet := get01_stavka(nBr_nal)
	case cTip == "99"
		cRet := get99_stavka(nBr_nal)
	case cTip == "10"
		cRet := get10_stavka(nBr_nal)
	case cTip == "11"
		cRet := get11_stavka(nBr_nal)
	case cTip == "12"
		cRet := get12_stavka(nBr_nal)
	case cTip == "20"
		cRet := get20_stavka(nBr_nal)
	case cTip == "30"
		cRet := get30_stavka(nBr_nal)
endcase

select (nTArea)
return cRet


// -----------------------------------------
// prikaz info-a o promjeni
// -----------------------------------------
static function pr_log_info()
local nBr_nal
local nR_br
local cProizvod
local cTip
local cSpace := SPACE(6)
local nTArea := SELECT()

nBr_nal := rnlog->br_nal
nR_br := rnlog->r_br
cTip := s_prom_tip(rnlog->tip)

select rnlog_it
set order to tag "br_nal"
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

START PRINT CRET

sh_log_zagl()

? 

do while !EOF() .and. rnlog_it->br_nal == nBr_nal ;
		.and. rnlog_it->r_br == nR_br
	
	? STR(rnlog_it->p_br, 3, 0) + ")", ALLTRIM(rnlog_it->idroba2)
	
	? cSpace + "K1:", STR(rnlog_it->k_1, 8, 2)
	? cSpace + "K2:", STR(rnlog_it->k_2, 8, 2)
	? cSpace + "K3:", STR(rnlog_it->k_3, 8, 2)
	
	? cSpace + "N1:", STR(rnlog_it->n_1, 8, 2)
	? cSpace + "N2:", STR(rnlog_it->n_2, 8, 2)
	? cSpace + "N3:", STR(rnlog_it->n_3, 8, 2)
	
	? cSpace + "C1:", ALLTRIM(rnlog_it->c_1)
	? cSpace + "C2:", ALLTRIM(rnlog_it->c_2)
	? cSpace + "C3:", ALLTRIM(rnlog_it->c_3)
	
	?

	skip
enddo

FF
END PRINT

select (nTArea)

return


// ----------------------------------------
// zaglavlje prikaza info-a
// ----------------------------------------
static function sh_log_zagl()
local cLine := REPLICATE("-", 60)

? cLine
? "Proizvod: ", ALLTRIM(rnlog_it->idroba)
? "Datum promjene: ", DToC(rnlog->datum), "vrijeme promjene: ", ALLTRIM(rnlog->vrijeme)
? "Akcija: " + g_akcija_info(rnlog_it->akcija)
? cLine

return


// -------------------------------------------------
// vraca opis akcije prema oznaci cAkcija
// -------------------------------------------------
static function g_akcija_info(cAkcija)
local xRet := ""

do case 
	case cAkcija == "E"
		xRet := "ispravka stavki"
	case cAkcija == "+"
		xRet := "dodavanje stavki"
	case cAkcija == "-"
		xRet := "brisanje stavki"
endcase

return xRet


