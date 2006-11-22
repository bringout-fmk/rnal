#include "\dev\fmk\rnal\rnal.ch"


// variables
static __doc_no



// -------------------------------------------
// logiranje promjena pri operaciji azuriranja
// dokumenta
// -------------------------------------------
function doc_logit()
local cDesc := ""
local aArr

select _docs
go top

__doc_no := field->doc_no

// logiraj osnovne podatke
cDesc := "Inicijalni osnovni podaci"

aArr := a_log_main(field->cust_id, ;
		field->doc_pay_id, ;
		field->doc_priority )

log_main(__doc_no, cDesc, nil, aArr)

select _docs
go top

// logiraj podatke o isporuci
cDesc := "Inicijalni podaci isporuke"
aArr := a_log_ship( field->doc_dvr_date, ;
		field->doc_dvr_time, ;
		field->doc_ship_place)
		
log_ship(__doc_no, cDesc, nil, aArr)

select _docs
go top

// logiranje podataka o kontaktu
cDesc := "Inicijalni podaci kontakta"
aArr := a_log_cont( field->cont_id, field->cont_add_desc )

log_cont(__doc_no, cDesc, nil, aArr)


select _doc_it
go top

// logiranje artikala
cDesc := "Inicijalni podaci stavki"

log_items(__doc_no, cDesc)


return


// -------------------------------------------------
// puni matricu sa osnovnim podacima dokumenta
// aArr = { customer_id, doc_pay_id, doc_priority }
// -------------------------------------------------
function a_log_main(nCustId, nDocPay, nPriority)
local aArr := {}
AADD(aArr, { nCustId, nDocPay, nPriority })
return aArr


// -------------------------------------------------
// puni matricu sa podacima isporuke
// aArr = { doc_dvr_date, doc_dvr_time, doc_ship_place }
// -------------------------------------------------
function a_log_ship(dDate, cTime, cPlace)
local aArr := {}
AADD(aArr, { dDate, cTime, cPlace })
return aArr


// -------------------------------------------------
// puni matricu sa podacima kontakta
// aArr = { cont_id, cont_add_desc }
// -------------------------------------------------
function a_log_cont(nCont_id, cCont_desc)
local aArr := {}
AADD(aArr, { nCont_id, cCont_desc })
return aArr





