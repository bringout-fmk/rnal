#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// azuriranje RNLOG za novi nalog
// ------------------------------------------
function a_rnlog( nBr_nal )
local dDatum := DATE()
local cVrijeme := TIME()
local cOperater
local cPartner
local cPrioritet
local cVrPlac
local cMjIsp
local cDatIsp
local cVrIsp
local cKontakt
local nLOGR_br
local cAkcija
local cTip

// uzmi podatke iz pripreme
select p_rnal
go top

cOperater := field->operater
cPartner := field->idpartner
cPrioritet := field->hitnost
cVrPlac := field->vr_plac
cKontakt := field->kontakt
cDatIsp := DTOC(field->datisp)
cVrIsp := field->vr_isp
cMjIsp := field->mj_isp


// logiranje osnovnih podataka o nalogu
// partner, vrsta placanja, prioritet
nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "10"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)
f10_stavke(nBr_nal, nLOGR_br, cPartner, cVrPlac, cPrioritet)

// logiranje podataka o isporuci
// vrijeme, mjesto, datum

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "11"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)
f11_stavke(nBr_nal, nLOGR_br, cMjIsp, cDatIsp, cVrIsp)

// logiranje podataka o kontaktu

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "12"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)
f12_stavke(nBr_nal, nLOGR_br, cKontakt)

// logiranje stavki naloga

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "20"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)

select p_rnst
set order to tag "br_nal"
go top
do while !EOF()
	cIdRoba := field->idroba
	nKolicina := field->kolicina
	nSirina := field->d_sirina
	nVisina := field->d_visina
	nStP_br := field->p_br
	f20_stavke(nBr_nal, nLOGR_br, nStP_br, cIdRoba, nKolicina, nSirina, nVisina)
	select p_rnst
	skip
enddo

select p_rnal

// logiranje operacija


return


// filuje stavku u RNLOG
function f_rnlog(nBr_nal, nR_br, cTip, cAkcija,;
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
function f10_stavke(nBr_nal, nR_br, cPartn, cVrPlac, cPrioritet)

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
function f11_stavke(nBr_nal, nR_br, cMjIsp, cDatIsp, cVrIsp)

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
function f12_stavke(nBr_nal, nR_br, cKontakt)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cKontakt

return


// --------------------------------
// filovanje stavki tip 12
// kontakti
// --------------------------------
function f20_stavke(nBr_nal, nR_br, nP_br, cRoba, nKol, nVis, nSir)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
replace idroba with cRoba
replace k_1 with nKol
replace n_1 with nVis
replace n_2 with nSir

return



//------------------------------------------------
// vraca sljedeci redni broj naloga u LOG tabeli
//------------------------------------------------
function n_log_rbr(nBr_nal)
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
function n_logit_pbr(nBr_nal, nR_br)
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


