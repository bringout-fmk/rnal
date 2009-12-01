#include "rnal.ch"


static LEN_IT_NO := 4
static LEN_DESC := 65

static LEN_QTTY := 10
static LEN_DIMENSION := 10
static LEN_VALUE := 10

static PIC_QTTY := "9999999.99"
static PIC_VALUE := "9999999.99"
static PIC_DIMENSION := "9999999.99"

static LEN_PAGE := 58

static RAZMAK := " "

static nPage := 0
static lPrintedTotal := .f.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0


// ----------------------------------------------
// definicija linije za glavnu tabelu sa stavkama
// nVar - 1 = nalog
//        2 = obracunski list
// ----------------------------------------------
static function g_line( )
local cLine

// linija za obraèunski list
cLine := RAZMAK
cLine += REPLICATE("-", 10 ) 
cLine += " " + REPLICATE("-", LEN_IT_NO ) 
cLine += " " + REPLICATE("-", LEN_DESC)
cLine += " " + REPLICATE("-", LEN_QTTY)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_VALUE)
cLine += " " + REPLICATE("-", LEN_VALUE)
cLine += " " + REPLICATE("-", LEN_VALUE)

return cLine



// ------------------------------------------------------
// glavna funkcija za poziv stampe obracunskog lista
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
function obrl_print( lStartPrint )

// ako je nil onda je uvijek .t.
if ( lStartPrint == nil )
	lStartPrint := .t.
endif

LEN_QTTY := LEN(PIC_QTTY)
LEN_VALUE := LEN(PIC_VALUE)
LEN_DIMENSION := LEN(PIC_DIMENSION)

// razmak ce biti
RAZMAK := SPACE(gDl_margina)
// nek je razmak 1
RAZMAK := SPACE(1)

t_rpt_open()

select t_docit
go top

// stampaj obracunski listic
p_a4_obrl( lStartPrint )

return


// -----------------------------------
// stampa obracunskog lista...
// -----------------------------------
function p_a4_obrl(lStartPrint)
local lShow_zagl
local i

nDuzStrKorekcija := 0
lPrintedTotal := .f.

if lStartPrint

	if !StartPrint(nil, nil)
		close all
		return
	endif

endif

nTTotal := VAL(g_t_pars_opis("N10"))

// zaglavlje 
obrl_header()

cLine := g_line(2)

// broj dokumenta.....
cDoc_no := g_t_pars_opis("N01")
cDoc_date := g_t_pars_opis("N02")
cDoc_time := g_t_pars_opis("N12")
cDocs := g_t_pars_opis("N14")
cCust := g_t_pars_opis("P02")
cObject := g_t_pars_opis("P21")

// setuj len_ukupno
LEN_TOTAL := LEN( cLine )

? RAZMAK + "SPECIFIKACIJA, " 

if "," $ cDocs
	
	?? "prema nalozima:" + cDocs
	
else
	
	?? "prema nalogu br.:" + cDoc_no
	? RAZMAK + "Datum naloga: " + cDoc_date + ", vrijeme naloga: " + cDoc_time
endif

// kupac, objekat
? RAZMAK + "Kupac: " + ALLTRIM( cCust ) + ", obj: " + ALLTRIM( cObject )

?

select t_docit
set order to tag "1"
go top

B_OFF
// kondenzuj font
P_COND2

// print header tabele
s_tbl_header()

select t_docit
set order to tag "1"

nPage := 1
aArt_desc := {}
nArt_id := 0
nArt_tmp := 0
nUTotal := 0
nUNeto := 0
nUBruto := 0
nUQty := 0
nUHeig := 0
nUWidt := 0
nUZHeig := 0
nUZWidt := 0

cDocXX := "XX"

// stampaj podatke 
do while !EOF()

	// da li se stavka stampa ili ne ?
	if field->print == "N"
		skip
		loop
	endif
	
	nDoc_no := field->doc_no
	nArt_id := field->art_id
	
	cDoc_no := docno_str( field->doc_no )
	cDoc_it_no := docit_str( field->doc_it_no )
	
	nQty := field->deliver
	nHeig := field->doc_it_height
	nWidt := field->doc_it_width
	
	nZaHeig := field->doc_it_zheigh
	nZaWidt := field->doc_it_zwidth

	nNeto := field->doc_it_neto
	nBruto := field->doc_it_bruto
	
	nTotal := field->doc_it_total

	nUTotal += nTotal
	nUNeto += nNeto
	nUBruto += nBruto
	nUQty += nQty
	nUHeig += nHeig
	nUWidt += nWidt
	nUZHeig += nZaHeig
	nUZWidt += nZaWidt

	if EMPTY( field->art_desc )
		cArt_desc := "-//-"
	else
		cArt_desc := ALLTRIM( field->art_desc )
	endif
	
	aArt_desc := SjeciStr( cArt_desc, LEN_DESC )	
	
	// ------------------------------------------
	// prvi red...
	// ------------------------------------------
	
	if cDocXX <> cDoc_no

		? RAZMAK
	
		// nalog broj
		?? "stavke naloga broj: " + ALLTRIM( cDoc_no )
	
	endif

	? RAZMAK + SPACE(10)

	// r.br
	?? PADL(ALLTRIM(cDoc_it_no) + ")", LEN_IT_NO)
	
	?? " "
	
	// proizvod, naziv robe, jmj
	?? aArt_desc[1]
	?? " "
	
	// kolicina
	?? show_number(nQty, nil, -10 )
	?? " "
	
	// sirina
	?? show_number(nWidt, nil, -10 )
	?? " "

	// visina
	?? show_number(nHeig, nil, -10 )
	?? " "

	// zaokruzenja po GN-u
	
	// sirina
	?? show_number(nZaWidt, nil, -10 )
	?? " "
	
	// visina
	?? show_number(nZaHeig, nil, -10 )
	?? " "

	// neto
	?? show_number(nNeto, nil, -10 )
	?? " "

	// bruto
	?? PADR( "_", 10 , "_")
	?? " "

	// ukupno m2
	?? show_number(nTotal, nil, -10 )

	// provjeri za novu stranicu
	if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	
		++ nPage
		Nstr_a4(nPage, .t.)
		
    		P_COND2
	
	endif	

	// ostatak naziva artikla....
	if LEN(aArt_desc) > 1
		
		for i:=2 to LEN(aArt_desc)
		
			? RAZMAK
			
			?? PADL("", 10)
			
			?? " "

			?? PADL("", LEN_IT_NO)
			
			?? " "
			
			?? aArt_desc[i]
		
			// provjeri za novu stranicu
			if prow() > LEN_PAGE - DSTR_KOREKCIJA()
				++ nPage
				Nstr_a4(nPage, .t.)
				P_COND2
			endif	
		next
		
	endif
	
	cDocXX := cDoc_no

	select t_docit
	skip

