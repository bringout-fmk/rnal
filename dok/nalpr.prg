#include "\dev\fmk\rnal\rnal.ch"

static LEN_IT_NO := 6
static LEN_DESC := 60

static LEN_TOTAL := 99
static LEN_CUSTOMER := 35
static LEN_CONTACT := 35
static LEN_DATE := 34

static LEN_AOP := 40
static LEN_AOP_ATT := 70

static LEN_QTTY := 8
static LEN_DIMENSION := 10
static LEN_VALUE := 12

static DEC_QTTY := 2
static DEC_DIMENSION := 2 
static DEC_VALUE := 2

static PIC_QTTY := ""
static PIC_VALUE := ""
static PIC_DIMENSION := ""

static LEN_PAGE := 58

static RAZMAK := 0

static nPage := 0
static lPrintedTotal := .f.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0


// ------------------------------------------------------
// glavna funkcija za poziv stampe naloga za proizvodnju
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
function nalpr_print( lStartPrint )

// ako je nil onda je uvijek .t.
if ( lStartPrint == nil )
	lStartPrint := .t.
endif

PIC_QTTY := PIC_KOL()
PIC_VALUE := PIC_IZN()
PIC_DIMENSION := PIC_DIM()

LEN_QTTY := LEN(PIC_QTTY)
LEN_VALUE := LEN(PIC_VALUE)
LEN_DIMENSION := LEN(PIC_DIMENSION)

// razmak ce biti
RAZMAK := SPACE(gDl_margina)

t_rpt_open()

select t_docit
go top

// stampaj nalog
p_a4_nalpr( lStartPrint )

return


// -----------------------------------
// stampa naloga za proizvodnju
// -----------------------------------
function p_a4_nalpr(lStartPrint)
local lShow_zagl

nDuzStrKorekcija := 0
lPrintedTotal := .f.

if lStartPrint

	if !StartPrint(nil, nil)
		close all
		return
	endif

endif


nTTotal := VAL(g_t_pars_opis("N10"))

// zaglavlje naloga za proizvodnju
nalpr_header()

// podaci kupac i broj dokumenta itd....
nalpr_kupac()

cLine := g_line()

// setuj len_ukupno
LEN_TOTAL := LEN( cLine )

select t_docit
set order to tag "1"
go top

P_COND

// print header tabele
s_tbl_header()

select t_docit
set order to tag "1"

nPage := 1
aArtDesc := {}

// stampaj podatke 
do while !EOF()
	
	cDoc_no := docno_str( field->doc_no )
	cDoc_it_no := docit_str( field->doc_it_no )
	cArt_desc := ALLTRIM( field->art_desc )
	
	? RAZMAK
	
	// r.br
	?? PADL(cDoc_it_no + ")", LEN_IT_NO)
	
	?? " "
	
	?? SPACE(LEN_IT_NO)
	
	?? " "
	
	// proizvod, naziv robe, jmj
	?? PADR(cArt_desc, LEN_DESC) 
	
	?? " "

	?? show_number(field->doc_it_qtty, PIC_QTTY)

	?? " "

	?? show_number(field->doc_it_heigh, PIC_DIMENSION)

	?? " "

	?? show_number(field->doc_it_width, PIC_DIMENSION)
	
	// provjeri za novu stranicu
	if prow() > LEN_PAGE - DSTR_KOREKCIJA()
		++ nPage
		Nstr_a4(nPage, .t.)
    	endif	

	SELECT t_docit
	skip
enddo

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++nPage
	Nstr_a4(nPage, .t.)
endif	

? cLine

?
s_nal_izdao()
?
s_nal_footer()

if lStartPrint
	FF
	EndPrint()
endif

return



// stampa potpisa nalog izdao
static function s_nal_izdao()
local cPom

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

// nalog izdao

cPom := "Nalog izdao: "
cPom += REPLICATE("_", 30)
cPom += " "
cPom += "Vrijeme: "
cPom += REPLICATE("_", 20)

? PADL(cPom, LEN_TOTAL)

return


// ----------------------------------------
// nalog footer...
// ----------------------------------------
static function s_nal_footer()
local cPom
local cPayDesc := ""

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

cPayDesc := g_t_pars_opis("N06")

// footer
// vrsta placanja
? RAZMAK + "Vrsta placanja: " + cPayDesc
?

// konacan proizvod
cPom := "Konacan proizvod:"
? RAZMAK + SPACE(30) + PADR(cPom,  40)
cPom := PADR("VALIDAN", 20)
cPom += PADR("NIJE VALIDAN", 20)
? RAZMAK + SPACE(30) + PADR(cPom, 40)
cPom := PADR(REPLICATE("_", 18), 20)
cPom += PADR(REPLICATE("_", 18), 20)
? RAZMAK + SPACE(30) + PADR(cPom, 40)

? 

