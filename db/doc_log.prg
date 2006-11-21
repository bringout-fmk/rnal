#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// logiranje promjena pri operaciji azuriranja
// dokumenta
// -------------------------------------------
function doc_logit( nDoc_no )
local cOperater
local cKontakt
local cVrIsp
local cMjIsp
local cDatIsp
local cPartner
local cPrioritet
local cVrPlac

// uzmi podatke iz _DOCS
select _docs
go top

/*
cOperater := field->operater
cK_ime := field->k_ime
cK_tel := field->k_tel
cK_opis := field->k_opis
cVrIsp := field->vr_isp
cMjIsp := field->mj_isp
cDatIsp := DTOC(field->dat_isp)
cPartner := field->idpartner
cPrioritet := field->hitnost
cVrPlac := field->vr_plac


// logiraj osnovne podatke
cOpis := "Init.osnovni podaci"
log_osn(nBr_nal, cOperater, cOpis, cPartner, cPrioritet, cVrPlac)

// logiraj podatke o isporuci
cOpis := "Init.podaci isporuke"
log_isporuka(nBr_nal, cOperater, cOpis, cMjIsp, cVrIsp, cDatIsp)

// logiranje podataka o kontaktu
cOpis := "Init.podaci isporuke"
log_kontakt(nBr_nal, cOperater, cOpis, cK_ime, cK_tel, cK_opis)

// logiranje artikala
cOpis := "Init.podaci stavki"
log_artikal(nBr_nal, cOperater, cOpis)

// logiranje operacija
cOpis := "Init.podaci operacija"
log_operacije(nBr_nal, cOperater, cOpis)

*/
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
local lLogSt := .f.

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "20"

select p_rnst
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	cItemId := field->item_id
	nKolicina := field->item_kol
	nVisina := field->item_visina
	nSirina := field->item_sirina
	nDebljina := field->item_debljina
	cRobVrsta := ""
		
	f20_stavke(cAkcija, nBr_nal, nLOGR_br, ;
		cItemID, "", cRobVrsta, nKolicina, ;
		nSirina, nVisina)
		
	lLogSt := .t.
	
	select p_rnst
	skip
	
enddo

// ako je bilo stavki dodaj i RNLOG zapis
if lLogSt
	f_rnlog(nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
endif

return


// ------------------------------
// logiranje operacija
// ------------------------------
function log_operacije(nBr_nal, cOperater, cOpis)
local cProizvod
local nLOGR_br
local cAkcija
local cTip
local lLogOper := .f.

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "30"

select p_rnst
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_Nal

	cItemID := field->item_id
	nR_br := field->r_br
		
	select p_rnop
	set order to tag "br_nal"
	go top
	
	seek s_br_nal(nBr_nal) + s_r_br(nR_br) + cItemID
		
	do while !EOF() .and. field->br_nal == nBr_nal;
			.and. field->r_br == nR_br;
			.and. field->idroba == cItemID

		nSTP_br := field->p_br
		cRnKa := field->id_rnka
		cRnOper := field->id_rnop
		cInstr := field->rn_instr
			
		f30_stavke(cAkcija, nBr_nal, nLOGR_br, ;
				   cItemID, "", cRnOper, ;
				   cRnKa, cInstr)
			
		lLogOper := .t.
			
		select p_rnop
		skip
	enddo
		
	select p_rnst
	skip
enddo

// ako je bilo operacija dodaj i RNLOG zapis
if lLogOper
	f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)
endif

return


// ---------------------------------------
// logiranje zatvaranje naloga...
// ---------------------------------------
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



// ---------------------------------------
// logiranje otvaranje naloga...
// ---------------------------------------
function log_otvori(nBr_nal, cOperater, cOpis)
local nLOGR_br
local cTip

if (cOpis == nil)
	cOpis := "Nalog otvoren radi dorade"
endif

if (cOperater == nil)
	cOperater := goModul:oDataBase:cUser
endif

cTip := "01"
nLOGR_br := n_log_rbr( nBr_nal )

f_rnlog( nBr_nal, nLOGR_br, cTip, cOperater, cOpis)

return



