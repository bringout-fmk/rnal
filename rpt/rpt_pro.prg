#include "rnal.ch"


static __doc_no
static __op_1 := 0
static __op_2 := 0
static __op_3 := 0
static __op_4 := 0
static __opa1 := 0
static __opa2 := 0
static __opa3 := 0
static __opa4 := 0

// ------------------------------------------
// osnovni poziv pregleda proizvodnje
// ------------------------------------------
function m_get_rpro()

local dD_From := CTOD("")
local dD_to := DATE()
local nOper := 0
local cArticle := SPACE(100)
local nOp1 := nOp2 := nOp3 := nOp4 := 0
local nOpA1 := nOpA2 := nOpA3 := nOpA4 := 0

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
local nOp1 := nOp2 := nOp3 := nOp4 := 0
local nOpA1 := nOpA2 := nOpA3 := nOpA4 := 0
local cOp1 := cOp2 := cOp3 := cOp4 := SPACE(10)
local cOpA1 := cOpA2 := cOpA3 := cOpA4 := SPACE(10)

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
		VALID {|| s_aops(@cOp1,cOp1), set_var(@nOp1, @cOp1) }
	@ m_x + nX, col() + 2 SAY "podoper.:" GET cOpA1 ;
		VALID {|| s_aops_att( @cOpA1, nOp1, cOpA1 ), ;
		set_var(@nOpA1, @cOpA1) }
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "operacija:" GET cOp2 ;
		VALID {|| s_aops(@cOp2,cOp2), set_var(@nOp2, @cOp2) }
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

__op_1 := nOp1
__op_2 := nOp2
__opa1 := nOpA1
__opa2 := nOpA2

return nRet



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_spec( dD_from, dD_to, nOper, cArticle )
local nDoc_no
local nArt_id
local aArtArr := {}
local nCount := 0
local cCust_desc
local aField
local nScan
local ii
local cAop
local cAopDesc
local aGrCount := {}
local nGr1 
local nGr2


// kreiraj tmp tabelu
aField := _spec_fields()

cre_tmp1( aField )
O__TMP1
index on el_id tag "1"  

// otvori potrebne tabele
o_tables( .f. )

_main_filter( dD_from, dD_to, nOper )

Box(, 1, 50 )

do while !EOF()

	nDoc_no := field->doc_no
	
	select doc_it
	set order to tag "1"
	go top
	seek docno_str( nDoc_no ) 

	do while !EOF() .and. field->doc_no == nDoc_no
		
		nDoc_it_no := field->doc_it_no
		nArt_id := field->art_id

		// da li element odgovara
		if __chk_elem( nArt_id, cArticle ) == 0
			select doc_it
			skip 
			loop
		endif
	
		// da li operacija odgovara
		if __chk_oper( nDoc_no, nDoc_it_no ) == 0
			select doc_it
			skip
			loop
		endif

		select articles
		go top
		seek artid_str(nArt_id)


		select doc_it

		cEl_id := articles->art_desc
		cEl_desc := ""
		nQtty := field->doc_it_qtty
		nEl_tick := 0
		cEl_type := ""

		_ins_tmp1( cEl_id, ;
			cEl_desc, ;
			nEl_tick, ;
			cEl_type, ;
			nQtty )

		++ nCount
		
		@ m_x + 1, m_y + 2 SAY "nalog broj: " + ALLTRIM( STR(nDoc_no) )
	
		select doc_it
		skip
		
	enddo
	
	select docs
	skip
	
enddo

BoxC()


return


// -------------------------------------------------
// provjeri da li ovaj artikal zadovoljava
// -------------------------------------------------
static function __chk_elem( nArt_id, cArticle )
local nRet := 0
local nTArea := SELECT()
local nLen := LEN( ALLTRIM( cArticle ) )

if EMPTY(cArticle)
	return 1
endif

select articles
seek artid_str( nArt_id )

if FOUND() .and. field->art_id == nArt_id
	if LEFT( field->art_desc, nLen ) == ALLTRIM(cArticle)
		return 1
	else
		return 0
	endif
endif

select (nTArea)

return nRet

// -------------------------------------------------
// provjeri operacije 
// -------------------------------------------------
static function __chk_oper( nDoc_no, nDoc_it_no )
local nRet := 0

select DOC_OPS
set order to tag "1"
go top
seek docno_str(nDoc_no) + docit_str( nDoc_it_no )

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_it_no == nDoc_it_no

	// oper.1
	if _in_oper_( __op_1, __opa1, field->aop_id, field->aop_att_id )
		return 1
	endif
	
	// oper.2
	if _in_oper_( __op_2, __opa2, field->aop_id, field->aop_att_id )
		return 1
	endif
	
	skip
enddo

return nRet


static function _in_oper_( nOp, nOpA, nFldOp, nFldOpA )

if nOp == 0 
	return .t.
endif

if nOp <> 0 .and. nOp <> nFldOp
	return .f.
else
	if nOpA <> 0 .and. nOpA <> nFldOpA
		return .f.
	endif
endif

return .t.


static function _main_filter( dDFrom, dDTo, nOper )
local cFilter := ""

cFilter += "(doc_status == 0 .or. doc_status > 2)"
cFilter += " .and. DTOS(doc_date) >= " + cm2str(DTOS(dDFrom))
cFilter += " .and. DTOS(doc_date) <= " + cm2str(DTOS(dDTo))

if nOper <> 0
	
	cFilter += ".and. ALLTRIM(STR(operater_id)) == " + cm2str( ALLTRIM( STR( nOper ) ) )
	
endif

select docs
set filter to &cFilter
go top
	
return





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
	
	cEl_id := field->el_id
	nQtty := 0
	nTick := 0
	cType := ""
	cDesc := ""
	
	do while !EOF() .and. field->el_id == cEl_id
		
		nTick := field->el_tick
		cType := field->el_type
		cDesc := field->el_desc

		nQtty += field->qtty
		
		skip

	enddo

	? PADR(  ALLTRIM(cEl_id) + " " + ALLTRIM(cDesc)  , 50), ;
		nTick, PADR( cType, 20 ), nQtty

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
cTxt += PADR("Debljina", 10)
cTxt += SPACE(1)
cTxt += PADR("Tip", 20)
cTxt += SPACE(1)
cTxt += PADR("Kolicina", 12)

? cLine
? cTxt
? cLine

return



// -----------------------------------------------
// vraca strukturu polja tabele _tmp1
// -----------------------------------------------
static function _spec_fields()
local aDbf := {}

AADD( aDbf, { "el_id", "C", 100, 0 })
AADD( aDbf, { "el_desc", "C", 200, 0 })
AADD( aDbf, { "el_tick", "N", 4, 0 })
AADD( aDbf, { "el_type", "C", 100, 0 })
AADD( aDbf, { "qtty", "N", 15, 5 })

return aDbf


// -----------------------------------------------------
// insert into _tmp1
// -----------------------------------------------------
static function _ins_tmp1( cEl_id, cEl_desc, nEl_tick, ;
		cEl_type, nQtty )

local nTArea := SELECT()

O__TMP1
select _tmp1
	
APPEND BLANK
	
replace field->el_id with cEl_id
replace field->el_desc with cEl_desc
replace field->el_tick with nEl_tick
replace field->el_type with cEl_type
replace field->qtty with ( field->qtty + nQtty ) 

select (nTArea)
return



