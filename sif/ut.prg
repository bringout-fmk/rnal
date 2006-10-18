#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------------
// vrati opis match_code/naz za stavku sifrarnika
// -------------------------------------------------
function say_item_mc(nArea, cTable, cId)
local nTArea := SELECT()
local xRet := "-----"

if !USED(nArea)
	use (nArea)
endif
select &cTable

set order to tag "ID"
go top

seek cId

if FOUND()
	xRet := ALLTRIM(field->match_code)
	xRet += "/"
	xRet += ALLTRIM(field->naz)
endif

xRet := PADR(xRet, 20)

select (nTArea)
return xRet


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

// ----------------------------
// get roba grupa
// ----------------------------
function g_roba_gr(cRoba)
local nTArea := SELECT()
local cRet := ""
local cPom := ""
select roba
set filter to
set order to tag "ID"
go top

if roba->(fieldpos("ROBA_TIP")) == 0
	select (nTArea)
	return cRet
endif

seek cRoba

if FOUND()
	
	cPom := field->roba_tip
	
	select s_tipovi
	set filter to
	set order to tag "ID"
	go top
	seek cPom

	if FOUND()
		cRet := field->grupa
	endif
	
endif

select (nTArea)
return cRet



// ----------------------------
// get grupa vrsta K1 polje
// ----------------------------
function g_gr_vrsta(cGrupa)
local nTArea := SELECT()
local cRet := ""
select s_grupe
set filter to
set order to tag "ID"
go top

seek cGrupa

if FOUND()
	cRet := ALLTRIM(field->k_1)
endif

select (nTArea)
return cRet


// ----------------------------
// get roba tip
// ----------------------------
function g_roba_tip(cRoba)
local nTArea := SELECT()
local cRet := ""
select roba
set order to tag "ID"
go top

if roba->(fieldpos("ROBA_TIP")) == 0
	select (nTArea)
	return cRet
endif

hseek cRoba

if FOUND()
	cRet := field->roba_tip
endif

select (nTArea)
return cRet



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


