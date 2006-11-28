#include "\dev\fmk\rnal\rnal.ch"

static LEN_IT_NO := 7
static LEN_DESC := 70

static LEN_QTTY := 12
static LEN_DIMENSION := 12
static LEN_VALUE := 12

static PIC_QTTY := "999999999.99"
static PIC_VALUE := "999999999.99"
static PIC_DIMENSION := "999999999.99"

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

// zaglavlje naloga za proizvodnju
nalpr_header()

// podaci kupac i broj dokumenta itd....
nalpr_kupac()

?

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
aArt_desc := {}

// stampaj podatke 
do while !EOF()
	
	cDoc_no := docno_str( field->doc_no )
	cDoc_it_no := docit_str( field->doc_it_no )
	cArt_desc := ALLTRIM( field->art_desc )
	
	aArt_desc := SjeciStr( cArt_desc, LEN_DESC )	
	
	// ------------------------------------------
	// prvi red...
	// ------------------------------------------
	
	? RAZMAK
	
	// r.br
	?? PADL(ALLTRIM(cDoc_it_no) + ")", LEN_IT_NO)
	
	?? " "
	
	// proizvod, naziv robe, jmj
	?? aArt_desc[1]
	
	
	if field->doc_it_heigh == 0 .and. !EMPTY(field->doc_it_desc)
		
		// prikazi opis stavke
		?? " "

		?? PADC(ALLTRIM(field->doc_it_desc), ; 
			LEN_DIMENSION + LEN_DIMENSION + 1 )
		
	else
		// prikazi prave dimenzije
	
		?? " "
	
		?? show_number(field->doc_it_heigh, PIC_DIMENSION)

		?? " "

		?? show_number(field->doc_it_width, PIC_DIMENSION)
	
	endif
	
	?? " "

	?? show_number(field->doc_it_qtty, PIC_QTTY)

	// provjeri za novu stranicu
	if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	
		++ nPage
		Nstr_a4(nPage, .t.)
		
    	endif	
	
	// ostatak naziva artikla....
	if LEN(aArt_desc) > 1
		
		for i:=2 to LEN(aArt_desc)
			? RAZMAK
			?? PADL("", LEN_IT_NO)
			?? ""
			?? aArt_desc[i]
		
			// provjeri za novu stranicu
			if prow() > LEN_PAGE - DSTR_KOREKCIJA()
				++ nPage
				Nstr_a4(nPage, .t.)
			endif	
		next
		
	endif

	// ako je shema u prilogu
	if field->doc_it_schema <> ""
	
		? RAZMAK
		?? PADL("", LEN_IT_NO)
		?? " "
	
		// shema
		?? "napomena: shema u prilogu"
	endif
	
	// dodatne operacije operacije....
	
	select t_docop
	set order to tag "1"
	go top
	seek docno_str(t_docit->doc_no) + docit_str(t_docit->doc_it_no)

	do while !EOF() .and. field->doc_no == t_docit->doc_no ;
			.and. field->doc_it_no == t_docit->doc_it_no

		? RAZMAK

		?? PADL("", LEN_IT_NO)

		?? " "
		
		?? "d.operacija ---> "

		?? " "
		
		if !EMPTY(field->aop_desc) .and. ALLTRIM(field->aop_desc) <> "?????"
			?? ALLTRIM(field->aop_desc)
			?? ", "
		endif

		if !EMPTY(field->aop_att_desc) .and. ALLTRIM(field->aop_att_desc) <> "?????"
			?? ALLTRIM(field->aop_att_desc)
			?? ", "
		endif
		
		if !EMPTY(field->doc_op_desc)
			?? ALLTRIM(field->doc_op_desc)
		endif
		
		select t_docop
		skip
	enddo

	select t_docit
	skip
enddo

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++nPage
	Nstr_a4(nPage, .t.)
endif	

// dodatne operacije koje vaze za sve artikle...

? cLine

select t_docit
go top

select t_docop
set order to tag "1"
go top
seek docno_str( t_docit->doc_no ) + docit_str( 0 ) 

