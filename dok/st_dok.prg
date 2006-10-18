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
fill_rn_oper(lPriprema, nBrNal)

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
fill_rn_oper(lPriprema, nBrNal)

otpr_print( .t. )

close all

o_rnal(lPriprema)

return DE_REFRESH




// ----------------------------------
// filuj tabele za stampu
// ----------------------------------
static function fill_stavke( lPriprema, nBr_Nal )
local nTb_st := F_RNST
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
local nZ_Netto
local nNUZTotal := 0
local nNUDTotal := 0
local nNUNeto := 0

if ( lPriprema == .t. )
	nTb_st := F_P_RNST
endif

select (nTb_st)
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

// filuj stavke
do while !EOF() .and. field->br_nal == nBr_nal
	
	cItemID := field->item_id
	nR_br := field->r_br
	
	// nadji proizvod
	select roba
	hseek cItemID

	cItemNaz := ALLTRIM(roba->naz)
	cItemJmj := ALLTRIM(roba->jmj)
	
	nKolicina := field->item_kol
	nSirina := field->item_sir
	nVisina := field->item_vis

	a_t_rnst( cBr_nal, cR_br, cItemID, cItemNaz, cItemJmj, ;
                  nKolicina, nSirina, nVisina, ;
	          nZ_sirina, nZ_visina, nD_ukupno, ;
	          nZ_ukupno, nZ_Netto )
	
	select (nTb_ST)
	skip
enddo
	
// dodaj i nalog ukupno itd...
add_tpars("N10", TRANSFORM(nNUDTotal, PIC_IZN()))
add_tpars("N11", TRANSFORM(nNUZTotal, PIC_IZN()))
add_tpars("N12", TRANSFORM(nNUNeto, PIC_IZN()))

return


// --------------------------------------------------
// filovanje operacija 
// --------------------------------------------------
static function fill_rn_oper( lPriprema, nBr_Nal )
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
	nTb_OP := F_P_RNOP
endif

// filuj operacije
select (nTb_OP)
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	if EMPTY(field->rn_instr)
		skip
		loop
	endif
	
	cBr_nal := str_nal(field->br_nal)
	cR_br := str_rbr(field->r_br)
	cP_br := str_rbr(field->p_br)
	cIdRoba := field->idroba
	cRn_op := field->id_rnop
	cRn_op_naz := s_operacija(cRn_op)
	cRn_ka := field->id_rnka
	cRn_ka_naz := s_karakt(cRn_ka)
	cRn_instr := field->rn_instr
	
	a_t_rnop( cBr_nal, cR_br, cP_br, cIdroba, ;
                   cRn_op, cRn_op_naz, ;
		   cRn_ka, cRn_ka_naz, cRn_instr)

	select (nTb_OP)
	skip
enddo

return


// --------------------------------------
// napuni podatke narucioca i ostalo
// --------------------------------------
static function fill_nalog_osn(lPriprema, nBr_Nal)
local nTb_RN := F_RNAL

if ( lPriprema == .t. )
	nTb_RN := F_P_RNAL
endif

select (nTb_RN)
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

f_narucioc(field->idpartner)

select (nTb_RN)

// iz prvog sloga odmah uzmi osnovne podatke naloga
// partner, datumi itd...

// broj naloga
add_tpars("N01", str_nal(nBr_nal) )
// datum naloga
add_tpars("N02", DToC(field->dat_nal) )
// datum isporuke
add_tpars("N03", DToC(field->dat_isp) )
// vrijeme isporuke
add_tpars("N04", PADR(field->vr_isp, 5))
// hitnost - prioritet
add_tpars("N05", say_hitnost(field->hitnost))
// nalog vrsta placanja
add_tpars("N06", say_vr_plac(field->vr_plac))

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



