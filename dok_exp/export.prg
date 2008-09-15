#include "rnal.ch"


// -------------------------------------------
// export dokumenta
// nDoc_no - dokument broj
// lTemporary - priprema .t., kumulativ .f.
// lWriteRel - upisi rel_ver prvi zapis
// -------------------------------------------
function exp_2_lisec( nDoc_no, lTemporary, lWriteRel )
local cLocation
local cFile := ""
local nH
local nADOCS := F_DOCS
local nADOC_IT := F_DOC_IT
local nADOC_OP := F_DOC_OPS
local nTArea := SELECT()

local aRel
local aRelSpec
local aPos
local aPosSpec
local aOrd
local aOrdSpec
local aTxt
local aTxtSpec
local aTx2Spec
local aTx3Spec
local aGl1
local aGl2
local aGl3
local aGlSpec
local aFr1
local aFr2
local aFrSpec

// napuni matrice sa specifikacijama record-a
aRelSpec := _get_rel()
aOrdSpec := _get_ord()
aPosSpec := _get_pos()
aPo2Spec := _get_po2()
aTxtSpec := _get_txt(1)
aTx2Spec := _get_txt(2)
aTx3Spec := _get_txt(3)
aFrSpec  := _get_frx()
aGlSpec  := _get_glx()

if lTemporary == nil
	lTemporary := .f.
endif

if lWriteRel == nil
	lWriteRel := .f.
endif

if lTemporary == .t.
	nADOCS := F__DOCS
	nADOC_IT := F__DOC_IT
	nADOC_OP := F__DOC_OPS
endif

select (nADOCS)
go top
seek docno_str( nDoc_no )


// ako je nalog 0 ili manje, znaci da nema broja
// nije odstampan !

if nDoc_no <= 0
	msgbeep("Broj naloga: " + ALLTRIM(STR(nDoc_no)) + ;
		"#Odradite prvo stampu naloga !" )
	return
endif

// uzmi lokaciju fajla
g_exp_location( @cLocation )

// kreiraj fajl exporta....
if cre_exp_file( nDoc_no, cLocation, @cFile, @nH ) == 0

	select (nTArea)
	msgbeep("Operacija ponistena, nista nije exportovano!")
	return

endif


// -----------------------------------------------------
//
// WRITE VALUES TO TRF FILE
//
// -----------------------------------------------------


// upisi <REL>
aRel := add_rel( "" )
write_rec( nH, aRel, aRelSpec )

select (nADOCS)
nCustId := field->cust_id
nContId := field->cont_id

// nadji naziv narucioca
select customs
set filter to
set order to tag "1"
go top
seek custid_str(nCustid)

select contacts
set filter to
set order to tag "1"
go top
seek contid_str(nContId)

select (nADOCS)

// ako su podaci ispravni
if field->cust_id <> 0

	// uzmi i upisi osnovne elemente naloga
	aOrd := add_ord( field->doc_no , ;
		field->cust_id , ;
		ALLTRIM( customs->cust_desc ) + " " + ALLTRIM(customs->cust_addr) + " " + ALLTRIM(customs->cust_tel) , ;
		ALLTRIM( field->doc_desc ) , ;
		ALLTRIM( field->doc_sh_desc ) , ;
		ALLTRIM( field->cont_add_desc ) , ;
		ALLTRIM( contacts->cont_desc) + " " + ALLTRIM(contacts->cont_tel) , ;
		nil, ;
		field->doc_date, ;
		field->doc_dvr_date, ;
		field->doc_ship_place )
		
	// UPISI <ORD>
	write_rec( nH, aOrd, aOrdSpec )
	
else

	select (nTArea)
	msgbeep("Nisu ispravni podaci narudzbe !!!!#Operacija prekinuta...")
	
	// izadji....
	return

endif

// predji na stavke naloga

