#include "rnal.ch"


static __doc_no
static __op_1 := 0
static __op_2 := 0
static __op_3 := 0
static __op_4 := 0
static __op_5 := 0
static __op_6 := 0
static __op_7 := 0
static __op_8 := 0
static __op_9 := 0
static __op_10 := 0
static __op_11 := 0
static __op_12 := 0

static __opu_1 := ""
static __opu_2 := ""
static __opu_3 := ""
static __opu_4 := ""
static __opu_5 := ""
static __opu_6 := ""
static __opu_7 := ""
static __opu_8 := ""
static __opu_9 := ""
static __opu_10 := ""
static __opu_11 := ""
static __opu_12 := ""

// ------------------------------------------
// osnovni poziv pregleda proizvodnje
// ------------------------------------------
function m_get_rpro()

local dD_From := CTOD("")
local dD_to := DATE()
local nOper := 0
local cArticle := SPACE(100)
local nVar1

o_sif_tables()

// daj uslove izvjestaja
if _g_vars( @dD_From, @dD_To, @nOper, @cArticle, @nVar1 ) == 0
 	return 
endif

do case

	case nVar1 = 1
		// kreiraj specifikaciju po elementima
		_cre_sp_el( dD_from, dD_to, nOper, cArticle )
	case nVar1 = 2
		// kreiraj sp. po artiklima
		_cre_sp_art( dD_from, dD_to, nOper, cArticle )

endcase

// printaj specifikaciju
_p_rpt_spec()

return



// ------------------------------------------------------------------------
// uslovi izvjestaja specifikacije
// nVar1 - gledati rasclanjene sifre 1, gledati samo artikal - 2
// ------------------------------------------------------------------------
static function _g_vars( dDatFrom, dDatTo, nOperater, cArticle, nVar1 )

local nRet := 1
local nBoxX := 17
local nBoxY := 70
local nX := 1
local nOp1 := nOp2 := nOp3 := nOp4 := nOp5 := nOp6 := 0
local nOp7 := nOp8 := nOp9 := nOp10 := nOp11 := nOp12 := 0
local cOp1 := cOp2 := cOp3 := cOp4 := cOp5 := cOp6 := SPACE(10)
local cOp7 := cOp8 := cOp9 := cOp10 := cOp11 := cOp12 := SPACE(10)
local nTArea := SELECT()
private GetList := {}
private cSection:="R"
private cHistory:=" "
private aHistory:={}

nVar1 := 1

O_PARAMS

