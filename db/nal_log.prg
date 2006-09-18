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
local nLOGR_br
local cTip

if ( cAkcija == nil)
	cAkcija := "+"
endif
cTip := "10"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
f10_stavke(cAkcija, nBr_nal, nLOGR_br, cPartner, cVrPlac, cPrioritet)

return


// logiranje podatka isporuke
function log_isporuka(nBr_nal, cOperater, cOpis, cMjIsp, cVrIsp, cDatIsp, cAkcija)
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif

cTip := "11"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
f11_stavke(cAkcija, nBr_nal, nLOGR_br, cMjIsp, cDatIsp, cVrIsp)

return


// logiranje kontakta
function log_kontakt(nBr_nal, cOperater, cOpis, cK_ime, cK_tel, cK_opis, cAkcija)
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif
cTip := "12"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
f12_stavke(cAkcija, nBr_nal, nLOGR_br, cK_ime, cK_tel, cK_opis)

return


// logiranje artikala
function log_artikal(nBr_nal, cOperater, cOpis)
local cProizvod
local nLOGR_br
local cAkcija
local cTip
local cRobVrsta

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "20"

f_rnlog(nBr_nal, nLOGR_br, cTip, cOperater, cOpis)

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
		cRobVrsta := field->roba_vrsta
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, nStP_br, cProizvod, cIdRoba, cRobVrsta, nKolicina, nSirina, nVisina)
		
		select p_rnst
		skip
	enddo
enddo

return


// ------------------------------
// logiranje operacija
// ------------------------------
function log_operacije(nBr_nal, cOperater, cOpis)
local cProizvod
local nLOGR_br
local cAkcija
local cTip

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "30"

