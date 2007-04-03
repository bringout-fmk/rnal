#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// export u FMK
// ------------------------------------------
function exp_2_fmk( nDoc_no, lTemp )
local nTArea := SELECT()
local nADOCS := F_DOCS
local nADOC_IT := F_DOC_IT
local nCust_id

// select pripreme fakt
select (245)
use ( ALLTRIM(gFaPrivDir) + "PRIPR" ) alias X_TBL

if RECCOUNT2() > 0
	
	msgbeep("priprema fakt nije prazna !")
	select (nTArea)
	return
		
endif

if lTemp == nil
	lTemp := .f.
endif

if lTemp == .t.
	nADOCS := F__DOCS
	nADOC_IT := F__DOC_IT
endif

select (nADOCS)
set order to tag "1"
seek docno_str( nDoc_no )

nCust_id := field->cust_id

cPartn := PADR( g_rel_val("1", "CUSTOMS", "PARTN", ALLTRIM(STR(nCust_id)) ), 6 )
cBrDok := "99999999"
cIdVd := "12"
dDatDok := DATE()

select (nADOC_IT)
set order to tag "3"
seek docno_str( nDoc_no )

nRbr := 0

do while !EOF() .and. field->doc_no == nDoc_no

	nArt_id := field->art_id
	cIdRoba := g_rel_val("1", "ARTICLES", "ROBA", ALLTRIM(STR(nArt_id)) )

	nQty := 0

	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->art_id == nArt_id

		nQty += field->doc_it_qtty
		
		skip
		
	enddo
	
	
	select X_TBL
	append blank

	scatter()
	
	_rbr := STR( ++nRbr, 3 )
	_idpartner := cPartn
	_idfirma := "10"
	_brdok := cBrDok
	_idtipdok := cIdVd
	_datdok := dDatDok
	_idroba := cIdRoba
	_kolicina := nQty
	_dindem := "KM "
	_zaokr := 2

	gather()

	select (nADOC_IT)
	skip
	
enddo

select (245)
use

msgbeep("export dokumenta zavrsen !")

select (nTArea)
return