RPar("o1", @cOp1)
RPar("o2", @cOp2)
RPar("o3", @cOp3)
RPar("o4", @cOp4)
RPar("o5", @cOp5)
RPar("o6", @cOp6)
RPar("o7", @cOp7)
RPar("o8", @cOp8)
RPar("o9", @cOp9)
RPar("o0", @cOp10)
RPar("p1", @cOp11)
RPar("p2", @cOp12)
RPar("d1", @dDatFrom)
RPar("d2", @dDatTo)
RPar("v1", @nVar1)

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
	nTmp := nX

	// prvi red operacija

	@ m_x + nX, m_y + 2 SAY "op. 1:" GET cOp1 ;
		VALID {|| s_aops(@cOp1, cOp1), set_var(@nOp1, @cOp1), ;
			show_it( g_aop_desc( nOp1 ), 10 )}
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "op. 2:" GET cOp2 ;
		VALID {|| s_aops(@cOp2, cOp2), set_var(@nOp2, @cOp2), ;
			show_it( g_aop_desc( nOp2 ), 10 )}
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "op. 3:" GET cOp3 ;
		VALID {|| s_aops(@cOp3, cOp3), set_var(@nOp3, @cOp3), ;
			show_it( g_aop_desc( nOp3 ), 10 )}

	nX += 1

	@ m_x + nX, m_y + 2 SAY "op. 4:" GET cOp4 ;
		VALID {|| s_aops(@cOp4, cOp4), set_var(@nOp4, @cOp4), ;
			show_it( g_aop_desc( nOp4 ), 10 )}

	nX += 1

	@ m_x + nX, m_y + 2 SAY "op. 5:" GET cOp5 ;
		VALID {|| s_aops(@cOp5, cOp5), set_var(@nOp5, @cOp5), ;
			show_it( g_aop_desc( nOp5 ), 10 )}
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "op. 6:" GET cOp6 ;
		VALID {|| s_aops(@cOp6, cOp6), set_var(@nOp6, @cOp6), ;
			show_it( g_aop_desc( nOp6 ), 10 )}

	// drugi red operacija

	nTmp2 := col() + 15

	@ m_x + nTmp, nTmp2 SAY "op. 7:" GET cOp7 ;
		VALID {|| s_aops(@cOp7, cOp7), set_var(@nOp7, @cOp7), ;
			show_it( g_aop_desc( nOp7 ), 10 )}

	nTmp += 1
	
	@ m_x + nTmp, nTmp2 SAY "op. 8:" GET cOp8 ;
		VALID {|| s_aops(@cOp8, cOp8), set_var(@nOp8, @cOp8), ;
			show_it( g_aop_desc( nOp8 ), 10 )}
	
	nTmp += 1

	@ m_x + nTmp, nTmp2 SAY "op. 9:" GET cOp9 ;
		VALID {|| s_aops(@cOp9, cOp9), set_var(@nOp9, @cOp9), ;
			show_it( g_aop_desc( nOp9 ), 10 )}
	
	nTmp += 1

	@ m_x + nTmp, nTmp2 SAY "op.10:" GET cOp10 ;
		VALID {|| s_aops(@cOp10, cOp10), set_var(@nOp10, @cOp10), ;
			show_it( g_aop_desc( nOp10 ), 10 )}
	
	nTmp += 1

	@ m_x + nTmp, nTmp2 SAY "op.11:" GET cOp11 ;
		VALID {|| s_aops(@cOp11, cOp11), set_var(@nOp11, @cOp11), ;
			show_it( g_aop_desc( nOp11 ), 10 )}
	
	nTmp += 1

	@ m_x + nTmp, nTmp2 SAY "op.12:" GET cOp12 ;
		VALID {|| s_aops(@cOp12, cOp12), set_var(@nOp12, @cOp12), ;
			show_it( g_aop_desc( nOp12 ), 10 )}

	nX += 2

	@ m_x + nX, m_y + 2 SAY "-------------- ostali uslovi " 
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "Operater (0 - svi op.):" GET nOperater VALID {|| nOperater == 0 .or. p_users( @nOperater ) } PICT "999"
	
	nX += 1
 	
	@ m_x + nX, m_y + 2 SAY "Izvjestaj po (1) elementima (2) artiklima" ;
		GET nVar1 VALID nVar1 > 0 .and. nVar1 < 3 PICT "9"

	nX += 2
	
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

select params

// upisi parametre u params
WPar("o1", cOp1)
WPar("o2", cOp2)
WPar("o3", cOp3)
WPar("o4", cOp4)
WPar("o5", cOp5)
WPar("o6", cOp6)
WPar("o7", cOp7)
WPar("o8", cOp8)
WPar("o9", cOp9)
WPar("o0", cOp10)
WPar("p1", cOp11)
WPar("p2", cOp12)
WPar("d1", dDatFrom)
WPar("d2", dDatTo)
WPar("v1", nVar1)

// operacije
__op_1 := nOp1
__op_2 := nOp2
__op_3 := nOp3
__op_4 := nOp4
__op_5 := nOp5
__op_6 := nOp6
__op_7 := nOp7
__op_8 := nOp8
__op_9 := nOp9
__op_10 := nOp10
__op_11 := nOp11
__op_12 := nOp12

// daj mi jedinice mjere za operacije
__opu_1 := g_aop_unit( __op_1 )
__opu_2 := g_aop_unit( __op_2 )
__opu_3 := g_aop_unit( __op_3 )
__opu_4 := g_aop_unit( __op_4 )
__opu_5 := g_aop_unit( __op_5 )
__opu_6 := g_aop_unit( __op_6 )
__opu_7 := g_aop_unit( __op_7 )
__opu_8 := g_aop_unit( __op_8 )
__opu_9 := g_aop_unit( __op_9 )
__opu_10 := g_aop_unit( __op_10 )
__opu_11 := g_aop_unit( __op_11 )
__opu_12 := g_aop_unit( __op_12 )

