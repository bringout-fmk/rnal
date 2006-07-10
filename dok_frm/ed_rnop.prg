#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// unos operacija stakla
// ------------------------------------------
function ed_st_oper(nBrNal, nRBr, nPBr, cIdRoba)
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
@ m_x + 15, m_y + 2 SAY "<c-N> Nova operacija    | <c-T> Brisi operaciju  | <c-F9> Brisi sve operacije "

select (nArea)

// setuj filter
set_f_kol(nBrNal, nRBr, nPBr, cIdRoba)
set_a_kol(@ImeKol, @Kol)

// setuj varijable direktnog moda....
private bGoreRed:=NIL
private bDoleRed:=NIL
private bDodajRed:=NIL
private fTBNoviRed:=.f. 
private TBCanClose:=.t. 
private TBAppend:="N"  
private bZaglavlje:=NIL
private TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
private nTBLine:=1      
private nTBLastLine:=1  
private TBPomjerise:="" 
private TBScatter:="N"  

set order to tag "br_nal"
go top

ObjDbedit("prop", 15, 77, {|| k_handler(nBrNal, nRBr, nPBr, cIdRoba)}, "", cFooter, , , , , 1)
BoxC()

select p_rnop
set filter to

return
  


// ------------------------------------------
// set filter na tabeli P_RNOP
// ------------------------------------------
static function set_f_kol(nBrNal, nRBr, nPBr, cIdRoba)
local cFilter
cFilter := "br_nal == " + STR(nBrNal, 10, 0)
cFilter += " .and. "
cFilter += "r_br == " + STR(nRBr, 4, 0)
cFilter += " .and. " 
cFilter += "p_br == " + STR(nPBr, 4, 0)
cFilter += " .and. "
cFilter += "idroba ==" + Cm2Str(cIdRoba)
set filter to &cFilter
return


// ------------------------------------------
// key handler tabele P_RNOP
// ------------------------------------------
static function k_handler(nBrNal, nRBr, nPBr, cIdRoba)

if (Ch==K_CTRL_T .or. Ch==K_CTRL_F9) .and. reccount2()==0
	return DE_CONT
endif

// setuj direktni edit mod
if gTBDir=="N"
	gTBDir:="D"
        select P_RNOP
        DaTBDirektni()
endif

do case
	case (Ch == K_ESC) 
		// prilikom zatvaranja forme vrati na st.mod unosa
		gTBDir:="N"
        	NeTBDirektni()

	case (Ch == K_CTRL_T)
		if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      			delete
      			return DE_REFRESH
      		endif
     		return DE_CONT
		
	case (Ch == K_CTRL_N)
		gTbDir:="N"
		NeTBDirektni()
		fill_p_rnop(nBrNal, nRBr, nPBr, cIdRoba)
		gTbDir:="D"
		DaTBDirektni()
		return DE_REFRESH
		
	case (Ch  == K_CTRL_F9)
        	select P_RNOP
		if Pitanje( ,"Zelite li izbrisati sve zapise ?????","N") == "D"
	     		set order to tag "br_nal"
			go top
			seek STR(nBrNal, 10, 0) + STR(nRBr, 4, 0) + STR(nPBrm 4, 0) + cIdRoba
			do while !EOF() .and. field->br_nal == nBrNal;
			     .and. field->r_br == nRBr;
			     .and. field->p_br == nPBr;
			     .and. field->idroba == cIdRoba
				delete
				skip
			enddo
        		return DE_REFRESH
		endif
        	return DE_CONT
endcase

return DE_CONT


// -------------------------------------------------------
// napuni podatke p_rnop sa karakteristikama
// -------------------------------------------------------
static function fill_p_rnop(nBrNal, nRBr, nPBr, cIdRoba, cOper)
local nCount

if ( cOper == nil )
	cOper := SPACE(6)
endif

// uzmi operaciju
if EMPTY(cOper) .and. get_oper(@cOper) == 0
	return DE_CONT
endif

select s_rnka
set order to tag "idop"
go top
seek cOper

if !Found()
	MsgBeep("Karakteristike ove operacije ne postoje!!!")
	select p_rnop
	return
endif
	
nCount := 0

do while !EOF() .and. s_rnka->id_rnop == cOper
	cRnKa := s_rnka->id
	select p_rnop
		
	// ako ne postoji karakteristika u pripremi dodaj
	if !post_rnka(nBrNal, nRBr, nPBr, cIdRoba, cRnKa)
		append blank
		replace br_nal with nBrNal
		replace r_br with nRBr
		replace p_br with nPBr
		replace idroba with cIdRoba
		replace id_rnop with s_rnka->id_rnop
		replace id_rnka with s_rnka->id
		if !EMPTY(s_rnka->ka_def)
			replace rn_instr with s_rnka->ka_def
		endif
	endif
		
	select s_rnka
	skip
		
	++ nCount
enddo

select p_rnop
// pozicioniraj se na nove zapise
go bottom
skip -(nCount)

return



// -------------------------------------------------------
// ispituje da li postoji vec unesena karakteristika 
// -------------------------------------------------------
static function post_rnka(nBrNal, nRBr, nPBr, cIdRoba, cIdKa)
local nTRec
local xRet:=.f.

nTRec := RecNo()

set order to tag "rn_ka"
go top
seek STR(nBrNal, 10, 0) + STR(nRBr, 4, 0) + cIdRoba + cIdKa

if Found()
	xRet := .t.
endif

set order to tag "br_nal"
go (nTRec)

return xRet


// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}

AADD(aImeKol, {"Operacija"  , {|| PADR(s_operacija(id_rnop, .t.),10) }  })
AADD(aImeKol, {"Karakteristika", {|| PADR(s_karakt(id_rnka, .t.),40) }  })
AADD(aImeKol, {"Unesi instrukciju" , {|| PADR(rn_instr, 20)}, "rn_instr", {|| .t.}, {|| val_instr( id_rnka, @wrn_instr ) }, "V" })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return



