#include "\dev\fmk\rnal\rnal.ch"


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

// napuni matrice sa specifikacijama record-a
aRelSpec := _get_rel()
aOrdSpec := _get_ord()
aPosSpec := _get_pos()
aPo2Spec := _get_po2()
aTxtSpec := _get_txt(1)
aTx2Spec := _get_txt(2)
aTx3Spec := _get_txt(3)

if lTemporary == nil
	lTemporary := .f.
endif

if lWriteRel == nil
	lWriteRel := .f.
endif

if lTemporary == .t.
	nADOCS := F__DOCS
	nADOC_IT := F__DOC_IT
endif

select (nADOCS)
go top
seek docno_str( nDoc_no )

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

// nadji naziv narucioca
select customs
set filter to
set order to tag "1"
go top
seek custid_str(nCustid)

select (nADOCS)

// ako su podaci ispravni
if field->cust_id <> 0

	// uzmi i upisi osnovne elemente naloga
	aOrd := add_ord( field->doc_no , ;
		field->cust_id , ;
		ALLTRIM( customs->cust_desc ) , ;
		ALLTRIM( field->doc_desc ) , ;
		ALLTRIM( field->doc_sh_desc ) , ;
		ALLTRIM( field->cont_add_desc ) , ;
		nil, ;
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

	nArt_id := field->art_id
	
	select articles
	set order to tag "1"
	seek artid_str( nArt_id )

	select (nADOC_IT)
	
	cGl1 := ""
	cGl2 := ""
	cGl3 := ""
	cFr1 := ""
	cFr2 := ""
	
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
		endif
		
		if i == 2
			cFr1 := aArtDesc[i]
		endif
		
		if i == 3
			cGl2 := aArtDesc[i]
		endif
		
		if i == 4
			cFr2 := aArtDesc[i]
		endif
		
		if i == 5
			cGl3 := aArtDesc[i]
		endif
	
	next
	
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
			cGl1, ;
			cFr1, ;
			cGl2, ;
			cFr2, ;
			cGl3 )

		// upisi <POS>
		write_rec( nH, aPos, aPosSpec )

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



