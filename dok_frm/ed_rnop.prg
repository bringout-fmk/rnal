#include "\dev\fmk\rnal\rnal.ch"



// edit operacija stakla
function ed_st_oper(nBrNal, cIdRoba)
local nArea
local nTArea

private ImeKol
private Kol

nTArea := SELECT()
nArea := F_P_RNOP

Box(, 15, 77)
@ m_x + 15, m_y + 2 SAY "<c-N> Nova operacija    | <F2> Ispravi operaciju    | <c-T> Brisi operaciju"

select (nArea)

// setuj filter
set_f_kol(nBrNal, cIdRoba)

set_a_kol(@ImeKol, @Kol)

set order to tag "br_nal"
go top

ObjDbedit("prop", 15, 77, {|| k_handler(nBrNal, cIdRoba)}, "", "unos operacija nad artiklom...", , , , , 1)
BoxC()

select (nTArea)

return .t. 


static function set_f_kol(nBrNal, cIdRoba)
local cFilter
cFilter := "br_nal == " + STR(nBrNal, 8, 0) + ".and. idroba ==" + Cm2Str(cIdRoba)
set filter to &cFilter
return


// key handler
static function k_handler(nBrNal, cIdRoba)

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		select P_RNOP
		if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      			delete
      			return DE_REFRESH
      		endif
     		return DE_CONT
	case (Ch == K_CTRL_N)
		SELECT P_RNOP
		op_item(.t., nBrNal, cIdRoba)
		return DE_REFRESH
	case (Ch == K_F2)
		SELECT P_RNOP
		Scatter()
		if op_item(.f., nBrNal, cIdRoba) == 1
			Gather()
			return DE_REFRESH
		endif
		return DE_CONT
	case (Ch  == K_CTRL_F9)
        	select P_RNOP
		if Pitanje( ,"Zelite li izbrisati sve zapise ?????","N") == "D"
	     		zap
        		return DE_REFRESH
		endif
        	return DE_CONT
endcase

return DE_CONT


// nova stavka...
static function op_item(lNova, nBrNal, cIdRoba)
local nX := 2
local nCount 

UsTipke()

Box(, 10, 60, .f., "Unos novih operacija")

select roba
seek cIdRoba

cPom := ALLTRIM(cIdRoba)
cPom += SPACE(1) + "-" + SPACE(1)
cPom += ALLTRIM(roba->naz)

@ m_x + nX, m_y + 2 SAY "Artikal: " + cPom

select p_rnop

Scatter()
nCount := 0

do while .t.
	if nCount > 0
		Scatter()
	endif
	
	++ nCount
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "uneseno stavki: " + ALLTRIM(STR(nCount))
	
	if g_op_item(lNova) == 0
		exit
	endif
	
	select p_rnop
	
	if lNova
		append blank
	endif
	
	_br_nal := nBrNal
	_idroba := cIdRoba
	
	Gather()
enddo

SELECT p_rnop

BoxC()

return 1


// operacija stavka
static function g_op_item(lNova)
local nX := 7

if lNova
	_id_rnop := SPACE(6)
	_id_rnka := SPACE(6)
	_rn_instr := SPACE(6)
endif

@ m_x + nX, m_y + 2 SAY "     Operacija:" GET _id_rnop

nX += 1

@ m_x + nX, m_y + 2 SAY "Karakteristika:" GET _id_rnka

nX += 1

@ m_x + nX, m_y + 2 SAY "   Instrukcija:" GET _rn_instr PICT "@S20"

read

ESC_RETURN 0

return 1



// setovanje kolona operacija
static function set_a_kol(aImeKol, aKol)
aImeKol := {}

AADD(aImeKol, {"Oper."  , {|| id_rnop }, "id_rnop", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Karakt.", {|| id_rnka }, "id_rnka", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Instr." , {|| PADR(rn_instr, 20)}, "rn_instr", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return