enddo

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++nPage
	Nstr_a4(nPage, .t.)
	P_COND2
endif	

? cLine

? RAZMAK
	
// r.br
?? PADL( "U K U P N O : ", LEN_IT_NO + 11 + LEN_DESC )
	
?? " "
	
// kolicina
?? show_number(nUQty, nil, -10 )
?? " "
	
// sirina
?? show_number(nUWidt, nil, -10 )
?? " "

// visina
?? show_number(nUHeig, nil, -10 )
?? " "

// zaokruzenja po GN-u
	
// sirina
?? show_number(nUZWidt, nil, -10 )
?? " "
	
// visina
?? show_number(nUZHeig, nil, -10 )
?? " "

// neto
?? show_number(nUNeto, nil, -10 )
?? " "

// bruto
?? PADR( "_", 10 , "_" )
?? " "

// ukupno m2
?? show_number(nUTotal, nil, -10 )

? cLine

// prikazi GN tabelu.....
s_gn_tbl()

// prikazi rekapitulaciju dodatnog repromaterijala
s_nal_rekap( nDoc_no, .t. )

P_10CPI

s_obrl_footer()

if lStartPrint
	FF
	EndPrint()
endif

return


// ---------------------------------------------
// prikaz GN tabele
// ---------------------------------------------
static function s_gn_tbl()
local aGn := {}
local cLine := SPACE(1) + REPLICATE("-", 125)
local cTxt := SPACE(1) + "GN tabela (izrazena u mm):"
local i
local nTmp
local nTmp2
local nX
local nY
local nX_pos
local nY_pos

// napuni gn matricu
aGn := arr_gn()

P_COND2

?
? cLine
? cTxt
? cLine

for i := 1 to LEN( aGn )
	
	if i = 1
		? SPACE(1)
	endif
	
	if i%25 = 0
		? SPACE(1)
	endif	

	@ prow(), pcol() + 1 SAY ;
		PADL( ALLTRIM( STR( aGn[ i, 1 ] )), 4 )

next

? cLine


return



// ----------------------------------------
// footer obracunskog lista
// ----------------------------------------
static function s_obrl_footer()
local cPom 

cPom := "Izdao: _________________"
cPom += SPACE(10)
cPom += "Primio: _________________"


// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

?
? RAZMAK + SPACE(5) + cPom

return



// -----------------------------------------
// zaglavlje glavne tabele sa stavkama
// -----------------------------------------
static function s_tbl_header()
local cLine
local cRow1
local cRow2

cLine := g_line(2)

? cLine

cRow1 := RAZMAK 
cRow2 := RAZMAK

cRow1 += PADC("nalog", 10)
cRow2 += PADC("broj", 10)

cRow1 += " " + PADC("r.br", LEN_IT_NO) 
cRow2 += " " + PADC(SPACE(4), LEN_IT_NO)

cRow1 += " " + PADR("Artikal (naziv,jmj)", LEN_DESC)
cRow2 += " " + PADR(" ", LEN_DESC )

cRow1 += " " + PADC("Kol.", LEN_QTTY)
cRow2 += " " + PADC(" ", LEN_QTTY)

cRow1 += " " + PADC("Sirina", LEN_DIMENSION)
cRow2 += " " + PADC("(mm)", LEN_DIMENSION)

cRow1 += " " + PADC("Visina", LEN_DIMENSION)
cRow2 += " " + PADC("(mm)", LEN_DIMENSION)

cRow1 += " " + PADC("Sir.GN", LEN_DIMENSION)
cRow2 += " " + PADC("(mm)", LEN_DIMENSION)

cRow1 += " " + PADC("Vis.GN", LEN_DIMENSION)
cRow2 += " " + PADC("(mm)", LEN_DIMENSION)

cRow1 += " " + PADC("Netto", LEN_VALUE)
cRow2 += " " + PADC("(kg)", LEN_DIMENSION)

cRow1 += " " + PADC("Bruto", LEN_VALUE)
cRow2 += " " + PADC("(kg)", LEN_DIMENSION)

cRow1 += " " + PADC("Ukupno", LEN_VALUE)
cRow2 += " " + PADC("(m2)", LEN_DIMENSION)

? cRow1
? cRow2

? cLine

return


// -----------------------------------------
// funkcija za ispis headera
// -----------------------------------------
static function obrl_header()
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




