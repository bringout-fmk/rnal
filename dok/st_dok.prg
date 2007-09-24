#include "\dev\fmk\rnal\rnal.ch"


// variables
static __temp
static __doc_no

// -------------------------------------
// stampa naloga, filovanje prn tabela
// -------------------------------------
function st_nalpr( lTemporary, nDoc_no )

__temp := lTemporary
__doc_no := nDoc_no

// kreiraj print tabele
t_rpt_create()
// otvori tabele
t_rpt_open()

o_tables( __temp )

// osnovni podaci naloga
_fill_main()
// stavke naloga
_fill_items()
// operacije
_fill_aops()

// printaj nalog
nalpr_print( .t. )

close all

o_tables( __temp )

return DE_REFRESH


// -------------------------------------
// stampa obracunskog lista
// filovanje prn tabela
// -------------------------------------
function st_obr_list( lTemporary, nDoc_no )
local lGN := .t.

__temp := lTemporary
__doc_no := nDoc_no

// kreiraj print tabele
t_rpt_create()
// otvori tabele
t_rpt_open()

o_tables( __temp )

// osnovni podaci naloga
_fill_main()
// stavke naloga
_fill_items( lGN )

// printaj obracunski list
obrl_print( .t. )

close all

o_tables( __temp )

return DE_REFRESH




// ----------------------------------
// filuj tabele za stampu
// ----------------------------------
static function _fill_items( lZpoGN )
local nTable := F_DOC_IT
local nArt_id
local cArt_desc
local cArt_full_desc
local nDoc_it_no
local nDoc_gr_no := 0
local nQtty
local nTotal
local nHeigh
local nWidth
local nZWidth := 0
local nZHeigh := 0
local nNeto := 0
local nBruto := 0
local lGroups := .t.

if lZpoGN == nil
	lZPoGN := .f.
endif

if !lZpoGN .and. Pitanje(,"Razdijeliti nalog po grupama ?", "D" ) == "N"
	lGroups := .f.
endif

if ( __temp == .t. )
	nTable := F__DOC_IT
endif

select (nTable)
set order to tag "1"
go top
seek docno_str(__doc_no)

// filuj stavke
do while !EOF() .and. field->doc_no == __doc_no
	
	nArt_id := field->art_id
	nDoc_it_no := field->doc_it_no
	
	// nadji proizvod
	select articles
	hseek artid_str( nArt_id )

	if lGroups == .t.
		
		altd()
		
		// odredi grupu artikla
		// - izo i kaljeno, izo i bruseno ili ....
		nDoc_gr_no := set_art_docgr( nArt_id, nDoc_it_no )
		
	else
		
		nDoc_gr_no := 0
		
	endif

	cArt_full_desc := ALLTRIM(articles->art_full_desc)
	cArt_desc := ALLTRIM(articles->art_desc)
	
	// temporary
	cArt_desc := "(" + cArt_desc + ")"
	cArt_desc += " " + cArt_full_desc

	select ( nTable )
	
	nQtty := field->doc_it_qtty
	nHeigh := field->doc_it_heigh
	nWidth := field->doc_it_width
	nDocit_altt := field->doc_it_altt
	
	// ukupno mm -> m2
	nTotal := ROUND( c_ukvadrat(nQtty, nHeigh, nWidth), 2)

	cDoc_it_schema := field->doc_it_schema
	cDoc_it_desc := field->doc_it_desc
	
	if lZpoGN == .t.


		altd()
		
		aZpoGN := {}
		// zaokruzi vrijednosti....
		_art_set_descr( nArt_id, nil, nil, @aZpoGN, lZpoGN )
		
		nZHeigh := obrl_zaok( nHeigh, aZpoGN )
		
		nZWidth := obrl_zaok( nWidth, aZpoGN )
		
		// ako se zaokruzuje onda total ide po zaokr.vrijednostima
		nTotal := ROUND( c_ukvadrat( nQtty, nZHeigh, nZWidth ), 2)
		
		// izracunaj neto
		nNeto := ROUND( obrl_neto( nTotal, aZpoGN ), 2)
		
		nBruto := 0
		
	endif
	
	a_t_docit( __doc_no, nDoc_gr_no, nDoc_it_no, nArt_id, cArt_desc , ;
		  cDoc_it_schema, cDoc_it_desc, nQtty, nHeigh, nWidth, ;
		  nDocit_altt, nTotal, ;
		  nZHeigh, nZWidth, nNeto, nBruto )
	
	select ( nTable )
	skip
enddo
	
return


// --------------------------------------------------
// filovanje operacija 
// --------------------------------------------------
static function _fill_aops()
local nTable := F_DOC_OPS
local nTable2 := F_DOC_IT
local nDoc_op_no
local nDoc_it_no
local nDoc_el_no
local cDoc_el_desc
local nArt_id
local aElem
local nElem_no
local nAop_id
local cAop_desc
local nAop_att_id
local cAop_att_desc
local cDoc_op_desc

if ( __temp == .t. )
	nTable := F__DOC_OPS
	nTable2 := F__DOC_IT
endif

select (nTable2)
set order to tag "2"
go top

