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
// citanje parametara
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
AADD(aImeKol, {"Dat.isp", {|| datisp}, "datisp", {|| .t.}, {|| .t.} })
AADD(aImeKol, { PADR("Roba", 6), {|| idroba }, "idroba", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kolicina", {|| TRANSFORM(kolicina, "99999.99") }, "kolicina", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Sirina", {|| TRANSFORM(d_sirina, PIC_DIM()) }, "d_sirina", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Visina", {|| TRANSFORM(d_visina, PIC_DIM()) }, "d_visina", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// obrada sve stavke 
// ---------------------------------------------
static function ed_item(lNova)
local nCount 

UsTipke()

Box(, 21, 77, .f., "Unos novih stavki")

Scatter()

if RECCOUNT2() == 0
	if g_nal_header(lNova) == 0
		select p_rnal
		BoxC()
		return 1
	endif
else
	if g_nal_header(.f.) == 0
		select p_rnal
		BoxC()
		return 1
	endif
endif

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


// ---------------------------------------
// obradi stavka naloga
// ---------------------------------------
function g_nal_item(lNovi)
local nX := 9
local nRobaX
local nRobaOpX
local nUkX
local nUnOpX
local cUnosOp := "D"
local nBrNal
local nRBr
local cIdRoba
local nDebStakla
local nXRekap
local nYRekap
local lIzoStaklo := .f.

if lNovi
	_r_br := next_r_br()
	_idroba := SPACE(LEN(idroba))
	_kolicina := 0
	_d_sirina := 0
	_d_visina := 0
	_d_ukupno := 0
	cUnosOp := "D"
endif

@ m_x + nX, m_y + 2 SAY "Rbr:" GET _r_br PICT "9999"

nX += 1
nRobaX := m_x + nX
nRobaY := m_y + 25
nRobaOpX := nRobaX + 1

@ m_x + nX, m_y + 2 SAY "Artikal:" GET _idroba VALID { || !EMPTY(_idroba) .and. p_roba(@_idroba) .and. s_roba_info(@_idroba, nRobaX, nRobaY) .and. s_staklo_info(_idroba, nRobaOpX ) }

nX += 3

@ m_x + nX, m_y + 2 SAY "Kolicina:" GET _kolicina PICT PIC_KOL() VALID val_kolicina( _kolicina )
 
@ m_x + nX, col() + 2 SAY "Sirina (cm):" GET _d_sirina PICT PIC_DIM() VALID val_dimenzija( _d_sirina )
 
@ m_x + nX, col() + 2 SAY "Visina (cm):" GET _d_visina PICT PIC_DIM() VALID val_dimenzija( _d_visina )

read

ESC_RETURN 0

// debljina stakla
nDebStakla := g_deb_stakla( _idroba )
lIzoStaklo := izo_staklo(_idroba)

// zaokruzenja po gn-u
_z_sirina := z_po_gnu(nDebStakla, _d_sirina)
_z_visina := z_po_gnu(nDebStakla, _d_visina)

// ukupno bez zaokruzenja
_d_ukupno := c_ukvadrat( _kolicina, _d_sirina, _d_visina )
// ukupno sa zaokruzenjima
_z_ukupno := c_ukvadrat( _kolicina, _z_sirina, _d_visina )

// racunaj neto (kilaza)
_neto := c_netto( nDebStakla, _d_ukupno, lIZOStaklo )

nXRekap := m_x + nX + 1
nYRekap := m_y + 2

// prikazi rekapitulaciju
s_rekap_stavka(nXRekap, nYRekap, _z_sirina, _z_visina, _d_ukupno, _z_ukupno, _neto)

// unos operacija

nUnOpX := 20

@ m_x + nUnOpX, m_y + 2 SAY "Unos operacija (D/N)?" GET cUnosOp VALID val_d_n( cUnosOp ) PICT "@!"

read

ESC_RETURN 0

if cUnosOp == "D"
	// unos operacija nad artiklom
	nBrNal := _br_nal
	nRBr := _r_br
	cIdRoba := _idroba
	ed_st_oper(nBrNal, nRBr, cIdRoba)
endif

if !lNovi
	return 0
endif


return 1


// ---------------------------------------
// obradi header naloga
// ---------------------------------------
function g_nal_header(lNovi)
local nX := 1
local nPartX 

if lNovi
	_br_nal := next_br_nal()
	_datnal := DATE()
	_datisp := DATE()
	_hitnost := "2"
	_idpartner := SPACE(LEN(idpartner))
	_vr_isp := PADR( LEFT( TIME(), 5 ), 8 )
	_vr_plac := "1"
	if _rn_status == " "
		_rn_status := "O"
	endif
endif

set cursor on

@ m_x + nX, m_y + 2 SAY "Broj naloga:" GET _br_nal PICT "999999999"

@ m_x + nX, col() + 30 SAY "Datum naloga:" GET _datnal

nX += 2

nPartX := m_x + nX + 1

@ m_x + nX, m_y + 2 SAY "Partner:" GET _idpartner VALID {|| !Empty(_idpartner) .and. p_firma(@_idpartner) .and. s_part_box(@_idpartner, nPartX ) }

nCol := col()

@ m_x + nX, nCol + 29 SAY "      Datum isporuke:" GET _datisp

nX += 1

@ m_x + nX, nCol + 29 SAY "    Vrijeme isporuke:" GET _vr_isp

nX += 2

@ m_x + nX, nCol + 30 SAY "Prioritet hitnosti (1/2/3):" GET _hitnost VALID val_kunos( _hitnost, "123" ) PICT "9"

nX += 1

@ m_x + nX, nCol + 30 SAY "  Vr.placanja 1-kes 2-z.r.:" GET _vr_plac VALID val_kunos( _vr_plac, "12") PICT "9"

read

ESC_RETURN 0

return 1


// ---------------------------------------------
// tabela RNAL keyboard handler 
// ---------------------------------------------
static function k_handler()
local nBr_nal

if (Ch==K_CTRL_T .or. Ch==K_ENTER;
	.or. Ch==K_CTRL_P;
	.or. Ch==K_CTRL_F9) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		select P_RNAL
		if br_stavku()
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
        	SELECT P_RNAL
		if br_sve_zapise()
			return DE_REFRESH
		endif
		return DE_CONT
		
	case Ch==K_CTRL_P
		select p_rnal
		go top
		nBr_nal := p_rnal->br_nal
		st_nalpr( .t., nBr_nal )
		select p_rnal
		return DE_REFRESH
		
	case Ch==K_ALT_A
		if Pitanje( , "Azurirati nalog (D/N)?", "D") == "D"
	  		if azur_nalog() == 1
				SELECT P_RNAL
				RETURN DE_REFRESH
			endif
		endif
		RETURN DE_CONT
		
	case Ch==K_ALT_P
		if Pitanje(, "Povrat naloga u pripremu ?", "N") == "D"
			nBr_nal := 0
			if g_br_nal( @nBr_Nal )
				if pov_nalog( nBr_nal ) == 1
					SELECT P_RNAL
					GO TOP
					RETURN DE_REFRESH
				endif
			endif
		endif
		SELECT P_RNAL
		RETURN DE_CONT
		
	case UPPER(CHR(Ch)) == "O"
		select p_rnop
		ed_st_oper(p_rnal->br_nal, p_rnal->r_br, p_rnal->idroba)
		select p_rnal
		return DE_REFRESH

endcase

return DE_CONT


// ---------------------------------------
// brisi stavku iz pripreme
// ---------------------------------------
static function br_stavku()
local nBrNal
local nRbr
local cIdRoba

// kod brisanja stavke je bitno da se izbrise stavka iz P_RNAL
// kao i sve stavke iz P_RNOP

if Pitanje(, "Zelite izbrisati ovu stavku ?", "D") == "N"
	return .f.
endif

nBrNal := field->br_nal
nRBr := field->r_br
cIdRoba := field->idroba

delete

// sada izbrisi ako ima sta i u P_RNOP
br_prnop(nBrNal, nRBr, cIdRoba)

select p_rnal

return .t.



// ---------------------------------------
// brisanje kompletne pripreme
// ---------------------------------------
static function br_sve_zapise()

if Pitanje( ,"Zelite li izbrisati pripremu !!????","N") == "N"
	return .f.
endif

select p_rnal
zap        
select p_rnop
zap
select p_rnal

return .t.


// ---------------------------------------
// brisi stavke iz p_rnop
// ---------------------------------------
static function br_prnop(nBrNal, nR_br, cIdRoba)
local nArea
nArea := SELECT()

select p_rnop
set order to tag "br_nal"
go top
seek STR(nBrNal, 10, 0) + STR(nR_br) + cIdRoba

if !Found()
	return
endif

// brisi sve stavke iz P_RNOP za dati uslov
do while !EOF() .and. field->br_nal == nBrNal .and. field->r_br == nR_br .and. field->idroba == cIdRoba
	delete
	skip
enddo

select (nArea)

return


// ----------------------------------------
// ispisuje rekapitulaciju stavke GN
// ----------------------------------------
static function s_rekap_stavka(nX, nY, nGNSirina, nGNVisina, nUkupno, nGNUkupno, nNeto)
local cLine 

cLine := REPLICATE("-", 70)

@ nX, nY SAY cLine

nX += 1

@ nX, nY SAY "Zaokruzenje po GN:"
@ nX, col() + 4 SAY "Sirina (cm)"
@ nX, col() + 2 SAY nGNSirina PICT PIC_DIM()

@ nX, col() + 2 SAY "Visina (cm)"
@ nX, col() + 2 SAY nGNVisina PICT PIC_DIM()

nX += 1

@ nX, nY SAY PADL("UKUPNO:", 15)
@ nX, col() + 2 SAY nUkupno PICT PIC_IZN()
@ nX, col() + 1 SAY "m2"

nX += 1

@ nX, nY SAY PADL("UKUPNO PO GN-u:", 15)
@ nX, col() + 2 SAY nGNUkupno PICT PIC_IZN()
@ nX, col() + 1 SAY "m2"

nX += 1

@ nX, nY SAY PADL("NETO:", 15)
@ nX, col() + 2 SAY nNeto PICT PIC_IZN()
@ nX, col() + 1 SAY "kg"

nX += 1

@ nX, nY SAY cLine

return
