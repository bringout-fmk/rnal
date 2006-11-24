#include "\dev\fmk\rnal\rnal.ch"


// variables
static __doc_no
static __oper_id

// --------------------------
// meni promjena
// --------------------------
function m_changes( nDoc_no )
private opc:={}
private opcexe:={}
private izbor:=1

__doc_no := nDoc_no
__oper_id := GetUserID()

AADD(opc, "1. promjena osnovnih podataka naloga ")
AADD(opcexe, {|| _ch_main() })
AADD(opc, "2. promjena podataka o isporuci ")
AADD(opcexe, {|| _ch_ship() })
AADD(opc, "3. promjena kontakta na nalogu")
AADD(opcexe, {|| _ch_cont() })
AADD(opc, "4. dodaj novi kontakt ")
AADD(opcexe, {|| _ch_cont(.t.) })

Menu_sc("changes")

return DE_CONT



// ---------------------------------
// promjena osnovnih podataka 
// ---------------------------------
function _ch_main()
local nTRec := RecNo()
local nCustId
local nDoc_priority
local nDoc_pay_type
local cDesc
local aArr

if Pitanje(,"Zelite izmjeniti osnovne podatke naloga (D/N)?", "D") == "N"
	return
endif

select docs

nCustId := field->cust_id
nDoc_priority := field->doc_priority
nDoc_pay_type := field->doc_pay_id

// box sa unosom podataka
if _box_main(@nCustId, @nDoc_priority, @nDoc_pay_type, @cDesc) == 0
	return
endif

aArr := a_log_main( nCustId, nDoc_priority, nDoc_pay_type ) 
log_main(__doc_no, cDesc, "E", aArr)

select docs
Scatter()

if _cust_id <> nCustId
	_cust_id := nCustId
endif
if _doc_priority <> nDoc_priority
	_doc_priority := nDoc_priority
endif
if _doc_pay_id <> nDoc_pay_type
	_doc_pay_id := nDoc_pay_type
endif

_operater_id := __oper_id

Gather()

skip

select docs
go (nTRec)

return


// --------------------------------------
// box sa unosom podataka osnovnih
// --------------------------------------
static function _box_main(nCust, nPrior, nPay, cDesc)

Box(, 7, 65)
	cDesc := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena na osnovnim podacima naloga:"
	@ m_x + 3, m_y + 2 SAY "Narucioc:" GET nCust VALID {|| s_customers(@nCust), show_it( g_cust_desc( nCust ) ) }
	@ m_x + 4, m_y + 2 SAY "Prioritet (1/2/3):" GET nPrior VALID nPrior > 0 .and. nPrior < 4
	@ m_x + 5, m_y + 2 SAY "Vrsta placanja 1-kes, 2-ziro rn.:" GET nPay VALID nPay > 0 .and. nPay < 3
	@ m_x + 7, m_y + 2 SAY "Opis promjene:" GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1



// ---------------------------------
// promjena podataka o isporuci
// ---------------------------------
function _ch_ship()
local nTRec := RecNo()
local cShipPlace
local cDvrTime
local dDvrDate
local cDesc
local aArr

if Pitanje(,"Zelite izmjeniti podatke o isporuci naloga (D/N)?", "D") == "N"
	return
endif

select docs

cShipPlace := field->doc_ship_place
dDvrDate := field->doc_dvr_date
cDvrTime := field->doc_dvr_time

// box sa unosom podataka
if _box_ship(@cShipPlace, @cDvrTime, @dDvrDate, @cDesc) == 0
	return
endif

// logiraj isporuku
aArr := a_log_ship( dDvrDate, cDvrTime, cShipPlace )
log_ship(__doc_no, cDesc, "E", aArr)

select docs

Scatter()

if _doc_ship_place <> cShipPlace
	_doc_ship_place := cShipPlace
endif

if _doc_dvr_time <> cDvrTime
	_doc_dvr_time := cDvrTime
endif

if _doc_dvr_date <> dDvrDate
	_doc_dvr_date := dDvrDate
endif

_operater_id := __oper_id

Gather()

select docs
go (nTRec)

return


// --------------------------------------
// box sa unosom podataka o isporuci
// --------------------------------------
static function _box_ship(cShip, cTime, dDate, cDesc)

Box(, 7, 65)
	cDesc := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena podataka o isporuci:"
	@ m_x + 3, m_y + 2 SAY PADL("Novo mjesto isporuke:",22) GET cShip VALID !EMPTY(cShip) PICT "@S30"
	@ m_x + 4, m_y + 2 SAY PADL("Novo vrijeme isporuke:",22) GET cTime VALID !EMPTY(cTime)
	@ m_x + 5, m_y + 2 SAY PADL("Novi datum isporuke:",22) GET dDate VALID !EMPTY(dDate)
	@ m_x + 7, m_y + 2 SAY PADL("Opis promjene:",22) GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1


// ---------------------------------
// promjeni kontakt naloga
// ---------------------------------
function _ch_cont( lNew )
local nTRec := RecNo()
local cDesc
local aArr
local cType := "E"
local nCont_id := VAL(STR(0, 10))
local cCont_desc := SPACE(150)

if lNew == nil
	lNew := .f.
endif

if !lNew
	
	select docs
	
	nCont_id := field->cont_id
	cCont_desc := field->cont_add_desc
	
endif

if _box_cont(@nCont_id, @cCont_desc, @cDesc) == 0
	return 
endif

// logiraj promjenu kontakta
aArr := a_log_cont( nCont_id, cCont_desc )

if lNew 
	cType := "+"
endif

log_cont(__doc_no, cDesc, cType, aArr)

select docs
	
Scatter()

if _cont_id <> nCont_id
	_cont_id := nCont_id
endif
if _cont_add_desc <> cCont_desc
	_cont_add_desc := cCont_desc
endif

_operater_id := __oper_id

Gather()

select docs
go (nTRec)

return


// ------------------------------------
// box sa podatkom o kontaktu
// ------------------------------------
static function _box_cont(nCont, cContdesc, cDesc)
local lNew := .f.

if nCont == 0
	lNew := .t.
endif

Box(, 7, 65)

	cDesc := SPACE(150)
	
	if lNew == .t.
		@ m_x + 1, m_y + 2 SAY "Novi kontakti naloga:"
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka kontakta naloga:"
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("Kontakt:",20) GET nCont VALID {|| s_contacts(@nCont) , show_it( g_cont_desc( nCont ) )}
	
	@ m_x + 4, m_y + 2 SAY PADL("Kontakt, dodatni opis:",20) GET cContDesc PICT "@S30"
	
	@ m_x + 7, m_y + 2 SAY "Opis promjene:" GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1






