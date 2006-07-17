#include "\dev\fmk\rnal\rnal.ch"


// ----------------------------------
// prikazi info o robi
// ----------------------------------
function s_roba_naz(cId, nX, nY)
local nArr
local nRazmak := 2
local nRobaLen := 40
local cPom

nArr := SELECT()
select roba
hseek cId

if Found()
	cPom := ALLTRIM( LEFT(roba->naz,40) )
	cPom += "(" + ALLTRIM(roba->jmj) + ")"
	cPom := PADR(cPom, nRobaLEN)
	@ nX, nY SAY cPom
else
	@ nX, nY SAY SPACE(nRobaLen)
endif

select (nArr)

return .t.



// ----------------------------------
// prikazi info o tipu artikla 
// ----------------------------------
function s_rtip_naz(cId)
local nArr
local cPom

nArr := SELECT()
select s_tipovi
set order to tag "id"
seek cId

if Found()
	cPom := ALLTRIM(s_tipovi->naziv)
	cPom += ", "
	cPom += "Oznaka: "
	cPom += ALLTRIM(s_tipovi->vrsta)
	?? SPACE(2) + cPom
endif

select (nArr)

return .t.



// --------------------------------------
// prikazi partner naziv + adresa
// --------------------------------------
function s_partner( cId )
local xRet
local nArea

nArea := SELECT()

select partn
seek cId

if Found()
	xRet := ALLTRIM(partn->naz)
	xRet += SPACE(1)
	xRet += ALLTRIM(partn->adresa)
else
	xRet := cId
endif

select (nArea)

return xRet



// -------------------------------------
// prikazi box sa podacima partnera
// -------------------------------------
function s_part_box(cId, nX, nY)
local cPAdresa
local cPNaziv
local cPMjesto

if g_part_info(cId, @cPNaziv, @cPAdresa, @cPMjesto)

	@ nX, nY SAY cPNaziv
	nX += 1
	@ nX, nY SAY cPAdresa
	nX += 1
	@ nX, nY SAY cPMjesto
endif

return .t.


// -------------------------------------
// setuj podatke partnera
// -------------------------------------
static function g_part_info(cId, cNaziv, cAdresa, cMjesto)
local nArr
local xRet

nArr := SELECT()

select partn
hseek cId

if !Found()
	select (nArr)
	return .f.
endif
 
cNaziv := ALLTRIM(LEFT(partn->naz, 25))
cAdresa := ALLTRIM(partn->adresa)
cMjesto := ALLTRIM(partn->mjesto)

select (nArr)
return .t.



// ---------------------------------------
// prikazi karakteristiku
// lBrowse - iz brows-a
// ---------------------------------------
function s_karakt(cIdKar, lBrowse)
local cRet
local nTArea

if (lBrowse == nil)
	lBrowse := .f.
endif

nTArea := SELECT()

select s_rnka
set order to tag "id"
go top
seek cIdKar

if Found()
	cRet := ALLTRIM(field->naziv)
else
	cRet := cIdKar
endif

select (nTArea)

return cRet



// ------------------------------------------
// prikazi operaciju
// lBrowse - iz browsa
// ------------------------------------------
function s_operacija(cIdOper, lBrowse)
local cRet
local nTArea

if (lBrowse == nil)
	lBrowse := .f.
endif

nTArea := SELECT()

select s_rnop
set order to tag "id"
go top
seek cIdOper

if Found()
	cRet := ALLTRIM(field->naziv)
	if (lBrowse .and. LEN(cRet) > 8)
		cRet := PADR(cRet, 8) + ".."
	endif
else
	cRet := cIdOper
endif

select (nTArea)

return cRet


// -----------------------------------
// vraca id operacije, kroz box unos
// -----------------------------------
function get_oper(cOper)
Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Unesi operaciju:" GET cOper VALID !EMPTY(cOper) .and. p_rnop(@cOper)
	read
BoxC()

ESC_RETURN 0

return 1


// -------------------------------------- 
// vraca opis hitnosti
// -------------------------------------- 
function s_hitnost(cVal)
local xVal
do case
	case cVal == "1"
		xVal := "LOW"
	case cVal == "2"
		xVal := "NORMAL"
	case cVal == "3"
		xVal := "HIGH"
endcase 
return xVal



// -------------------------------------- 
// vraca opis vrste placanja
// -------------------------------------- 
function s_placanje(cVal)
local xVal
do case
	case cVal == "1"
		xVal := "Kes"
	case cVal == "2"
		xVal := "Ziro racun"
endcase 
return xVal


// -----------------------------------------------------
// get broja radnog naloga
// -----------------------------------------------------
function g_br_nal( nBr_nal )
Box(, 1, 40)
	@ m_x+1, m_y+2 SAY "Radni nalog br:" GET nBr_nal PICT "99999999"
	READ
BoxC()
ESC_RETURN .f.
return .t.