return nRet



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_sp_el( dD_from, dD_to, nOper, cArticle )
local nDoc_no
local cArt_id
local aArt := {}
local nCount := 0
local cCust_desc
local nAop_1 := nAop_2 := nAop_3 := nAop_4 := nAop_5 := nAop_6 := 0
local nAop_7 := nAop_8 := nAop_9 := nAop_10 := nAop_11 := nAop_12 := 0

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

	// prebaci se na operacije i vidi da li one zadovoljavaju
	select doc_ops
	
	// element artikla nad kojim je operacija izvrsena
	nEl_no := field->doc_it_el_no
	cAopValue := field->aop_value

	aElem := {}
	nElem_no := 0
	
	_g_art_elements( @aElem, nArt_id )
	
	// vrati broj elementa artikla (1, 2, 3 ...)
	_g_elem_no( aElem, nEl_no, @nElem_no )
	
	// sifra artikla - identifikator "4FL", "6O" itd...
	cArt_id := g_el_descr( aArt, nElem_no )
	
	// opis stavke
	//cArt_desc := get_elem_desc( aElem, nEl_no, 30 )
	cArt_desc := ""

	// debljina stakla
	nTick := g_gl_el_tick( aArt, nElem_no )
	
	// aArr[1] = { 1, "G", "staklo", "<GL_TYPE>", "FL", "FLOAT" }
	// aArr[2] = { 1, "G", "staklo", "<GL_TICK>", "4", "4mm" }
	// aArr[3] = { 2, "F", "distancer", "<FR_TYPE>", "A", "Aluminij" }

	// operacija-1  .T. ?
	if _in_oper_( __op_1, field->aop_id )
		nAop_1 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_1, __opu_1, cAopValue )
	endif
	
	// operacija-2  .T. ?
	if _in_oper_( __op_2, field->aop_id )
		nAop_2 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_2, __opu_2, cAopValue )
	endif
	
	// operacija-3  .T. ?
	if _in_oper_( __op_3, field->aop_id )
		nAop_3 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_3, __opu_3, cAopValue )
	endif
	
	// operacija-4  .T. ?
	if _in_oper_( __op_4, field->aop_id )
		nAop_4 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_4, __opu_4, cAopValue )
	endif
	
	// operacija-5  .T. ?
	if _in_oper_( __op_5, field->aop_id )
		nAop_5 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_5, __opu_5, cAopValue )
	endif
	
	// operacija-6  .T. ?
	if _in_oper_( __op_6, field->aop_id )
		nAop_6 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_6, __opu_6, cAopValue )
	endif
	
	// operacija-7  .T. ?
	if _in_oper_( __op_7, field->aop_id )
		nAop_7 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_7, __opu_7, cAopValue )
	endif

	// operacija-8  .T. ?
	if _in_oper_( __op_8, field->aop_id )
		nAop_8 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_8, __opu_8, cAopValue )
	endif

	// operacija-9  .T. ?
	if _in_oper_( __op_9, field->aop_id )
		nAop_9 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_9, __opu_9, cAopValue )
	endif

	// operacija-10  .T. ?
	if _in_oper_( __op_10, field->aop_id )
		nAop_10 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_10, __opu_10, cAopValue )
	endif

	// operacija-11  .T. ?
	if _in_oper_( __op_11, field->aop_id )
		nAop_11 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_11, __opu_11, cAopValue )
	endif

	// operacija-12  .T. ?
	if _in_oper_( __op_12, field->aop_id )
		nAop_12 := _calc_oper( nQtty, nWidth, nHeight, ;
				__op_12, __opu_12, cAopValue )
	endif

	//if ( nAop_1 + nAop_2 + nAop_3 + nAop_4 + nAop_5 + nAop_6 ) <> 0
	// upisi u tabelu samo ako postoje operacije nad stavkom

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
		nAop_6, ;
		nAop_7, ;
		nAop_8, ;
		nAop_9, ;
		nAop_10, ;
		nAop_11, ;
		nAop_12 )
	
	++ nCount
	
	//endif

	// resetuj vrijednosti
	nAop_1 := 0
	nAop_2 := 0
	nAop_3 := 0
	nAop_4 := 0
	nAop_5 := 0
	nAop_6 := 0
	nAop_7 := 0
	nAop_8 := 0
	nAop_9 := 0
	nAop_10 := 0
	nAop_11 := 0
	nAop_12 := 0

	select doc_ops
	skip
	
