#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */


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
	cPom := ALLTRIM(roba->naz)
	cPom += "(" + ALLTRIM(roba->jmj) + ")"
	cPom := PADR(cPom, nRobaLEN)
	@ nX, nY SAY cPom
else
	@ nX, nY SAY SPACE(nRobaLen)
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
function s_part_box(cId, nX)
local cPAdresa
local cPNaziv
local cPMjesto
local cLine

cLine := REPLICATE("=", 35)

if g_part_info(cId, @cPNaziv, @cPAdresa, @cPMjesto)

	@ nX, m_y + 2 SAY cLine
	nX += 1
	@ nX, m_y + 2 SAY cPNaziv
	nX += 1
	@ nX, m_y + 2 SAY cPAdresa
	nX += 1
	@ nX, m_y + 2 SAY cPMjesto
	nX += 1
	@ nX, m_y + 2 SAY cLine
endif

return .t.


// setuj podatke partnera
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
 
cNaziv := ALLTRIM(partn->naz)
cAdresa := ALLTRIM(partn->adresa)
cMjesto := ALLTRIM(partn->mjesto)

select (nArr)
return .t.



// ---------------------------------------
// show karakteristika
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
// show operacija
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


// vrati operaciju, box
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
		xVal := "KES"
	case cVal == "2"
		xVal := "ZIRO RACUN"
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
// konvertuje rbr naloga u string
// lijevo poravnat
// ------------------------------------
function str_rbr(nRbr)
local xRet
xRet := PADL( ALLTRIM(STR(nRbr)), 4)
return xRet



// -------------------------------------------
// vraca naziv statusa relizacije naloga
// -------------------------------------------
function s_real_stat(cStatus)
local xRet 
if cStatus == "R"
	xRet := "real."
endif
if cStatus == "X"
	xRet := "poni."
endif
return xRet

