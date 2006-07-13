#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// stavke obrada
// ---------------------------------------------
function rnst_obrada(nBr_nal, nR_br, lPrip)
local cHeader
local cFooter
local nF_RNST := F_P_RNST

if (lPrip == nil)
	lPrip := .t.
endif

if (lPrip == .f.)
	nF_RNST := F_RNST
endif

cHeader := "SIROVINE / OPERACIJE STAVKE NALOGA"

if lPrip == .t.
	cFooter := "Unos stavki naloga za proizvodnju..."
else
	cFooter := "Dorada stavki naloga za proizvodnju..."
endif

Box(,18,77)

@ m_x+16,m_y+2 SAY "<c-N> Nova stavka     | <ENT> Ispravi stavku     | <O> Pregled operacija"
@ m_x+17,m_y+2 SAY "<c-T> Brisi stavku    | <c-F9> Brisi sve         |"
@ m_x+18,m_y+2 SAY ""

private ImeKol
private Kol

SELECT (nF_RNST)
SET ORDER TO TAG "br_nal"
GO TOP

set_f_kol(nBr_nal, nR_br)
set_a_kol(@Kol, @ImeKol)

ObjDbedit("prnst", 18, 77, {|| k_handler(nBr_nal, nR_br, lPrip)}, cHeader, cFooter, , , , , 3)
BoxC()

return

// ------------------------------------------
// postavlja filter na brnal i rbr
// ------------------------------------------
static function set_f_kol(nBr_nal, nR_br)
local cFilter

cFilter := "br_nal == " + STR(nBr_nal, 10, 0)
cFilter += " .and. "
cFilter += "r_br == " + STR(nR_br, 4, 0)

set filter to &cFilter
go top

return

// ---------------------------------------------
// postavi matrice ImeKol, Kol
// ---------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"Br.nal", {|| TRANSFORM(br_nal, "99999")}, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"R.br", {|| TRANSFORM(r_br, "99999")}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"P.br", {|| TRANSFORM(p_br, "99999")}, "p_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, { PADR("Sirovina", 10), {|| idroba }, "idroba", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kolicina", {|| TRANSFORM(kolicina, PIC_KOL()) }, "kolicina", {|| .t.}, {|| .t.} })
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
static function stavke_item(nBr_nal, nR_br, lNova, lPrip)
local nCount
local nF_RNST := F_P_RNST

if (lPrip == nil)
	lPrip := .t.
endif
if (lPrip == .f.)
	nF_RNST := F_RNST
endif

UsTipke()

Box(, 20, 77, .f., "Unos novih stavki")

select (nF_RNST)

Scatter()

nCount := 0

do while .t.
	
	if nCount > 0
		Scatter()
	endif
	
	++ nCount
	
	if g_st_item(nBr_nal, nR_br, lNova, lPrip) == 0
		exit
	endif
	
	select (nF_RNST)
	
	if lNova
		append blank
	endif
	
	Gather()
enddo

SELECT (nF_RNST)

BoxC()

return 1


// ---------------------------------------
// obradi stavka naloga
// ---------------------------------------
static function g_st_item(nBr_nal, nR_br, lNovi, lPrip)
local nX := 2
local nRobaX
local nRobaY
local nUkX
local nUnOpX
local cUnosOp := "D"
local cIdRoba
local nDebStakla
local nXRekap
local nYRekap
local cRobaVrsta:=""
local nZaokruzenje := 0
local nNetoKoef := 0
local nNetoProc := 0
local cRFilt := ""
local nF_RNST := F_P_RNST

if (lPrip == nil)
	lPrip := .t.
endif

if (lPrip == .f.)
	nF_RNST := F_RNST
endif

if lNovi
	_br_nal := nBr_nal
	_r_br := nR_br
	_p_br := next_p_br(nBr_nal, nR_br, lPrip )
	_idroba := SPACE(LEN(idroba))
	_roba_vrsta := "S"
	_kolicina := 0
	_roba_tip := SPACE(6)
	_debljina := 0
	_d_sirina := 0
	_d_visina := 0
	_d_ukupno := 0
	cUnosOp := "D"
endif

@ m_x + nX, m_y + 2 SAY "R.br:" GET _r_br PICT "9999" WHEN _r_br == 0
@ m_x + nX, col() + 2 SAY "P.br:" GET _p_br PICT "9999"

nX += 2

@ m_x + nX, m_y + 2 SAY "Tip:" GET _roba_tip VALID p_rtip(@_roba_tip) 

nX += 1

@ m_x + nX, m_y + 2 SAY "Debljina:" GET _debljina PICT PIC_DIM()  
@ m_x + nX, col() + 1 SAY "(mm)"

read

ESC_RETURN 0

// sastavi filter za tabelu robe
cRFilt := g_sast_filter(_roba_tip, _debljina)