// ovjerio
cPom := "Ovjerio poslovodja: "
cPom += REPLICATE("_", 20)
cPom += " "
cPom += "Vrijeme: "
cPom += REPLICATE("_", 10)

? RAZMAK + SPACE(30) + cPom

return



// -----------------------------------------
// zaglavlje glavne tabele sa stavkama
// -----------------------------------------
static function s_tbl_header()
local cLine
local cRow1

cLine := g_line()

? cLine

cRow1 := RAZMAK 
cRow1 += PADC("R.br", LEN_IT_NO + LEN_IT_NO + 1) 
cRow1 += " " + PADR("Artikal", LEN_DESC)
cRow1 += " " + PADC("kolicina", LEN_QTTY)
cRow1 += " " + PADC("Sirina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("Visina(mm)", LEN_DIMENSION)

? cRow1

? cLine

return


// -----------------------------------------
// funkcija za ispis headera
// -----------------------------------------
function nalpr_header()
local cDLHead 
local cSLHead 
local cINaziv
local cRazmak := SPACE(2)

// naziv
cINaziv  := ALLTRIM(gFNaziv)

// double line header
cDLHead := REPLICATE("=", 60)

// single line header
cSLHead := REPLICATE("-", LEN(gFNaziv))

// prvo se pozicioniraj na g.marginu
for i:=1 to gDg_margina
	?
next

p_line(cRazmak + cDlhead, 10, .t.)
p_line(cRazmak + cINaziv, 10, .t.)
p_line(cRazmak + cDlhead, 10, .t.)

?

return



// ----------------------------------------------
// definicija linije za glavnu tabelu sa stavkama
// ----------------------------------------------
static function g_line()
local cLine

cLine := RAZMAK
cLine += REPLICATE("-", LEN_IT_NO + LEN_IT_NO + 1) 
cLine += " " + REPLICATE("-", LEN_DESC)
cLine += " " + REPLICATE("-", LEN_QTTY)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)

return cLine



// ----------------------------------------------
// funkcija za ispis podataka o kupcu
// dokument, datumi, hitnost itd..
// ----------------------------------------------
static function nalpr_kupac()
local cNalprNaziv := "NALOG ZA PROIZVODNJU br."
local cDatNal
local cDatIsp
local cVrIsp
local cPrioritet
local cNarNaz
local cNarAdr
local cNarTel
local cNarFax
local cNarMjesto
local cNarIdBroj
local cBr_nal
local cRazmak := SPACE(2)

// sve se iscitava iz T_PARS

// podaci naloga
cBr_nal := g_t_pars_opis("N01")
cDatNal := g_t_pars_opis("N02")
cDatIsp := g_t_pars_opis("N03")
cVrIsp := g_t_pars_opis("N04")
cPrioritet := g_t_pars_opis("N05")

// podaci partnera
cNarId := g_t_pars_opis("P01")
cNarNaz := g_t_pars_opis("P02")
cNarAdr := g_t_pars_opis("P03")
cNarTel := g_t_pars_opis("P04")


// broj naloga
cPom := cNalPrNaziv + cBr_nal
p_line(cRazmak + cPom, 10, .t.)

B_OFF

// ostali podaci naloga
cPom := "Datum naloga: " + cDatNal
cPom += " Datum isporuke: " + cDatIsp
cPom += " Vrijeme isporuke: " + cVrIsp
cPom += " Prioritet: " + cPrioritet
p_line(cRazmak + SPACE(1) + cPom, 12, .f.)

?

// kupac - naziv
cPom := "Narucioc: " + cNarNaz
p_line( cRazmak + cPom, 12, .f.)

// adresa i mjesto
cPom := "adresa: " + ALLTRIM(cNarAdr) 
p_line( cRazmak + SPACE(1) + cPom, 12, .f. )

cKTelFax := "-"
// telefon
cPom := ALLTRIM(cNarTel)
if !EMPTY(cPom)
	cKTelFax := "tel: " + cPom
endif
if !EMPTY(cKTelFax)
	p_line( cRazmak + SPACE(1) + cKTelFax, 12, .f.)
endif

?

return



// -----------------------------------------
// funkcija za novu stranu
// -----------------------------------------
function NStr_a4(nPage, lShZagl)
local cLine

cLine := g_line()

// korekcija duzine je na svako strani razlicita
nDuzStrKorekcija := 0 

P_COND
? cLine
p_line( "Prenos na sljedecu stranicu", 17, .f. )
? cLine

FF

P_COND
? cLine
if nPage <> nil
	p_line( "       Strana:" + str(nPage, 3), 17, .f.)
endif

return


// --------------------------------
// korekcija za duzinu strane
// --------------------------------
function DSTR_KOREKCIJA()
local nPom

nPom := ROUND(nDuzStrKorekcija, 0)
if ROUND(nDuzStrKorekcija - nPom, 1) > 0.2
	nPom ++
endif

return nPom

return


