#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// edit radni nalog
// ---------------------------------------------
function ed_rnal()
*{

// procitaj parametre
read_params()

// otvori tabele
o_rnal(.t.)

// prikazi tabelu pripreme
tbl_priprema()

return
*}


// ---------------------------------------------
// ---------------------------------------------
static function read_params()

/*
O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}
Params1()
//RPar("po",@gPotpis)
select params
use
*/
return



// ---------------------------------------------
// prikazi tabelu pripreme
// ---------------------------------------------
static function tbl_priprema()


Box(,20,77)
@ m_x+18,m_y+2 SAY "<c-N>  Nove Stavke    | <ENT> Ispravi stavku   | <c-T> Brisi Stavku         "
@ m_x+19,m_y+2 SAY "<c-A>  Ispravka Naloga| <c-P> Stampa dokumenta | <a-A> Azuriranje           "
@ m_x+20,m_y+2 SAY "<a-P>  Povrat dok.    |"

private ImeKol
private Kol

SELECT (F_P_RNAL)
SET ORDER TO TAG "brnal"
GO TOP

set_a_kol( @Kol, @ImeKol)
ObjDbedit("prnal", 20, 77, {|| k_handler()}, "", "priprema radnog naloga...", , , , , 3)
BoxC()
closeret


// ---------------------------------------------
// postavi matrice ImeKol, Kol
// ---------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"Br.nal", {|| TRANSFORM(br_dok, "99999")}, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"R.br", {|| TRANSFORM(r_br, "99999")}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Datum", {|| datum}, "datum", {|| .t.}, {|| .t.} })
AADD(aImeKol, { PADR("Roba", 6), {|| id_roba }, "id_roba", {|| .t.}, {|| .t.} })
//AADD(aImeKol, {"Izn.b.pdv", {|| TRANSFORM(i_b_pdv, PIC_IZN()) }, "i_b_pdv", {|| .t.}, {|| .t.} })
//AADD(aImeKol, {"Izn.pdv", {|| TRANSFORM(i_pdv, PIC_IZN()) }, "i_pdv", {|| .t.}, {|| .t.} })
//AADD(aImeKol, {"Izn.s.pdv", {|| TRANSFORM(i_b_pdv+i_pdv, PIC_IZN()) }, "", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// ispravka jedne stavke 
// ---------------------------------------------
static function ed_item(lNova)
local cIspravno := "D"
local nI_s_pdv := 0
local nX := 2
local nXPart := 0
local nYPart := 22

UsTipke()

Box(, 16, 70)

/*
if lNova
	_br_dok := 0
	_r_br := next_r_br("P_KUF")
	_id_part:= SPACE(LEN(id_part))
	_id_tar:= PADR("PDV17", LEN(id_tar))
	_datum := DATE()
	_opis:= SPACE(LEN(opis))
	_i_b_pdv := 0
	_i_pdv := 0
	_src_br_2 := SPACE(LEN(src_br_2))
endif

@ m_x + nX, m_y+2 SAY "R.br: " GET _r_br ;
	PICT "999999"
	
@ m_x + nX, col()+2 SAY "datum: " GET _datum
nX += 2

nXPart := nX
@ m_x + nX, m_y+2 SAY "Dobavljac: " GET _id_part ;
	VALID v_part(@_id_part, @_id_tar, "KUF", .t.) ;
	PICT "@!"
	
nX += 2

@ m_x + nX, m_y+2 SAY "Broj fakture " GET _src_br_2 
nX ++

@ m_x + nX, m_y+2 SAY "Opis stavke: " GET _opis ;
	WHEN { || SETPOS(m_x + nXPart, m_y + nYPart), QQOUT(s_partner(_id_part)) , .t. } ;
	PICT "@S50"
	
nX += 2

@ m_x + nX, m_y+2 SAY "Iznos bez PDV (osnovica): " GET _i_b_pdv ;
	PICT PIC_IZN()
++nX

@ m_x + nX, m_y+2 SAY "tarifa: " GET _id_tar ;
	valid v_id_tar(@_id_tar, @_i_b_pdv, @_i_pdv,  col(), lNova)  ;
	PICT "@!"
	
++nX

@ m_x + nX, m_y+2 SAY "   Iznos PDV: " GET _i_pdv ;
        WHEN { ||  .t. } ;
	VALID { || nI_s_pdv := _i_b_pdv + _i_pdv, .t. } ;
	PICT PIC_IZN()
++nX

@ m_x + nX, m_y+2 SAY "Iznos sa PDV: " GET nI_s_pdv ;
	when { || .f. } ;
	PICT PIC_IZN()
nX += 2

@ m_x + nX, m_y+2 SAY "Ispravno ?" GET cIspravno ;
	pict "@!"
++nX

read

SELECT F_P_KUF
*/

BoxC()

ESC_RETURN .f.

return .t.
*}


// ---------------------------------------------
// tabela RNAL keyboard handler 
// ---------------------------------------------
static function k_handler()
local nTekRec
local nBrDokP

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		select P_RNAL
		if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      			delete
      			return DE_REFRESH
      		endif
     		return DE_CONT
	case (Ch == K_ENTER)
		SELECT P_RNAL
		nTekRec := RECNO()
  		Scatter()
  		if ed_item(.f.)
			SELECT P_RNAL
			GO nTekRec
			Gather()
			RETURN DE_REFRESH
		endif
		return DE_CONT
	case (Ch == K_CTRL_N)
		// stavke unosimo cirkularno do ESC znaka
 		DO WHILE .t.
		   	SELECT P_RNAL
			APPEND BLANK
			nTekRec := RECNO()
        		Scatter()
			if ed_item(.t.)
				GO nTekRec
				Gather()
			else
				// brisi necemo ovu stavku
				SELECT P_RNAL
				go nTekRec
				DELETE
				exit
			endif
		ENDDO 
		GO BOTTOM
		return DE_REFRESH
	case (Ch  == K_CTRL_F9)
        	if Pitanje( ,"Zelite li izbrisati pripremu !!????","N") == "D"
	     		zap
        		return DE_REFRESH
		endif
        	return DE_CONT
	case Ch==K_CTRL_P
		nBrDokP := 0
   		Box( , 2, 60)
			@ m_x+1, m_y+2 SAY "Dokument (0-stampaj pripremu) " GET nBrDokP PICT "999999"
		READ
		BoxC()
		if LASTKEY() <> K_ESC
	     		rpt_rnal(nBrDokP)
		endif
		close all
		o_rnal(.t.)
		SELECT P_RNAL
		SET ORDER TO TAG "br_dok"
     		return DE_REFRESH
	case Ch==K_ALT_A
		if Pitanje( , "Azurirati P_RNAL -> RNAL ?", "N") == "D"
	  		azur_rnal()
			RETURN DE_REFRESH
		else
			RETURN DE_CONT
		endif
	case Ch==K_ALT_P
		if Pitanje( , "Povrat dokumenta RNAL -> P_RNAL ?", "N") == "D"
			nBrDokP := 0
			Box(, 1, 40)
		  		@ m_x+1, m_y+2 SAY "Radni nalog br:" GET nBrDokP  PICT "999999"
				READ
			BoxC()
			if LASTKEY()<> K_ESC
				pov_rnal(nBrDokP)
				RETURN DE_REFRESH
			endif
		endif
		SELECT P_RNAL
		RETURN DE_REFRESH

	case (Ch == K_F10)
     		t_ost_opcije()
     		return DE_REFRESH

endcase

return DE_CONT


// ---------------------------------
// ostale opcije pripreme
// ---------------------------------
static function t_ost_opcije()

notimp()

return


