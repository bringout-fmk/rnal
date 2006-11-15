#include "\dev\fmk\rnal\rnal.ch"



// -------------------------------------------------
// vrati match_code za stavku sifrarnika
// -------------------------------------------------
function say_item_mc(nArea, cTable, nId)
local nTArea := SELECT()
local xRet := "-----"

if !USED(nArea)
	use (nArea)
endif
select &cTable

set order to tag "1"
go top

seek STR(nId)

if FOUND()
	xRet := ALLTRIM(field->match_code)
endif

select (nTArea)
return xRet



// ---------------------------------------------
// prikaz id/mc za stavku u browse-u sifrarnika
// nFieldId - vrijednost id polja
// ---------------------------------------------
function sif_idmc(nFieldId)
local cId := STR(nFieldId)
local cMCode := IF(FIELDPOS("MATCH_CODE") <> 0, ALLTRIM(field->match_code), "")
local xRet

xRet := ALLTRIM(cId)

if !EMPTY(cMCode)
	xRet += "/"
	if LEN(cMCode) > 4
		xRet += LEFT(cMCode, 4) + ".."
	else
		xRet += cMCode
	endif
endif

return PADR(xRet,10)



function show_it(cItem)

@ row(), col() + 3 SAY cItem

return .t.



// --------------------------------------
// increment id u sifrarniku
// wId - polje id proslijedjeno po ref.
// cFieldName - ime id polja
// --------------------------------------
function _inc_id( wid, cFieldName )
local nTRec
local cDbFilter

if ((Ch == K_CTRL_N) .or. (Ch == K_F4))
	
	if (LastKey() == K_ESC)
		return .f.
	endif
	
	nTRec := RecNo()
	cDbFilter := DBFilter()

	set filter to
	
	wid := _last_id( cFieldName ) + 1
	
	set filter to &cDbFilter
	go top
	go (nTRec)
	
	AEVAL(GetList,{|o| o:display()})

endif

return .t.


// ----------------------------------------
// vraca posljednji id zapis iz tabele
// cFieldName - ime id polja
// ----------------------------------------
static function _last_id( cFieldName )
local nLast_rec := 0

go bottom

nLast_rec := field->&cFieldName

return nLast_rec









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