enddo

BoxC()

return


// ----------------------------------------------
// kreiraj specifikaciju po artiklima
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_sp_art( dD_from, dD_to, nOper, cArticle )
local nDoc_no
local cArt_id
local aArt := {}
local nCount := 0
local cCust_desc
local nAop_1 := nAop_2 := nAop_3 := nAop_4 := nAop_5 := nAop_6 := 0
local nAop_7 := nAop_8 := nAop_9 := nAop_10 := nAop_11 := nAop_12 := 0

// kreiraj tmp tabelu
aField := _spec_fields()

cre_tmp1( aField )
O__TMP1

// kreiraj indekse
index on art_id + STR(tick, 10, 2) tag "1"  
index on STR(cust_id, 10, 0) + art_id + STR(tick, 10, 2) tag "2" 

// otvori potrebne tabele
o_tables( .f. )

select docs
go top

Box(, 1, 50 )

do while !EOF()

	nDoc_no := field->doc_no
	
	@ m_x + 1, m_y + 2 SAY "... vrsim odabir stavki ... nalog: " + ALLTRIM( STR(nDoc_no) )
	
	nCust_id := field->cust_id

	// provjeri da li ovaj dokument zadovoljava kriterij
	
	if field->doc_status > 1 
		
		// uslov statusa dokumenta
		skip
		loop

	endif

	if DTOS( field->doc_date ) > DTOS( dD_To ) .or. ;
		DTOS( field->doc_date ) < DTOS( dD_From )
	
		// datumski period
		skip
		loop

	endif

	if nOper <> 0

		// po operateru
		
		if ALLTRIM( STR( field->operater_id )) <> ;
			ALLTRIM( STR( nOper ) )
			
			skip
			loop

		endif
	endif

	select customs
	go top
	seek custid_str( nCust_id )
	cCust_desc := field->cust_desc

	// pronadji stavku u items
	// i daj osnovne parametre, kolicinu, sirinu, visinu...

	select doc_it
	set order to tag "1"
	go top
	seek docno_str( nDoc_no )

	// prodji kroz stavke naloga

	do while !EOF() .and. field->doc_no = nDoc_no
		
		nArt_id := field->art_id

		select articles
		seek artid_str( nArt_id )

		cArt_id := field->art_desc
		cArt_desc := field->art_full_desc

		select doc_it
	
		nDoc_it_no := field->doc_it_no

		nQtty := field->doc_it_qtty
		nHeight := field->doc_it_height
		nWidth := field->doc_it_width

		// koliko kvadrata ?
		nTot_m2 := c_ukvadrat( nQtty, nWidth, nHeight )
		nTick := 0
		
		// upisi vrijednost
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
			nAop_6, ;
			nAop_7, ;
			nAop_8, ;
			nAop_9, ;
			nAop_10, ;
			nAop_11, ;
			nAop_12 )
	
			// resetuj vrijednosti
			nAop_1 := 0
			nAop_2 := 0
			nAop_3 := 0
			nAop_4 := 0
			nAop_5 := 0
			nAop_6 := 0
			nAop_7 := 0
			nAop_8 := 0
			nAop_9 := 0
			nAop_10 := 0
			nAop_11 := 0
			nAop_12 := 0

		// prebaci se na operacije i vidi da li one zadovoljavaju
		select doc_ops
		seek docno_str( nDoc_no ) + docit_str( nDoc_it_no )

		do while !EOF() .and. field->doc_no = nDoc_no ;
				.and. field->doc_it_no = nDoc_it_no

			// element artikla nad kojim je operacija izvrsena
			nEl_no := field->doc_it_el_no
			cAopValue := field->aop_value

			aElem := {}
			nElem_no := 0
			nTick := 0
			
			if nDoc_no = 5824
				altd()
			endif

			//_g_art_elements( @aElem, nArt_id )
	
			// vrati broj elementa artikla (1, 2, 3 ...)
			//_g_elem_no( aElem, nEl_no, @nElem_no )
	
			// sifra artikla - identifikator "4FL", "6O" itd...
			//cArt_id := g_el_descr( aArt, nElem_no )
	
			// opis stavke
			//cArt_desc := get_elem_desc( aElem, nEl_no, 30 )
			//cArt_desc := ""

			// debljina stakla
			//nTick := g_gl_el_tick( aArt, nElem_no )
	
			// operacija-1  .T. ?
			if _in_oper_( __op_1, field->aop_id )
				nAop_1 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_1, __opu_1, cAopValue )
			endif
	
			// operacija-2  .T. ?
			if _in_oper_( __op_2, field->aop_id )
				nAop_2 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_2, __opu_2, cAopValue )
			endif
	
			// operacija-3  .T. ?
			if _in_oper_( __op_3, field->aop_id )
				nAop_3 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_3, __opu_3, cAopValue )
			endif
		
			// operacija-4  .T. ?
			if _in_oper_( __op_4, field->aop_id )
				nAop_4 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_4, __opu_4, cAopValue )
			endif
			
			// operacija-5  .T. ?
			if _in_oper_( __op_5, field->aop_id )
				nAop_5 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_5, __opu_5, cAopValue )
			endif
			
			// operacija-6  .T. ?
			if _in_oper_( __op_6, field->aop_id )
				nAop_6 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_6, __opu_6, cAopValue )
			endif
		
			// operacija-7  .T. ?
			if _in_oper_( __op_7, field->aop_id )
				nAop_7 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_7, __opu_7, cAopValue )
			endif
			
			// operacija-8  .T. ?
			if _in_oper_( __op_8, field->aop_id )
				nAop_8 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_8, __opu_8, cAopValue )
			endif

			// operacija-9  .T. ?
			if _in_oper_( __op_9, field->aop_id )
				nAop_9 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_9, __opu_9, cAopValue )
			endif

			// operacija-10  .T. ?
			if _in_oper_( __op_10, field->aop_id )
				nAop_10 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_10, __opu_10, cAopValue )
			endif

			// operacija-11  .T. ?
			if _in_oper_( __op_11, field->aop_id )
				nAop_11 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_11, __opu_11, cAopValue )
			endif

			// operacija-12  .T. ?
			if _in_oper_( __op_12, field->aop_id )
				nAop_12 := _calc_oper( nQtty, nWidth, nHeight, ;
					__op_12, __opu_12, cAopValue )
			endif

			if ( nAop_1 + nAop_2 + nAop_3 + ;
				nAop_4 + nAop_5 + nAop_6 + ;
				nAop_7 + nAop_8 + nAop_9 + ;
				nAop_10 + nAop_11 + nAop_12 ) > 0

			  _ins_op1( nCust_id, ;
				cArt_id, ;
				nTick, ;
				nAop_1, ;
				nAop_2, ;
				nAop_3, ;
				nAop_4, ;
				nAop_5, ;
				nAop_6, ;
				nAop_7, ;
				nAop_8, ;
				nAop_9, ;
				nAop_10, ;
				nAop_11, ;
				nAop_12 )
	

			  // resetuj vrijednosti
			  nAop_1 := 0
			  nAop_2 := 0
			  nAop_3 := 0
			  nAop_4 := 0
			  nAop_5 := 0
			  nAop_6 := 0
			  nAop_7 := 0
			  nAop_8 := 0
			  nAop_9 := 0
			  nAop_10 := 0
			  nAop_11 := 0
			  nAop_12 := 0

			endif

			select doc_ops
			skip

		enddo
	
		select doc_it
		skip

	enddo
		
	select docs
	skip