select (nADOC_IT)
go top
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nArt_id := field->art_id
	
	select articles
	set order to tag "1"
	seek artid_str( nArt_id )

	select (nADOC_IT)
	
	cGl1 := ""
	cPosGl1 := ""
	cGl2 := ""
	cPosGl2 := ""
	cGl3 := ""
	cPosGl3 := ""
	cFr1 := ""
	cPosFr1 := ""
	cFr2 := ""
	cPosFr2 := ""
	
	// uzmi i razlozi artikal
	// F4_A12_F3
	cArtDesc := ALLTRIM( articles->art_desc )

	// aArtDesc[1] = F4
	// ....    [2] = A12
	// ....    [3] = F3
	aArtDesc := TokToNiz( cArtDesc, "_" )
	
	for i := 1 to LEN( aArtDesc )
			
		if i == 1
			cGl1 := aArtDesc[i]
			cPosGl1 := ALLTRIM(STR(i))
		endif
		
		if i == 2
			cFr1 := aArtDesc[i]
			cPosFr1 := ALLTRIM(STR(i))
		endif
		
		if i == 3
			cGl2 := aArtDesc[i]
			cPosGl2 := ALLTRIM(STR(i))
		endif
		
		if i == 4
			cFr2 := aArtDesc[i]
			cPosFr2 := ALLTRIM(STR(i))
		endif
		
		if i == 5
			cGl3 := aArtDesc[i]
			cPosGl3 := ALLTRIM(STR(i))
		endif
	
	next

	// pregledaj operacije artikla
	// ako ima brusenje - mora se dodati po 3mm na dimenzije

	select (nADOC_OP)
	set order to tag "1"
	go top
	seek docno_str(nDoc_no) + docit_str(nDoc_it_no)

	lBrusenje := .f.

	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->doc_it_no == nDoc_it_no

			cJoker := g_aatt_joker( field->aop_att_id )
			
			if cJoker == "<A_B>"
				lBrusenje := .t.
				exit
			endif
	
	enddo

	select (nADOC_IT)
	
	// samo ako su dimenzije ispravne.....
	if field->doc_it_width <> 0 .and. ;
		field->doc_it_height <> 0 .and. ;
		field->doc_it_qtty <> 0
		
		// ubaci u matricu podatke
		aPos := add_pos( field->doc_it_no, ;
			"", ;
			nil, ;
			field->doc_it_qtty, ;
			_calc_dimension( field->doc_it_width, lBrusenje ), ;
			_calc_dimension( field->doc_it_height, lBrusenje ), ;
			cPosGl1, ;
			cPosFr1, ;
			cPosGl2, ;
			cPosFr2, ;
			cPosGl3 )

		// upisi <POS>
		write_rec( nH, aPos, aPosSpec )

		// upisi <GLx>, <FRx>
		if !EMPTY( cGl1 )
		
			aGl1 := add_glx( "1", cGl1 )
			write_rec( nH, aGl1, aGlSpec )
		
		endif
		if !EMPTY( cFr1 )
			
			aFr1 := add_frx( "1", cFr1 )
			write_rec( nH, aFr1, aFrSpec )
			
		endif
		if !EMPTY( cGl2 )
			
			aGl2 := add_glx( "2", cGl2 )
			write_rec( nH, aGl2, aGlSpec )
			
		endif
		if !EMPTY( cFr2 )
			
			aFr2 := add_frx( "2", cFr2 )
			write_rec( nH, aFr2, aFrSpec )
			
		endif
		if !EMPTY( cGl3 )

			aGl3 := add_glx( "3", cGl3 )
			write_rec( nH, aGl3, aGlSpec )
		
		endif
		
		// ako ima napomena...
		if !EMPTY( field->doc_it_desc )
		
			// upisi <TXT> ostale informacije
			aTxt := add_txt( 1, ALLTRIM( field->doc_it_desc ) )

			write_rec(nH, aTxt, aTxtSpec )
	
		endif

	endif

	select (nADOC_IT)
	skip
	
enddo

select (nADOC_IT)
go top

close_exp_file( cFile )

select (nTArea)

msgbeep("Export zavrsen ... kreiran je fajl#" + ;
	IF( LEN(cLocation) > 20,  ;
		PADR( cLocation, 20 ) + "..." , ;
		cLocation ) + cFile )

return


// -------------------------------------------------------------
// kalkuliranje nove dimenzije ako je brusenje u pitanju
// -------------------------------------------------------------
static function _calc_dimension( nDimension, lBrusenje )
local nNewDim := nDimension

if lBrusenje == .t.
	nNewDim := nDimension + gAddToDim
endif

return nNewDim





