#include "rnal.ch"


static __doc_no
static __op_1 := 0
static __op_2 := 0
static __op_3 := 0
static __op_4 := 0
static __op_5 := 0
static __op_6 := 0
static __opa1 := 0
static __opa2 := 0
static __opa3 := 0
static __opa4 := 0
static __opa5 := 0
static __opa6 := 0

// ------------------------------------------
// osnovni poziv pregleda proizvodnje
// ------------------------------------------
function m_get_rpro()

local dD_From := CTOD("")
local dD_to := DATE()
local nOper := 0
local cArticle := SPACE(100)

o_sif_tables()

// daj uslove izvjestaja
if _g_vars( @dD_From, @dD_To, @nOper, @cArticle ) == 0
 	return 
endif

// kreiraj specifikaciju po uslovima
_cre_spec( dD_from, dD_to, nOper, cArticle )

// printaj specifikaciju
_p_rpt_spec( )


return



// ----------------------------------------
// uslovi izvjestaja specifikacije
// ----------------------------------------
static function _g_vars( dDatFrom, dDatTo, nOperater, cArticle )

local nRet := 1
local nBoxX := 15
local nBoxY := 70
local nX := 1
local nOp1 := nOp2 := nOp3 := nOp4 := nOp5 := nOp6 := 0
local nOpA1 := nOpA2 := nOpA3 := nOpA4 := nOpA5 := nOpA6 := 0
local cOp1 := cOp2 := cOp3 := cOp4 := cOp5 := cOp6 := SPACE(10)
local cOpA1 := cOpA2 := cOpA3 := cOpA4 := cOpA5 := cOpA6 := SPACE(10)

private GetList := {}

Box(, nBoxX, nBoxY)

	@ m_x + nX, m_y + 2 SAY "*** Pregled ucinka proizvodnje"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Obuhvatiti period od:" GET dDatFrom
	@ m_x + nX, col() + 1 SAY "do:" GET dDatTo

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Artikal/element (prazno-svi):" GET cArticle PICT "@S30"

	nX += 1

	@ m_x + nX, m_y + 2 SAY "-------------- operacije " 

	nX += 1

	@ m_x + nX, m_y + 2 SAY "operacija:" GET cOp1 ;
		VALID {|| s_aops(@cOp1, cOp1), set_var(@nOp1, @cOp1) }
	@ m_x + nX, col() + 2 SAY "podoper.:" GET cOpA1 ;
		VALID {|| s_aops_att( @cOpA1, nOp1, cOpA1 ), ;
		set_var(@nOpA1, @cOpA1) }
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "operacija:" GET cOp2 ;
		VALID {|| s_aops(@cOp2, cOp2), set_var(@nOp2, @cOp2) }
	@ m_x + nX, col() + 2 SAY "podoper.:" GET cOpA2 ;
		VALID {|| s_aops_att( @cOpA2, nOp2, cOpA2 ), ;
		set_var(@nOpA2, @cOpA2) }
	
	nX += 1

	
	@ m_x + nX, m_y + 2 SAY "-------------- ostali uslovi " 
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "Operater (0 - svi op.):" GET nOperater VALID {|| nOperater == 0 .or. p_users( @nOperater ) } PICT "999"
	
	nX += 2
	
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

// operacije
__op_1 := nOp1
__op_2 := nOp2
__op_3 := nOp3
__op_4 := nOp4
__op_5 := nOp5
__op_6 := nOp6

// podoperacije
__opa1 := nOpA1
__opa2 := nOpA2
__opa3 := nOpA3
__opa4 := nOpA4
__opa5 := nOpA5
__opa6 := nOpA6

return nRet



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_spec( dD_from, dD_to, nOper, cArticle )
local nDoc_no
local cArt_id
local aArt := {}
local nCount := 0
local cCust_desc
local nAop_1 := nAop_2 := nAop_3 := nAop_4 := nAop_5 := nAop_6 := 0

// kreiraj tmp tabelu
aField := _spec_fields()

cre_tmp1( aField )
O__TMP1

// kreiraj indekse
index on art_id + STR(tick, 10, 2) tag "1"  
index on STR(cust_id, 10, 0) + art_id + STR(tick, 10, 2) tag "2" 

// otvori potrebne tabele
o_tables( .f. )

select doc_ops
go top

Box(, 1, 50 )

