#include "rnal.ch"


// ------------------------------------------------------
// glavna funkcija za poziv stampe labele
// -----------------------------------------------------
function lab_print( lTemporary )

if lTemporary == nil
	lTemporary := .f.
endif

t_rpt_open()

select t_docit
go top

_lab_print( lTemporary )

return


// -----------------------------------
// stampa labele...
// -----------------------------------
static function _lab_print( lTemporary )

// daj mi osnovne podatke o dokumentu
cCust := g_t_pars_opis("P02")
cObject := g_t_pars_opis("P21")

// otvori xml za upis
open_xml()
// upisi header
xml_head()
// <label>
xml_subnode("label", .f.)

// <cust></cust>
xml_node( "cust", ALLTRIM(cCust) )
// <obj></obj>
xml_node( "obj", ALLTRIM(cObject) )

// sada prodji po stavkama
select t_docit
set order to tag "1"
go top

// stampaj podatke 
do while !EOF()

	nDoc_no := field->doc_no
	nDoc_it_no := field->doc_it_no

	nArt_id := field->art_id
	nQty := field->doc_it_qtty
	cArt_desc := ALLTRIM( field->art_desc )
	
	// <glass>
	xml_subnode( "glass", .f. )

	// <art></art>
	xml_node( "art", cArt_desc )
	// <qtty></qtty>
	xml_node( "qtty", ALLTRIM(STR(nQty, 12)) )
	// <gl_type></gl_type>

	cRawValue := ""

	// uzmi sa operacija sta se ima uzeti
	select t_docop
	seek docno_str(nDoc_no) + docit_str(nDoc_it_no)

	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->doc_it_no == nDoc_it_no
			
		// ovo je ono sto me zanima
		cRawValue := ALLTRIM( field->aop_vraw )
		
		if "STAMP" $ cRawValue
			// imam pecat
			exit
		endif

		skip
	enddo
	
	select t_docit

	// <pos></pos>
	
	// <l_pos></l_pos>
	xml_node( "l_pos", cRawValue )

	// </glass>
	xml_subnode( "glass", .t. )

	select t_docit
	skip

enddo

// </label>
xml_subnode("label", .t.)
close_xml()

altd()
// stampanje labele
cCmdLine := "start java -jar " + EXEPATH + "java\" + "JODReports-2.1-RC.jar" + ;
	" " + EXEPATH + "rg_label.odt " + PRIVPATH + "data.xml " + ;
	PRIVPATH + "label.odt"

run &cCmdLine

return