// ----------------------------------------------------
// logiranje osnovnih podataka
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aMain - matrica sa osnovnim podacima
// ----------------------------------------------------
function log_main( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "10"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_10_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return


// -----------------------------------
// punjenje loga sa stavkama tipa 10
// -----------------------------------
function _lit_10_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with aArr[1, 1]
replace int_2 with aArr[1, 2]
replace int_3 with aArr[1, 3]
replace doc_lit_action with cAction

return



// ----------------------------------------------------
// logiranje podataka isporuke
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aArr - matrica sa podacima
// ----------------------------------------------------
function log_ship( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "11"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_11_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return


// -----------------------------------
// punjenje loga sa stavkama tipa 11
// -----------------------------------
function _lit_11_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace date_1 with aArr[1, 1]
replace char_1 with aArr[1, 2]
replace char_2 with aArr[1, 3]
replace doc_lit_action with cAction

return


// ----------------------------------------------------
// logiranje podataka kontakata
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aArr - matrica sa podacima
// ----------------------------------------------------
function log_cont( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "12"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_12_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return


// -----------------------------------
// punjenje loga sa stavkama tipa 12
// -----------------------------------
function _lit_12_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with aArr[1, 1]
replace char_1 with aArr[1, 2]
replace doc_lit_action with cAction

return



// ----------------------------------------------------
// logiranje podataka stavki naloga
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aArr - matrica sa podacima
// ----------------------------------------------------
function log_items( nDoc_no, cDesc, cAction )
local nDoc_log_no
local cDoc_log_type

select _doc_it
if RECCOUNT2() == 0
	return
endif

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "20"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

select _doc_it
go top
seek docno_str(nDoc_no)

do while !EOF() .and. field->doc_no == nDoc_no

	_lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
			field->art_id,  ;
			field->doc_it_qtty,  ;
			field->doc_it_heigh, ;
			field->doc_it_width )
	
	select _doc_it
	skip
	
enddo

return


// -----------------------------------
// punjenje loga sa stavkama tipa 12
// -----------------------------------
function _lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			nArt_id, nArt_qtty, nArt_heigh, nArt_width)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace art_id with nArt_id
replace num_1 with nArt_qtty
replace num_2 with nArt_heigh
replace num_3 with nArt_width
replace doc_lit_action with cAction

return



// --------------------------------------------
// dodaje zapis u tabelu doc_log
// --------------------------------------------
function _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
local nOperId
local nTArea := SELECT()

nOperId := GetUserID()

select doc_log
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_log_date with DATE()
replace doc_log_time with PADR(TIME(), 5)
replace doc_log_type with cDoc_log_type
replace operater_id with nOperId
replace doc_log_desc with cDesc

select (nTArea)
return



//-------------------------------------------------------
// vraca sljedeci redni broj dokumenta u DOC_LOG tabeli
//-------------------------------------------------------
function _inc_log_no( nDoc_no )
local nLastNo:=0

PushWa()

select doc_log
set order to tag "1"
go top

seek docno_str( nDoc_no )

do while !EOF() .and. (field->doc_no == nDoc_no)
	nLastNo := field->doc_log_no
	skip
enddo

PopWa()

return nLastNo + 1



// ----------------------------------------------
// konvert doc_log_no -> STR(doc_log_no,10)
// ----------------------------------------------
static function doclog_str(nId)
return STR(nId,10)



//------------------------------------------------
// vraca sljedeci doc_lit_no u tabeli DOC_LIT
//------------------------------------------------
static function _inc_lit_no( nDoc_no, nDoc_log_no )
local nLastNo:=0

PushWa()
select doc_lit
set order to tag "1"
go top
seek docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

do while !EOF() .and. (field->doc_no == nDoc_no) ;
		.and. (field->doc_log_no == nDoc_log_no)
	
	nLastNo := field->doc_lit_no
	skip
	
enddo
PopWa()

return nLastNo + 1



// -----------------------------------------------
// logiranje delte izmedju kumulativa i pripreme
// -----------------------------------------------
function doc_delta( nDoc_no, cDesc )
local nTArea := SELECT()

if cDesc == nil
	cDesc := ""
endif

select _docs
set filter to
select _doc_it
set filter to
select _doc_ops
set filter to
select docs
set filter to
select doc_ops
set filter to
select doc_it
set filter to

// delta stavki dokumenta
_doc_it_delta( nDoc_no, cDesc )

// delta dodatnih operacija dokumenta
//_doc_op_delta( nDoc_no, cDesc )

select (nTArea)

return


// -------------------------------------------------
// function _doc_it_delta() - delta stavki dokumenta
// nDoc_no - broj naloga
// funkcija gleda _doc_it na osnovu doc_it i trazi
// 1. stavke koje nisu iste
// 2. stavke koje su izbrisane
// -------------------------------------------------
static function _doc_it_delta( nDoc_no, cDesc )
local nDoc_log_no
local cDoc_log_type := "20"
local cAction
local lLogAppend := .f.

// uzmi sljedeci broj DOC_LOG
nDoc_log_no := _inc_log_no( nDoc_no )

// pozicioniraj se na trazeni dokument
select doc_it
set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nArt_id := field->art_id
	nDoc_it_qtty := field->doc_it_qtty
	nDoc_it_heigh := field->doc_it_heigh
	nDoc_it_width := field->doc_it_width
	
	// DOC_IT -> _DOC_IT - provjeri da li je sta brisano
	// akcija "-"
	
	if !item_exist( nDoc_no, nDoc_it_no, nArt_id, .f.)
		
		cAction := "-"
		
		_lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			   nArt_id , ;
			   nDoc_it_qtty , ;
			   nDoc_it_heigh , ;
			   nDoc_it_width )
			
		lLogAppend := .t.
		
		select doc_it
		
		skip
		loop
		
	endif

	// DOC_IT -> _DOC_IT - da li je sta mjenjano od podataka 
	// akcija "E"
	
	if !item_value(nDoc_no, nDoc_it_no, nArt_id, ;
		      nDoc_it_qtty, ;
		      nDoc_it_heigh, ;
		      nDoc_it_width, .f.)
		
		cAction := "E"
		
		_lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			   _doc_it->art_id, ;
			   _doc_it->doc_it_qtty, ;
			   _doc_it->doc_it_heigh, ;
			   _doc_it->doc_it_width )
	
		lLogAppend := .t.
	endif
	
	select doc_it
	
	skip
