#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------
// stampa naloga, filovanje prn tabela
// -------------------------------------
function st_nalpr( lPriprema, nBrNal )

// kreiraj print tabele
t_prn_create()
// otvori tabele
t_prn_open()

o_rnal(lPriprema)

// osnovni podaci naloga
fill_nalog_osn(lPriprema, nBrNal)
// stavke naloga
fill_stavke(lPriprema, nBrNal)
// operacije
fill_operacije(lPriprema, nBrNal)

nalpr_print( .t. )

close all

o_rnal(lPriprema)

return DE_REFRESH


// -------------------------------------
// stampa otpremnice, filovanje prn tabela
// -------------------------------------
function st_otpremnica( lPriprema, nBrNal )

// kreiraj print tabele
t_prn_create()
// otvori tabele
t_prn_open()

o_rnal(lPriprema)

// osnovni podaci naloga
fill_nalog_osn(lPriprema, nBrNal)
// stavke naloga
fill_stavke(lPriprema, nBrNal)
// operacije
fill_operacije(lPriprema, nBrNal)

otpr_print( .t. )

close all

o_rnal(lPriprema)

return DE_REFRESH




// ----------------------------------
// filuj tabele za stampu
// ----------------------------------
static function fill_stavke( lPriprema, nBr_Nal )
local nTb_ST := F_RNAL
local cIdRoba
local cRobaNaz
local cRobaJmj
local cBr_nal
local cR_br
local nKolicina
local nD_sirina
local nD_visina
local nZ_sirina
local nZ_visina
local nD_ukupno
local nZ_ukupno
local nNetto

if ( lPriprema == .t. )
	nTb_ST := F_P_RNAL
endif

select (nTb_ST)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

// filuj stavke
do while !EOF() .and. field->br_nal == nBr_nal
	
	// pronadji robu
	cIdRoba := field->idroba
	select roba
	seek cIdRoba
	
	select (nTb_ST)
	
	cRobaNaz := ALLTRIM(roba->naz)
	cRobaJmj := ALLTRIM(roba->jmj)
	
	cBr_nal := str_nal( field->br_nal )
	cR_br := str_rbr( field->r_br )
	
	nKolicina := field->kolicina
	nD_sirina := field->d_sirina
	nD_visina := field->d_visina
	nZ_sirina := field->z_sirina
	nZ_visina := field->z_visina
	nD_ukupno := field->d_ukupno
	nZ_ukupno := field->z_ukupno
	nNetto    := field->neto
	
	a_t_rnst( cBr_nal, cR_br, cIdroba, cRobanaz, cRobaJmj, ;
                   nKolicina, nD_sirina, nD_visina, ;
		   nZ_sirina, nZ_visina, nD_ukupno, ;
		   nZ_ukupno, nNetto )
	
	select (nTb_ST)
	skip
enddo

return


// --------------------------------------------------
// filovanje operacija 
// --------------------------------------------------
static function fill_operacije( lPriprema, nBr_Nal )
local nTb_OP := F_RNOP
local cBr_nal
local cR_br
local cIdRoba
local cRn_op
local cRn_op_naz
local cRn_ka
local cRn_ka_naz
local cRn_instr

if ( lPriprema == .t. )
	nTb_ST := F_P_RNOP
endif

// filuj operacije
select (nTb_OP)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. field->br_nal == nBr_nal

	cBr_nal := str_nal(field->br_nal)
	cR_br := str_rbr(field->r_br)
	cIdRoba := field->idroba
	cRn_op := field->id_rnop
	cRn_op_naz := s_operacija(cRn_op)
	cRn_ka := field->id_rnka
	cRn_ka_naz := s_karakt(cRn_ka)
	cRn_instr := field->rn_instr
	
	a_t_rnop( cBr_nal, cR_br, cIdroba, ;
                   cRn_op, cRn_op_naz, ;
		   cRn_ka, cRn_ka_naz, cRn_instr)

	select (nTb_OP)
	skip
enddo

return


// ---------------------------------
// napuni podatke narucioca
// ---------------------------------
static function fill_nalog_osn(lPriprema, nBr_Nal)
local nTb_ST := F_RNAL
local nTb_OP := F_RNOP

if ( lPriprema == .t. )
	nTb_ST := F_P_RNAL
	nTb_OP := F_P_RNOP
endif

select (nTb_ST)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

f_narucioc(field->idpartner)

select (nTb_ST)
// iz prvog sloga odmah uzmi osnovne podatke naloga
// partner, datumi itd...
add_tpars("N01",  str_nal(nBr_nal) )
add_tpars("N02",  DToC(field->datnal) )
add_tpars("N03",  DToC(field->datisp) )


return



// ----------------------------------------
// dodaj podatke o naruciocu
// ----------------------------------------
static function f_narucioc( cIdPartn )
local cPartNaz
local cPartAdr
local cPartMje
local cPartPtt
local cPartTel
local cPartFax

select partn
seek cIdPartn

cPartNaz := ALLTRIM(partn->naz)
cPartMje := ALLTRIM(partn->mjesto)
cPartPtt := ALLTRIM(partn->ptt)
cPartAdr := ALLTRIM(partn->adresa)
cPartTel := ALLTRIM(partn->telefon)
cPartFax := ALLTRIM(partn->fax)
cIdPartn := ALLTRIM(cIdPartn)

add_tpars("P01", cIdPartn)
add_tpars("P02", cPartNaz)
add_tpars("P03", cPartAdr)
add_tpars("P04", cPartMje)
add_tpars("P05", cPartPtt)
add_tpars("P06", cPartTel)
add_tpars("P07", cPartFax)

return