enddo

BoxC()

return


// --------------------------------------------------------------------
// kalkulisi operaciju nad elementom
// nQtty - kolicina
// nH - height
// nW - width
// nOp - id operacija
// cOpU - jedinica mjere operacije
// cValue - value polja operacije iz baze "<A_B>:23#22#33" i slicno...
// lComp - .t. - komponentno staklo
// --------------------------------------------------------------------
static function _calc_oper( nQtty, nH, nW, nOp, cOpU, cValue, lComp )
local xRet := 0
local nTArea := SELECT()
local nU_m2 := c_ukvadrat( nQtty, nH, nW )

if lComp == nil
	lComp := .f.
endif

cJoker := g_aop_joker( nOp )

// iscupaj na osnovu jokera kako se racuna operacija
// kolicina, m ili m2

do case
	case UPPER(cOpU) == "M"
		
		xRet := 0
		_g_kol( cValue, cOpU, @xRet, nQtty, nH, nW, 0, 0 )

	case UPPER(cOpU) == "KOM"
		
		xRet := 0
		_g_kol( cValue, cOpU, @xRet, nQtty, nH, nW, 0, 0 )

	case UPPER(cOpU) == "M2"
		
		xRet := nU_m2
	
	otherwise 

		// racunaj kao povrsinu
		xRet := nU_m2