do while !EOF()

	nDoc_no := field->doc_no
	
	@ m_x + 1, m_y + 2 SAY "... vrsim odabir stavki ... nalog: " + ALLTRIM( STR(nDoc_no) )
	
	select docs
	set order to tag "1"
	go top
	seek docno_str( nDoc_no )

	nCust_id := field->cust_id

	// provjeri da li ovaj dokument zadovoljava kriterij
	
	if field->doc_status > 1 
		
		// uslov statusa dokumenta
		select doc_ops
		skip
		loop

	endif

	if DTOS( field->doc_date ) > DTOS( dD_To ) .or. ;
		DTOS( field->doc_date ) < DTOS( dD_From )
	
		// datumski period
		select doc_ops
		skip
		loop

	endif

	if nOper <> 0

		// po operateru
		
		if ALLTRIM( STR( field->operater_id )) <> ;
			ALLTRIM( STR( nOper ) )
			
			select doc_ops
			skip
			loop

		endif
	endif

	select doc_ops
	
	nDoc_it_no := field->doc_it_no

	// pronadji stavku u items
	// i daj osnovne parametre, kolicinu, sirinu, visinu...

	select doc_it
	set order to tag "1"
	go top
	seek docno_str( nDoc_no ) + docit_str( nDoc_it_no )

	nArt_id := field->art_id
	nQtty := field->doc_it_qtty
	nHeight := field->doc_it_height
	nWidth := field->doc_it_width

	// koliko kvadrata ?
	nTot_m2 := c_ukvadrat( nQtty, nWidth, nHeight )

	// setuj matricu artikla
	_art_set_descr( nArt_id, nil, nil, @aArt, .t. )

	// prebaci se opet na operacije i vidi da li one zadovoljavaju
	select doc_ops
	
	// element artikla nad kojim je operacija izvrsena
	nEl_no := field->doc_it_el_no
	cAopValue := field->aop_value

	aElem := {}
	nElem_no := 0
	
	_g_art_elements( @aElem, nArt_id )
	
	// vrati broj elementa artikla (1, 2, 3 ...)
	_g_elem_no( aElem, nEl_no, @nElem_no )
	
	//cArt_id := get_elem_desc( aElem, nEl_no, 30 )

	// sifra artikla - identifikator "4FL", "6O" itd...
	cArt_id := g_el_descr( aArt, nElem_no )
	cArt_desc := ""

	// debljina stakla
	nTick := g_gl_el_tick( aArt, nElem_no )
	
	// aArr[1] = { 1, "G", "staklo", "<GL_TYPE>", "FL", "FLOAT" }
	// aArr[2] = { 1, "G", "staklo", "<GL_TICK>", "4", "4mm" }
	// aArr[3] = { 2, "F", "distancer", "<FR_TYPE>", "A", "Aluminij" }

	// operacija-1  .T. ?
	if _in_oper_( __op_1, __opa1, field->aop_id, field->aop_att_id )
		nAop_1 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_1, cAopValue )
	endif
	
	// operacija-2  .T. ?
	if _in_oper_( __op_2, __opa2, field->aop_id, field->aop_att_id )
		nAop_2 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_2, cAopValue )
	endif

	if ( nAop_1 + nAop_2 + nAop_3 + nAop_4 + nAop_5 + nAop_6 ) <> 0
	
		// upisi u tabelu
	
		select customs
		go top
		seek custid_str( nCust_id )
		cCust_desc := field->cust_desc
		
		_ins_tmp1( nCust_id, ;
			cCust_desc, ;
			cArt_id, ;
			cArt_desc, ;
			nTick, ;
			nWidth, ;
			nHeight, ;
			nQtty, ;
			nTot_m2, ;
			nAop_1, ;
			nAop_2, ;
			nAop_3, ;
			nAop_4, ;
			nAop_5, ;
			nAop_6 )
	
		++ nCount
	
	endif

	// resetuj vrijednosti
	nAop_1 := 0
	nAop_2 := 0
	nAop_3 := 0
	nAop_4 := 0
	nAop_5 := 0
	nAop_6 := 0

	select doc_ops
	skip
	
enddo

BoxC()

return


// ------------------------------------------------------------
// kalkulisi operaciju nad elementom
// ------------------------------------------------------------
static function _calc_oper( nQtty, nH, nW, nOp, cValue )
local xRet := 0
local nTArea := SELECT()
local nU_m2 := c_ukvadrat( nQtty, nH, nW )

cJoker := g_aop_joker( nOp )

// iscupaj na osnovu jokera kako se racuna operacija
// kolicina, m ili m2

xRet := nU_m2

select ( nTArea )

return xRet


// ----------------------------------------------------------
// da li je zadovoljen uslov operacije ?
// ----------------------------------------------------------
static function _in_oper_( nOp, nOpA, nFldOp, nFldOpA )
local lRet := .t.

