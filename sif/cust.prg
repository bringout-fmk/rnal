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
cHeader += "/ 'K' - pregled kontakata"

select customs
set order to tag "1"

if cCustDesc == nil
	cCustDesc := ""
endif

set_a_kol(@ImeKol, @Kol)

if VALTYPE(cId) == "C"
	//try to validate
	if VAL(cId) <> 0
		cId := VAL(cId)
		cCustDesc := ""
	endif
endif

// postavi filter...
set_f_kol(cCustDesc)	

cRet := PostojiSifra(F_CUSTOMS, 1, 12, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

cId := field->cust_id

if !EMPTY(cCustDesc)
	set filter to
	go top
endif

if LastKey() == K_ESC
	cId := 0
endif

select (nTArea)

return cRet


// --------------------------------------------------
// setovanje filtera nad tabelom customers
// --------------------------------------------------
static function set_f_kol(cCustDesc)
local cFilter := ""

if !EMPTY(cCustDesc)
	
	cCustDesc := ALLTRIM(cCustDesc)
	cFilter += "ALLTRIM(UPPER(cust_desc)) = " + cm2str( UPPER(cCustDesc) )
	
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
AADD(aImeKol, { "ID broj", {|| cust_ident_no } , "cust_ident_no", {|| set_cust_mc(@wmatch_code, @wcust_desc) }, {|| .t.} })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------------------------
// generisi match code za contakt...
// --------------------------------------------------
static function set_cust_mc( m_code, cust_desc )

if !EMPTY(m_code)
	return .t.
endif

m_code := UPPER( PADR( cust_desc, 5 ) )
m_code := PADR( m_code, 10 )

return .t.


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
do case
	case UPPER(CHR(Ch)) == "K"
	
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
function g_cust_desc(nCust_id, lEmpty)
local cCustDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cCustDesc := ""
endif

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



