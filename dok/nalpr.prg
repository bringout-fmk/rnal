#include "\dev\fmk\rnal\rnal.ch"


static LEN_IT_NO := 4
static LEN_DESC := 65

static LEN_QTTY := 10
static LEN_DIMENSION := 10
static LEN_VALUE := 10

static PIC_QTTY := "9999999.99"
static PIC_VALUE := "9999999.99"
static PIC_DIMENSION := "9999999.99"

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
local aGroups := {}
local nCnt := 0
local i

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
set order to tag "2"
go top
nDoc_no := field->doc_no

altd()

// izvuci sve grupe....
do while !EOF() .and. field->doc_no == nDoc_no
	
	// grupa dokumenta
	nDoc_gr := field->doc_gr_no
	
	do while !EOF() .and. field->doc_no == nDoc_no .and. ;
			field->doc_gr_no == nDoc_gr
		
		skip		
	enddo
	
	++ nCnt
	
	AADD(aGroups, { nDoc_gr, nCnt })
	
enddo

if !StartPrint(nil, nil)
	close all
	return
endif

for i:=1 to LEN( aGroups )
	
	// stampaj nalog za grupu....
	p_a4_nalpr( .f. , aGroups[i, 1], aGroups[i, 2], LEN(aGroups) )
	
	FF
next

EndPrint()

return


// -----------------------------------
// stampa naloga za proizvodnju
// -----------------------------------
function p_a4_nalpr(lStartPrint, nDoc_gr, nGr_cnt, nGr_total )
local lShow_zagl
local i
local nDocRbr := 0

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
nalpr_header( nGr_cnt, nGr_total )

// podaci kupac i broj dokumenta itd....
nalpr_kupac()

B_ON

?

cLine := g_line()

// setuj len_ukupno
LEN_TOTAL := LEN( cLine )

select t_docit
set order to tag "1"
go top

// kondenzuj font
//P_COND

// stampaj grupu artikala naloga
s_art_group(nDoc_gr)

// print header tabele
s_tbl_header()

select t_docit
set order to tag "2"
nDoc_no := field->doc_no

seek docno_str( nDoc_no ) + STR(nDoc_gr, 2)

nPage := 1
aArt_desc := {}
nArt_id := 0
nArt_tmp := 0
lSh_art_desc := .f.