// filuj operacije
select (nTable)
set order to tag "1"
go top
seek docno_str(__doc_no)

do while !EOF() .and. field->doc_no == __doc_no

	nElem_no := 0
	nDoc_it_no := field->doc_it_no
	nDoc_op_no := field->doc_op_no
	nDoc_el_no := field->doc_it_el_no
	
	select (nTable2)
	set order to tag "1"
	go top
	seek docno_str( __doc_no ) + docit_str( nDoc_it_no )

	nArt_id := field->art_id

	aElem := {}
	_g_art_elements( @aElem, nArt_id )
	
	// vrati broj elementa artikla (1, 2, 3 ...)
	_g_elem_no( aElem, nDoc_el_no, @nElem_no )
	
	cDoc_el_desc := get_elem_desc( aElem, nDoc_el_no, 150 )
	
	select (nTable)
	
	nAop_id := field->aop_id
	nAop_att_id := field->aop_att_id

	cAop_desc := g_aop_desc( nAop_id )
	cAop_att_desc := g_aop_att_desc( nAop_att_id )

	cDoc_op_desc := ALLTRIM( field->doc_op_desc )
	
	a_t_docop( __doc_no, nDoc_op_no, nDoc_it_no, ;
		   nElem_no, cDoc_el_desc, ;
                   nAop_id, cAop_desc, ;
		   nAop_att_id, cAop_att_desc, cDoc_op_desc)

	select (nTable)
	skip
enddo

return


// --------------------------------------
// napuni podatke narucioca i ostalo
// --------------------------------------
static function _fill_main()
local nTable := F_DOCS

if ( __temp == .t. )
	nTable := F__DOCS
endif

select (nTable)
set order to tag "1"
go top
seek docno_str( __doc_no )

_fill_customer( field->cust_id )
_fill_contacts( field->cont_id )

select (nTable)

// broj naloga
add_tpars("N01", docno_str( __doc_no ) )
// datum naloga
add_tpars("N02", DToC( field->doc_date ) )
// datum isporuke
add_tpars("N03", DToC( field->doc_dvr_date ) )
// vrijeme isporuke
add_tpars("N04", PADR( field->doc_dvr_time, 5))
// hitnost - prioritet
add_tpars("N05", s_priority( field->doc_priority ))
// nalog vrsta placanja
add_tpars("N06", s_pay_id( field->doc_pay_id ))
// mjesto isporuke
add_tpars("N07", ALLTRIM(field->doc_ship_place) )
// dokument dodatni podaci
add_tpars("N08", ALLTRIM(field->doc_desc) )
// dokument, kontakt dodatni podaci...
add_tpars("N09", ALLTRIM(field->cont_add_desc) )

// ako je kes, dodaj i podatke o placeno D i napomene
if field->doc_pay_id == 2
	
	// placeno d/n...
	add_tpars("N10", ALLTRIM( field->doc_paid ) )
	// placanje dodatne napomene...
	add_tpars("N11", ALLTRIM( field->doc_pay_desc ) )

endif

if fieldpos("DOC_TIME") <> 0
	// vrijeme dokumenta
	add_tpars("N12", ALLTRIM(field->doc_time) )
endif

return



// ----------------------------------------
// dodaj podatke o naruciocu
// ----------------------------------------
static function _fill_customer( nCust_id )
local nTArea := SELECT()
local cCust_desc := ""
local cCust_addr := ""
local cCust_tel := ""

select customs
set order to tag "1"
go top
seek custid_str(nCust_id)

if FOUND()
	cCust_desc := ALLTRIM( customs->cust_desc )
	cCust_addr := ALLTRIM( customs->cust_addr )
	cCust_tel := ALLTRIM( customs->cust_tel )
endif

add_tpars("P01", custid_str(nCust_id))
add_tpars("P02", cCust_desc )
add_tpars("P03", cCust_addr )
add_tpars("P04", cCust_tel )

select (nTArea)
return


// ----------------------------------------
// dodaj podatke o kontaktu
// ----------------------------------------
static function _fill_contact( nCont_id )
local nTArea := SELECT()
local cCont_desc := ""
local cCont_tel := ""
local cCont_add_desc := ""

select contacts
set order to tag "1"
go top
seek contid_str(nCont_id)

if FOUND()
	cCont_desc := ALLTRIM( contacts->cont_desc )
	cCont_tel := ALLTRIM( contacts->cont_tel )
	cCont_add_desc := ALLTRIM( contacts->cont_add_desc )
endif

add_tpars("P10", contid_str(nCont_id))
add_tpars("P11", cCont_desc )
add_tpars("P12", cCont_tel )
add_tpars("P13", cCont_add_desc )

select (nTArea)
return

// ---------------------------------------------
// vraca opis grupe za stampu dokumenta
// ---------------------------------------------
function get_art_docgr( nGr )
local cGr := "sve grupe"

do case
	case nGr == 1
		cGr := "rezano"
	case nGr == 2
		cGr := "kaljeno"
	case nGr == 3
		cGr := "bruseno"
	case nGr == 4
		cGr := "IZO i rezano"
	case nGr == 5
		cGr := "IZO i kaljeno"
	case nGr == 6
		cGr := "IZO i bruseno"
	case nGr == 7
		cGr := "LAMI-RG"
