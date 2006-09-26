#include "\dev\fmk\rnal\rnal.ch"

static LEN_RBR := 6
static LEN_NAZIV := 60

static LEN_UKUPNO := 99
static LEN_KUPAC := 35
static LEN_DATUM := 34

static LEN_RNOP := 40
static LEN_RNKA := 70

static LEN_KOLICINA := 8
static LEN_DIMENZIJA := 10
static LEN_VRIJEDNOST := 12

static DEC_KOLICINA := 2
static DEC_DIMENZIJA := 2 
static DEC_VRIJEDNOST := 2

static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_DIMENZIJA := ""

static LEN_STRANICA := 58

static RAZMAK := 0

static nStr := 0
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

PIC_KOLICINA := PIC_KOL()
PIC_VRIJEDNOST := PIC_IZN()
PIC_DIMENZIJA := PIC_DIM()

LEN_KOLICINA := LEN(PIC_KOLICINA)
LEN_VRIJEDNOST := LEN(PIC_VRIJEDNOST)
LEN_DIMENZIJA := LEN(PIC_DIMENZIJA)

// razmak ce biti
RAZMAK := SPACE(gDl_margina)

LEN_NAZIV(53)

t_prn_open()

select t_rnst
go top

// stampaj nalog
p_a4_nalpr( lStartPrint )

return


// -----------------------------------
// stampa naloga za proizvodnju
// -----------------------------------
function p_a4_nalpr(lStartPrint)
local nBr_nal
local nR_br
local dDatnal
local dDatisp
local cProizId
local cProizNaz
local cSirovNaz
local cSirovId
local cLine
local cProizRbr
local cSirovRbr
local cOperRbr
local cProizLine
local lShow_zagl
local cCurrOper
local cOperacija
local nNUkupno

nDuzStrKorekcija := 0
lPrintedTotal := .f.

if lStartPrint

	if !StartPrint(nil, nil)
		close all
		return
	endif

endif


nNUkupno := VAL(g_t_pars_opis("N10"))

// zaglavlje naloga za proizvodnju
nalpr_header()

// podaci kupac i broj dokumenta itd....
nalpr_kupac()

cLine := g_line()
cProizLine := g_proiz_line()

// setuj len_ukupno
LEN_UKUPNO := LEN(cLine)

select t_rnst
set order to tag "br_nal"
go top

P_COND

// print header tabele
s_tbl_header()

select t_rnst
set order to tag "br_nal"

nStr:=1
aRobaNaz := {}

// stampaj podatke 
do while !EOF()
	
	cNal_br := t_rnst->br_nal
	cProizRbr := t_rnst->r_br
	cProizId := t_rnst->idproizvod
	cProizNaz := NazivDobra(t_rnst->idproizvod, t_rnst->pro_naz, t_rnst->jmj)
	? RAZMAK
	// r.br
	?? PADL(cProizRbr + ")", LEN_RBR)
	
	?? " "
	
	?? SPACE(LEN_RBR)
	
	?? " "
	
	// proizvod, naziv robe, jmj
	?? PADR(cProizNaz, LEN_NAZIV) 
	
	?? " "

	?? show_number(t_rnst->pro_kol, PIC_KOLICINA)
	
	// ispisi liniju ispod proizvoda...
	? cProizLine
	
	do while !EOF() .and. t_rnst->(br_nal + r_br + idproizvod) == cNal_br + cProizRbr + cProizId
		
		cSirovRbr := t_rnst->p_br
		cSirovId := t_rnst->idroba
		cSirovNaz := NazivDobra(t_rnst->idroba, t_rnst->roba_naz, t_rnst->jmj)

		? RAZMAK
	
		?? SPACE(LEN_RBR)
		
		?? " "
		
		?? PADL(ALLTRIM(cProizRbr) + "." + ALLTRIM(cSirovRbr) + ")", LEN_RBR)
	
		?? " "
	
		// sirovina, naziv robe, jmj
		?? PADR(cSirovNaz, LEN_NAZIV) 
	
		?? " "

		?? show_number(t_rnst->sir_kol, PIC_KOLICINA)

		?? " "

		?? show_number(t_rnst->d_sirina, PIC_DIMENZIJA)

		?? " "

		?? show_number(t_rnst->d_visina, PIC_DIMENZIJA)
		
		// instrukcije.....
		select t_rnop
		seek t_rnst->br_nal + t_rnst->r_br + t_rnst->p_br + t_rnst->idroba
		
		nOperRazmak := LEN(RAZMAK) + (LEN_RBR * 3)
		do while !EOF() .and. t_rnop->(br_nal + r_br + p_br + idroba) == t_rnst->(br_nal + r_br + p_br + idroba)
			
			? SPACE(nOperRazmak)
			?? " "
			?? ALLTRIM(t_rnop->rn_op_naz)
			?? ","
			?? ALLTRIM(t_rnop->rn_ka_naz)
			?? " = "
			?? ALLTRIM(t_rnop->rn_instr)
			
			skip
		enddo
				
		select t_rnst
		skip
	enddo
	
	// provjeri za novu stranicu
	if prow() > LEN_STRANICA - DSTR_KOREKCIJA()
		++nStr
		Nstr_a4(nStr, .t.)
    	endif	

	SELECT t_rnst
