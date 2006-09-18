#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


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
cFooter := " Pregled lista statusa naloga... "

Box(, 20, 77)

set_box_dno()

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

// prikazi opis na formi
//s_log_opis_on_form()

do case
	// browse...
	case (Ch == K_UP .or. Ch == K_DOWN) 
		s_log_opis_on_form()
		return DE_REFRESH
		
	// stampa liste log-a
	case (Ch == K_CTRL_P)
		if Pitanje(, "Stampati liste promjena (D/N) ?", "D") == "D"
			// stampa liste
			return DE_CONT
		endif
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

// --------------------------------------------
// prikaz akcije promjene
// --------------------------------------------
static function s_prom_akcija(cAkc)
local xRet:=""
do case
	case cAkc == "+"
		xRet := "dodavanje"
	case cAkc == "-"
		xRet := "brisanje"
	case cAkc == "E"
		xRet := "ispravka"
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


