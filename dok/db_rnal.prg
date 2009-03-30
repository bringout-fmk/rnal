#include "rnal.ch"


// ----------------------------------
// brisanje print tabela
// ----------------------------------
function d_rpt_dbfs()
close all

// t_docit.dbf
FErase(PRIVPATH + "T_DOCIT.DBF")
FErase(PRIVPATH + "T_DOCIT.CDX")

// t_docop.dbf
FErase(PRIVPATH + "T_DOCOP.DBF")
FErase(PRIVPATH + "T_DOCOP.CDX")

// t_pars.dbf
FErase(PRIVPATH + "T_PARS.DBF")
FErase(PRIVPATH + "T_PARS.CDX")

return 1


// ------------------------------------
// kreiranje print tabela
// ------------------------------------
function t_rpt_create()
local cT_DOCIT := "T_DOCIT.DBF"
local cT_DOCOP := "T_DOCOP.DBF"
local cT_PARS := "T_PARS.DBF"
local aT_DOCIT:={}
local aT_DOCOP:={}
local aT_PARS:={}

// brisi tabele....
if d_rpt_dbfs() == 0
	MsgBeep("Greska: brisanje pomocnih tabela !!!")
	return
endif

// kreiraj T_DOCIT
if !FILE(PRIVPATH + cT_DOCIT)
	g_docit_fields(@aT_DOCIT)
	dbcreate2(PRIVPATH + cT_DOCIT, aT_DOCIT)
endif

// kreiraj T_DOCOP
if !FILE(PRIVPATH + cT_DOCOP)
	g_docop_fields(@aT_DOCOP)
	dbcreate2(PRIVPATH + cT_DOCOP, aT_DOCOP)
endif

// kreiraj T_PARS
if !FILE(PRIVPATH + cT_PARS)
	g_pars_fields(@aT_PARS)
	dbcreate2(PRIVPATH + cT_PARS, aT_PARS)
endif

// kreiraj indexe
CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(art_id,10)", PRIVPATH + "T_DOCIT")
CREATE_INDEX("2", "STR(doc_no,10)+STR(doc_gr_no,2)+STR(doc_it_no,4)+STR(art_id,10)", PRIVPATH + "T_DOCIT")
CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_el_no,4)+STR(doc_op_no,4)", PRIVPATH + "T_DOCOP")
CREATE_INDEX("id_par", "id_par", PRIVPATH + "T_PARS")

return

// -----------------------------------------------
// setovanje polja tabele T_DOCIT
// -----------------------------------------------
static function g_docit_fields(aArr)

