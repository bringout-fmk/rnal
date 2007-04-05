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
// stampa otpremnice, filovanje prn tabela
// -------------------------------------
function st_otpremnica( lTemporary, nDoc_no )

__temp := lTemporary
__doc_no := nDoc_no

return DE_REFRESH




// ----------------------------------
// filuj tabele za stampu
// ----------------------------------
static function _fill_items()
local nTable := F_DOC_IT
local nArt_id
local cArt_desc
local cArt_full_desc
local nDoc_it_no
local nQtty
local nTotal
local nHeigh
local nWidth

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

	cArt_full_desc := ALLTRIM(articles->art_full_desc)
	cArt_desc := ALLTRIM(articles->art_desc)
	
	// temporary
	cArt_desc := "(" + cArt_desc + ")"
	cArt_desc += " " + cArt_full_desc

	select ( nTable )
	
	nQtty := field->doc_it_qtty
	nHeigh := field->doc_it_heigh
	nWidth := field->doc_it_width
	cDoc_it_schema := field->doc_it_schema
	cDoc_it_desc := field->doc_it_desc
	nTotal := nQtty * (nHeigh * nWidth)

	a_t_docit( __doc_no, nDoc_it_no, nArt_id, cArt_desc , cDoc_it_schema, ;
                  cDoc_it_desc, nQtty, nHeigh, nWidth, nTotal )
	
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

