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
AADD(aImeKol, {"Tip" , {|| tip }, "tip", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Akcija" , {|| akcija }, "akcija", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return

// --------------------------------------------
// prikaz opisa statusa u tabeli rnlog
// --------------------------------------------
static function s_status(cStatus)
local xRet:=""
do case
	case cStatus == "O"
		xRet := "OTVOREN"
	case cStatus == "R"
		xRet := "OBRADA"
	case cStatus == "Z"
		xRet := "ZATOVREN"
endcase
return xRet


// -------------------------------------------
// prikaz opisa log-a na formi
// -------------------------------------------
static function s_log_opis_on_form()
local aOpisArr:={}
local cRow1
local cRow2
local nLenText:=76
local cOpis

cRow1 := SPACE(nLenText)
cRow2 := SPACE(nLenText)

cOpis := rnlog->log_opis

aOpisArr := SjeciStr(cOpis, nLenText)
if LEN(aOpisArr) > 0
	cRow1 := aOpisArr[1]
	if LEN(aOpisArr) == 2
		cRow2 := aOpisArr[2]
	endif
endif

// separator
@ m_x + 16, m_y + 2 SAY PADR("OPIS STAVKE", nLenText)
// prvi red
@ m_x + 17, m_y + 2 SAY SPACE(nLenText)
@ m_x + 17, m_y + 2 SAY PADR(cRow1, nLenText) COLOR "I"
// drugi red
@ m_x + 18, m_y + 2 SAY SPACE(nLenText)
@ m_x + 18, m_y + 2 SAY PADR(cRow2, nLenText) COLOR "I"

return