// ako je operacija 0 - nista od toga
// ili ako se ne slaze sa operacijom iz polja

if ( nOp <> 0 .and. nOp <> nFldOp )
	lRet := .f.
endif

return lRet




// ------------------------------------------
// stampa specifikacije
// stampa se iz _tmp0 tabele
// ------------------------------------------
static function _p_rpt_spec()

START PRINT CRET

?
P_COND2

// naslov izvjestaja
_rpt_descr()
// info operater, datum
__rpt_info()
// header
_rpt_head()

select _tmp1
set order to tag "1"
go top

do while !EOF()

	? field->art_id, PADR(field->art_desc, 10), field->qtty, field->tick, ;
		field->total, field->aop_1, field->aop_2, field->aop_3, ;
		field->aop_4, field->aop_5, field->aop_6

	skip

enddo

FF
END PRINT

return


// -----------------------------------
// provjerava za novu stranu
// -----------------------------------
static function _nstr()
local lRet := .f.

if prow() > 62
	lRet := .t.
endif

return lRet



// ------------------------------------------------
// ispisi naziv izvjestaja po varijanti
// ------------------------------------------------
static function _rpt_descr()
local cTmp := "rpt: "

cTmp += "Pregled ucinka proizvodnje za period"

? cTmp

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head()

cLine := REPLICATE("-", 50) 
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 20)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

cTxt := PADR("Artikal / element (id, opis)", 50)
cTxt += SPACE(1)
cTxt += PADR("Kolicina", 10)
cTxt += SPACE(1)
cTxt += PADR("Debljina", 10)
cTxt += SPACE(1)
cTxt += PADR("ukupno m2", 12)

? cLine
? cTxt
? cLine

return



// -----------------------------------------------
// vraca strukturu polja tabele _tmp1
// -----------------------------------------------
static function _spec_fields()
local aDbf := {}

AADD( aDbf, { "cust_id",  "N", 10, 0 })
AADD( aDbf, { "cust_desc", "C", 100, 0 })
AADD( aDbf, { "art_id",  "C", 30, 0 })
AADD( aDbf, { "art_desc", "C", 100, 0 })
AADD( aDbf, { "tick", "N", 10, 2 })
AADD( aDbf, { "width", "N", 15, 5 })
AADD( aDbf, { "height", "N", 15, 5 })
AADD( aDbf, { "qtty", "N", 15, 5 })
AADD( aDbf, { "total", "N", 15, 5 })
AADD( aDbf, { "aop_1", "N", 15, 5 })
AADD( aDbf, { "aop_2", "N", 15, 5 })
AADD( aDbf, { "aop_3", "N", 15, 5 })
AADD( aDbf, { "aop_4", "N", 15, 5 })
AADD( aDbf, { "aop_5", "N", 15, 5 })
AADD( aDbf, { "aop_6", "N", 15, 5 })

return aDbf


// -----------------------------------------------
// vraca formatiran string za seek
// -----------------------------------------------
static function tick_str( nTick )
return STR( nTick, 10, 2 )


// -----------------------------------------------------
// insert into _tmp1
// -----------------------------------------------------
static function _ins_tmp1( nCust_id, cCust_desc, cArt_id, cArt_desc, ;
			nTick, nWidth, nHeight, nQtty, nTot_m2, ;
			nAop_1, nAop_2, nAop_3, nAop_4, nAop_5, nAop_6 )

local nTArea := SELECT()

select _tmp1
set order to tag "1"
go top

seek PADR( cArt_id, 30 ) + tick_str( nTick )

if !FOUND()
	
	APPEND BLANK
	
	replace field->cust_id with nCust_id
	replace field->cust_desc with cCust_desc

	replace field->art_id with cArt_id
	replace field->art_desc with cArt_desc

	replace field->tick with nTick

endif

replace field->width with ( field->width + nWidth )
replace field->height with ( field->height + nHeight )
replace field->qtty with ( field->qtty + nQtty )
replace field->total with ( field->total + nTot_m2 )
replace field->aop_1 with ( field->aop_1 + nAop_1 )
replace field->aop_2 with ( field->aop_2 + nAop_2 )
replace field->aop_3 with ( field->aop_3 + nAop_3 )
replace field->aop_4 with ( field->aop_4 + nAop_4 )
replace field->aop_5 with ( field->aop_5 + nAop_5 )
replace field->aop_6 with ( field->aop_6 + nAop_6 )

select (nTArea)
return