nX += 2
nRobaX := m_x + nX
nRobaY := m_y + 35

@ m_x + nX, m_y + 2 SAY "Sirovina / operacija:" GET _idroba VALID val_sast(@_idroba, cRFilt, nRobaX, nRobaY)

nX += 2

@ m_x + nX, m_y + 2 SAY "Vrsta [S] - sirovina [K] - kupac:" GET _roba_vrsta VALID val_kunos(@_roba_vrsta, "KS")

read

ESC_RETURN 0

if _debljina == 0
	_debljina := g_roba_debljina(_idroba)
endif

if EMPTY(_roba_tip)
	_roba_tip := g_roba_tip(_idroba)
endif

// pronadji zaokruzenje
g_rtip_params(_roba_tip, @cRobaVrsta, @nZaokruzenje, @nNetoKoef, @nNetoProc)

select (nF_RNST)

nX += 2

@ m_x + nX, m_y + 2 SAY "Kolicina:" GET _kolicina PICT PIC_KOL() VALID val_kolicina( _kolicina )

@ m_x + nX, col() + 2 SAY "Sirina (mm):" GET _d_sirina PICT PIC_DIM() VALID val_dim_sirina( _d_sirina )
 
@ m_x + nX, col() + 2 SAY "Visina (mm):" GET _d_visina PICT PIC_DIM() VALID val_dim_visina( _d_visina )

read

ESC_RETURN 0

// zaokruzenja dimenzija
_z_sirina := dim_zaokruzi(_d_sirina, nZaokruzenje)
_z_visina := dim_zaokruzi(_d_visina, nZaokruzenje)

// ukupno bez zaokruzenja
_d_ukupno := c_ukvadrat( _kolicina, _d_sirina, _d_visina )
// ukupno sa zaokruzenjima
_z_ukupno := c_ukvadrat( _kolicina, _z_sirina, _z_visina )

// racunaj neto (kilaza)
_neto := c_netto( _debljina, _z_ukupno, cRobaVrsta, nNetoKoef, nNetoProc )

nXRekap := m_x + nX + 1
nYRekap := m_y + 2

// prikazi rekapitulaciju
s_rekap_stavka(nXRekap, nYRekap, _z_sirina, _z_visina, _d_ukupno, _z_ukupno, _neto)

// unos operacija
nUnOpX := 18
@ m_x + nUnOpX, m_y + 2 SAY "Unos instrukcija (D/N)?" GET cUnosOp VALID val_d_n( cUnosOp ) PICT "@!"

read

ESC_RETURN 0

if cUnosOp == "D"
	// unos operacija nad artiklom
	nP_br := _p_br
	cIdRoba := _idroba
	ed_st_instr(nBr_Nal, nR_Br, nP_Br, cIdRoba, lPrip)
endif

if !lNovi
	return 0
endif

return 1


// -----------------------------------
// sastavlja filter za tabelu robe
// -----------------------------------
static function g_sast_filter(cTip, nDebljina)
local cRet := ""

if EMPTY(cTip)
	cRet += ".t."
else
	cRet += "roba_tip == " + Cm2Str(PADR(cTip,6))
endif

cRet += " .and. "

// ako je uneseno 999 idi sve debljine...
if nDebljina == 999
	cRet += ".t."
else
	cRet += "debljina == " + STR(nDebljina, 15, 5)
endif

return cRet



// ---------------------------------------------
// tabela RNAL keyboard handler 
// ---------------------------------------------
static function k_handler(nBr_nal, nR_br, lPrip)
local nF_RNST := F_P_RNST
local nF_RNOP := F_P_RNOP

if (lPrip == nil)
	lPrip := .t.
endif

if (lPrip == .f.)
	nF_RNST := F_RNST
	nF_RNOP := F_RNOP
endif

if (Ch==K_CTRL_T .or. Ch==K_ENTER;
	.or. Ch==K_CTRL_P;
	.or. Ch==K_CTRL_F9) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		SELECT (nF_RNST)
		if br_stavku(lPrip)
			return DE_REFRESH
		endif
		SELECT (nF_RNST)
		return DE_CONT
		
	case (Ch == K_ENTER)
		SELECT (nF_RNST)
  		Scatter()
  		if stavke_item(nBr_nal, nR_br, .f. ,lPrip) == 1
			Gather()
			RETURN DE_REFRESH
		endif
		SELECT (nF_RNST)
		return DE_CONT
		
	case (Ch == K_CTRL_N)
		SELECT (nF_RNST)
		stavke_item(nBr_nal, nR_br, .t., lPrip)
		SELECT (nF_RNST)
		return DE_REFRESH
		
	case (Ch  == K_CTRL_F9)
        	SELECT (nF_RNST)
		nBr_nal := field->br_nal
		if br_sve_zapise(nBr_nal, lPrip)
			return DE_REFRESH
		endif
		SELECT (nF_RNST)
		return DE_CONT
		
	case UPPER(CHR(Ch)) == "O"
		nBr_nal := field->br_nal
		nR_br := field->r_br
		nP_br := field->p_br
		cIdRoba := field->idroba
		select (nF_RNOP)
		ed_st_instr(nBr_nal, nR_br, nP_br, cIdRoba, lPrip)
		select (nF_RNST)
		return DE_REFRESH
	
	case ( Ch == K_ESC )
		select (nF_RNST)
		return DE_CONT 

