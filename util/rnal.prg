#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

// vraca sljedeci redni broj naloga
function next_r_br()

PushWa()
select p_rnal
set order to tag "br_nal"
go bottom
nLastRbr := r_br
PopWa()
return nLastRbr + 1



// vraca sljedeci broj radnog naloga
function next_br_nal()

PushWa()
select rnal
set order to tag "br_nal"
go bottom
nLastRbr := br_nal
PopWa()

return nLastRbr + 1




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


// prikazi info o robi
function v_roba(cId)
local nArr
nArr := SELECT()
select roba
hseek cId

if Found()
	?? SPACE(4), ALLTRIM(roba->naz)
endif

select (nArr)

return .t.


// prikazi info o partneru
function v_partn(cId, nX)
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
seek cIdKar

if Found()
	cRet := ALLTRIM(field->naziv)
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
	@ m_x + 1, m_y + 2 SAY "operacija:" GET cOper VALID !EMPTY(cOper) .and. p_rnop(@cOper)
	read
BoxC()

ESC_RETURN 0

return 1



