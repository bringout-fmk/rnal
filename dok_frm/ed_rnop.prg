#include "\dev\fmk\rnal\rnal.ch"



// edit operacija stakla
function ed_st_oper(nBrNal, cIdRoba)
local nArea
local nTArea
local cRNaziv
local cFooter
private ImeKol
private Kol

nTArea := SELECT()

select roba
go top
seek cIdRoba

cFooter := ALLTRIM(cIdRoba)
cFooter += "-"
cFooter += PADR(roba->naz, 40)

nArea := F_P_RNOP

Box(, 15, 77)
@ m_x + 15, m_y + 2 SAY "<c-N> Nova operacija    | <c-T> Brisi operaciju"

select (nArea)

// setuj filter
set_f_kol(nBrNal, cIdRoba)

set_a_kol(@ImeKol, @Kol)

set order to tag "br_nal"
go top

ObjDbedit("prop", 15, 77, {|| k_handler(nBrNal, cIdRoba)}, "", cFooter, , , , , 1)
BoxC()

select (nTArea)
return
  


static function set_f_kol(nBrNal, cIdRoba)
local cFilter
cFilter := "br_nal == " + STR(nBrNal, 8, 0) + ".and. idroba ==" + Cm2Str(cIdRoba)
set filter to &cFilter
return


// key handler
static function k_handler(nBrNal, cIdRoba)

if (Ch==K_CTRL_T .or. Ch==K_CTRL_F9) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		//select P_RNOP
		if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      			delete
      			return DE_REFRESH
      		endif
     		return DE_CONT
	case (Ch == K_CTRL_N)
		//SELECT P_RNOP
		fill_p_rnop(nBrNal, cIdRoba)
		return DE_REFRESH
	case UPPER(CHR(Ch)) == "I"
		set_rnop_instr()
		return DE_REFRESH
	case (Ch  == K_CTRL_F9)
        	select P_RNOP
		if Pitanje( ,"Zelite li izbrisati sve zapise ?????","N") == "D"
	     		set order to tag "br_nal"
			hseek STR(nBrNal,8,0) + cIdRoba
			do while !EOF() .and. field->br_nal == nBrNal .and. field->idroba == cIdRoba
				delete
				skip
			enddo
        		return DE_REFRESH
		endif
        	return DE_CONT
endcase

return DE_CONT



// napuni podatke p_rnop sa karakteristikama
static function fill_p_rnop(nBrNal, cIdRoba)
local cOper
local nCount

cOper := SPACE(6)
// uzmi operaciju
if get_oper(@cOper) == 0
	return DE_CONT
endif

select s_rnka
set order to tag "idop"
go top
seek cOper

nCount := 0
if Found()
	// napuni tabelu podacima
	do while !EOF() .and. s_rnka->id_rnop == cOper
	
		cRnKa := s_rnka->id
		
		select p_rnop
		
		// ako ne postoji karakteristika u pripremi dodaj
		if !post_rnka(nBrNal, cIdRoba, cRnKa)
			append blank
			replace br_nal with nBrNal
			replace idroba with cIdRoba
			replace id_rnop with s_rnka->id_rnop
			replace id_rnka with s_rnka->id
		endif
		
		select s_rnka
		skip
		
		++ nCount
	enddo
endif

select p_rnop
skip -(nCount)

return



// ispituje da li postoji vec unesena karakteristika 
function post_rnka(nBrNal, cIdRoba, cIdKa)
local nTRec
local xRet:=.f.
nTRec := RecNo()
set order to tag "rn_ka"
go top
seek STR(nBrNal,8,0) + cIdRoba + cIdKa

if Found()
	xRet := .t.
endif

set order to tag "br_nal"
go (nTRec)

return xRet


// setuj instrukciju za slog u tabeli
function set_rnop_instr()
Scatter()
Box(,1,60)
	@ m_x+1, m_y + 2 SAY "vrijednost" GET _rn_instr PICT "@S40"
	read
BoxC()
Gather()
return


// setovanje kolona operacija
static function set_a_kol(aImeKol, aKol)
aImeKol := {}

AADD(aImeKol, {"Oper."  , {|| PADR(s_operacija(id_rnop),15) }, "id_rnop", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Karakt.", {|| PADR(s_karakt(id_rnka),40) }, "id_rnka", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Instr." , {|| PADR(rn_instr, 15)}, "rn_instr", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return



