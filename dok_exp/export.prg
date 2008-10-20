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
local aPo2
local aPo2Spec
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


Box(,2, 60)

@ m_x + 1, m_y + 2 SAY PADR("upisujem osnovne podatke", 50)

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

	@ m_x + 1, m_y + 2 SAY PADR("upisujem podatke o partneru ...... ",50)
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

	BoxC()

	// izadji....
	return

endif

// predji na stavke naloga

select (nADOC_IT)
go top
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no

	
	@ m_x + 1, m_y + 2 SAY PADR("upisujem stavke naloga.....", 50)
	
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
	// glass 1 element no
	nGlass1 := -99
	// glass 2 element no
	nGlass2 := -99
	// glass 3 element no
	nGlass3 := -99
	// isto vazi i za frame
	nFrame1 := -99
	nFrame2 := -99

	// uzmi i razlozi artikal
	// F4_A12_F3
	cArtDesc := ALLTRIM( articles->art_desc )

	// napuni aElem sa elemetima artikla
	aElem := {}
	// aelem = { elem_id, descriptin, rec.no }
	_g_art_elements( @aElem, articles->art_id )

	// aArtDesc[1] = F4
	// ....    [2] = A12
	// ....    [3] = F3
	aArtDesc := TokToNiz( cArtDesc, "_" )
	
	for i := 1 to LEN( aArtDesc )
			
		if i == 1
			cGl1 := aArtDesc[i]
			cPosGl1 := ALLTRIM(STR(i))
			nGlass1 := aElem[i, 1]
		endif
		
		if i == 2
			cFr1 := aArtDesc[i]
			cPosFr1 := ALLTRIM(STR(i))
			nFrame1 := aElem[i, 1]
		endif
		
		if i == 3
			cGl2 := aArtDesc[i]
			cPosGl2 := ALLTRIM(STR(i))
			nGlass2 := aElem[i, 1]
		endif
		
		if i == 4
			cFr2 := aArtDesc[i]
			cPosFr2 := ALLTRIM(STR(i))
			nFrame2 := aElem[i, 1]
		endif
		
		if i == 5
			cGl3 := aArtDesc[i]
			cPosGl3 := ALLTRIM(STR(i))
			nGlass3 := aElem[i, 1]
		endif
	
		@ m_x + 2, m_y + 2 SAY PADR("ok stavka - " + ;
				ALLTRIM(STR(i)), 50)

	next
	
	// pregledaj operacije artikla
	// npr: ako ima brusenje - mora se dodati po 1.5 mm na dimenzije

	nWidth := field->doc_it_width
	nHeight := field->doc_it_height

	nW1 := 0
	nW2 := 0
	nW3 := 0
	nH1 := 0
	nH2 := 0
	nH3 := 0

	// setuj pomocne dimenzije
	if !EMPTY(cGl1)
		nW1 := nWidth
		nH1 := nHeight
	endif
	
	if !EMPTY(cGl2)
		nH2 := nHeight
		nW2 := nWidth
	endif

	if !EMPTY(cGl3)
		nH3 := nHeight
		nW3 := nWidth
	endif

	lChange := .f.

	select (nADOC_OP)
	set order to tag "1"
	go top
	seek docno_str(nDoc_no) + docit_str(nDoc_it_no)

	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->doc_it_no == nDoc_it_no

		cJoker := g_aatt_joker( field->aop_att_id )
			
		select (nADOC_OP)

		if cJoker == "<A_B>"
			
			lChange := .t.

			// moramo znati i koji je element
			nElemPos := field->doc_it_el_no
		
			// radi se o staklu 1
			if nElemPos == nGlass1
			  nH1 := _calc_dimension( nHeight,.t. )
			  nW1 := _calc_dimension( nWidth, .t. )
			endif
				
			// radi se o staklu 2
			if nElemPos == nGlass2
			  nH2 := _calc_dimension( nHeight,.t. )
			  nW2 := _calc_dimension( nWidth, .t. )
			endif
			
			// radi se o staklu 3
			if nElemPos == nGlass3
			  nH3 := _calc_dimension( nHeight,.t. )
			  nW3 := _calc_dimension( nWidth, .t. )
			endif
				
		endif

		skip
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
			field->doc_it_width, ;
			field->doc_it_height, ;
			cPosGl1, ;
			cPosFr1, ;
			cPosGl2, ;
			cPosFr2, ;
			cPosGl3 )

		// upisi <POS>
		write_rec( nH, aPos, aPosSpec )

		// da li ima za dodatne informacije <PO2> ?
		if lChange == .t. 
	
			aPo2 := add_po2( "", ;
				nW1, ;
				nH1, ;
				0, 0, 0, 0, 0, 0, 0, 0, ;
				nW2, ;
				nH2, ;
				0, 0, 0, 0, 0, 0, 0, 0, ;
				nW3, ;
				nH3, ;
				0, 0, 0, 0, 0, 0, 0, 0 )
		
			// upisi <PO2>
			write_rec( nH, aPo2, aPo2Spec )
		endif

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

BoxC()

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