enddo

// provjeri za novu stranicu
if prow() > LEN_STRANICA - DSTR_KOREKCIJA()
	++nStr
	Nstr_a4(nStr, .t.)
endif	

? cLine

?

// stampa potpisa nalog izdao
s_nal_izdao()

?

// printanje tabele za proizvodnju
prn_pr_table()

?

// stampa footer-a
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
if prow() > LEN_STRANICA - DSTR_KOREKCIJA()
	++nStr
	Nstr_a4(nStr, .t.)
endif	

// nalog izdao

cPom := "Nalog izdao: "
cPom += REPLICATE("_", 30)
cPom += " "
cPom += "Vrijeme: "
cPom += REPLICATE("_", 20)

? PADL(cPom, LEN_UKUPNO)

return


// stampa potpisa nalog izdao
static function s_nal_footer()
local cPom
local cVrstaP:=""

// provjeri za novu stranicu
if prow() > LEN_STRANICA - DSTR_KOREKCIJA()
	++nStr
	Nstr_a4(nStr, .t.)
endif	

cVrstaP := g_t_pars_opis("N06")

// footer
// vrsta placanja
? RAZMAK + "Vrsta placanja: " + cVrstaP
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
local cRed1:=""
local cRed2:=""
local cRed3:=""

cLine := g_line()

? cLine

cRed1 := RAZMAK 
cRed1 += PADC("R.br", LEN_RBR + LEN_RBR + 1) 
cRed1 += " " + PADR("Proizvod/sirovina/usluga", LEN_NAZIV)
cRed1 += " " + PADC("kolicina", LEN_KOLICINA)
cRed1 += " " + PADC("Sirina(mm)", LEN_DIMENZIJA)
cRed1 += " " + PADC("Visina(mm)", LEN_DIMENZIJA)

? cRed1

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
cLine += REPLICATE("-", LEN_RBR + LEN_RBR + 1) 
cLine += " " + REPLICATE("-", LEN_NAZIV)
cLine += " " + REPLICATE("-", LEN_KOLICINA)
cLine += " " + REPLICATE("-", LEN_DIMENZIJA)
cLine += " " + REPLICATE("-", LEN_DIMENZIJA)

return cLine


// ----------------------------------------------
// definicija linije za podvlacenje proizvoda
// ----------------------------------------------
static function g_proiz_line()
local cLine

cLine := RAZMAK
cLine += REPLICATE("-", LEN_RBR + 1 + LEN_RBR + 1 + LEN_NAZIV + 1 + LEN_KOLICINA)

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
cNarMjesto := g_t_pars_opis("P04")
cNarPtt := g_t_pars_opis("P05")
cNarTel := g_t_pars_opis("P06")
cNarFax := g_t_pars_opis("P07")


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
cPom := " mjesto: " + ALLTRIM(cNarMjesto)
p_line( cRazmak + SPACE(1) + cPom, 12, .f. )

cKTelFax := "-"
// telefon
cPom := ALLTRIM(cNarTel)
if !EMPTY(cPom)
	cKTelFax := "tel: " + cPom
endif
// fax
cPom := ALLTRIM(cNarTel)
if !EMPTY(cPom)
	cKTelFax += " fax: " + cPom
endif
if !EMPTY(cKTelFax)
	p_line( cRazmak + SPACE(1) + cKTelFax, 12, .f.)
endif

?

return



// -----------------------------------------
// funkcija za novu stranu
// -----------------------------------------
function NStr_a4(nStr, lShZagl)
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
if nStr <> nil
	p_line( "       Strana:" + str(nStr, 3), 17, .f.)
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



// --------------------------------------
// print tabele za proizvodnju
// --------------------------------------
static function prn_pr_table()
local nTblDuz := 130
local cZagl
local cLine
local aCols:={}

aCols := a_pr_cols()
cCols := g_pr_cols(aCols)

cLine := REPLICATE("=", nTblDuz)

? "Naradni dio naloga popunjava proizvodnja nakon obrade:"
? cLine
? cCols
? cLine
?
?
?
?
? cLine

return




// ---------------------------------------------------
// setovanje matrice sa kolonama i velicinama
// ---------------------------------------------------
static function a_pr_cols()
local aArr:={}

AADD(aArr, { "Pogon" , 10 })
AADD(aArr, { "R.br" , 4 })
AADD(aArr, { "Sir X Vis" , 15 })
AADD(aArr, { "Kom." , 4 })
AADD(aArr, { "Uradjeno" , 25 })
AADD(aArr, { "Skart" , 25 })
AADD(aArr, { "Vrijeme" , 7 })
AADD(aArr, { "Napomene" , 30 })

return aArr


// -------------------------------------------
// vraca string zaglavlja kolone
// -------------------------------------------
static function g_pr_cols(aArr)
local cRet := ""

for i:=1 to LEN(aArr)
	cRet += PADC( aArr[i, 1], aArr[i, 2] )
	cRet += "*"
next

return cRet