enddo

// pozicioniraj se na _DOC_IT
select _doc_it
set order to tag "1"
go top
seek docno_str(nDoc_no)

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nArt_id := field->art_id
	nDoc_it_qtty := field->doc_it_qtty
	nDoc_it_heigh := field->doc_it_heigh
	nDoc_it_width := field->doc_it_width
	
	// _DOC_IT -> DOC_IT, da li stavka postoji u kumulativu
	// akcija "+"
	
	if !item_exist(nDoc_no, nDoc_it_no, nArt_id, .t.)
		
		cAction := "+"
		
		_lit_20_insert(cAction, nDoc_no, nDoc_it_no, ;
			   nArt_id, ;
			   nDoc_it_qtty, ;
			   nDoc_it_heigh, ;
			   nDoc_it_width)

		lLogAppend := .t.
	
	endif
	
	select _doc_it
	
	skip
enddo

altd()

// bilo je promjena dodaj novi log zapis
if lLogAppend 
	_d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
endif

return


/*
// -------------------------------------------------
// function op_delta() - delta operacija naloga
// -------------------------------------------------
static function op_delta(nBr_nal, cOpis)
local nR_br
local nP_br
local cAkcija
local nLOGR_br
local cTip := "30"
local lSetRNLOG := .f.
local cOperater := goModul:oDataBase:cUser
local cIdOper
local cIdKarakt
local cInstr
local cItemID

// uzmi sljedeci broj RNLOG
nLOGR_br := n_log_rbr( nBr_nal )

// pozicioniraj se na trazeni radni nalog
select rnop
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cIdOper := field->id_rnop
	cIdKarakt := field->id_rnka
	cItemID := field->item_id
	cInstr := field->rn_instr
	
	// provjeri da li rnop(stavka) postoji u p_rnop 
	// akcija "-"
	
	if !op_exist(nBr_nal, nR_br, nP_br, cItemID, cIdOper, cIdKarakt, .f.)
		
		cAkcija := "-"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br,;
			   cItemID, ;
			   "", ;
			   cIdOper, ;
			   cIdKarakt, ;
			   cInstr)
			
		lSetRNLOG := .t.
		
		select rnop
		skip
		loop
		
	endif

	// provjeri integritet stavki RNOP <-> P_RNOP (idroba)
	// akcija "E"
	
	if !op_value(nBr_nal, nR_br, nP_br, cItemID, cIdOper, ;
		      cIdKarakt, cInstr, .f.)
		
		cAkcija := "E"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br, ;
			   cItemID, ;
			   "", ;
			   cIdOper, ;
			   cIdKarakt, ;
			   cInstr)
	
		lSetRNLOG := .t.
	endif
	
	select rnop
	skip
enddo

// pozicioniraj se na P_RNOP
select p_rnop
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cIdOper := field->id_rnop
	cIdKarakt := field->id_rnka
	cItemID := field->item_id
	cInstr := field->rn_instr

	// provjeri da li stavka postoji u kumulativu
	// akcija "+"
	
	if !op_exist(nBr_nal, nR_br, nP_br, cItemID, cIdOper, cIdKarakt, .t.)
		
		cAkcija := "+"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br,;
			   cItemID, ;
			   "", ;
			   cIdOper, ;
			   cIdKarakt, ;
			   cInstr)
	
		lSetRNLOG := .t.
	
	endif
	
	select p_rnst
	skip
enddo

// ako je bilo promjena upisi i u RNLOG...
if lSetRNLOG 
	f_rnlog(nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
endif

return
*/