endcase

select ( nTArea )

return xRet


// ----------------------------------------------------------
// da li je zadovoljen uslov operacije ?
// ----------------------------------------------------------
static function _in_oper_( nOp, nFldOp )
local lRet := .f.

// ako je operacija 0 - nista od toga
// ili ako se ne slaze sa operacijom iz polja

if ( nOp <> 0 .and. nOp = nFldOp )
	lRet := .t.
endif

return lRet



// ------------------------------------------
// stampa specifikacije
// stampa se iz _tmp0 tabele
// ------------------------------------------
static function _p_rpt_spec()
local nT_height := 0
local nT_width := 0
local nT_qtty := 0
local nT_um2 := 0
local cLine := ""
local nCount := 0

START PRINT CRET

?
P_COND2

// naslov izvjestaja
_rpt_descr()
// info operater, datum
__rpt_info()
// header
_rpt_head( @cLine )

select _tmp1
set order to tag "1"
go top

do while !EOF()

	// provjeri za novu stranu
	if _nstr()
		FF
	endif
	
	// r.br
	? PADL( ALLTRIM( STR(++nCount) ) + ".", 6)
	// artikal
	@ prow(), pcol() + 1 SAY field->art_id
	// debljina
	@ prow(), pcol() + 1 SAY STR( field->tick, 6, 2 )
	// kolicina
	@ prow(), pcol() + 1 SAY STR( field->qtty, 12, 2 )
	// sirina
	@ prow(), pcol() + 1 SAY STR( field->width, 12, 2 )
	// visina
	@ prow(), pcol() + 1 SAY STR( field->height, 12, 2 )
	// ukupno m2
	@ prow(), pcol() + 1 SAY STR( field->total, 12, 2 )

	nT_height += field->height
	nT_width += field->width
	nT_um2 += field->total
	nT_qtty += field->qtty

	// sada prikazi i operacije
	if __op_1 <> 0
		// operacija 1
		@ prow(), pcol() + 1 SAY STR( field->aop_1, 12, 2 )
	endif
	
	if __op_2 <> 0
		// operacija 2
		@ prow(), pcol() + 1 SAY STR( field->aop_2, 12, 2 )
	endif
	
	if __op_3 <> 0
		// operacija 3
		@ prow(), pcol() + 1 SAY STR( field->aop_3, 12, 2 )
	endif

	if __op_4 <> 0
		// operacija 4
		@ prow(), pcol() + 1 SAY STR( field->aop_4, 12, 2 )
	endif

	if __op_5 <> 0
		// operacija 5
		@ prow(), pcol() + 1 SAY STR( field->aop_5, 12, 2 )
	endif
	
	if __op_6 <> 0
		// operacija 6
		@ prow(), pcol() + 1 SAY STR( field->aop_6, 12, 2 )
	endif
	
	if __op_7 <> 0
		// operacija 7
		@ prow(), pcol() + 1 SAY STR( field->aop_7, 12, 2 )
	endif
	
	if __op_8 <> 0
		// operacija 8
		@ prow(), pcol() + 1 SAY STR( field->aop_8, 12, 2 )
	endif

	if __op_9 <> 0
		// operacija 9
		@ prow(), pcol() + 1 SAY STR( field->aop_9, 12, 2 )
	endif
	
	if __op_10 <> 0
		// operacija 10
		@ prow(), pcol() + 1 SAY STR( field->aop_10, 12, 2 )
	endif
	
	if __op_11 <> 0
		// operacija 11
		@ prow(), pcol() + 1 SAY STR( field->aop_11, 12, 2 )
	endif

	if __op_12 <> 0
		// operacija 12
		@ prow(), pcol() + 1 SAY STR( field->aop_12, 12, 2 )
	endif

	skip

