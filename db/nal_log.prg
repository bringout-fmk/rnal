#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// logiranje promjena pri operaciji azuriranja
// naloga
// -------------------------------------------
function a_rnlog( nBr_nal, cOpis )
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
cK_ime := field->k_ime
cK_tel := field->k_tel
cK_opis := field->k_opis
cVrIsp := field->vr_isp
cMjIsp := field->mj_isp
cDatIsp := DTOC(field->datisp)
cPartner := field->idpartner
cPrioritet := field->hitnost
cVrPlac := field->vr_plac

if (cOpis == nil)
	cOpis := "Otvoren novi nalog"
endif

// logiraj osnovne podatke
log_osn(nBr_nal, cOperater, cOpis, cPartner, cPrioritet, cVrPlac)
// logiraj podatke o isporuci
log_isporuka(nBr_nal, cOperater, cOpis, cMjIsp, cVrIsp, cDatIsp)
// logiranje podataka o kontaktu
log_kontakt(nBr_nal, cOperater, cOpis, cK_ime, cK_tel, cK_opis)
// logiranje artikala
log_artikal(nBr_nal, cOperater, cOpis)
// logiranje operacija
log_operacije(nBr_nal, cOperater, cOpis)

return


// logiranje osnovnih podataka
function log_osn(nBr_nal, cOperater, cOpis, cPartner, cPrioritet, cVrPlac, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil)
	cAkcija := "+"
endif
cTip := "10"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater, cOpis)
f10_stavke(nBr_nal, nLOGR_br, cPartner, cVrPlac, cPrioritet)

return


// logiranje podatka isporuke
function log_isporuka(nBr_nal, cOperater, cOpis, cMjIsp, cVrIsp, cDatIsp, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif
cTip := "11"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater, cOpis)
f11_stavke(nBr_nal, nLOGR_br, cMjIsp, cDatIsp, cVrIsp)

return


// logiranje kontakta
function log_kontakt(nBr_nal, cOperater, cOpis, cK_ime, cK_tel, cK_opis, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif
cTip := "12"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater, cOpis)
f12_stavke(nBr_nal, nLOGR_br, cK_ime, cK_tel, cK_opis)

return


// logiranje artikala
function log_artikal(nBr_nal, cOperater, cOpis)
local dDatum := DATE()
local cVrijeme := TIME()
local cProizvod
local nLOGR_br
local cAkcija
local cTip

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "20"

f_rnlog(nBr_nal, nLOGR_br, cTip, cAkcija,;
        dDatum, cVrijeme, cOperater, cOpis)

select p_rnst
set order to tag "br_nal"
go top
do while !EOF()

	nR_br := field->r_br
	nP_br := field->p_br

	select p_rnal
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)
	cProizvod := field->proizvod

	select p_rnst
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
enddo

return


// ------------------------------
// logiranje operacija
// ------------------------------
function log_operacije(nBr_nal, cOperater, cOpis)
local dDatum := DATE()
local cVrijeme := TIME()
local cProizvod
local nLOGR_br
local cAkcija
local cTip

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "30"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater, cOpis)

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
			
			f30_stavke(nBr_nal, nLOGR_br, nStP_br,;
				   cProizvod, cRoba, cRnOper,;
				   cRnKa, cInstr)
			
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


// logiranje kontakta
function log_zatvori(nBr_nal, cOperater, cOpis, cReal, cAkcija)
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif

cTip := "99"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater, cOpis)
f99_stavke(nBr_nal, nLOGR_br, cReal)

return


// filuje stavku u RNLOG
function f_rnlog(nBr_nal, nR_br, cTip, cAkcija,;
 		      dDatum, cVrijeme, cOperater, cOpis)
select rnlog
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace datum with dDatum
replace vrijeme with cVrijeme
replace akcija with cAkcija
replace tip with cTip
replace operater with cOperater
replace opis with cOpis

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
function f12_stavke(nBr_nal, nR_br, cK_ime, cK_tel, cK_opis)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cK_ime
replace c_2 with cK_tel
replace c_3 with cK_opis

return