if FOUND()
	
	?
	
	? RAZMAK 
	
	?? PADL("", LEN_IT_NO)

	?? " "
	
	?? "DODATNE OPERACIJE ZA SVE ARTIKLE:"
	
	? cLine

	nAopCnt := 0
	
	do while !EOF() .and. field->doc_it_no == 0
	
		? RAZMAK
		
		?? PADL(STR(++nAopCnt,3) + ")", LEN_IT_NO)
		
		?? " "
		
		if !EMPTY(field->aop_desc) .and. ALLTRIM(field->aop_desc) <> "?????"
			?? ALLTRIM(field->aop_desc)
			?? ", "
		endif
		
		if !EMPTY(field->aop_att_desc) .and. ALLTRIM(field->aop_att_desc) <> "?????"
			?? ALLTRIM(field->aop_att_desc)
			?? ", " 
		endif
		
		if !EMPTY(field->doc_op_desc)
			?? ALLTRIM(field->doc_op_desc)
		endif
		
		select t_docop
		skip
	enddo
	
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
cRow1 += PADC("r.br", LEN_IT_NO) 
cRow1 += " " + PADR("artikal/naziv", LEN_DESC)
cRow1 += " " + PADC("sirina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("visina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("kolicina", LEN_QTTY)

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
cLine += REPLICATE("-", LEN_IT_NO ) 
cLine += " " + REPLICATE("-", LEN_DESC)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_QTTY)

return cLine



// ----------------------------------------------
// funkcija za ispis podataka o kupcu
// dokument, datumi, hitnost itd..
// ----------------------------------------------
static function nalpr_kupac()
local cDoc_desc := "NALOG ZA PROIZVODNJU br."
local cDoc_date
local cDoc_dvr_date
local cDoc_dvr_time
local cDoc_ship_place
local cPriority
local cCust_desc
local cCust_addr
local cCust_tel
local cContId
local cCont_desc
local cCont_tel
local cContadesc
local cCont_add_desc
local cDoc_no
local cRazmak := SPACE(2)
local nLeft := 20

// get/set document data
cDoc_no := g_t_pars_opis("N01")
cDoc_date := g_t_pars_opis("N02")
cDoc_dvr_date := g_t_pars_opis("N03")
cDoc_dvr_time := g_t_pars_opis("N04")
cPriority := g_t_pars_opis("N05")
cDoc_ship_place := g_t_pars_opis("N07")
cDoc_add_desc := g_t_pars_opis("N08")

// get/set customer data
cCustId := g_t_pars_opis("P01")
cCust_desc := g_t_pars_opis("P02")
cCust_addr := g_t_pars_opis("P03")
cCust_tel := g_t_pars_opis("P04")

// get/set contacts data
cContId := g_t_pars_opis("P10")
cCont_desc := g_t_pars_opis("P11")
cCont_tel := g_t_pars_opis("P12")
cContadesc := g_t_pars_opis("P13")
cCont_add_desc := g_t_pars_opis("N09")


// broj naloga
cPom := cDoc_desc + cDoc_no
p_line(cRazmak + cPom, 10, .t.)

B_OFF

?

// doc_date + doc_dvr_date
cPom := PADL("Datum naloga: ", nLeft ) + cDoc_date + PADL("Datum isporuke: ", nLeft) + cDoc_dvr_date
p_line(cRazmak + SPACE(1) + cPom, 12, .f.)

// doc_dvr_time + priority
cPom := PADL("Vrijeme isporuke: ", nLeft) + cDoc_dvr_time + PADL("Prioritet: ", nLeft) + cPriority
p_line(cRazmak + SPACE(1) + cPom, 12, .f.)

// ship_place
cPom := PADL("Mjesto isporuke: ", nLeft) + cDoc_ship_place
p_line(cRazmak + SPACE(1) + cPom, 12, .f.)

?

// podaci narucioca

cPom := "Narucioc: "
p_line( cRazmak + cPom, 12, .f.)

// naziv, adresa, telefon
cPom := ALLTRIM(cCust_desc) + ", " + ALLTRIM(cCust_addr) + ", " + ALLTRIM("tel: " + cCust_tel)
p_line( cRazmak + SPACE(1) + cPom, 12, .f. )

?

cPom := "Kontakti: "
p_line( cRazmak + cPom, 12, .f.)

// ime, telefon, opis
cPom := ALLTRIM(cCont_desc) + " (" + ALLTRIM(cContadesc) + "), " + ALLTRIM("tel: " + cCont_tel) + ", " + ALLTRIM(cCont_add_desc)
p_line( cRazmak + SPACE(1) + cPom, 12, .f. )

?

cPom := "Ostale napomene: " + cDoc_add_desc
p_line( cRazmak + cPom, 12, .f.)

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