enddo

? cLine

? PADR( "UKUPNO:", 35 )
// debljina
@ prow(), pcol() + 1 SAY PADR("", 8)
// kolicina
@ prow(), pcol() + 1 SAY STR( nT_qtty, 12, 2 )
// sirina
@ prow(), pcol() + 1 SAY STR( nT_width, 12, 2 )
// visina
@ prow(), pcol() + 1 SAY STR( nT_height, 12, 2 )
// ukupno m2
@ prow(), pcol() + 1 SAY STR( nT_um2, 12, 2 )

? cLine 

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
static function _rpt_head( cLine )
cLine := ""
cTxt := ""
cTxt2 := ""

cLine += REPLICATE("-", 6)
cLine += SPACE(1)
cLine += REPLICATE("-", 30) 
cLine += SPACE(1)
cLine += REPLICATE("-", 6)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

cTxt += PADR("r.br", 6)
cTxt += SPACE(1)
cTxt += PADR("Artikal / element", 30)
cTxt += SPACE(1)
cTxt += PADR("Deblj.", 6)
cTxt += SPACE(1)
cTxt += PADR("Kolicina", 12)
cTxt += SPACE(1)
cTxt += PADR("Sirina", 12)
cTxt += SPACE(1)
cTxt += PADR("Visina", 12)
cTxt += SPACE(1)
cTxt += PADR("Ukupno", 12)

cTxt2 += PADR("", 6)
cTxt2 += SPACE(1)
cTxt2 += PADR("", 30)
cTxt2 += SPACE(1)
cTxt2 += PADR("(mm)", 6)
cTxt2 += SPACE(1)
cTxt2 += PADR("(kom)", 12)
cTxt2 += SPACE(1)
cTxt2 += PADR("(mm)", 12)
cTxt2 += SPACE(1)
cTxt2 += PADR("(mm)", 12)
cTxt2 += SPACE(1)
cTxt2 += PADR("(m2)", 12)

if __op_1 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_1 ) )
	
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_1 ) + ")", 12 )

endif

if __op_2 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_2 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_2 ) + ")", 12 )

endif

if __op_3 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_3 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_3 ) + ")", 12 )

endif

if __op_4 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_4 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_4 ) + ")", 12 )

endif

if __op_5 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_5 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_5 ) + ")", 12 )

endif

if __op_6 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_6 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_6 ) + ")", 12 )

endif

if __op_7 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_7 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_7 ) + ")", 12 )

endif

if __op_8 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_8 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_8 ) + ")", 12 )

endif

if __op_9 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_9 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_9 ) + ")", 12 )

endif

if __op_10 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_10 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_10 ) + ")", 12 )

endif

if __op_11 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_11 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_11 ) + ")", 12 )

endif

if __op_12 <> 0
	
	cTmp := ALLTRIM( g_aop_desc( __op_12 ) )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( cTmp, 12 )
	cTxt2 += SPACE(1)
	cTxt2 += PADC( "(" + ALLTRIM( __opu_12 ) + ")", 12 )

endif

? cLine
? cTxt
? cTxt2
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
AADD( aDbf, { "aop_7", "N", 15, 5 })
AADD( aDbf, { "aop_8", "N", 15, 5 })
AADD( aDbf, { "aop_9", "N", 15, 5 })
AADD( aDbf, { "aop_10", "N", 15, 5 })
AADD( aDbf, { "aop_11", "N", 15, 5 })
AADD( aDbf, { "aop_12", "N", 15, 5 })

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
			nAop_1, nAop_2, nAop_3, nAop_4, nAop_5, nAop_6, ;
			nAop_7, nAop_8, nAop_9, nAop_10, nAop_11, nAop_12 )

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