endcase

return cGr


// -----------------------------------------------
// setuj grupu artikla za stampu naloga
// -----------------------------------------------
function set_art_docgr( nArt_id, nDocit_no )
local nGroup := 1
local aArt := {}
local lIsIZO := .f.
local lIsBruseno := .f.
local lIsKaljeno := .f.

// daj matricu aArt sa definicijom artikla....
_art_set_descr( nArt_id, nil, nil, @aArt, .t. )

// da li je artikal IZO...
lIsIZO := is_izo( aArt )
lIsLAMI := is_lami( aArt )
lIsBruseno := is_bruseno( aArt, nDocIt_no )
lIsKaljeno := is_kaljeno( aArt, nDocIt_no )

do case
	case lIsLAMI == .t.
		// LAMI staklo
		nGroup := 7
	case lIsIZO == .t. .and. lIsBruseno == .t.
		// IZO i bruseno
		nGroup := 6
	case lIsIZO == .t. .and. lIsKaljeno == .t.
		// IZO i kaljeno
		nGroup := 5
	case lIsIZO == .t.
		// IZO - rezano
		nGroup := 4
	case lIsIZO == .f. .and. lIsBruseno == .t.
		// bruseno
		nGroup := 3
	case lIsIZO == .f. .and. lIsKaljeno == .t.
		// kaljeno
		nGroup := 2
	case lIsIZO == .f.
		// rezano
		nGroup := 1
	
endcase

return nGroup


// ---------------------------------------
// da li je staklo IZO
// ---------------------------------------
function is_izo( aArticle )
local lRet := .f.
local nElNo
local nGlass
local nFrame

local cGlCode := ALLTRIM( gGlassJoker )
local cFrCode := ALLTRIM( gFrameJoker )

nElNo := aArticle[ LEN(aArticle), 1 ]

if nElNo > 1

	nGlass := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cGlCode })
	nFrame := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cFrCode })
	
	if nGlass <> 0 .and. nFrame <> 0
		lRet := .t.
	endif
	
endif

return lRet


// ---------------------------------------
// da li je staklo LAMI
// ---------------------------------------
function is_lami( aArticle )
local lRet := .f.
local nLAMI

local cGlCode := ALLTRIM( gGlassJoker )
local cLamiCode := ALLTRIM( gGlLamiJoker )

nLAMI := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cGlCode .and. ;
		ALLTRIM(xVar[5]) == cLamiCode } )

if nLAMI <> 0
	lRet := .t.
endif

return lRet



// ---------------------------------------------
// da li je staklo kaljeno ???
// ---------------------------------------------
function is_kaljeno( aArticle, nDocit_no )
local lRet := .f.
local cSrcJok := ALLTRIM( gAopKaljenje )

// provjeri obradu iz matrice
lRet := ck_obr( aArticle, cSrcJok )

if lRet == .f.
	// provjeri i tabelu DOC_OPS
	lRet := ck_obr_aops( nDocit_no, cSrcJok )
endif

return lRet 


// ---------------------------------------------
// da li je staklo kaljeno ???
// ---------------------------------------------
function is_bruseno( aArticle, nDocit_no )
local lRet := .f.
local cSrcJok := ALLTRIM( gAopBrusenje )

// provjeri obradu iz matrice
lRet := ck_obr( aArticle, cSrcJok )

if lRet == .f.
	// provjeri i tabelu DOC_OPS
	lRet := ck_obr_aops( nDocit_no, cSrcJok )
endif

return lRet 


// ----------------------------------------------------
// provjeri obradu na osnovu matrice artikla
// ----------------------------------------------------
static function ck_obr( aArticle, cSrcObrada )
local lRet := .f.
local nObrada 
nObrada := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[4]) == cSrcObrada } )
if nObrada <> 0
	lRet := .t.
endif
return lRet


// ---------------------------------------
// provjeri obradu u tabeli DOC_OPS
//   nDocIt_no - redni broj stavke naloga
//   cSrcObrada - djoker obrade <AOP_K> .... 
//                koju obradu trazimo
// ---------------------------------------
static function ck_obr_aops( nDocit_no, cSrcObrada )
local lRet := .f.
local nTArea := SELECT()
local nTable := F_DOC_OPS

if __temp == .t.
	nTable := F__DOC_OPS
endif
	
// provjeri na osnovu DOC_AOP
	
select (nTable)
set order to tag "1"
go top
	
nDoc_no := __doc_no
	
seek docno_str(nDoc_no) + docit_str(nDocit_no)
	
do while !EOF() .and. field->doc_no == nDoc_no .and. ;
		field->doc_it_no == nDocit_no
			
	nAop_id := field->aop_id

	// idi u operacije pa vidi djoker
	select aops
	go top
	seek aopid_str( nAop_id )
		
	if FOUND() .and. field->aop_id == nAop_id .and. ;
		ALLTRIM( field->aop_joker ) == cSrcObrada
			
		lRet := .t.
		exit
			
	endif
		
	select (nTable)
	skip
enddo
	
select (nTArea)
return lRet