f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)

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
			
			f30_stavke(cAkcija, nBr_nal, nLOGR_br, nStP_br,;
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
local nLOGR_br
local cTip

if ( cAkcija == nil )
	cAkcija := "+"
endif

cTip := "99"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
f99_stavke(cAkcija, nBr_nal, nLOGR_br, cReal)

return

// -------------------------------------------------------
// dodaje stavku u tabelu RNLOG
// -------------------------------------------------------
function f_rnlog(nBr_nal, nR_br, cTip,;
 		 cOperater, cOpis)
select rnlog
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace datum with DATE()
replace vrijeme with TIME()
replace tip with cTip
replace operater with cOperater
replace opis with cOpis

return

// -----------------------------------
// filovanje stavki tip 10
// partner, vrsta placanja, prioritet
// -----------------------------------
function f10_stavke(cAkcija, nBr_nal, nR_br, cPartn, cVrPlac, cPrioritet)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cPartn
replace c_2 with cVrPlac
replace c_3 with cPrioritet
replace akcija with cAkcija

return


// --------------------------------
// filovanje stavki tip 11
// mjesto, datum i vrijeme isporuke
// --------------------------------
function f11_stavke(cAkcija, nBr_nal, nR_br, cMjIsp, cDatIsp, cVrIsp)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cMjIsp
replace c_2 with cDatIsp
replace c_3 with cVrIsp
replace akcija with cAkcija

return


// --------------------------------
// filovanje stavki tip 12
// kontakti
// --------------------------------
function f12_stavke(cAkcija, nBr_nal, nR_br, cK_ime, cK_tel, cK_opis)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cK_ime
replace c_2 with cK_tel
replace c_3 with cK_opis
replace akcija with cAkcija

return


// --------------------------------
// filovanje stavki tip 20
// stavke.... sastavnice
// --------------------------------
function f20_stavke(cAkcija, nBr_nal, nR_br, nSt_Rbr,;
		    cRoba, cRoba2, cRobVrsta, nKol, nVis, nSir)
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
replace c_1 with cRobVrsta
replace k_1 with nKol
replace n_1 with nVis
replace n_2 with nSir
replace akcija with cAkcija

return


// --------------------------------
// filovanje stavki tip 30
// stavke.... instrukcije
// --------------------------------
function f30_stavke(cAkcija, nBr_nal, nR_br, nSt_rbr,;
		     cRoba1, cRoba2, cRnOper,;
		     cRnKa, cInstr)
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
replace akcija with cAkcija

return


// --------------------------------
// filovanje stavki tip 99
// zatvori nalog....
// --------------------------------
function f99_stavke(cAkcija, nBr_nal, nR_br, cReal)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace c_1 with cReal
replace akcija with cAkcija

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

// delta stavki naloga - robe
rn_delta(nBr_nal, cOpis)

// delta stavki naloga - operacije
op_delta(nBr_nal, cOpis)

select (nTArea)

return


// -------------------------------------------------
// function rn_delta() - delta stavki naloga
// nBr_nal - broj naloga
// cOpis - opis promjene
// funkcija gleda p_rnst na osnovu rnst i trazi
// 1. stavke koje nisu iste
// 2. stavke koje su izbrisane
// -------------------------------------------------
static function rn_delta(nBr_nal, cOpis)
local nR_br
local nP_br
local cProizvod
local cSirovina
local cRobVrsta
local cAkcija
local nLOGR_br
local cTip := "20"
local lSetRNLOG := .f.
local cOperater := goModul:oDataBase:cUser

// uzmi sljedeci broj RNLOG
nLOGR_br := n_log_rbr( nBr_nal )

// pozicioniraj se na trazeni radni nalog
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
	cRobVrsta := field->roba_vrsta
	
	// provjeri da li rnal(stavka) postoji u p_rnal 
	// akcija "-"
	
	if !st_exist(nBr_nal, nR_br, nP_br, cSirovina, .f.)
		
		// pozicioniraj se na rnal
		seek_rnal(nBr_nal, nR_br)
		
		cAkcija := "-"
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, nP_br,;
			   rnal->proizvod, rnst->idroba, rnst->roba_vrsta,;
			   rnst->kolicina, rnst->d_visina,;
			   rnst->d_sirina)
			
		lSetRNLOG := .t.
		
		select rnst
		skip
		loop
		
	endif

	// provjeri integritet stavki RNST <-> P_RNST (idroba)
	// akcija "E"
	
	if !st_value(nBr_nal, nR_br, nP_br, cSirovina,;
		      nKolicina, nSirina, nVisina, .f.)
		
		// pozicioniraj se na RNAL zapis
		seek_rnal(nBr_nal, nR_br)
	
		cAkcija := "E"
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, nP_br,;
			   rnal->proizvod, rnst->idroba, rnst->roba_vrsta,;
			   rnst->kolicina, rnst->d_visina,;
			   rnst->d_sirina)
	
		lSetRNLOG := .t.
	endif
	
	select rnst
	skip
enddo

// pozicioniraj se na P_RNST
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
	cRobVrsta := field->roba_vrsta
	
	// provjeri da li stavka postoji u kumulativu
	// akcija "+"
	
	if !st_exist(nBr_nal, nR_br, nP_br, cSirovina, .t.)
		
		// pozicioniraj se na P_RNAL
		seek_prnal(nBr_nal, nR_br)
		
		cAkcija := "+"
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, nP_br,;
			   p_rnal->proizvod, cSirovina, cRobVrsta, ;
			   nKolicina, nVisina, nSirina)

		lSetRNLOG := .t.
	
	endif
	
	select p_rnst
	skip
enddo

