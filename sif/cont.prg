#include "\dev\fmk\rnal\rnal.ch"



// -------------------------------------
// otvara tabelu kontakata
// -------------------------------------
function s_contacts(cId, dx, dy)
local nTArea
private ImeKol
private Kol

nTArea := SELECT()

select contacts
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_CONTACTS, 1, 10, 70, "Contacts", @cId, dx, dy)

select (nTArea)

return cRet

// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| cont_id}, "cont_id", {|| _inc_id(@wcont_id, "CONT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Customer", 10), {|| g_cust_desc( cust_id ) }, "cust_id", {|| .t.}, {|| s_customers(@wcust_id) }})
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(cont_desc, 20)}, "cont_desc"})
AADD(aImeKol, {PADC("Telefon", 20), {|| PADR(cont_tel, 20)}, "cont_tel"})
AADD(aImeKol, {PADC("Dodatni opis", 20), {|| PADR(cont_add_desc, 20)}, "cont_add_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

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




