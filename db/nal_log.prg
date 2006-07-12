#include "\dev\fmk\rnal\rnal.ch"


// --------------------------
// meni promjena
// --------------------------
function m_prom(nBr_nal)
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. promjena osnovnih podataka naloga ")
AADD(opcexe, {|| prom_osnovni(nBr_nal) })
AADD(opc, "2. promjena podataka o isporuci ")
AADD(opcexe, {|| prom_isporuka(nBr_nal) })
AADD(opc, "3. dodaj novi kontakt ")
AADD(opcexe, {|| prom_kontakt(nBr_nal) })
AADD(opc, "4. promjena stavki naloga ")
AADD(opcexe, {|| prom_artikli(nBr_nal) })

Menu_sc("prom")

return DE_CONT

// ---------------------------------
// promjena osnovnih podataka 
// ---------------------------------
function prom_osnovni(nBr_nal)

return

// ---------------------------------
// promjena podataka o isporuci
// ---------------------------------
function prom_isporuka(nBr_nal)

return

// ---------------------------------
// promjena kontakta
// ---------------------------------
function prom_kontakt(nBr_nal)

return

// ---------------------------------
// promjena stavki naloga, artikli
// ---------------------------------
function prom_artikli(nBr_nal)

return

// -------------------------------------------
// logiranje promjena pri operaciji azuriranja
// naloga
// -------------------------------------------
function a_rnlog( nBr_nal )
local cOperater
local cKontakt
local cVrIsp
local cMjIsp
local cDatIsp
local cPartner
local cPrioritet
local cVrPlac

// uzmi podatke iz pripreme
select p_rnal
go top

cOperater := field->operater
cKontakt := field->kontakt
cVrIsp := field->vr_isp
cMjIsp := field->mj_isp
cDatIsp := DTOC(field->datisp)
cPartner := field->idpartner
cPrioritet := field->hitnost
cVrPlac := field->vr_plac

// logiraj osnovne podatke
log_osn(nBr_nal, cOperater, cPartner, cPrioritet, cVrPlac)

// logiraj podatke o isporuci
log_isporuka(nBr_nal, cOperater, cMjIsp, cVrIsp, cDatIsp)

// logiranje podataka o kontaktu
log_kontakt(nBr_nal, cOperater, cKontakt)

// logiranje artikala
log_artikal(nBr_nal)

// logiranje operacija
log_operacije(nBr_nal)

return


// logiranje osnovnih podataka
function log_osn(nBr_nal, cOperater, cPartner, cPrioritet, cVrPlac, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil)
	cAkcija := "+"
endif
cTip := "10"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)
f10_stavke(nBr_nal, nLOGR_br, cPartner, cVrPlac, cPrioritet)

return


// logiranje podatka isporuke
function log_isporuka(nBr_nal, cOperater, cMjIsp, cVrIsp, cDatIsp, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif
cTip := "11"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)
f11_stavke(nBr_nal, nLOGR_br, cMjIsp, cDatIsp, cVrIsp)

return


// logiranje kontakta
function log_kontakt(nBr_nal, cOperater, cKontakt, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif
cTip := "12"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)
f12_stavke(nBr_nal, nLOGR_br, cKontakt)

return


// logiranje artikala
function log_artikal(nBr_nal)
local dDatum := DATE()
local cVrijeme := TIME()
local cOperater
local cProizvod
local nLOGR_br
local cAkcija
local cTip

// uzmi podatke iz pripreme
select p_rnal
go top

cOperater := field->operater

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "20"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)

select p_rnal
set order to tag "br_nal"
go top
do while !EOF()

	cProizvod := field->proizvod
	nR_br := field->r_br
	
	select p_rnst
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

	do while !EOF() .and. field->br_nal == nBr_nal ;
			.and. field->r_br == nR_br
			
		cIdRoba := field->idroba
		nKolicina := field->kolicina
		nVisina := field->d_visina
		nSirina := field->d_sirina
		nStP_br := field->p_br
		
		f20_stavke(nBr_nal, nLOGR_br, nStP_br, cProizvod, cIdRoba, nKolicina, nSirina, nVisina)
		
		select p_rnst
		skip
	enddo

	select p_rnal
	skip
enddo

return

// logiranje operacija
function log_operacija(nBr_nal)
local dDatum := DATE()
local cVrijeme := TIME()
local cOperater
local cProizvod
local nLOGR_br
local cAkcija
local cTip