endcase

return DE_CONT


// ---------------------------------------
// brisi stavku iz pripreme
// ---------------------------------------
static function br_stavku(lPrip)
local nBrNal
local nRbr
local nPbr
local cIdRoba
local nF_RNST := F_P_RNST
local nF_RNAL := F_P_RNAL
local dDatum := DATE()
local cVrijeme := TIME()
local cAkcija := "-"
local cTipArt := "20"
local cOperater := goModul:oDataBase:cUser
local cOpis := SPACE(150)
local nLOGR_br 

if (lPrip == nil)
	lPrip := .t.
endif

if (lPrip == .f.)
	nF_RNST := F_RNST
	nF_RNAL := F_RNAL
endif

// kod brisanja stavke je bitno da se izbrise stavka iz P_RNST
// kao i sve stavke iz P_RNOP

if Pitanje(, "Zelite izbrisati ovu stavku ?", "D") == "N"
	return .f.
endif

nBrNal := field->br_nal
nRBr := field->r_br
nPBr := field->p_br
cIdRoba := field->idroba
nKolicina := field->kolicina
nSirina := field->sirina
nVisina := field->visina

if lPrip == .f.
	// uzmi opis
	if g_opis_box(@cOpis) == 0
		return .f.
	endif
	
	select (nF_RNAL)
	set order to tag "br_nal"
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)
	
	cProizvod := field->proizvod
	
	select (nF_RNST)
endif

delete

if (lPrip == .f.)
	nLOGR_br := n_log_rbr( nBr_nal )
	f_rnlog( nBr_nal, nLOGR_br, cTipArt, cAkcija,;
		 dDatum, cVrijeme, cOperater, cOpis)

	f20_stavke(nBr_nal, nLOGR_br, nStP_br, cProizvod, cIdRoba,;
        	   nKolicina, nSirina, nVisina)
endif

// sada izbrisi ako ima sta i u P_RNOP
br_prnop(nBrNal, nRBr, nPBr, cIdRoba, lPrip)

select (nF_RNST)

return .t.



// ---------------------------------------
// brisanje kompletne pripreme
// ---------------------------------------
static function br_sve_zapise(nBr_nal, lPrip)
local nF_RNST := F_P_RNST
local nF_RNOP := F_P_RNOP

if Pitanje( ,"Zelite li izbrisati pripremu !!????","N") == "N"
	return .f.
endif

if (lPrip == nil)
	lPrip := .t.
endif

if (lPrip == .f.)
	nF_RNST := F_RNST
	nF_RNOP := F_RNOP
endif

select (nF_RNST)
go top
do while !EOF() .and. field->br_nal == nBr_nal
	delete
	skip
enddo

select (nF_RNOP)
go top
do while !EOF() .and. field->br_nal == nBr_nal
	delete
	skip
enddo

select (nF_RNST)

return .t.


// ---------------------------------------
// brisi stavke iz p_rnop
// ---------------------------------------
static function br_prnop(nBrNal, nR_br, nP_br, cIdRoba, lPrip)
local nArea
local nF_RNOP := F_P_RNOP

if (lPrip == nil)
	lPrip := .t.
endif
if (lPrip == .f.)
	nF_RNOP := F_RNOP
endif

nArea := SELECT()

select (nF_RNOP)
set order to tag "br_nal"
go top
seek STR(nBrNal, 10, 0) + STR(nR_br) + STR(nP_br) + cIdRoba

if !Found()
	return
endif

// brisi sve stavke iz P_RNOP za dati uslov
do while !EOF() .and. field->br_nal == nBrNal .and. field->r_br == nR_br .and. field->p_br == nP_br .and. field->idroba == cIdRoba
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

cLine := REPLICATE(CHR(205), 76)

@ nX, nY SAY cLine

nX += 1

@ nX, nY SAY "      Zaokruzenja:"
@ nX, col() + 4 SAY "Sirina (cm)"
@ nX, col() + 2 SAY nGNSirina PICT PIC_DIM()

@ nX, col() + 2 SAY "Visina (cm)"
@ nX, col() + 2 SAY nGNVisina PICT PIC_DIM()

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


