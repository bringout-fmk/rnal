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
SET ORDER TO TAG "br_nal"
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

AADD(aImeKol, {"Br.nal", {|| TRANSFORM(br_nal, "99999")}, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"R.br", {|| TRANSFORM(r_br, "99999")}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.n.", {|| datnal}, "datnal", {|| .t.}, {|| .t.} })
AADD(aImeKol, { PADR("Roba", 6), {|| idroba }, "idroba", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kolicina", {|| TRANSFORM(kolicina, "99999.99") }, "kolicina", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Sirina", {|| TRANSFORM(d_sirina, PIC_IZN()) }, "d_sirina", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Visina", {|| TRANSFORM(d_visina, PIC_IZN()) }, "d_visina", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// obrada stavke 
// ---------------------------------------------
static function ed_item(lNova)
local nCount 

UsTipke()

Box(, 20, 77, .f., "Unos novih stavki")

Scatter()

g_nal_header(lNova)

nCount := 0

do while .t.
	if nCount > 0
		Scatter()
	endif
	++ nCount
	if g_nal_item(lNova) == 0
		exit
	endif
	select p_rnal
	if lNova
		append blank
	endif
	Gather()
enddo

SELECT p_rnal

BoxC()

return 1


// stavka naloga
function g_nal_item(lNovi)
local nX := 11
local nRobaX
local cUnosOp := "D"

if lNovi
	_r_br := next_r_br()
	_idroba := SPACE(LEN(idroba))
	_kolicina := 0
	_d_sirina := 0
	_d_visina := 0
	_d_ukupno := 0
endif

@ m_x + nX, m_y + 2 SAY "Rbr:" GET _r_br PICT "9999"

nX += 2
nRobaX := m_x + nX + 1

@ m_x + nX, m_y + 2 SAY "Artikal:" GET _idroba VALID { || !EMPTY(_idroba) .and. p_roba(@_idroba) .and. v_roba(@_idroba) .and. g_art_type(_idroba, nRobaX ) }

nX += 3

@ m_x + nX, m_y + 2 SAY "Kolicina:" GET _kolicina PICT PIC_KOL()
 
@ m_x + nX, col() + 2 SAY "Sirina:" GET _d_sirina PICT PIC_DIM()
 
@ m_x + nX, col() + 2 SAY "Visina:" GET _d_visina PICT PIC_DIM()

nX += 2

@ m_x + nX, m_y + 2 SAY "Unos operacija (D/N)?" GET cUnosOp VALID !EMPTY(cUnosOp) .and. cUnosOp $ "DN" PICT "@!"

read

if cUnosOp == "D"
	// unos operacija nad artiklom
	nBrNal := _br_nal
	cIdRoba := _idroba
	ed_st_oper(nBrNal, cIdRoba)
	select p_rnal
endif

ESC_RETURN 0

if !lNovi
	return 0
endif

return 1


// header naloga
function g_nal_header(lNovi)
local nX := 2
local nPartX 

if lNovi
	_br_nal := next_br_nal()
	_datnal := DATE()
	_datisp := DATE()
	_hitnost := "2"
	_idpartner := SPACE(LEN(idpartner))
	_vr_isp := PADR( LEFT( TIME(), 5 ), 8 )
	_vr_plac := "1"
	
endif

set cursor on

@ m_x + nX, m_y + 2 SAY "Broj naloga:" GET _br_nal PICT "999999999"

@ m_x + nX, col() + 26 SAY "Datum naloga:" GET _datnal

nX += 2

nPartX := m_x + nX + 1

@ m_x + nX, m_y + 2 SAY "Partner:" GET _idpartner VALID {|| !Empty(_idpartner) .and. p_firma(@_idpartner) .and. v_partn(@_idpartner, nPartX ) }

nCol := col()

@ m_x + nX, nCol + 25 SAY "      Datum isporuke:" GET _datisp

nX += 1

@ m_x + nX, nCol + 25 SAY "    Vrijeme isporuke:" GET _vr_isp

nX += 2

@ m_x + nX, nCol + 25 SAY "       Hitnost (1/2):" GET _hitnost VALID !Empty(_hitnost) .and. _hitnost $ "12" PICT "9"

nX += 1

@ m_x + nX, nCol + 25 SAY "Vrsta placanja (1/2):" GET _vr_plac VALID !Empty(_vr_plac) .and. _vr_plac $ "12" PICT "9"

read

ESC_RETURN 0

return


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
  		Scatter()
  		if ed_item(.f.) == 1
			Gather()
			RETURN DE_REFRESH
		endif
		return DE_CONT
	case (Ch == K_CTRL_N)
		SELECT P_RNAL
		ed_item(.t.)
		return DE_REFRESH
	case (Ch  == K_CTRL_F9)
        	if Pitanje( ,"Zelite li izbrisati pripremu !!????","N") == "D"
	     		zap
        		return DE_REFRESH
		endif
        	return DE_CONT
	case Ch==K_CTRL_P
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
	case UPPER(CHR(Ch)) == "O"
		select p_rnop
		ed_st_oper(p_rnal->br_nal, p_rnal->idroba)
		select p_rnal
		return DE_REFRESH
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