// stampaj podatke 
do while !EOF() .and. field->doc_no == nDoc_no .and. field->doc_gr_no == nDoc_gr
	
	lSh_art_desc := .f.
	nArt_id := field->art_id
	
	if nArt_tmp <> nArt_id 
		
		lSh_art_desc := .t.

	endif
	
	cDoc_no := docno_str( field->doc_no )
	cDoc_it_no := docit_str( field->doc_it_no )
	
	// prikazuj naziv artikla
	if lSh_art_desc == .t.
		cArt_desc := ALLTRIM( field->art_desc )
	else
		cPom := "-//-"
		cArt_desc := PADC( cPom , 10 )
	endif
	
	aArt_desc := SjeciStr( cArt_desc, LEN_DESC )	
	
	// ------------------------------------------
	// prvi red...
	// ------------------------------------------
	
	? RAZMAK
	
	// r.br
	?? PADL(ALLTRIM( STR( ++nDocRbr) ) + ")", LEN_IT_NO)
	
	?? " "
	
	// proizvod, naziv robe, jmj
	?? aArt_desc[1]
	
	?? " "
	
	// sirina
	?? show_number(field->doc_it_width, nil, -10 )

	?? " "

	// visina
	?? show_number(field->doc_it_heigh, nil, -10 )
	
	?? " "

	// kolicina
	?? show_number(field->doc_it_qtty, nil, -10 )

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
			
			?? " "
			
			?? aArt_desc[i]
		
			// provjeri za novu stranicu
			if prow() > LEN_PAGE - DSTR_KOREKCIJA()
				++ nPage
				Nstr_a4(nPage, .t.)
			endif	
		next
		
	endif

	? RAZMAK
	?? PADL("", LEN_IT_NO)
	?? " "
	?? REPLICATE("-", LEN_DESC)
	
	// dodatne operacije operacije....
	
	nOpHeader := 1

	select t_docop
	set order to tag "1"
	go top
	seek docno_str(t_docit->doc_no) + docit_str(t_docit->doc_it_no)

	do while !EOF() .and. field->doc_no == t_docit->doc_no ;
			.and. field->doc_it_no == t_docit->doc_it_no

	    // uzmi element
	    nDoc_el_no := field->doc_el_no
	    
	    nElDesc := 1
	    nElCount := 0
	    
	    do while !EOF() .and. field->doc_no == t_docit->doc_no ;
	    		    .and. field->doc_it_no == t_docit->doc_it_no ;
			    .and. field->doc_el_no == nDoc_el_no
		
		// el.op.header
		if nOpHeader == 1
			
			// ? RAZMAK
		     	//?? PADL("", LEN_IT_NO)
		     	//?? " "
			//cPom := "Br.elementa, dodatne operacije:"
			//?? cPom
			// podvlaka
			//? RAZMAK
			//?? PADL("", LEN_IT_NO)
			//?? " "
			//?? REPLICATE("-", LEN( cPom ) )
			
			// iskljuci ga do daljnjeg
			nOpHeader := 0
			
		endif
		
		// element...
		if nElDesc == 1
			
			? RAZMAK
		    	?? PADL("", LEN_IT_NO)
			?? " "
		    	B_ON
			?? "obrada na " + STR( field->doc_el_no, 2 ) + ":" 
			B_OFF
	    		?? " "
	    		?? ALLTRIM( field->doc_el_desc )
		
			// iskljuci ga do daljnjeg
			nElDesc := 0
	
		endif
		
		// operacije....
		
		? RAZMAK

		?? PADL("", LEN_IT_NO)

		?? " "
		
		if !EMPTY(field->aop_desc) .and. ALLTRIM(field->aop_desc) <> "?????"
			?? PADL( STR( ++ nElCount, 3), 3) + ")" + SPACE(1) + ALLTRIM(field->aop_desc)
		endif

		if !EMPTY(field->aop_att_desc) .and. ALLTRIM(field->aop_att_desc) <> "?????"
			?? ", "
			?? ALLTRIM(field->aop_att_desc)
		endif
		
		if !EMPTY(field->doc_op_desc)
			
			cPom := "- napomene: "
			cPom += ALLTRIM( field->doc_op_desc )
			aPom := SjeciStr( cPom , 70 )
			
			for i:=1 to LEN( aPom )
				
				? RAZMAK
				?? PADR("", LEN_IT_NO)
				?? SPACE(5)
				?? aPom[ i ]
				
			next
			
		endif
		
		select t_docop
		
		skip
	   
	   enddo
	   
	enddo

	select t_docit
	
	// napomene za item:
	// - napomene
	// - shema u prilogu
	
	if !EMPTY( field->doc_it_desc ) ;
		.or. ( field->doc_it_schema == "D" )
	
		cPom := "Napomene: " + ;
			ALLTRIM( field->doc_it_desc )
		
		if field->doc_it_schema == "D"
		
			cPom += " "
			cPom += "(SHEMA U PRILOGU)"
		endif	
		
		aDoc_it_desc := SjeciStr( cPom , 100 )
		
		// podvuci
		//? RAZMAK
		//?? PADL( "", LEN_IT_NO )
		//?? " "
		//?? REPLICATE( "-", LEN_DESC )

		for i:=1 to LEN(aDoc_it_desc)
						
			? RAZMAK

			?? PADL("", LEN_IT_NO)

			?? " "
			
			?? aDoc_it_desc[i]
		next
		
	
	endif
	
	? cLine

	select t_docit
	skip

	nArt_tmp := nArt_id 
	
enddo

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++nPage
	Nstr_a4(nPage, .t.)
endif	

//? cLine

B_OFF

s_nal_izdao()

s_nal_footer()

if lStartPrint
	FF
	EndPrint()
endif

return


// ----------------------------------------
// stampanje grupe artikala naloga
// ----------------------------------------
static function s_art_group( nGr )
? RAZMAK + "grupa artikala: (" + ALLTRIM(STR(nGr)) + ") - " + get_art_docgr( nGr )
return



// -------------------------------------------
// stampa potpisa nalog izdao
// -------------------------------------------
static function s_nal_izdao()
local cPom := ""

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

// nalog izdao
cPom += "Nalog izdao: "
cPom += PADC( ALLTRIM(goModul:oDataBase:cUser), 20)
cPom += " "
cPom += "Vrijeme: "
cPom += PADR( TIME(), 5 )

? PADL(cPom, LEN_TOTAL)

return


// ----------------------------------------
// nalog footer...
// ----------------------------------------
static function s_nal_footer()
local cPom
local cPayDesc := ""
local cPayed := ""
local cPayAddDesc := ""

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

cPayDesc := g_t_pars_opis("N06")
cPayed := g_t_pars_opis("N10")
cPayAddDesc := g_t_pars_opis("N11")

