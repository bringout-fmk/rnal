#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// edit radni nalog
// lDorada - dorada naloga
// ---------------------------------------------
function ed_rnal(lDorada)

if (lDorada == nil)
	lDorada := .f.
endif

// otvori tabele
o_rnal(.t.)

// prikazi tabelu pripreme
rnal_priprema(lDorada)

return



// ---------------------------------------------
// prikazi tabelu pripreme
// ---------------------------------------------
static function rnal_priprema(lDorada)
local cHeader
local cFooter

cHeader := "NOVI NALOG ZA PROIZVODNJU"
if (lDorada == .t.)
	cHeader := "Dorada naloga"
endif
cFooter := "Unos/dorada naloga za proizvodnju..."

Box(,20,77)
@ m_x+18,m_y+2 SAY "<c-N> Nova stavka     | <ENT> Ispravi stavku     | <a-A> Azuriranje naloga"
@ m_x+19,m_y+2 SAY "<c-P> Stampa naloga   | <c-O> Stampa otpremnice  | <S> Pregled sirovina "
@ m_x+20,m_y+2 SAY "<c-T> Brisi stavku    | <c-F9> Brisi sve         |"

private ImeKol
private Kol

SELECT (F_P_RNAL)
SET ORDER TO TAG "br_nal"
GO TOP

set_a_kol( @Kol, @ImeKol)

ObjDbedit("prnal", 20, 77, {|| k_handler()}, cHeader, cFooter, , , , , 3)
BoxC()

if (lDorada == .t.)
	return
endif

closeret


// ---------------------------------------------
// postavi matrice ImeKol, Kol
// ---------------------------------------------
static function set_a_kol( aKol, aImeKol )

aImeKol := {}

AADD(aImeKol, {"Br.nal", {|| TRANSFORM(br_nal, "99999")}, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"R.br", {|| TRANSFORM(r_br, "99999")}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Proizvod", {|| proizvod}, "proizvod", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.n.", {|| datnal}, "datnal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp", {|| datisp}, "datisp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Mj.isp", {|| mj_isp}, "mj_isp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp", {|| vr_isp}, "vr_isp", {|| .t.}, {|| .t.} })

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

SELECT p_rnal

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
// obradi stavku naloga
// ---------------------------------------
function g_nal_item(lNovi)
local nX := 13
local nRobaX
local nRobaY
local cDefSast:="N"

if lNovi
	_r_br := next_r_br()
	_proizvod := SPACE(LEN(proizvod))
endif

@ m_x + nX, m_y + 2 SAY "R.br:" GET _r_br PICT "9999"

nX += 2
nRobaX := m_x + nX
nRobaY := m_y + 25

@ m_x + nX, m_y + 2 SAY "Proizvod:" GET _proizvod VALID val_roba(@_proizvod, nRobaX, nRobaY)

nX += 2

@ m_x + nX, m_y + 2 SAY "Definisi sastavnice proizvoda (D/N)" GET cDefSast VALID val_d_n(@cDefSast)

read

ESC_RETURN 0

// definisanje sastavnica
if cDefSast == "D"
	nBr_nal := _br_nal
	nR_br := _r_br
	rnst_priprema(nBr_nal, nR_br)
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
local nPartY

if lNovi
	//_br_nal := next_br_nal()
	_br_nal := 0
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
nPartY := m_y + 2

@ m_x + nX, m_y + 2 SAY "Partner:" GET _idpartner VALID val_partner(@_idpartner, nPartX, nPartY)

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
local cLOG_opis

if (Ch==K_CTRL_T .or. Ch==K_ENTER;
	.or. Ch==K_CTRL_P;
	.or. Ch==K_CTRL_F9) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		SELECT P_RNAL
		if br_sve_zapise()
			return DE_REFRESH
		endif
		return DE_CONT
	
	case (Ch == K_ENTER)
		SELECT P_RNAL
  		Scatter()
  		if nalog_item(.f.) == 1
			Gather()
			RETURN DE_REFRESH
		endif
		return DE_CONT
		
	case (Ch == K_CTRL_N)
		SELECT P_RNAL
		nalog_item(.t.)
		return DE_REFRESH
		
	case (Ch  == K_CTRL_F9)
        	SELECT P_RNAL
		if br_sve_zapise()
			return DE_REFRESH
		endif
		return DE_CONT
	
	case ( UPPER(CHR(Ch)) == "S" )
		// pregled sirovina / operacija
		SELECT P_RNAL
		rnst_priprema(p_rnal->br_nal, p_rnal->r_br)
		SELECT P_RNAL
		return DE_CONT

	case Ch==K_CTRL_P
		select p_rnal
		go top
		
		//nBr_nal := p_rnal->br_nal
		
		// ------------------------
		// nove funkcije mrezni rad
		
		nBr_nal := _n_br_nal()
		f_p_br_nal( nBr_nal )
		
		// ------------------------
		
		st_nalpr( .t., nBr_nal )
		select p_rnal
		return DE_REFRESH
		
	case Ch==K_ALT_A
		if Pitanje( , "Azurirati nalog (D/N)?", "D") == "D"
	  		// trazi opis prije azuriranja
			g_log_opis(@cLOG_opis, p_rnal->rn_status, .t.)
			nBr_nal := _n_br_nal()
			f_p_br_nal( nBr_nal )
			del_op_error()
			if azur_nalog(cLOG_opis) == 1
				SELECT P_RNAL
				RETURN DE_REFRESH
			endif
		endif
		RETURN DE_CONT
	
	case ( Ch == K_ESC )
		select p_rnal
		if RECCOUNT2() <> 0
			MsgBeep("Nalog u pripremi ostavljen za doradu!")
		endif
		return DE_CONT 

endcase

return DE_CONT



// ---------------------------------------
// uzmi opis pri azuriranju
// ---------------------------------------
function g_log_opis(cLog_opis, cStatus, lAzur)
local cUnos_dn := "D"
cLog_opis := SPACE(100)

if ( lAzur == nil )
	lAzur := .f.
endif

// ako je tek azuriranje i status O ne treba opis
if (lAzur .and. cStatus == "O")
	return 0
endif

Beep(2)
Box(,3,60)
do while .t.
	@ m_x + 1, m_y + 2 SAY "Unesi opis obrade:" COLOR "I"
	@ m_x + 2, m_y + 2 SAY "->" GET cLog_opis PICT "@S50"
	read
	@ m_x + 3, m_y + 2 SAY "unos ispravan (D/N)" GET cUnos_dn PICT "@!" VALID val_kunos(cUnos_dn, "DN")
	read
	
	ESC_RETURN 0
	
	if (cUnos_dn == "D")
		exit
	endif
	
enddo
BoxC()

return 1


// ---------------------------------------
// brisanje kompletne pripreme
// ---------------------------------------
static function br_sve_zapise()
local nBr_nal

if Pitanje( ,"Zelite li izbrisati pripremu !!????","N") == "N"
	return .f.
endif

select p_rnal
nBr_nal := field->br_nal
zap        

select p_rnst
zap

select p_rnop
zap

del_rnal_z( nBr_nal )

select p_rnal

return .t.

