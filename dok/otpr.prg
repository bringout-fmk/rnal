#include "\dev\fmk\rnal\rnal.ch"

static LEN_RBR := 6
static LEN_NAZIV := 0

static LEN_UKUPNO := 99
static LEN_KUPAC := 35
static LEN_DATUM := 34

static LEN_KOLICINA := 8
static LEN_DIMENZIJA := 10
static LEN_VRIJEDNOST := 12

static DEC_KOLICINA := 2
static DEC_DIMENZIJA := 2 
static DEC_VRIJEDNOST := 2

static PIC_PROC := "999.99"
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_DIMENZIJA := ""

static LEN_STRANICA := 58
static RAZMAK := ""

static nStr := 0
static lPrintedTotal := .f.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0


// ------------------------------------------------------
// glavna funkcija za poziv stampe otpremnice
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
function otpr_print( lStartPrint )

// ako je nil onda je uvijek .t.
if ( lStartPrint == nil )
	lStartPrint := .t.
endif

PIC_KOLICINA := PIC_KOL()
PIC_VRIJEDNOST := PIC_IZN()
PIC_DIMENZIJA := PIC_DIM()

t_prn_open()

select t_rnst
go top

LEN_NAZIV(53)
LEN_UKUPNO(99)

// stampaj nalog
p_a4_otpr( lStartPrint )

return


// stampa radnog naloga
function p_a4_otpr(lStartPrint)
local nBr_nal
local nR_br
local dDatnal
local dDatisp
local aRobaNaz
local cRobaNaz
local cLine
local lShow_zagl

nDuzStrKorekcija := 0
lPrintedTotal := .f.

if lStartPrint

	if !StartPrint(nil, nil)
		close all
		return
	endif

endif

// uzmi glavne varijable za print
//g_otpr_gvars( @lShow_zagl )

// zaglavlje otpremnice
otpr_header()

// podaci kupac i broj dokumenta itd....
otpr_kupac()

cLine := g_otp_line()

select t_rnst
set order to tag "br_nal"
go top

P_COND

// print header tabele
s_o_tbl_header()

select t_rnst
set order to tag "br_nal"

nStr:=1
aRobaNaz := {}

// stampaj podatke 
do while !EOF()
	
	// uzmi naziv u matricu
	cRobaNaz := NazivDobra(t_rnst->idroba, t_rnst->robanaz, t_rnst->jmj)
	aRobaNaz := SjeciStr(cRobaNaz, 53)
	
	// PRVI RED
	// redni broj ili podbroj
	? RAZMAK
	
	?? PADL(t_rnst->r_br + ")", LEN_RBR)
	
	?? " "
	
	// idroba, naziv robe, jmj
	?? PADR( aRobaNaz[1], LEN_NAZIV) 
	?? " "
	?? show_number(t_rnst->kolicina, PIC_KOLICINA) 
	?? " "
	
	// dimenzije
	?? show_number( t_rnst->d_sirina,  PIC_DIMENZIJA)
	
	?? " "
	
	?? show_number( t_rnst->d_visina,  PIC_DIMENZIJA)
	
	?? " "
	
	?? show_number( t_rnst->d_ukupno,  PIC_VRIJEDNOST)
	
	// provjeri za novu stranicu
	if prow() > LEN_STRANICA - DSTR_KOREKCIJA()
		++nStr
		Nstr_a4(nStr, .t.)
    	endif	

	SELECT t_rnst
	skip
enddo

// provjeri za novu stranicu
if prow() > LEN_STRANICA - DSTR_KOREKCIJA()
	++nStr
	Nstr_a4(nStr, .t.)
endif	

? cLine
?

if lStartPrint
	FF
	EndPrint()
endif

return


// uzmi osnovne parametre za stampu dokumenta
//static function g_otpr_gvars(gVar1)
// uzmi ... gvar1 
//gvar1 := g_t_pars_opis("P01"))
//return


// zaglavlje glavne tabele sa stavkama
static function s_o_tbl_header()
local cLine
local cRed1:=""
local cRed2:=""
local cRed3:=""

cLine := g_otp_line()

? cLine

cRed1 := RAZMAK 
cRed1 += PADC("R.br", LEN_RBR) 
cRed1 += " " + PADR("Trgovacki naziv dobra/usluge (sifra, naziv, jmj)", LEN_NAZIV)
cRed1 += " " + PADC("kolicina", LEN_KOLICINA)
cRed1 += " " + PADC("xxxxxx", LEN_DIMENZIJA)
cRed1 += " " + PADC("xxxxxx", LEN_DIMENZIJA)

? cRed1

? cLine

return



// funkcija za ispis headera
function otpr_header()
local cPom
local nPom
local nPos1
local cDLHead 
local cSLHead 
local cINaziv
local cIAdresa
local cIIdBroj
local cIBanke
local aBanke
local cITelef
local cIWeb
local cIText1
local cIText2
local cIText3
local nPRowsDelta

// double line header
cDLHead := REPLICATE("=", 60)
// single line header
cSLHead := REPLICATE("-", 30)
nPRowsDelta := prow()
// naziv
cINaziv  := g_t_pars_opis("I01")
// adresa
cIAdresa := g_t_pars_opis("I02")
// idbroj
cIIdBroj := g_t_pars_opis("I03") 
cIBanke  := g_t_pars_opis("I09")

return



// definicija linije za glavnu tabelu sa stavkama
static function g_otp_line()
local cLine

cLine:= RAZMAK
cLine += REPLICATE("-", LEN_RBR)
cLine += " " + REPLICATE("-", LEN_NAZIV)
cLine += " " + REPLICATE("-", LEN_KOLICINA)
cLine += " " + REPLICATE("-", LEN_DIMENZIJA)

return cLine


// funkcija za ispis podataka o kupcu
// dokument, datumi, hitnost itd..
static function otpr_kupac()
local cNalprNaziv := "OTPREMNICA br."
local dDatNal
local dDatIsp
local cVrIsp
local cNarucioc
local aNarucioc
// itd....

// sve se iscitava iz T_PARS

cNarucioc := g_t_pars_opis("P01")
dDatNal := g_t_pars_opis("P02")
dDatIsp := g_t_pars_opis("P03")
// itd....

aNarucioc := Sjecistr(cNarucioc, 30)

return



return



