#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */





// vraca tip stakla
function st_type(cId)
local nRet

do case
	case LEFT(cId, 2) $ "22#33"
		nRet := 2
	case LEFT(cId, 1) $ "1#2#3"
		nRet := 1
	case AT(cId, "PROF") <> 0
		nRet := 3
	otherwise
		nRet := 0
endcase

return nRet



function g_art_type(cId, nX)
local nType 
local cType

nType := st_type(cId)

do case
	case nType == 0
		cType := ""
	case nType == 1
		cType := "Obicno staklo"
	case nType == 2
		cType := "IZO staklo"
	case nType == 3
		cType := "PROFILIT staklo"
endcase

cPom := "Tip stakla: "
cPom += cType

@ nX, m_y + 2 SAY cPom

return .t.

// ----------------------------------
// prikazi info o robi
// ----------------------------------
function s_roba_info(cId, nX, nY)
local nArr
local nRazmak := 2
local nRobaLen := 40

nArr := SELECT()
select roba
hseek cId

if Found()
	@ nX, nY SAY PADR(ALLTRIM(roba->naz), nRobaLen)
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

cLine := REPLICATE("-", 35)

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



// show karakteristika
function s_karakt(cIdKar)
local cRet
local nTArea

nTArea := F_P_RNOP

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


// show operacija
function s_operacija(cIdOper)
local cRet
local nTArea

nTArea := F_P_RNOP

select s_rnop
set order to tag "id"
go top
seek cIdOper

if Found()
	cRet := ALLTRIM(field->naziv)
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
// vraca vrijednost u m2 izmedju 2 velicine unesene u cm
// -----------------------------------------------------
function mkvadrat(nKol, nDim1, nDim2)
local xRet
xRet := ( nDim1 / 100 ) * (nDim2 / 100)
xRet := nKol * xRet
return xRet


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