// -------------------------------------------------------
// dodaje stavku u tabelu RNLOG
// -------------------------------------------------------
function f_rnlog(nBr_nal, nR_br, cTip, ;
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
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
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
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
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
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
replace c_1 with cK_ime
replace c_2 with cK_tel
replace c_3 with cK_opis
replace akcija with cAkcija

return


// --------------------------------
// filovanje stavki tip 20
// stavke.... sastavnice
// --------------------------------
function f20_stavke(cAkcija, nBr_nal, nR_br, ;
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
function f30_stavke(cAkcija, nBr_nal, nR_br,;
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
local nP_br

nP_br := n_logit_pbr(nBr_nal, nR_br)

select rnlog_it
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace p_br with nP_br
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
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. (field->br_nal == nBr_nal) ;
		.and. (field->r_br == nR_br)
	nLastPbr := field->p_br
	skip
enddo
PopWa()

return nLastPbr + 1


// -----------------------------------------------
// logiranje delte izmedju kumulativa i pripreme
// -----------------------------------------------
function doc_delta( nDoc_no )
local nTArea := SELECT()

select _docs
set filter to
select _doc_it
set filter to
select _doc_op
set filter to
select docs
set filter to
select doc_op
set filter to
select doc_it
set filter to

// delta stavki naloga - robe
//rn_delta(nBr_nal, cOpis)

// delta stavki naloga - operacije
//op_delta(nBr_nal, cOpis)

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
local cItemID
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
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	cItemID := field->item_id
	nKolicina := field->item_kol
	nSirina := field->item_sirina
	nVisina := field->item_visina
	
	// provjeri da li rnal(stavka) postoji u p_rnal 
	// akcija "-"
	
	if !st_exist(nBr_nal, nR_br, cItemID, .f.)
		
		cAkcija := "-"
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, ;
			   rnst->item_id, "", "",;
			   rnst->item_kol, rnst->item_visina,;
			   rnst->item_sirina)
			
		lSetRNLOG := .t.
		
		select rnst
		skip
		loop
		
	endif

	// provjeri integritet stavki RNST <-> P_RNST (idroba)
	// akcija "E"
	
	if !st_value(nBr_nal, nR_br, cItemID, ;
		      nKolicina, nSirina, nVisina, .f.)
		
		cAkcija := "E"
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, ;
			   p_rnst->item_id, ;
			   "", ;
			   "", ;
			   p_rnst->item_kol, ;
			   p_rnst->item_visina, ;
			   p_rnst->item_sirina )
	
		lSetRNLOG := .t.
	endif
	
	select rnst
	skip
enddo

// pozicioniraj se na P_RNST
select p_rnst
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	cItemID := field->item_id
	nKolicina := field->item_kol
	nSirina := field->item_sirina
	nVisina := field->item_visina
	
	// provjeri da li stavka postoji u kumulativu
	// akcija "+"
	
	if !st_exist(nBr_nal, nR_br, cItemID, .t.)
		
		cAkcija := "+"
		
		f20_stavke(cAkcija, nBr_nal, nLOGR_br, ;
			   cItemID, "", "", ;
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
local cItemID

// uzmi sljedeci broj RNLOG
nLOGR_br := n_log_rbr( nBr_nal )

// pozicioniraj se na trazeni radni nalog
select rnop
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cIdOper := field->id_rnop
	cIdKarakt := field->id_rnka
	cItemID := field->item_id
	cInstr := field->rn_instr
	
	// provjeri da li rnop(stavka) postoji u p_rnop 
	// akcija "-"
	
	if !op_exist(nBr_nal, nR_br, nP_br, cItemID, cIdOper, cIdKarakt, .f.)
		
		cAkcija := "-"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br,;
			   cItemID, ;
			   "", ;
			   cIdOper, ;
			   cIdKarakt, ;
			   cInstr)
			
		lSetRNLOG := .t.
		
		select rnop
		skip
		loop
		
	endif

	// provjeri integritet stavki RNOP <-> P_RNOP (idroba)
	// akcija "E"
	
	if !op_value(nBr_nal, nR_br, nP_br, cItemID, cIdOper, ;
		      cIdKarakt, cInstr, .f.)
		
		cAkcija := "E"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br, ;
			   cItemID, ;
			   "", ;
			   cIdOper, ;
			   cIdKarakt, ;
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
seek s_br_nal(nBr_nal)

do while !EOF() .and. field->br_nal == nBr_nal

	nR_br := field->r_br
	nP_br := field->p_br
	cIdOper := field->id_rnop
	cIdKarakt := field->id_rnka
	cItemID := field->item_id
	cInstr := field->rn_instr

	// provjeri da li stavka postoji u kumulativu
	// akcija "+"
	
	if !op_exist(nBr_nal, nR_br, nP_br, cItemID, cIdOper, cIdKarakt, .t.)
		
		cAkcija := "+"
		
		f30_stavke(cAkcija, nBr_nal, nLOGR_br,;
			   cItemID, ;
			   "", ;
			   cIdOper, ;
			   cIdKarakt, ;
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



// --------------------------------------
// da li postoji sirovina u tabelama
// P_RNST, RNST
// --------------------------------------
static function st_exist(nBr_nal, nR_br, cItemID, lKumul)
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
seek s_br_nal(nBr_nal) + s_r_br(nR_br) + cItemID

if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet


// --------------------------------------
// da li je stavka sirovina ista....
// --------------------------------------
static function st_value(nBr_nal, nR_br, cItemID,;
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
seek s_br_nal(nBr_nal) + s_r_br(nR_br) + cItemID
 
if (field->item_kol == nKolicina) .and. ;
   (field->item_sirina == nSirina) .and. ;
   (field->item_visina == nVisina)
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet


// --------------------------------------
// da li postoji operacija u tabelama
// P_RNOP, RNOP
// --------------------------------------
static function op_exist(nBr_nal, nR_br, nP_br, cItemID, ;
			cIdOper, cIdKarakt, lKumul)
			
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
seek s_br_nal(nBr_nal) + s_r_br(nR_br) + s_p_br(nP_br) + cItemID + cIdOper + cIdKarakt

if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet


// --------------------------------------
// da li je stavka operacije ista....
// --------------------------------------
static function op_value(nBr_nal, nR_br, nP_br, cItemID,;
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
seek s_br_nal(nBr_nal) + s_r_br(nR_br) + s_p_br(nP_br) + cItemID + cIdOper + cIdKarak
 
if (ALLTRIM(field->rn_instr) == ALLTRIM(cInstr))
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "20"
// ----------------------------------------------
function get20_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "20" + s_r_br(nR_br)

select rnlog_it
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br

	cRet += "stavka: " + ALLTRIM(field->idroba2)
	cRet += "#"
	cRet += "kol.=" + ALLTRIM(STR(field->k_1, 8, 2))
	cRet += ","
	cRet += "vis.=" + ALLTRIM(STR(field->n_1, 8, 2))
	cRet += ","
	cRet += "sir.=" + ALLTRIM(STR(field->n_2, 8, 2))
	cRet += "#"
	
	select rnlog_it
	skip
enddo

select rnlog
set order to tag "br_nal"

select (nTArea)
return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "01"
// ----------------------------------------------
function get01_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "01" + s_r_br(nR_br)

cRet += "Otvaranje naloga...#"
	
set order to tag "br_nal"

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "99"
// ----------------------------------------------
function get99_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "99" + s_r_br(nR_br)

cRet += "Zatvaranje naloga...#"
	
set order to tag "br_nal"

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "10"
// ----------------------------------------------
function get10_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "10" + s_r_br(nR_br)

select rnlog_it
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br

	//cRet += "Partner: " + s_partner( ALLTRIM(field->c_1) )
	cRet += "#"
	//cRet += "vrsta placanja: " + say_vr_plac( ALLTRIM(field->c_2) )
	cRet += "#"
	//cRet += "prioritet: " + say_hitnost( ALLTRIM(field->c_3) )
	cRet += "#"
	
	select rnlog_it
	skip
enddo

select rnlog
set order to tag "br_nal"

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "11"
// ----------------------------------------------
function get11_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "11" + s_r_br(nR_br)

select rnlog_it
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br

	cRet += "mjesto isporuke: " + ALLTRIM(field->c_1)
	cRet += "#"
	cRet += "datum isporuke: " + ALLTRIM(field->c_2)
	cRet += "#"
	cRet += "vrijeme isporuke: " + ALLTRIM(field->c_3)
	cRet += "#"
	
	select rnlog_it
	skip
enddo

select rnlog
set order to tag "br_nal"

select (nTArea)

return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "12"
// ----------------------------------------------
function get12_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "12" + s_r_br(nR_br)

select rnlog_it
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br

	cRet += "kontakt ime: " + ALLTRIM(field->c_1)
	cRet += "#"
	cRet += "kontakt telefon: " + ALLTRIM(field->c_2)
	cRet += "#"
	cRet += "kontakt opis: " + ALLTRIM(field->c_3)
	cRet += "#"
	
	select rnlog_it
	skip
enddo

select rnlog
set order to tag "br_nal"

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "30"
// ----------------------------------------------
function get30_stavka(nBr_nal, nR_br)
local cRet := ""
local nTArea := SELECT()

select rnlog
set order to tag "tip"
go top
seek s_br_nal(nBr_nal) + "30" + s_r_br(nR_br)

select rnlog_it
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

cTmpSirov := "XXX"

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br

	cSirov := field->idroba2
	
	if cSirov <> cTmpSirov
		cRet += "sirov.= " + ALLTRIM(field->idroba2)
		cRet += "#"
	endif
	
	//cRet += s_karakt( ALLTRIM(field->c_2) )
	cRet += "="
	cRet += ALLTRIM(field->c_3)
	
	cRet += "#"
		
	select rnlog_it
	skip

	cTmpSirov := cSirov
	
enddo

select rnlog
set order to tag "br_nal"

select (nTArea)

return cRet