// ako je bilo promjena upisi i u RNLOG...
if lSetRNLOG 
	f_rnlog(nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
endif

return



// -------------------------------------------------
// function op_delta() - delta operacija naloga
// -------------------------------------------------
static function op_delta(nBr_nal, cOpis)
local nR_br
local nP_br
local cAkcija
local nLOGR_br
local cTip := "30"
local lSetRNLOG := .f.
local cOperater := goModul:oDataBase:cUser
local cIdOper
local cIdKarakt
local cInstr
local cRoba

// uzmi sljedeci broj RNLOG
nLOGR_br := n_log_rbr( nBr_nal )

// pozicioniraj se na trazeni radni nalog
select rnop
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cIdOper := field->id_rnop
	cIdKarakt := field->id_rnka
	cRoba := field->idroba
	cInstr := field->rn_instr
	
	// provjeri da li rnop(stavka) postoji u p_rnop 
	// akcija "-"
	
	if !op_exist(nBr_nal, nR_br, nP_br, cRoba, cIdOper, cIdKarakt, .f.)
		
		// pozicioniraj se na rnal
		seek_rnal(nBr_nal, nR_br)
		
		cAkcija := "-"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br, nP_br,;
			   rnal->proizvod, cRoba,;
			   cIdOper, cIdKarakt,;
			   cInstr)
			
		lSetRNLOG := .t.
		
		select rnop
		skip
		loop
		
	endif

	// provjeri integritet stavki RNOP <-> P_RNOP (idroba)
	// akcija "E"
	
	if !op_value(nBr_nal, nR_br, nP_br, cRoba, cIdOper, ;
		      cIdKarakt, cInstr, .f.)
		
		// pozicioniraj se na RNAL zapis
		seek_rnal(nBr_nal, nR_br)
	
		cAkcija := "E"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br, nP_br,;
			   rnal->proizvod, cRoba,;
			   cIdOper, cIdKarakt,;
			   cInstr)
	
		lSetRNLOG := .t.
	endif
	
	select rnop
	skip
enddo

// pozicioniraj se na P_RNOP
select p_rnop
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cIdOper := field->id_rnop
	cIdKarakt := field->id_rnka
	cRoba := field->idroba
	cInstr := field->rn_instr

	// provjeri da li stavka postoji u kumulativu
	// akcija "+"
	
	if !op_exist(nBr_nal, nR_br, nP_br, cRoba, cIdOper, cIdKarakt, .t.)
		
		// pozicioniraj se na P_RNAL
		seek_prnal(nBr_nal, nR_br)
		
		cAkcija := "+"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br, nP_br,;
			   rnal->proizvod, cRoba,;
			   cIdOper, cIdKarakt,;
			   cInstr)
	
		lSetRNLOG := .t.
	
	endif
	
	select p_rnst
	skip
enddo

// ako je bilo promjena upisi i u RNLOG...
if lSetRNLOG 
	f_rnlog(nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
endif

return


// -------------------------------------------------
// nastimaj pointer na rnal stavku...
// -------------------------------------------------
function seek_rnal(nBr_nal, nR_br)
local nTArea := SELECT()

select rnal
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

select (nTArea)
return


// -------------------------------------------------
// nastimaj pointer na p_rnal stavku...
// -------------------------------------------------
function seek_prnal(nBr_nal, nR_br)
local nTArea := SELECT()

select p_rnal
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

select (nTArea)
return


// --------------------------------------
// da li postoji sirovina u tabelama
// P_RNST, RNST
// --------------------------------------
static function st_exist(nBr_nal, nR_br, nP_br, cSirovina, lKumul)
local nF_RNST := F_P_RNST
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if ( lKumul == .t. )
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
static function st_value(nBr_nal, nR_br, nP_br, cSirovina,;
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


// --------------------------------------
// da li postoji operacija u tabelama
// P_RNOP, RNOP
// --------------------------------------
static function op_exist(nBr_nal, nR_br, nP_br, cRoba, cIdOper, cIdKarakt, lKumul)
local nF_RNOP := F_P_RNOP
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if ( lKumul == .t. )
	nF_RNOP := F_RNOP
endif

select (nF_RNOP)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0) + STR(nP_br, 4, 0) + cRoba + cIdOper + cIdKarakt

if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet


// --------------------------------------
// da li je stavka operacije ista....
// --------------------------------------
static function op_value(nBr_nal, nR_br, nP_br, cRoba,;
			   cIdOper, cIdKarak, cInstr, lKumul)
local nF_RNOP := F_P_RNOP
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if (lKumul == .t.)
	nF_RNOP := F_RNOP
endif

select (nF_RNOP)
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0) + STR(nP_br, 4, 0) + cRoba + cIdOper + cIdKarak
 
if (ALLTRIM(field->rn_instr) == ALLTRIM(cInstr))
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

select rnlog
set order to tag "br_nal"

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