// uzmi podatke iz pripreme
select p_rnal
go top

cOperater := field->operater

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "30"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)

select p_rnal
set order to tag "br_nal"
go top
do while !EOF()

	cProizvod := field->proizvod
	nR_br := field->r_br
	
	select p_rnst
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

	do while !EOF() .and. field->br_nal == nBr_nal ;
			.and. field->r_br == nR_br
			
		cRoba := field->idroba
		nR_br := field->r_br
		nP_br := field->p_br
		
		select p_rnop
		set order to tag "br_nal"
		go top
		seek STR(nBr_nal, 10, 0);
		 	+ STR(nR_br, 4, 0);
			+ STR(nP_br, 4, 0);
			+ cRoba
		
		do while !EOF() .and. field->br_nal == nBr_nal;
				.and. field->r_br == nR_br;
				.and. field->p_br == nP_br;
				.and. field->idroba == cRoba

			nSTP_br := field->p_br
			cRnKa := field->id_rnka
			cRnOper := field->id_rnop
			cInstr := field->rn_instr
			
			f30_stavke(nBr_nal, nLOGR_br, nStP_br, cProizvod, cRoba, cRnOper, cRnKa, cInstr)
			
			select p_rnop
			skip
		enddo
		
		select p_rnst
		skip
	enddo

	select p_rnal
	skip
enddo

return


// filuje stavku u RNLOG
static function f_rnlog(nBr_nal, nR_br, cTip, cAkcija,;
 		      dDatum, cVrijeme, cOperater)
select rnlog
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace datum with dDatum
replace vrijeme with cVrijeme
replace akcija with cAkcija
replace tip with cTip
replace operater with cOperater

return

// -----------------------------------
// filovanje stavki tip 10
// partner, vrsta placanja, prioritet
// -----------------------------------
static function f10_stavke(nBr_nal, nR_br, cPartn, cVrPlac, cPrioritet)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cPartn
replace c_2 with cVrPlac
replace c_3 with cPrioritet

return


// --------------------------------
// filovanje stavki tip 11
// mjesto, datum i vrijeme isporuke
// --------------------------------
static function f11_stavke(nBr_nal, nR_br, cMjIsp, cDatIsp, cVrIsp)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cMjIsp
replace c_2 with cDatIsp
replace c_3 with cVrIsp

return


// --------------------------------
// filovanje stavki tip 12
// kontakti
// --------------------------------
static function f12_stavke(nBr_nal, nR_br, cKontakt)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cKontakt

return


// --------------------------------
// filovanje stavki tip 20
// stavke.... sastavnice
// --------------------------------
static function f20_stavke(nBr_nal, nR_br, nSt_Rbr,;
			   cRoba, cRoba2, nKol, nVis, nSir)
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
replace idroba with cRoba
replace idroba2 with cRoba2
replace st_rbr with nSt_Rbr
replace k_1 with nKol
replace n_1 with nVis
replace n_2 with nSir

return


// --------------------------------
// filovanje stavki tip 30
// stavke.... instrukcije
// --------------------------------
static function f30_stavke(nBr_nal, nR_br, nSt_rbr,;
			   cRoba1, cRoba2, nRnOper,;
			   cRnKa, nInstr)
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
replace idroba1 with cRoba1
replace idroba2 with cRoba2
replace st_rbr with nSt_rbr
replace c_1 with cRnOper
replace c_2 with cRnKa
replace c_3 with cInstr

return


//------------------------------------------------
// vraca sljedeci redni broj naloga u LOG tabeli
//------------------------------------------------
static function n_log_rbr(nBr_nal)
local nLastRbr:=0
PushWa()
select rnlog
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)
do while !EOF() .and. (field->br_nal == nBr_nal)
	nLastRbr := field->r_br
	skip
enddo
PopWa()

return nLastRbr + 1



//------------------------------------------------
// vraca sljedeci podbroj u tabeli RNLOG_IT
//------------------------------------------------
static function n_logit_pbr(nBr_nal, nR_br)
local nLastPbr:=0

PushWa()
select rnlog_it
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)
do while !EOF() .and. (field->br_nal == nBr_nal);
		.and. (field->r_br == nR_br)
	nLastPbr := field->p_br
	skip
enddo
PopWa()

return nLastPbr + 1