if __op_1 <> 0 .and. nAop_1 <> nil
	replace field->aop_1 with ( field->aop_1 + nAop_1 )
endif

if __op_2 <> 0 .and. nAop_2 <> nil
	replace field->aop_2 with ( field->aop_2 + nAop_2 )
endif

if __op_3 <> 0 .and. nAop_3 <> nil
	replace field->aop_3 with ( field->aop_3 + nAop_3 )
endif

if __op_4 <> 0 .and. nAop_4 <> nil
	replace field->aop_4 with ( field->aop_4 + nAop_4 )
endif

if __op_5 <> 0 .and. nAop_5 <> nil
	replace field->aop_5 with ( field->aop_5 + nAop_5 )
endif

if __op_6 <> 0 .and. nAop_6 <> nil
	replace field->aop_6 with ( field->aop_6 + nAop_6 )
endif

if __op_7 <> 0 .and. nAop_7 <> nil
	replace field->aop_7 with ( field->aop_7 + nAop_7 )
endif

if __op_8 <> 0 .and. nAop_8 <> nil
	replace field->aop_8 with ( field->aop_8 + nAop_8 )
endif

if __op_9 <> 0 .and. nAop_9 <> nil
	replace field->aop_9 with ( field->aop_9 + nAop_9 )
endif

if __op_10 <> 0 .and. nAop_10 <> nil
	replace field->aop_10 with ( field->aop_10 + nAop_10 )
endif

if __op_11 <> 0 .and. nAop_11 <> nil
	replace field->aop_11 with ( field->aop_11 + nAop_11 )
endif

if __op_12 <> 0 .and. nAop_12 <> nil
	replace field->aop_12 with ( field->aop_12 + nAop_12 )
endif

select (nTArea)
return


// -----------------------------------------------------
// insert op. into _tmp1
// -----------------------------------------------------
static function _ins_op1( nCust_id, cArt_id, nTick, ;
			nAop_1, nAop_2, nAop_3, ;
			nAop_4, nAop_5, nAop_6, ;
			nAop_7, nAop_8, nAop_9, ;
			nAop_10, nAop_11, nAop_12 )

local nTArea := SELECT()

select _tmp1
set order to tag "1"
go top

seek PADR( cArt_id, 30 ) + tick_str( nTick )

if __op_1 <> 0 .and. nAop_1 <> nil
	replace field->aop_1 with ( field->aop_1 + nAop_1 )
endif

if __op_2 <> 0 .and. nAop_2 <> nil
	replace field->aop_2 with ( field->aop_2 + nAop_2 )
endif

if __op_3 <> 0 .and. nAop_3 <> nil
	replace field->aop_3 with ( field->aop_3 + nAop_3 )
endif

if __op_4 <> 0 .and. nAop_4 <> nil
	replace field->aop_4 with ( field->aop_4 + nAop_4 )
endif

if __op_5 <> 0 .and. nAop_5 <> nil
	replace field->aop_5 with ( field->aop_5 + nAop_5 )
endif

if __op_6 <> 0 .and. nAop_6 <> nil
	replace field->aop_6 with ( field->aop_6 + nAop_6 )
endif

if __op_7 <> 0 .and. nAop_7 <> nil
	replace field->aop_7 with ( field->aop_7 + nAop_7 )
endif

if __op_8 <> 0 .and. nAop_8 <> nil
	replace field->aop_8 with ( field->aop_8 + nAop_8 )
endif

if __op_9 <> 0 .and. nAop_9 <> nil
	replace field->aop_9 with ( field->aop_9 + nAop_9 )
endif

if __op_10 <> 0 .and. nAop_10 <> nil
	replace field->aop_10 with ( field->aop_10 + nAop_10 )
endif

if __op_11 <> 0 .and. nAop_11 <> nil
	replace field->aop_11 with ( field->aop_11 + nAop_11 )
endif

if __op_12 <> 0 .and. nAop_12 <> nil
	replace field->aop_12 with ( field->aop_12 + nAop_12 )
endif

select (nTArea)
return


