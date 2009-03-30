#include "rnal.ch"


// ------------------------------------------------
// otvara TBrowse objekat nad tabelom za stampu
// 
// ------------------------------------------------
function sel_items()
local nArea
local nTArea
local GetList:={}
local nBoxX := 12
local nBoxY := 77
local cHeader := ""
local cFooter := ""
local cBoxOpt := ""
private ImeKol
private Kol

nTArea := SELECT()

cHeader := ":: Odabir stavki za stampu ::"

t_rpt_open()

select t_docit
go top

Box(, nBoxX, nBoxY, .t.)

cBoxOpt += "<SPACE> markiranje stavke"
cBoxOpt += "    "
cBoxOpt += "<ESC> izlaz"

@ m_x + nBoxX, m_y + 2 SAY cBoxOpt

set_a_kol(@ImeKol, @Kol)

ObjDbedit("t_docit", nBoxX, nBoxY, {|| key_handler()}, cHeader, cFooter,,,,,1)

BoxC()

select (nTArea)

if LastKey() == K_ESC
	return 1
endif

return 1
  


// ------------------------------------------
// key handler nad tabelom
// ------------------------------------------
static function key_handler()
local nTRec := RECNO()
local nRet := DE_CONT

do case
	case (Ch == ASC(' '))
		Beep(0.5)
		if field->print == "D"
			replace field->print with "N"
		else
			replace field->print with "D"
		endif
		return DE_REFRESH
endcase


return nRet


// -------------------------------------------------------
// setovanje kolona za selekciju
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol:={}

AADD(aImeKol, {"stavka", {|| doc_it_no }, "doc_it_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"artikal", {|| g_art_desc(art_id,.t.,.f.) }, "art_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"dim." , {|| _g_dim(doc_it_qtty, doc_it_height, doc_it_width) }, "doc_it_qtty", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"marker", {|| _g_st(print) }, "print", {|| .t.}, {|| .t.} })


for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// -------------------------------------------------
// vraca ispis status polja
// -------------------------------------------------
static function _g_st( cVal )
local cRet := ""

cRet := ">> "
cRet += cVal
cRet += " <<"

return cRet


// ---------------------------------------------------
// ispisuje opis dimenzija
// ---------------------------------------------------
static function _g_dim( nQtty, nH, nW )
local cRet := ""

cRet += ALLTRIM(STR(nQtty,12,0))
cRet += " x "
cRet += ALLTRIM(STR(nH,12,2))
cRet += " x "
cRet += ALLTRIM(STR(nW,12,2))

return cRet