// --------------------------------
// filovanje stavki tip 20
// stavke.... sastavnice
// --------------------------------
function f20_stavke(nBr_nal, nR_br, nSt_Rbr,;
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
function f30_stavke(nBr_nal, nR_br, nSt_rbr,;
			   cRoba1, cRoba2, nRnOper,;
			   cRnKa, nInstr)
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
replace idroba with cRoba1
replace idroba2 with cRoba2
replace st_rbr with nSt_rbr
replace c_1 with cRnOper
replace c_2 with cRnKa
replace c_3 with cInstr

return


// --------------------------------
// filovanje stavki tip 99
// zatvori nalog....
// --------------------------------
function f99_stavke(nBr_nal, nR_br, cReal)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cReal

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


// -----------------------------------------------
// logiranje delte izmedju kumulativa i pripreme
// -----------------------------------------------
function rnal_delta(nBr_nal, cOpis)
local nTArea := SELECT()

select p_rnal
set filter to
select p_rnst
set filter to
select p_rnop
set filter to
select rnal 
set filter to
select rnop
set filter to
select rnst
set filter to

// delta artikala RNAL -> P_RNAL
dlt_rn(nBr_nal, cOpis)

// delta artikala P_RNAL -> RNAL
dlt_prn(nBr_nal, cOpis)

// delta operacija RNOP -> P_RNOP
//dlt_op()

// delta operacija P_RNOP -> RNOP
//dlt_pop()

select (nTArea)

return

// -----------------------------------
// pregledaj rnst -> p_rnst
// -----------------------------------
function dlt_rn(nBr_nal, cOpis)
local nR_br
local nP_br
local cProizvod
local cSirovina
local lFromKumul := .f.
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTipSir := "20"
local lSirFirst := .f.
local cOperater := goModul:oDataBase:cUser

select rnst
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cSirovina := field->idroba
	nKolicina := field->kolicina
	nSirina := field->d_sirina
	nVisina := field->d_visina
	
	// ako stavka ne postoji 
	if !sirov_exist(nBr_nal, nR_br, nP_br, cSirovina, lFromKumul)
		
		if !lSirFirst
			
			nLOGR_br := n_log_rbr( nBr_nal )
			
			f_rnlog( nBr_nal, nLOGR_br, cTipSir, "-", ;
		           	 dDatum, cVrijeme, cOperater, cOpis)
			
			lSirFirst := .t.
			
		endif
		
		// nadji proizvod
		select rnal
		go top
		seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)
		
		select rnst
	
		f20_stavke(nBr_nal, nR_br, nP_br,;
			   rnal->proizvod, rnst->idroba,;
			   rnst->kolicina, rnst->d_visina,;
			   rnst->d_sirina)
	
		select rnst
		skip
		loop
	endif

	// ako stavka nije ista....
	if !sirov_value(nBr_nal, nR_br, nP_br, cSirovina,;
		      nKolicina, nSirina, nVisina, lFromKumul)
		
		if !lSirFirst
		
			nLOGR_br := n_log_rbr( nBr_nal )
			
			f_rnlog( nBr_nal, nLOGR_br, cTipSir, "-", ;
		           	 dDatum, cVrijeme, cOperater, cOpis)
			
			lSirFirst := .t.
			
		endif
		
		// nadji proizvod
		select rnal
		go top
		seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)
		
		select rnst
	
		f20_stavke(nBr_nal, nR_br, nP_br,;
			   rnal->proizvod, rnst->idroba,;
			   rnst->kolicina, rnst->d_visina,;
			   rnst->d_sirina)
	
	endif
	
	select rnst
	skip
enddo

return

// ------------------------------------------
// pregledaj p_rnst -> rnst
// ------------------------------------------
function dlt_prn(nBr_nal, cOpis)
local nR_br
local nP_br
local cProizvod
local cSirovina
local lFromKumul := .t.
local dDatum := DATE()
local cVrijeme := TIME()
local nLOGR_br
local cTipSir := "20"
local lSirFirst := .f.
local cOperater := goModul:oDataBase:cUser

select p_rnst
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cSirovina := field->idroba
	nKolicina := field->kolicina
	nSirina := field->d_sirina
	nVisina := field->d_visina
	
	// ako stavka ne postoji 
	if !sirov_exist(nBr_nal, nR_br, nP_br, cSirovina, lFromKumul)
		
		if !lSirFirst
			
			nLOGR_br := n_log_rbr( nBr_nal )
			
			f_rnlog( nBr_nal, nLOGR_br, cTipSir, "+", ;
		           	 dDatum, cVrijeme, cOperater, cOpis)
			
			lSirFirst := .t.
			
		endif
		
		// nadji proizvod
		select p_rnal
		go top
		seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)
		
		select rnst
	
		f20_stavke(nBr_nal, nR_br, nP_br,;
			   p_rnal->proizvod, cSirovina,;
			   nKolicina, nVisina, nSirina)
	
	endif
	
	select p_rnst
	skip
enddo

return


// --------------------------------------
// da li postoji sirovina
// --------------------------------------
static function sirov_exist(nBr_nal, nR_br, nP_br, cSirovina, lKumul)
local nF_RNST := F_P_RNST
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if (lKumul == .t.)
	nF_RNST := F_RNST
endif

select (nF_RNST)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0) + STR(nP_br, 4, 0) + cSirovina
 
if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet


// --------------------------------------
// da li je stavka sirovina ista....
// --------------------------------------
static function sirov_value(nBr_nal, nR_br, nP_br, cSirovina,;
			   nKolicina, nSirina, nVisina, lKumul)
local nF_RNST := F_P_RNST
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if (lKumul == .t.)
	nF_RNST := F_RNST
endif

select (nF_RNST)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0) + STR(nP_br, 4, 0) + cSirovina
 
if (field->kolicina == nKolicina) .and. ;
   (field->d_sirina == nSirina) .and. ;
   (field->d_visina == nVisina)
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet

// --------------------------------------------
// vraca tekst sa opisom stavke 20
// --------------------------------------------
function get20_stavka(nBr_nal)
local cRet:=""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek STR(nBr_nal) + "20"

cRet += ALLTRIM(field->opis) + " "
nR_br := field->r_br

select rnlog_it
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br

	cRet += "Proizvod: " + ALLTRIM(field->idroba)
	cRet += " "
	cRet += "Sirovina: " + ALLTRIM(field->idroba2)
	cRet += " "
	cRet += "kol: " + ALLTRIM(STR(field->k_1))
	cRet += " "
	cRet += "vis: " + ALLTRIM(STR(field->n_1))
	cRet += " "
	cRet += "sir: " + ALLTRIM(STR(field->n_2))
	
	select rnlog_it
	skip
enddo

select (nTArea)
return cRet


function get01_stavka(nBr_nal)
local cRet := ""
return cRet

function get99_stavka(nBr_nal)
local cRet := ""
return cRet

function get10_stavka(nBr_nal)
local cRet := ""
return cRet

function get11_stavka(nBr_nal)
local cRet := ""
return cRet

function get12_stavka(nBr_nal)
local cRet := ""
return cRet

function get30_stavka(nBr_nal)
local cRet := ""
return cRet