// ------------------------------------
// konvertuje broj naloga u string
// lijevo poravnat
// ------------------------------------
function str_nal(nBrNal)
local xRet
xRet := PADL( ALLTRIM(STR(nBrNal)), 10)
return xRet



// ------------------------------------
// konvertuje r_br naloga u string
// lijevo poravnat
// ------------------------------------
function str_rbr(nRbr)
local xRet
xRet := PADL( ALLTRIM(STR(nRbr)), 4)
return xRet


// ------------------------------------
// konvertuje p_br naloga u string
// lijevo poravnat
// ------------------------------------
function str_pbr(nPbr)
local xRet
xRet := PADL( ALLTRIM(STR(nPbr)), 4)
return xRet


// -------------------------------------------
// vraca naziv statusa relizacije naloga
// -------------------------------------------
function s_real_stat(cStatus)
local xRet 
if cStatus == "R"
	xRet := "realizovan"
endif
if cStatus == "X"
	xRet := "ponisten"
endif
return xRet


// ----------------------------
// get roba tip
// ----------------------------
function g_roba_tip(cRoba)
local nTArea := SELECT()
local cRet := ""
select roba
if roba->(fieldpos("R_TIP")) == 0
	select (nTArea)
	return cRet
endif
hseek cRoba
if FOUND()
	cRet := field->r_tip
endif
select (nTArea)
return cRet


// ----------------------------
// get roba debljina
// ----------------------------
function g_roba_debljina(cRoba)
local nTArea := SELECT()
local nRet := 0
select roba
hseek cRoba
if FOUND()
	nRet := field->debljina
endif
select (nTArea)
return nRet


// ---------------------------------------
// vraca opis roka
// ---------------------------------------
function s_nal_expired(nExpired)
local cRet := ""
if nExpired == 0
	cRet := "u roku"
else
	cRet := ALLTRIM(STR(nExpired)) + " dana"
endif
return cRet


// --------------------------------------------------------
// automatski prebacuje sastavnice proizvoda u tabelu RNST
// --------------------------------------------------------
function sast_to_rnst(cProizvod, nBr_nal, nR_br)

// da li vec postoje sastavnice ???
if !sast_exist(nBr_nal, nR_br)
	dodaj_sastavnice(nBr_nal, nR_br)
endif

return

// ----------------------------------------
// dodaj sastavnice u P_RNST
// ----------------------------------------
function dodaj_sastavnice(cProizvod, nBr_nal, nR_br)
local nTArea
local nCount

if EMPTY(cProizvod)
	return
endif

nTArea := SELECT()

select sast
set order to tag "IDRBR"
go top
seek cProizvod

nCount := 0

// prodji kroz sastavnice
do while !EOF() .and. sast->id == cProizvod
	
	select p_rnst
	append blank
	
	Scatter()
	
	_br_nal := nBr_nal
	_r_br := nR_br
	_p_br := next_p_br(nBr_nal, nR_br)
	_idroba := sast->id2
	_kolicina := sast->kolicina
	_debljina := g_roba_debljina(_idroba)
	_roba_tip := g_roba_tip(_idroba)
	
	Gather()
	
	++ nCount
	
	select sast
	skip
enddo

MsgBeep("Prebacio sastavnica: " + ALLTRIM(STR(nCount)) )

select (nTArea)

return

// --------------------------------------
// da li vec postoje sastavnice
// --------------------------------------
function sast_exist(nBr_nal, nR_br)
local nTArea
local nCount := 0

nTArea := SELECT()

select p_rnst
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

do while !EOF() .and. field->br_nal == nBr_nal ;
                .and. field->r_br == nR_br
	
	++ nCount
	skip
enddo

select (nTArea)

if nCount > 0
	return .t.
endif

return .f.

// -------------------------------------------
// brisi sastavnice za broj naloga + r_br
// -------------------------------------------
function brisi_sastavnice(nBr_nal, nR_br)
local nTArea := SELECT()
select p_rnst
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br
	delete
	skip
enddo

select (nTArea)
return

// -------------------------------------
// provjera integriteta podataka 
// pri azuriranju ili stampanju naloga
// -------------------------------------
function nal_integritet()
local nTArea
local nBr_nal
local nR_br

nTArea := SELECT()

// provjeri rnal
select p_rnal
if RECCOUNT2() == 0
	MsgBeep("Nalog mora sadrzati najmanje jednu stavku!!!##Azuriranje onemoguceno!")
	return .f.
endif

select p_rnst
set filter to

select p_rnop
set filter to

// provjeri rnst
select p_rnal
set order to tag "br_nal"
go top

do while !EOF()
	nBr_nal := field->br_nal
	nR_br := field->r_br
	
	select p_rnst
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

	if !FOUND()
		MsgBeep("Stavka br. " + ALLTRIM(STR(nR_br)) + " nema sastavnica!##Azuriranje onemoguceno!")
		return .f.
	endif

	select p_rnal
	skip
enddo

select (nTArea)
return .t.



