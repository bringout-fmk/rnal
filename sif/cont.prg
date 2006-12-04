#include "\dev\fmk\rnal\rnal.ch"


static __cust_id


// -------------------------------------
// otvara tabelu kontakata
// -------------------------------------
function s_contacts(cId, nCust_id, cContDesc, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

if nCust_id == nil
	nCust_id := -1
endif

if cContDesc == nil
	cContDesc := ""
endif

__cust_id := nCust_id

nTArea := SELECT()

cHeader := "Kontakti /"

select contacts
set order to tag "1"

set_a_kol(@ImeKol, @Kol, nCust_id)
cust_filter(nCust_id, cContDesc)
	
cRet := PostojiSifra(F_CONTACTS, 1, 10, 70, cHeader, @cId, dx, dy)

select (nTArea)

return cRet

// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol, nCust_id)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(cont_id)}, "cont_id", {|| _inc_id(@wcont_id, "CONT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Narucioc", 10), {|| g_cust_desc( cust_id ) }, "cust_id", {|| set_cust_id(@wcust_id) }, {|| s_customers(@wcust_id), show_it( g_cust_desc(wcust_id)) }})
AADD(aImeKol, {PADC("Ime i prezime", 20), {|| PADR(cont_desc, 20)}, "cont_desc"})
AADD(aImeKol, {PADC("Telefon", 20), {|| PADR(cont_tel, 20)}, "cont_tel"})
AADD(aImeKol, {PADC("Dodatni opis", 20), {|| PADR(cont_add_desc, 20)}, "cont_add_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// ----------------------------------------------
// setuje cust_id pri unosu automatski
// ----------------------------------------------
static function set_cust_id( nCust_id )
if __cust_id > 0
	nCust_id := __cust_id
	return .f.
else
	return .t.
endif
return



// --------------------------------------------------
// generisi match code za contakt...
// --------------------------------------------------
static function gen_cont_mc( m_code, cont_desc )
local aPom := TokToNiz( ALLTRIM(cont_desc), " ")
local i

for i:=1 to LEN(aPom)
	m_code += UPPER(LEFT(aPom, 2))
next

return .t.




// -------------------------------------------
// filter po cust_id
// nCust_id - id customer
// -------------------------------------------
static function cust_filter(nCust_id, cContDesc)
local cFilter := ""

if nCust_id > 0
	cFilter += "cust_id == " + custid_str(nCust_id)
endif

if !EMPTY(cContDesc)
	
	if !EMPTY(cFilter)
		cFilter += " .and. "
	endif
	
	cFilter += " cont_desc = " + cm2str(cContDesc)
	
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return



// -------------------------------
// convert cont_id to string
// -------------------------------
function contid_str(nId)
return STR(nId, 10)



// -------------------------------
// get cont_id_desc by cont_id
// -------------------------------
function g_cont_desc(nCont_id)
local cContDesc := "?????"
local nTArea := SELECT()

O_CONTACTS
select contacts
set order to tag "1"
go top
seek contid_str(nCont_id)

if FOUND()
	if !EMPTY(field->cont_desc)
		cContDesc := ALLTRIM(field->cont_desc)
	endif
endif

select (nTArea)

return cContDesc

// -------------------------------
// get cont_tel by cont_id
// -------------------------------
function g_cont_tel(nCont_id)
local cContTel := "?????"
local nTArea := SELECT()

O_CONTACTS
select contacts
set order to tag "1"
go top
seek contid_str(nCont_id)

if FOUND()
	if !EMPTY(field->cont_tel)
		cContTel := ALLTRIM(field->cont_tel)
	endif
endif

select (nTArea)

return cContTel



