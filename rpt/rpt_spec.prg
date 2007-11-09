#include "\dev\fmk\rnal\rnal.ch"


static __nvar
static __doc_no
static __temp


// ------------------------------------------
// osnovni poziv specifikacije
// ------------------------------------------
function m_get_spec( nVar )
local dD_From := DATE() - 1
local dD_to := DATE()
local nGroup := 0
local nOper := 0

if nVar == nil
	nVar := 0
endif

__nVar := nVar

// gledaj kumulativne tabele
__temp := .f.

// daj uslove izvjestaja
if _g_vars( @dD_From, @dD_To, @nGroup, @nOper ) == 0
	return 
endif

// kreiraj specifikaciju po uslovima
_cre_spec( dD_from, dD_to, nGroup, nOper )

// printaj specifikaciju
_p_rpt_spec( nGroup )


return



// ----------------------------------------
// uslovi izvjestaja specifikacije
// ----------------------------------------
static function _g_vars( dDatFrom, dDatTo, nGroup, nOperater )
local nRet := 1
local nBoxX := 15
local nBoxY := 65
local nX := 1

private GetList := {}

Box(, nBoxX, nBoxY)

	@ m_x + nX, m_y + 2 SAY "*** Specifikacija radnih naloga za poslovodje"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Datum naloga od:" GET dDatFrom
	@ m_x + nX, col() + 1 SAY "do:" GET dDatTo

	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Operater (0 - svi op.):" GET nOperater VALID {|| nOperater == 0 .or. p_users( @nOperater ) } PICT "999"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "*** Selekcija grupe artikala "

	nX += 1

	@ m_x + nX, m_y + 2 SAY "(1) - rezano     (4) - IZO i rezano"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "(2) - kaljeno    (5) - IZO i kaljeno"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "(3) - bruseno    (6) - IZO i bruseno"
	
 	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "(7) - LAMI-RG"

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Grupa artikala (0 - sve grupe):" GET nGroup VALID nGroup >= 0 .and. nGroup < 8 PICT "9"
	
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_spec( dD_from, dD_to, nGroup, nOper )
local nDoc_no
local nArt_id
local aArtArr := {}
local nCount := 0
local cCust_desc
local aField
local aGrCount := {}

// kreiraj tmp tabelu
aField := _spec_fields()

cre_tmp1( aField )
O__TMP1

// otvori potrebne tabele
o_tables( .f. )

altd()

_main_filter( dD_from, dD_to, nOper )

Box(, 1, 50 )

do while !EOF()

	altd()

	nDoc_no := field->doc_no
	__doc_no := nDoc_no
	
	cCust_desc := ALLTRIM( g_cust_desc( docs->cust_id ) )
	
	cDoc_stat := g_doc_status( docs->doc_status )
	
	cDoc_oper := getusername( docs->operater_id )

	cDoc_prior := s_priority( docs->doc_priority )
	
	// get log if exist
	select doc_log
	set order to tag "1"
	go top

	seek docno_str( nDoc_no )

	do while !EOF() .and. field->doc_no == nDoc_no
		
		cLog := DTOC( field->doc_log_date ) 
		cLog += " / " 
		cLog += ALLTRIM( field->doc_log_time )
		cLog += " : "
		cLog += ALLTRIM( field->doc_log_desc )
		
		skip
	enddo
	
	// samo za log, koji nije inicijalni....
	if "Inicij" $ cLog
		cLog := ""
	endif
	
	aGrCount := {}
	
	select doc_it
	set order to tag "1"
	go top
	seek docno_str( nDoc_no )

	do while !EOF() .and. field->doc_no == nDoc_no
		
		nArt_id := field->art_id
		nDoc_it_no := field->doc_it_no
	
		// check group of item
		nIt_group := set_art_docgr( nArt_id, nDoc_no, nDoc_it_no )
		
		nScan := ASCAN(aGrCount, {|xVar| xVar[1] == nIt_Group })
		
		if nScan == 0
			AADD( aGrCount, { nIt_group })
		endif
		
		cDiv := ALLTRIM( STR( LEN(aGrCount) ) )
		
		cDoc_div := "(" + cDiv + "/" + cDiv + ")"
		
	
		// uzmi operaciju za ovu stavku naloga....
		// if exist
		
		cAop := " "
		
		select doc_ops
		set order to tag "1"
		go top
		seek docno_str( nDoc_no ) + docit_str( nDoc_it_no)

		do while !EOF() .and. field->doc_no == nDoc_no ;
				.and. field->doc_it_no == nDoc_it_no

			if !EMPTY( cAop )
				cAop += ", "
			endif
			
			cAop += ALLTRIM( g_aop_desc( field->aop_id ) )
			
			skip
		
		enddo

		select doc_it

		// item description
		cItem := ALLTRIM( STR(field->doc_it_qtty, 10, 2) )
		cItem += " x " 
		cItem += ALLTRIM( PADR( g_art_desc( nArt_id ), 60 ) )
		cItem += cAop

		_ins_tmp1( nDoc_no, ;
			cCust_desc, ;
			docs->doc_date , ;
			docs->doc_dvr_date, ;
			docs->doc_dvr_time, ;
			cDoc_stat, ;
			cDoc_prior, ;
			cDoc_div, ;
			docs->doc_desc, ;
			docs->doc_sh_desc, ;
			cDoc_oper, ;
			cItem, ;
			nIt_group, ;
			cLog )

		++ nCount
		
		@ m_x + 1, m_y + 2 SAY "nalog broj: " + ALLTRIM( STR(nDoc_no) )
	
		skip
		
	enddo
	
	select docs
	skip
	
