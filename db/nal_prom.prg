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