// --------------------------------------
// da li postoji item u tabelama
// _DOC_IT, DOC_IT
// --------------------------------------
static function item_exist( nDoc_no, nDoc_it_no, nArt_id, lKumul)
local nF_DOC_IT := F__DOC_IT
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if ( lKumul == .t. )
	nF_DOC_IT := F_DOC_IT
endif

select (nF_DOC_IT)
set order to tag "1"
go top

seek docno_str(nDoc_no) + docno_str(nDoc_it_no) + artid_str(nArt_id)

if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet



// --------------------------------------
// da li je stavka sirovina ista....
// --------------------------------------
static function item_value(nDoc_no, nDoc_it_no, nArt_id,;
			   nDoc_it_qtty, nDoc_it_heigh, nDoc_it_width, lKumul)
local nF_DOC_IT := F__DOC_IT
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if (lKumul == .t.)
	nF_DOC_IT := F_DOC_IT
endif

select (nF_DOC_IT)
set order to tag "1"
go top
seek docno_str(nDoc_no) + docno_str(nDoc_it_no) + artid_str(nArt_id)
 
if (field->doc_it_qtty == nDoc_it_qtty) .and. ;
   (field->doc_it_heigh == nDoc_it_heigh) .and. ;
   (field->doc_it_width == nDoc_it_width)
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet




// ----------------------------------------------
// vraca string napunjen promjenama tipa "20"
// ----------------------------------------------
function _lit_20_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()
local nTRec := RECNO()
local cTBFilter := DBFILTER()

select doc_log
set order to tag "2"
go top
seek docno_str( nDoc_no ) + "20" + doclog_str( nDoc_log_no )


select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "artikal: " + PADR(g_art_desc( field->art_id ), 10)
	cRet += "#"
	cRet += "kol.=" + ALLTRIM(STR(field->num_1, 8, 2))
	cRet += ","
	cRet += "vis.=" + ALLTRIM(STR(field->num_2, 8, 2))
	cRet += ","
	cRet += "sir.=" + ALLTRIM(STR(field->num_3, 8, 2))
	cRet += "#"
	
	select doc_lit
	
	skip
enddo

select (nTArea)
set order to tag "1"
set filter to &cTBFilter
go (nTRec)

return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "01"
// ----------------------------------------------
function _lit_01_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()
local nTRec := RECNO()
local cTBFilter := DBFILTER()

select doc_log
set order to tag "1"
go top
seek docno_str(nDoc_no) + "01" + doclog_str(nDoc_log_no)

cRet += "Otvaranje naloga...#"
	
set order to tag "1"

select (nTArea)
set order to tag "1"
set filter to &cTBFilter
go (nTRec)

return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "10"
// ----------------------------------------------
function _lit_10_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()
local nTRec := RecNo()
local cTbFilter := DBFILTER()

select doc_log
set order to tag "2"
go top
seek docno_str(nDoc_no) + "10" + doclog_str(nDoc_log_no)

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "narucioc: " + PADR( g_cust_desc( field->int_1 ), 20)
	cRet += "#"
	cRet += "vrsta placanja: " + ALLTRIM(STR(field->int_2))
	cRet += "#"
	cRet += "prioritet: " + ALLTRIM(STR(field->int_3))
	cRet += "#"
	
	select doc_lit
	skip
enddo

select (nTArea)
set filter to &cTBFilter
go (nTRec)

return cRet


