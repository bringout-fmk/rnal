#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/

// ------------------------------------------------
// prelged sifrarnika karaketeristika
// ------------------------------------------------
function p_rnka(cId, dx, dy)
*{
local nTArea
local nArea
local cHeader
local cOperacija
private Kol
private ImeKol

cHeader := "Lista: karakteristike "
nTArea := SELECT()

O_S_RNKA
nArea := F_S_RNKA

// postavi filter za operaciju
set_f_kol()
// setuj kolone tabele
set_a_kol( @Kol, @ImeKol)

select (nTArea)

return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
       @cId, dx, dy, ;
	{|Ch| k_handler(Ch)} )
	

// ---------------------------------------------------
// kolone tabele
// ---------------------------------------------------
static function set_a_kol( aKol, aImeKol)

aImeKol := {}
AADD(aImeKol, {"Operacija", {|| id_rnop}, "id_rnop", {|| .t.}, {|| p_rnop(@wid_rnop)} })
AADD(aImeKol, {"ID", {|| id}, "id", {|| auto_inc(@wid, @wid_rnop), .f. }, {|| .t.} })
AADD(aImeKol, {"Naziv", {|| naziv}, "naziv", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Opis", {|| opis}, "opis", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next
return


// sredi redni broj pri unosu
static function fix_rbr(cRbr)
if !Empty(cRbr)
	cRbr := PADL(ALLTRIM(cRbr), 3)
endif
return .t.


// set filter kolona
static function set_f_kol()
local cFilter

if Pitanje(,"Postaviti filter za operaciju (D/N)?","D") == "N"
	return
endif

cIdOper := SPACE(6)

get_oper(@cIdOper)

select s_rnka
cFilter := "id_rnop =" + Cm2Str(cIdOper)
set filter to &cFilter
go top

return


// ------------------------------------
// keyboard handler
// ------------------------------------
static function k_handler(Ch)
return DE_CONT

// ------------------------------------
// automatski uvecava ID 
// na osnovu id-a operacije
// ------------------------------------
static function auto_inc(wId, wIdOp)
local nRet:=.t.
if ((Ch==K_CTRL_N) .or. (Ch==K_F4))
	if (LastKey()==K_ESC)
		return nRet:=.f.
	endif
	select s_rnka
	nRecNo:=RecNo()
	g_last_rec(@wId, wIdOp, nRecNo)
	AEVAL(GetList,{|o| o:display()})
endif

return nRet

// ------------------------------------
// setuje varijablu xId 
// ------------------------------------
static function g_last_rec(xId, cIdOp, nRecNo)
xId := SPACE(6)

select s_rnka
set order to tag "idop"
go top
seek cIdOp

if Found()
	do while !EOF() .and. field->id_rnop == cIdOp
		xId := field->id
		skip
	enddo
endif

// uvecaj id
if !EMPTY(xId)
	xId := ALLTRIM( STR( VAL(ALLTRIM(xId)) + 1 ) )
else
	xId := ALLTRIM( STR( VAL(ALLTRIM(cIdOp)) + 1 ) )
endif

set order to tag "id"
go nRecNo

return



