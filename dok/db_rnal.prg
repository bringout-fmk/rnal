#include "\dev\fmk\rnal\rnal.ch"


// brisanje print tabela
function d_prn_dbfs()
close all
// t_rnst.dbf
FErase(PRIVPATH + "T_RNST.DBF")
FErase(PRIVPATH + "T_RNST.CDX")

// t_rnop.dbf
FErase(PRIVPATH + "T_RNOP.DBF")
FErase(PRIVPATH + "T_RNOP.CDX")

// t_pars.dbf
FErase(PRIVPATH + "T_PARS.DBF")
FErase(PRIVPATH + "T_PARS.CDX")

return 1


// kreiranje print tabela
function t_prn_create()
local cT_RNST := "T_RNST.DBF"
local cT_RNOP := "T_RNOP.DBF"
local cT_PARS := "T_PARS.DBF"
local aT_RNST:={}
local aT_RNOP:={}
local aT_PARS:={}

if d_prn_dbfs() == 0
	MsgBeep("Greska: brisanje pomocnih tabela !!!")
	return
endif

// kreiraj T_RNST
if !FILE(PRIVPATH + cT_RNST)
	g_t_st_fields(@aT_RNST)
	dbcreate2(PRIVPATH + cT_RNST, aT_RNST)
endif

// kreiraj T_RNOP
if !FILE(PRIVPATH + cT_RNOP)
	g_t_op_fields(@aT_RNOP)
	dbcreate2(PRIVPATH + cT_RNOP, aT_RNOP)
endif

// kreiraj T_PARS
if !FILE(PRIVPATH + cT_PARS)
	g_t_pars_fields(@aT_PARS)
	dbcreate2(PRIVPATH + cT_PARS, aT_PARS)
endif

// kreiraj indexe
CREATE_INDEX("br_nal", "br_nal+r_br", PRIVPATH + "T_RNST")
CREATE_INDEX("br_nal", "br_nal+r_br+idroba", PRIVPATH + "T_RNOP")
CREATE_INDEX("id_par", "id_par", PRIVPATH + "T_PARS")

return


// setovanje polja tabele T_RNST
static function g_t_st_fields(aArr)

AADD(aArr,{ "br_nal"     , "C" ,  10 ,  0 })
AADD(aArr,{ "r_br"       , "C" ,   4 ,  0 })
AADD(aArr,{ "p_br"       , "C" ,   4 ,  0 })
AADD(aArr,{ "idproizvod" , "C" ,  10 ,  0 })
AADD(aArr,{ "pro_naz"    , "C" , 250 ,  0 })
AADD(aArr,{ "idroba"     , "C" ,  10 ,  0 })
AADD(aArr,{ "roba_naz"   , "C" , 250 ,  0 })
AADD(aArr,{ "jmj"        , "C" ,   3 ,  0 })
AADD(aArr,{ "kolicina"   , "N" ,  15 ,  5 })
AADD(aArr,{ "d_sirina"   , "N" ,  15 ,  5 })
AADD(aArr,{ "z_sirina"   , "N" ,  15 ,  5 })
AADD(aArr,{ "d_visina"   , "N" ,  15 ,  5 })
AADD(aArr,{ "z_visina"   , "N" ,  15 ,  5 })
AADD(aArr,{ "d_ukupno"   , "N" ,  15 ,  5 })
AADD(aArr,{ "z_ukupno"   , "N" ,  15 ,  5 })
AADD(aArr,{ "z_netto"    , "N" ,  15 ,  5 })

return

// setovanje polja tabele T_RNOP
static function g_t_op_fields(aArr)

AADD(aArr,{ "br_nal"     , "C" ,  10 ,  0 })
AADD(aArr,{ "r_br"       , "C" ,   4 ,  0 })
AADD(aArr,{ "p_br"       , "C" ,   4 ,  0 })
AADD(aArr,{ "idroba"     , "C" ,  10 ,  0 })
AADD(aArr,{ "rn_op"      , "C" ,   6 ,  0 })
AADD(aArr,{ "rn_op_naz"  , "C" ,  40 ,  0 })
AADD(aArr,{ "rn_ka"      , "C" ,   6 ,  0 })
AADD(aArr,{ "rn_ka_naz"  , "C" , 100 ,  0 })
AADD(aArr,{ "rn_instr"   , "C" , 100 ,  0 })

return


// setovanje polja tabele T_PARS
static function g_t_pars_fields(aArr)
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
function t_pr_empty()
O_T_RNST
select t_rnst
zap

O_T_RNOP
select t_rnop
zap

O_T_PARS
select t_pars
zap

return


// otvori print tabele
function t_prn_open()
O_T_PARS
O_T_RNOP
O_T_RNST
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
function a_t_rnst( cBr_nal, cR_br, cP_br, cId_pro, cPro_naz, ;
		   cId_roba, cRoba_naz, cJmj, ;
                   nKolicina, nD_sirina, nD_visina, ;
		   nZ_sirina, nZ_visina, nD_ukupno, ;
		   nZ_ukupno, nZ_Netto )

O_T_RNST
select t_rnst
append blank
replace br_nal with cBr_nal
replace r_br with cR_br
replace p_br with cP_br
replace idproizvod with cId_pro
replace pro_naz with cPro_naz
replace idroba with cId_roba
replace roba_naz with cRoba_naz
replace jmj with cJmj
replace kolicina with nKolicina
replace d_sirina with nD_sirina
replace d_visina with nD_visina
replace z_sirina with nZ_sirina
replace z_visina with nZ_visina
replace d_ukupno with nD_ukupno
replace z_ukupno with nZ_ukupno
replace z_netto with nZ_Netto

return


// dodaj stavke u tabelu T_RNOP
function a_t_rnop( cBr_nal, cR_br, cP_br, cId_roba, ;
                   cRn_op, cRn_op_naz, ;
		   cRn_ka, cRn_ka_naz, cRn_in)

O_T_RNOP
select t_rnop
append blank

replace br_nal with cBr_nal
replace r_br with cR_br
replace p_br with cP_br
replace idroba with cId_roba
replace rn_op with cRn_op
replace rn_op_naz with cRn_op_naz
replace rn_ka with cRn_ka
replace rn_ka_naz with cRn_ka_naz
replace rn_instr with cRn_in

return


