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
AADD(opcexe, {|| add_kontakt(nBr_nal) })
AADD(opc, "4. promjena kontakta na nalogu")
AADD(opcexe, {|| prom_kontakt(nBr_nal) })

Menu_sc("prom")

return DE_CONT

// ---------------------------------
// promjena osnovnih podataka 
// ---------------------------------
function prom_osnovni(nBr_nal)
local nTRec := RecNo()
local cPartn
local cHitnost
local cVrPlac
local cOpis
local cDbFilt

if Pitanje(,"Zelite izmjeniti osnovne podatke naloga (D/N)?", "D") == "N"
	return
endif

cDbFilt := DBFilter()
select rnal
set filter to
set order to tag "br_nal"
go top
seek STR(nBr_nal)

cPartn := field->idpartner
cHitnost := field->hitnost
cVrPlac := field->vr_plac

// box sa unosom podataka
if box_osnovni(@cPartn, @cHitnost, @cVrPlac, @cOpis) == 0
	return
endif

cOperater := goModul:oDataBase:cUser

// logiraj ....
log_osn(nBr_nal, cOperater, cOpis, cPartn, cHitnost, cVrPlac, "E")

select rnal
do while !EOF() .and. field->br_nal == nBr_nal
	Scatter()
	if _idpartner <> cPartn
		_idpartner := cPartn
	endif
	if _hitnost <> cHitnost
		_hitnost := cHitnost
	endif
	if _vr_plac <> cVrPlac
		_vr_plac := cVrPlac
	endif
	_operater := cOperater
	Gather()
	skip
enddo

select rnal
set filter to &cDbFilt
go (nTRec)

MsgBeep("Napravljene promjene na osnovnim podacima!")

return



// --------------------------------------
// box sa unosom podataka osnovnih
// --------------------------------------
static function box_osnovni(cPartn, cHitnost, cVrPlac, cOpis)

Box(, 7, 65)
	cOpis := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena na osnovnim podacima naloga:"
	@ m_x + 3, m_y + 2 SAY "Partner:" GET cPartn VALID val_partner(@cPartn)
	@ m_x + 4, m_y + 2 SAY "Hitnost (1/2/3):" GET cHitnost VALID val_kunos(@cHitnost, "123")
	@ m_x + 5, m_y + 2 SAY "Vrsta placanja 1-kes, 2-ziro rn.:" GET cVrPlac VALID val_kunos(@cVrPlac, "12")
	@ m_x + 7, m_y + 2 SAY "Opis:" GET cOpis PICT "@S40"
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1



// ---------------------------------
// promjena podataka o isporuci
// ---------------------------------
function prom_isporuka(nBr_nal)
local nTRec := RecNo()
local cMjIsp
local cVrIsp
local dDatIsp
local cDatIsp
local cOperater
local cOpis
local cDbFilt

if Pitanje(,"Zelite izmjeniti podatke o isporuci naloga (D/N)?", "D") == "N"
	return
endif

cDbFilt := DBFilter()
select rnal
set filter to
set order to tag "br_nal"
go top
seek STR(nBr_nal)

cMjIsp := field->mj_isp
cVrIsp := field->vr_isp
dDatIsp := field->datisp

// box sa unosom podataka
if box_isporuka(@cMjIsp, @cVrIsp, @dDatIsp, @cOpis) == 0
	return
endif

cDatIsp := DTOC(dDatIsp)
cOperater := goModul:oDataBase:cUser
// logiraj isporuku
log_isporuka(nBr_nal, cOperater, cOpis, cMjIsp, cVrIsp, cDatIsp, "E")

select rnal
do while !EOF() .and. field->br_nal == nBr_nal
	Scatter()
	if _mj_isp <> cMjIsp
		_mj_isp := cMjIsp
	endif
	if _vr_isp <> cVrIsp
		_vr_isp := cVrIsp
	endif
	if _datisp <> dDatIsp
		_datisp := dDatIsp
	endif
	_operater := cOperater
	Gather()
	skip