enddo

BoxC()


return


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
static function _p_rpt_spec( nGroup )

START PRINT CRET

?
P_COND2

if gPrinter == "R"
	? "#%LANDS#"
endif

// naslov izvjestaja
_rpt_descr()
// info operater, datum
__rpt_info()
// header
_rpt_head()

select _tmp1
go top

do while !EOF()
	
	if nGroup <> 0
	
		// preskoci ako filterises po grupi
		if field->it_group <> nGroup
			skip
			loop
		endif
		
	endif


	if _nstr() == .t.
		FF
	endif
	
	nDoc_no := field->doc_no

	// ispisi prvu stavku

	? docno_str( field->doc_no )
	
	@ prow(), pcol() + 1 SAY PADR( field->cust_desc, 30 )
	
	@ prow(), pcol() + 1 SAY PADR( DToC( field->doc_date ) + " / " + ;
				DToC( field->doc_dvr_d ) + " / " + ;
				ALLTRIM( field->doc_dvr_t ), 30 )
	
	
	@ prow(), pcol() + 1 SAY PADR( PADR( field->doc_prior, 8 ) + " / " + ;
				PADR( field->doc_stat, 15 ), 30 )
	
	@ prow(), pcol() + 1 SAY PADR( field->doc_oper, 20 )
	
	@ prow(), pcol() + 1 SAY PADR( field->doc_sdesc, 50 )
	
	nCount := 0

	do while !EOF() .and. field->doc_no == nDoc_no
		
		if _nstr() == .t.
			FF
		endif
		
		++ nCount
		
		? SPACE(5)
		
		@ prow(), pcol() + 1 SAY STR(nCount, 3) + ") " + field->doc_item
	
		cLog := field->doc_log 
		cDiv := field->doc_div
		
		skip
	enddo
	
	? SPACE(5)
	@ prow(), pcol() + 1 SAY "DIV: " + cDiv
	
	// upisi i log na kraju
	if !EMPTY( cLog )
		
		@ prow(), pcol() + 2 SAY ", zadnja promjena:"
		
		@ prow(), pcol() + 1 SAY cLog
		
	endif

	?

enddo

FF
END PRINT


return


// -----------------------------------
// provjerava za novu stranu
// -----------------------------------
static function _nstr()
local lRet := .f.

if prow() > 55
	lRet := .t.
endif

return lRet



// ------------------------------------------------
// ispisi naziv izvjestaja po varijanti
// ------------------------------------------------
static function _rpt_descr()
local cTmp := "rpt: "

do case
	case __nvar == 1
		cTmp += "SPECIFIKACIJA NALOGA ZA POSLOVODJE"

	otherwise
		cTmp += "WITH NO NAME"
endcase

? cTmp

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head()

cLine := REPLICATE("-", 10) 
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 20)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)

cTxt := PADR("Nalog br.", 10)
cTxt += SPACE(1)
cTxt += PADR("Partner", 30)
cTxt += SPACE(1)
cTxt += PADR("Vremenski termini", 30)
cTxt += SPACE(1)
cTxt += PADR("Status/Prioritet", 30)
cTxt += SPACE(1)
cTxt += PADR("Operater", 20)
cTxt += SPACE(1)
cTxt += PADR("Opis naloga", 50)

? cLine
? cTxt
? cLine

return



// -----------------------------------------------
// vraca strukturu polja tabele _tmp1
// -----------------------------------------------
static function _spec_fields()
local aDbf := {}

AADD( aDbf, { "doc_no", "N", 10, 0 })
AADD( aDbf, { "cust_desc", "C", 50, 0 })
AADD( aDbf, { "doc_date", "D", 8, 0 })
AADD( aDbf, { "doc_dvr_d", "D", 8, 0 })
AADD( aDbf, { "doc_dvr_t", "C", 10, 0 })
AADD( aDbf, { "doc_stat", "C", 30, 0 })
AADD( aDbf, { "doc_prior", "C", 30, 0 })
AADD( aDbf, { "doc_oper", "C", 30, 0 })
AADD( aDbf, { "doc_div", "C", 20, 0 })
AADD( aDbf, { "doc_desc", "C", 100, 0 })
AADD( aDbf, { "doc_sdesc", "C", 100, 0 })
AADD( aDbf, { "doc_item", "C", 250, 0 })
AADD( aDbf, { "it_group", "N", 5, 0 })
AADD( aDbf, { "doc_log", "C", 200, 0 })

return aDbf


// -----------------------------------------------------
// insert into _tmp1
// -----------------------------------------------------
static function _ins_tmp1( nDoc_no, cCust_desc, dDoc_date, dDoc_dvr_d, ;
		cDoc_dvr_t, ;
		cDoc_stat, cDoc_prior, ;
		cDoc_div, cDoc_desc, cDoc_sDesc, cDoc_oper, ;
		cDoc_item, nIt_group, cDoc_log )

local nTArea := SELECT()

O__TMP1
select _tmp1
APPEND BLANK

replace field->doc_no with nDoc_no
replace field->cust_desc with cCust_desc
replace field->doc_date with dDoc_date
replace field->doc_dvr_d with dDoc_dvr_d
replace field->doc_dvr_t with cDoc_dvr_t
replace field->doc_stat with cDoc_stat
replace field->doc_prior with cDoc_prior
replace field->doc_oper with cDoc_oper
replace field->doc_div with cDoc_div
replace field->doc_desc with cDoc_desc
replace field->doc_sdesc with cDoc_sdesc
replace field->doc_item with cDoc_item
replace field->it_group with nIt_group
replace field->doc_log with cDoc_log

select (nTArea)
return


