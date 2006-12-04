#include "\dev\fmk\rnal\rnal.ch"

// -----------------------------------------
// otvara sifrarnik narucioca
// -----------------------------------------
function s_customers(cId, cCustDesc, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Narucioci"
cHeader += SPACE(5)
cHeader += "/ c+K - pregled kontakata"

select customs
set order to tag "1"

if cCustDesc == nil
	cCustDesc := ""
endif

set_a_kol(@ImeKol, @Kol)
// postavi filter...
set_f_kol(cCustDesc)	
	
cRet := PostojiSifra(F_CUSTOMS, 1, 12, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

if !EMPTY(cCustDesc)
	set filter to
	go top
endif

select (nTArea)

return cRet


// --------------------------------------------------
// setovanje filtera nad tabelom customers
// --------------------------------------------------
static function set_f_kol(cCustDesc)
local cFilter := ""

if !EMPTY(cCustDesc)
	cFilter += "cust_desc = " + cm2str(cCustDesc)
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return .t.



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(cust_id)}, "cust_id", {|| _inc_id(@wcust_id, "CUST_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(cust_desc, 20)}, "cust_desc"})
AADD(aImeKol, {PADC("Adresa", 20), {|| PADR(cust_addr, 20)}, "cust_addr"})
AADD(aImeKol, {PADC("Telefon", 20), {|| PADR(cust_tel, 20)}, "cust_tel"})
AADD(aImeKol, { "ID broj", {|| cust_ident_no } , "cust_ident_no"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
do case
	case Ch == K_CTRL_K
		// pregled kontakata
		s_contacts(nil, field->cust_id)
		return DE_CONT
endcase
return DE_CONT


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