enddo

select rnal
set filter to &cDbFilt
go (nTRec)

MsgBeep("Napravljene promjene na podacima o isporuci !")

return


// --------------------------------------
// box sa unosom podataka o isporuci
// --------------------------------------
static function box_isporuka(cMjIsp, cVrIsp, dDatIsp, cOpis)

Box(, 7, 65)
	cOpis := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena podataka o isporuci:"
	@ m_x + 3, m_y + 2 SAY PADL("Novo mjesto isporuke:",22) GET cMjIsp VALID !EMPTY(cMjIsp) PICT "@S30"
	@ m_x + 4, m_y + 2 SAY PADL("Novo vrijeme isporuke:",22) GET cVrIsp VALID !EMPTY(cVrIsp)
	@ m_x + 5, m_y + 2 SAY PADL("Novi datum isporuke:",22) GET dDatIsp VALID !EMPTY(dDatIsp)
	@ m_x + 7, m_y + 2 SAY PADL("Opis promjene:",22) GET cOpis PICT "@S40"
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1



// ---------------------------------
// dodaj kontakt naloga
// ---------------------------------
function add_kontakt(nBr_nal)
local nTArea
local cK_ime := SPACE(40)
local cK_tel := SPACE(60)
local cK_opis := SPACE(100)
local cOperater
local cOpis

nTArea := SELECT()

if box_kontakt(@cK_ime, @cK_tel, @cK_opis, @cOpis) == 0
	return 
endif

cOperater := goModul:oDataBase:cUser

// logiraj kontakt
log_kontakt(nBr_nal, cOperater, cOpis, cK_ime, cK_tel, cK_opis, "+")

select (nTArea)

MsgBeep("Novi kontakt naloga dodan !")

return


// ---------------------------------
// promjeni kontakt naloga
// ---------------------------------
function prom_kontakt(nBr_nal)
local nTRec := RecNo()
local cDbFilt
local cK_ime
local cK_tel
local cK_opis
local cOperater
local cOpis

cDbFilt := DBFilter()
select rnal
set filter to
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

cK_ime := field->k_ime
cK_tel := field->k_tel
cK_opis := field->k_opis

if box_kontakt(@cK_ime, @cK_tel, @cK_opis, @cOpis) == 0
	return 
endif

cOperater := goModul:oDataBase:cUser

// logiraj promjenu kontakta
log_kontakt(nBr_nal, cOperater, cOpis, cK_ime, cK_tel, cK_opis, "E")

select rnal
do while !EOF() .and. field->br_nal == nBr_nal
	Scatter()
	if _k_ime <> cK_ime
		_k_ime := cK_ime
	endif
	if _k_tel <> cK_tel
		_k_tel := cK_tel
	endif
	if _k_opis <> cK_opis
		_k_opis := cK_opis
	endif
	_operater := cOperater
	Gather()
	skip
enddo

select rnal
set filter to &cDbFilt
go (nTRec)

MsgBeep("Izmjenjen kontakt naloga !")

return


// ------------------------------------
// box sa podatkom o kontaktu
// ------------------------------------
static function box_kontakt(cK_ime, cK_tel, cK_opis, cOpis)

Box(, 7, 65)
	cOpis := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Novi kontakti naloga:"
	@ m_x + 3, m_y + 2 SAY PADL("Kontakt, ime:",20) GET cK_ime VALID !EMPTY(cK_ime) PICT "@S30"
	@ m_x + 4, m_y + 2 SAY PADL("Kontakt, telefoni:",20) GET cK_tel VALID !EMPTY(cK_tel) PICT "@S30"
	@ m_x + 5, m_y + 2 SAY PADL("Kontakt, dod.opis:",20) GET cK_opis VALID !EMPTY(cK_opis) PICT "@S30"
	@ m_x + 7, m_y + 2 SAY "Opis promjene:" GET cOpis PICT "@S40"
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1


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
function rnal_delta()

return