// footer
// vrsta placanja
? RAZMAK + "Vrsta placanja: " + cPayDesc

// placeno D/N
if !EMPTY(cPayed) .and. ALLTRIM(cPayed) <> "-"

	cPom := "Placeno: "
	
	if cPayed == "D"
		cPom += "DA"
	else
		cPom += "NE"
	endif
	
	? RAZMAK + cPom
	
endif

// dodatne napomene placanje
if !EMPTY(cPayAddDesc) .and. ALLTRIM(cPayAddDesc) <> "-"
		
	cPom := "Napomene za placanje: "
	cPom += cPayAddDesc

	? RAZMAK + cPom
		
endif


// konacan proizvod
cPom := "Konacan proizvod: "
cPom += "  VALIDAN  "
cPom += "  NIJE VALIDAN  "
cPom += " ovjerio: __________________ "
cPom += ", vrijeme: _____________"

? RAZMAK + cPom

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
cRow1 += " " + PADR("artikal/naziv/element/operacije/napomene", LEN_DESC)
cRow1 += " " + PADC("sirina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("visina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("kol. (kom)", LEN_QTTY)

? cRow1

? cLine

return


// -----------------------------------------
// funkcija za ispis headera
// -----------------------------------------
function nalpr_header( nDocGr, nDocGrTot )
local cDLHead 
local cSLHead 
local cINaziv
local cRazmak := SPACE(2)
local cDoc_no

// broj dokumenta
cDoc_no := g_t_pars_opis("N01")

// naziv
cINaziv := ALLTRIM(gFNaziv)
cINaziv += " : "
cINaziv += "NALOG ZA PROIZVODNJU br."
cINaziv += cDoc_no
cINaziv += " "
cINaziv += "(" 
cINaziv += ALLTRIM(STR(nDocGr)) 
cINaziv += "/" 
cINaziv += ALLTRIM(STR(nDocGrTot)) 
cINaziv += ")"

// double line header
cDLHead := REPLICATE("=", 70)

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
local cDoc_date
local cDoc_time
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
local nLeft := 15
local nRight := 8
local i
local cPom
local aPom

cDoc_date := g_t_pars_opis("N02")
cDoc_time := g_t_pars_opis("N12")
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

B_OFF

// doc_date + doc_time + doc_dvr_date + doc_dvr_time
cPom := "Datum/vrijeme naloga: "
cPom += cDoc_date
cPom += " "
cPom += cDoc_time
cPom += ",  "
cPom += "Datum/vrijeme isporuke: "
cPom += cDoc_dvr_date
cPom += " "
cPom += cDoc_dvr_time

p_line(cRazmak + cPom, 12, .f.)


// priority + sh_place
cPom := "Prioritet: "
cPom += cPriority
cPom += ",  "
cPom += "Mjesto isporuke: "
cPom += cDoc_ship_place
	
aPom := SjeciStr( cPom, 100 )

for i:=1 to LEN( aPom )

	p_line(cRazmak + aPom[i], 12, .f.)

next
	
// podaci narucioca
cPom := "Narucioc: "
cPom += ALLTRIM(cCust_desc) 
cPom += ", " 
cPom += ALLTRIM(cCust_addr) 
cPom += ", tel: " 
cPom += ALLTRIM(cCust_tel)

p_line( cRazmak + cPom, 12, .f.)

// podaci kontakta
cPom := "Kontakt: "
cPom += " " + ALLTRIM(cCont_desc) + " (" + ALLTRIM(cContadesc) + "), " + ALLTRIM("tel: " + cCont_tel) + ", " + ALLTRIM(cCont_add_desc)

aPom := SjeciStr( cPom, 100 )

for i:=1 to LEN( aPom )
	
	p_line( cRazmak + aPom[i] , 12, .f. )

next

// ostale napomene naloga...
if !EMPTY( cDoc_add_desc )
	
	cPom := "Ostale napomene: " + ALLTRIM( cDoc_add_desc )
	
	aPom := SjeciStr( cPom, 100 )

	for i:=1 to LEN( aPom )
		p_line( cRazmak + aPom[i] , 12, .f.)
	next

endif

return



// -----------------------------------------
// funkcija za novu stranu
// -----------------------------------------
function NStr_a4(nPage, lShZagl)
local cLine

cLine := g_line()

// korekcija duzine je na svako strani razlicita
nDuzStrKorekcija := 0 

//P_COND

? cLine
p_line( "Prenos na sljedecu stranicu", 12, .f. )
? cLine

FF

//P_COND

? cLine
if nPage <> nil
	p_line( "       Strana:" + str(nPage, 3), 12, .f.)
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


