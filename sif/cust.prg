#include "\dev\fmk\rnal\rnal.ch"

// -----------------------------------------
// otvara sifrarnik narucioca
// -----------------------------------------
function s_customers(cId, dx, dy)
local nTArea
private ImeKol
private Kol

nTArea := SELECT()

select customs
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_CUSTOMS, 1, 10, 70, "Customers", @cId, dx, dy)

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| cust_id}, "cust_id", {|| _inc_id(@wcust_id, "CUST_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(cust_desc, 20)}, "cust_desc"})
AADD(aImeKol, {PADC("Adresa", 20), {|| PADR(cust_addr, 20)}, "cust_addr"})
AADD(aImeKol, {PADC("Telefon", 20), {|| PADR(cust_tel, 20)}, "cust_tel"})
AADD(aImeKol, { "ID broj", {|| cust_ident_no } , "cust_ident_no"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



// -------------------------------
// convert cust_id to string
// -------------------------------
function custid_str(nId)
return STR(nId, 10)



// -------------------------------
// get cust_id_desc by cust_id
// -------------------------------
function g_cust_desc(nCust_id)
local cCustDesc := "?????"
local nTArea := SELECT()

O_CUSTOMS
select customs
set order to tag "1"
go top
seek custid_str(nCust_id)

if FOUND()
	if !EMPTY(field->cust_desc)
		cCustDesc := ALLTRIM(field->cust_desc)
	endif
endif

select (nTArea)

return cCustDesc



