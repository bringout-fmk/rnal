#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// dorada naloga - azuriranog...
// ---------------------------------------------
function nal_dorada( nBr_nal )
local cHeader
local cFooter

cHeader := "NALOG ZA PROIZVODNJU"
cFooter := "Dorada naloga za proizvodnju..."

Box(,20,77)
@ m_x+18,m_y+2 SAY "<c-N> Nova stavka     | <ENT> Ispravi stavku     | <S> Pregled sirovina"
@ m_x+19,m_y+2 SAY "<c-T> Brisi stavku    | <ESC> Izlaz              |"
@ m_x+20,m_y+2 SAY "                      |                          |"

private ImeKol
private Kol

SELECT (F_RNAL)
SET ORDER TO TAG "br_nal"
GO TOP

set_f_kol(nBr_nal)
set_a_kol( @Kol, @ImeKol)

ObjDbedit("rnald", 20, 77, {|| k_handler()}, cHeader, cFooter, , , , , 3)
BoxC()

return


// setuj filter
static function set_f_kol(nBr_nal)
local cFilt

cFilt := "br_nal == " + STR(nBr_nal, 10, 0)

set filter to &cFilt
go top
return

// ---------------------------------------------
// postavi matrice ImeKol, Kol
// ---------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"Br.nal", {|| PADR(TRANSFORM(br_nal, "99999"),7)}, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"R.br", {|| PADR(TRANSFORM(r_br, "99999"),7)}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Proizvod", {|| proizvod}, "proizvod", {|| .t.}, {|| .t.} })

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// obrada sve stavke 
// ---------------------------------------------
static function nalog_item(lNova)
local nCount 

UsTipke()

Box(, 21, 77, .f., "Unos novih stavki")

Scatter()

SELECT rnal

nCount := 0

do while .t.
	if nCount > 0
		Scatter()
	endif
	++ nCount
	if g_nal_item(lNova) == 0
		exit
	endif
	select rnal
	if lNova
		append blank
	endif
	Gather()
enddo

SELECT rnal

BoxC()

return 1


// ---------------------------------------
// obradi stavku naloga
// ---------------------------------------
static function g_nal_item(lNovi)
local nX := 1
local nRobaX
local nRobaY
local cDefSast:="D"
local cLine

if lNovi
	_r_br := next_r_br(.f.)
	_proizvod := SPACE(LEN(proizvod))
	_operater := goModul:oDataBase:cUser
endif

cLine := REPLICATE(CHR(205), 77)

@ m_x + nX, m_y + 2 SAY "DORADA NALOGA"
@ m_x + nX, col() + 10 SAY "Operater: " + PADR(goModul:oDataBase:cUser, 20)

nX += 2

@ m_x + nX, m_y + 2 SAY "Broj naloga" GET _br_nal WHEN _br_nal == 0

nX += 10

@ m_x + nX, m_y + 2 SAY cLine

nX += 1

@ m_x + nX, m_y + 2 SAY "R.br:" GET _r_br PICT "9999"

nX += 2
nRobaX := m_x + nX
nRobaY := m_y + 25

@ m_x + nX, m_y + 2 SAY "Proizvod:" GET _proizvod VALID val_roba(@_proizvod, nRobaX, nRobaY)

read

ESC_RETURN 0

// prebaci sastavnice u rnst ako postoje
sast_to_rnst(_proizvod, _br_nal, _r_br, .f.)

nX += 2

@ m_x + nX, m_y + 2 SAY "Definisi-pregledaj sastavnice proizvoda (D/N)" GET cDefSast VALID val_d_n(@cDefSast) PICT "@!"

read

ESC_RETURN 0

// definisanje sastavnica
if cDefSast == "D"
	nBr_nal := _br_nal
	nR_br := _r_br
	rnst_obrada(nBr_nal, nR_br, .f.)
endif

if !lNovi
	return 0
endif

return 1



// ---------------------------------------------
// tabela RNAL keyboard handler 
// ---------------------------------------------
static function k_handler()
local nBr_nal

do case
	case (Ch == K_CTRL_T)
		SELECT RNAL
		if br_stavku()
			return DE_REFRESH
		endif
		return DE_CONT
	
	case (Ch == K_ENTER)
		SELECT RNAL
  		Scatter()
  		if nalog_item(.f.) == 1
			Gather()
			RETURN DE_REFRESH
		endif
		return DE_CONT
		
	case (Ch == K_CTRL_N)
		SELECT RNAL
		nalog_item(.t.)
		return DE_REFRESH
		
	case ( UPPER(CHR(Ch)) == "S" )
		// pregled sirovina / operacija
		SELECT RNAL
		rnst_obrada(field->br_nal, field->r_br, .f.)
		SELECT RNAL
		return DE_CONT

	case ( Ch == K_ESC )
		return DE_CONT 

endcase

return DE_CONT


// ---------------------------------------
// brisanje stavke
// ---------------------------------------
static function br_stavku()
local nBr_nal
local nR_br
local cProizvod
local nKolicina
local nSirina
local nVisina
local dDatum := DATE()
local cVrijeme := TIME()
local cAkcija := "-"
local cTipArt := "20"
local cTipOp := "30"
local cOperater := goModul:oDataBase:cUser
local cOpis := SPACE(150)

if Pitanje( ,"Izbrisati stavku (D/N)","N") == "N"
	return .f.
endif

// uzmi opis
if g_opis_box(@cOpis) == 0
	return .f.
endif

select rnal
nBr_nal := field->br_nal
nR_br := field->r_br
cProizvod := field->proizvod

delete        

nLOGR_br := n_log_rbr( nBr_nal )
f_rnlog( nBr_nal, nLOGR_br, cTipArt, cAkcija,;
	 dDatum, cVrijeme, cOperater, cOpis)

select rnst
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_rb, 4, 0)

do while !EOF() .and. field->br_nal == nBr_nal;
                .and. field->r_br == nR_Br
	
	cRoba := field->idroba
	nKolicina := field->kolicina
	nSirina := field->d_sirina
	nVisina := field->d_visina
	nSTP_br := field->p_br
	
	f20_stavke(nBr_nal, nLOGR_br, nStP_br, cProizvod, cRoba,;
	           nKolicina, nSirina, nVisina)

	select rnst
	delete
	skip
enddo

select rnop
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0) + STR(nR_rb, 4, 0)

if FOUND()
	nLOGR_br := n_log_rbr( nBr_nal )
	f_rnlog( nBr_nal, nLOGR_br, cTipOp, cAkcija,;
	         dDatum, cVrijeme, cOperater, cOpis)
endif

do while !EOF() .and. field->br_nal == nBr_nal;
                .and. field->r_br == nR_Br
	
	nSTP_br := field->p_br
	cRoba := field->idroba
	cRnOper := field->id_rnop
	cRnKa := field->id_rnka
	cInstr := field->rn_instr
	
	f30_stavke(nBr_nal, nLOGR_br, nStP_br,;
		   cProizvod, cRoba, cRnOper,;
	           cRnKa, cInstr)
	
	select rnop
	delete
	skip
enddo

select rnal

return .t.

// ------------------------------------
// setuj opis promjene
// ------------------------------------
function g_opis_box(cOpis)

Box(,2,60)
	@ m_x + 1, m_y + 2 SAY "Unesi opis:" GET cOpis VALID !EMPTY(cOpis) PICT "@S40" 
	read
BoxC()

if LastKey() == K_ESC
	MsgBeep("Operacija prekinuta !!!")
	return 0
endif

return 1