AADD(aArr,{ "doc_gr_no"  , "N" ,   2 ,  0 })
AADD(aArr,{ "doc_no"     , "N" ,  10 ,  0 })
AADD(aArr,{ "doc_it_no"  , "N" ,   4 ,  0 })
AADD(aArr,{ "art_id"     , "N" ,  10 ,  0 })
AADD(aArr,{ "art_desc"   , "C" , 250 ,  0 })
AADD(aArr,{ "doc_it_qtty", "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_heigh" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_h2" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_width" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_w2" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_type" , "C" ,  1 ,  0 })
AADD(aArr,{ "doc_it_altt" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_acity" , "C" ,  50 ,  0 })
AADD(aArr,{ "doc_it_schema" , "C" ,   1 ,  0 })
AADD(aArr,{ "doc_it_desc" , "C" , 150 ,  0 })
AADD(aArr,{ "doc_it_total" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_zwidth" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_zw2" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_zheight" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_zh2" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_neto" , "N" ,  15 ,  5 })
AADD(aArr,{ "doc_it_bruto" , "N" ,  15 ,  5 })
AADD(aArr,{ "print" , "C" ,  1 ,  0 })

return

// setovanje polja tabele T_DOCOP
static function g_docop_fields(aArr)

AADD(aArr,{ "doc_no"     , "N" ,  10 ,  0 })
AADD(aArr,{ "doc_op_no"  , "N" ,   4 ,  0 })
AADD(aArr,{ "doc_it_no"  , "N" ,   4 ,  0 })
AADD(aArr,{ "doc_el_no"  , "N" ,   4 ,  0 })
AADD(aArr,{ "doc_el_desc", "C" , 150 ,  0 })
AADD(aArr,{ "aop_id"     , "N" ,  10 ,  0 })
AADD(aArr,{ "aop_desc"   , "C" , 150 ,  0 })
AADD(aArr,{ "aop_att_id" , "N" ,  10 ,  0 })
AADD(aArr,{ "aop_att_desc" , "C" , 150 ,  0 })
AADD(aArr,{ "doc_op_desc", "C" , 150 ,  0 })
AADD(aArr,{ "aop_value", "C" , 150 ,  0 })

return


// setovanje polja tabele T_PARS
static function g_pars_fields(aArr)
AADD(aArr, {"id_par", "C",   3, 0})
AADD(aArr, {"opis"  , "C", 200, 0})
return


// dodaj u tabelu T_PARS
function add_tpars(cId_par, cOpis)
local lFound
local nArea

nArea := SELECT()

if !USED(F_T_PARS)
	O_T_PARS
	SET ORDER TO TAG "ID_PAR"
endif

select t_pars
GO TOP

SEEK cId_par

if !FOUND()
	append blank
endif

replace id_par with cId_par
replace opis with cOpis

select (nArea)

return


// isprazni print tabele
function t_rpt_empty()
O_T_DOCOP
select t_docop
zap

O_T_DOCIT
select t_docit
zap

O_T_PARS
select t_pars
zap

return


// otvori print tabele
function t_rpt_open()
O_T_PARS
O_T_DOCOP
O_T_DOCIT
return



// vrati vrijednost polja opis iz tabele T_PARS po id kljucu
function g_t_pars_opis(cId_param)
local xRet

if !USED(F_T_PARS)
	O_T_PARS
endif

select t_pars
set order to tag "id_par"
go top
seek cId_param

if !Found()
	return "-"
endif

xRet := RTRIM(opis)

return xRet


// dodaj stavke u tabelu T_RNST
function a_t_docit( nDoc_no, nDoc_gr_no, nDoc_it_no, nArt_id, cArt_desc, ;
		    cDoc_it_schema, cDoc_it_desc, cDoc_it_type, ;
		    nDoc_it_qtty, nDoc_it_heigh, nDoc_it_width, ;
		    nDoc_it_h2, nDoc_it_w2, ;
		    nDoc_it_altt, ;
		    cDoc_it_city, ;
		    nDoc_it_total, nGNHeigh, nGNWidth, ;
		    nGnH2, nGNW2, ;
		    nNeto, nBruto )

O_T_DOCIT
select t_docit
append blank
replace doc_gr_no with nDoc_gr_no
replace doc_no with nDoc_no
replace doc_it_no with nDoc_it_no
replace art_id with nArt_id
replace art_desc with cArt_desc
replace doc_it_qtty with nDoc_it_qtty
replace doc_it_heigh with nDoc_it_heigh
replace doc_it_h2 with nDoc_it_h2
replace doc_it_width with nDoc_it_width
replace doc_it_w2 with nDoc_it_w2
replace doc_it_type with cDoc_it_type
replace doc_it_altt with nDoc_it_altt
replace doc_acity with cDoc_it_city
replace doc_it_total with nDoc_it_total
replace doc_it_schema with cDoc_it_schema
replace doc_it_desc with cDoc_it_desc
// printanje stavki iz tabele "D" - printaj, "N" - ne printaj
replace print with "D"

if nGNHeigh <> nil
	replace doc_it_zheight with nGNHeigh
	replace doc_it_zh2 with nGNH2
	replace doc_it_zwidth with nGNWidth
	replace doc_it_zw2 with nGNW2
	replace doc_it_neto with nNeto
	replace doc_it_bruto with nBruto
endif

return


// dodaj stavke u tabelu T_DOCOP
function a_t_docop( nDoc_no, nDoc_op_no, nDoc_it_no, ;
		   nDoc_el_no, cDoc_el_desc, ;	
                   nAop_id, cAop_desc, ;
		   nAop_att_id, cAop_att_desc , ;
		   cDoc_op_desc, ;
		   cAop_value )

O_T_DOCOP
select t_docop
append blank

replace doc_no with nDoc_no
replace doc_op_no with nDoc_op_no
replace doc_it_no with nDoc_it_no
replace doc_el_no with nDoc_el_no
replace doc_el_desc with cDoc_el_desc
replace aop_id with nAop_id
replace aop_desc with cAop_desc
replace aop_att_id with nAop_att_id
replace aop_att_desc with cAop_att_desc
replace doc_op_desc with cDoc_op_desc
replace aop_value with cAop_value

return


