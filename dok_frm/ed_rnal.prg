#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// edit radni nalog
// lDorada - dorada naloga
// ---------------------------------------------
function ed_rnal()

// otvori tabele
o_rnal(.t.)

// prikazi tabelu pripreme
rnal_priprema()

return



// ---------------------------------------------
// prikazi tabelu pripreme
// ---------------------------------------------
static function rnal_priprema()
local cHeader
local cFooter
local lDorada
private ImeKol
private Kol

SELECT (F_P_RNAL)
SET ORDER TO TAG "br_nal"
GO TOP
if field->rec_zak == "P"
	lDorada := .t.
endif

cHeader := "NOVI NALOG ZA PROIZVODNJU"
if (lDorada == .t.)
	cHeader := "DORADA NALOGA ZA PROIZVODNJU"
endif
cFooter := "Unos/dorada naloga za proizvodnju..."

Box(,20,77)
@ m_x+18,m_y+2 SAY "<c-N> Nova stavka     | <ENT> Ispravi stavku     | <a-A> Azuriranje naloga"
@ m_x+19,m_y+2 SAY "<c-P> Stampa naloga   | <c-O> Stampa otpremnice  | <S> Pregled sirovina "
@ m_x+20,m_y+2 SAY "<c-T> Brisi stavku    | <c-F9> Brisi sve         |"

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

AADD(aImeKol, {"Br.nal", {|| PADR(TRANSFORM(br_nal, "99999"),7)}, "br_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"R.br", {|| PADR(TRANSFORM(r_br, "99999"),7)}, "r_br", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Proizvod", {|| proizvod}, "proizvod", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kolicina", {|| TRANSFORM(kolicina, PIC_KOL())}, "kolicina", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.n.", {|| datnal}, "datnal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp", {|| datisp}, "datisp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Mj.isp", {|| PADR(mj_isp,20)}, "mj_isp", {|| .t.}, {|| .t.} })
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
local cStat 

UsTipke()

Box(, 21, 77, .f., "Unos novih stavki")

Scatter()

cStat := _rec_zak

if cStat <> "P"

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
local nX := 17
local nRobaX
local nRobaY
local cDefSast:="D"

if lNovi
	_r_br := next_r_br()
	_proizvod := SPACE(LEN(proizvod))
endif

@ m_x + nX, m_y + 2 SAY "R.br:" GET _r_br PICT "9999"

nX += 1
nRobaX := m_x + nX
nRobaY := m_y + 25

@ m_x + nX, m_y + 2 SAY "Proizvod:" GET _proizvod VALID val_roba(@_proizvod, nRobaX, nRobaY)

nX += 1

@ m_x + nX, m_y + 2 SAY "Kolicina:" GET _kolicina PICT PIC_KOL() VALID val_kolicina( _kolicina ) 

read

ESC_RETURN 0

// prebaci sastavnice u rnst ako postoje
sast_to_rnst(_proizvod, _br_nal, _r_br)

nX += 2

@ m_x + nX, m_y + 2 SAY "Definisi-pregledaj sastavnice proizvoda (D/N)" GET cDefSast VALID val_d_n(@cDefSast) PICT "@!"

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
local nX := 2
local nPartX 
local nPartY
local cLine

if lNovi
	//_br_nal := next_br_nal()
	_br_nal := 0
	_datnal := DATE()
	_datisp := DATE()
	_hitnost := "2"
	_idpartner := SPACE(LEN(idpartner))
	_vr_isp := PADR( LEFT( TIME(), 5 ), 8 )
	_mj_isp := SPACE(100)
	_operater := goModul:oDatabase:cUser
	_k_ime := SPACE(40)
	_k_tel := SPACE(60)
	_k_opis := SPACE(100)
	_vr_plac := "1"
	if _rn_status == " "
		_rn_status := "O"
	endif
endif

set cursor on

@ m_x, m_y + 45 SAY "Operater: " + PADR( _operater , 20)

@ m_x + nX, m_y + 2 SAY "Broj naloga:" GET _br_nal PICT "999999999" WHEN _br_nal <> 0

@ m_x + nX, col() + 4 SAY "Datum naloga:" GET _datnal VALID !EMPTY(_datnal)

nX += 2

nPartX := m_x + nX
nPartY := m_y + 20

@ m_x + nX, m_y + 2 SAY "Kupac:" GET _idpartner VALID val_partner(@_idpartner, nPartX, nPartY)

nX += 3

cLine := REPLICATE(CHR(205), 78)

@ m_x + nX, m_y + 1 SAY cLine

read

ESC_RETURN 0

nX += 1

@ m_x + nX, m_y + 2 SAY "  Datum isporuke:" GET _datisp VALID !EMPTY(_datisp)

@ m_x + nX, col() + 4 SAY "Vrijeme isporuke:" GET _vr_isp VALID !EMPTY(_vr_isp)

nX += 1

@ m_x + nX, m_y + 2 SAY " Mjesto isporuke:" GET _mj_isp VALID !EMPTY(_mj_isp) PICT "@S40"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Kontakt, ime:", 20) GET _k_ime VALID !EMPTY(_k_ime) PICT "@S40"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Kontakt, telefon:", 20) GET _k_tel VALID !EMPTY(_k_tel) PICT "@S40"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Kontakt, dod.opis:", 20) GET _k_opis VALID !EMPTY(_k_opis) PICT "@S40"

nX += 2

@ m_x + nX, m_y + 2 SAY "Prioritet hitnosti (1/2/3):" GET _hitnost VALID val_kunos( _hitnost, "123" ) PICT "9"

@ m_x + nX, col() + 2 SAY "Vr.placanja 1-kes 2-ziro racun:" GET _vr_plac VALID val_kunos( _vr_plac, "12") PICT "9"

nX += 1

@ m_x + nX, m_y + 1 SAY cLine

read

ESC_RETURN 0

return 1


// ---------------------------------------------
// tabela RNAL keyboard handler 
// ---------------------------------------------
static function k_handler()
local nBr_nal
local cLOGopis

if (Ch==K_CTRL_T .or. Ch==K_ENTER;
	.or. Ch==K_CTRL_P;
	.or. Ch==K_CTRL_F9) .and. reccount2()==0
	return DE_CONT
endif

do case
	case (Ch == K_CTRL_T)
		SELECT P_RNAL
		if br_stavku()
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
		if RECCOUNT2() == 0
			return DE_CONT
		endif
		rnst_priprema(p_rnal->br_nal, p_rnal->r_br)
		SELECT P_RNAL
		return DE_CONT

	case Ch==K_CTRL_P
		if nal_integritet()
			select p_rnal
			go top
			// generisi sifru proizvoda 
			gen_r_sif()
			
			nBr_nal := _n_br_nal()
			f_p_br_nal( nBr_nal )
			
			st_nalpr( .t., nBr_nal )
			select p_rnal
			return DE_REFRESH
		endif
		return DE_CONT
		
	case Ch==K_ALT_A
		
		if !nal_integritet()
			return DE_CONT
		endif
		
		select p_rnal
		go top
		
		if Pitanje(, "Azurirati nalog (D/N)?", "D") == "D"
			
			// opis prije azuriranja
			if get_p_marker() == "P"
				if get_box_opis(@cLOGopis) == 0
					return DE_CONT
				endif
			else
				cLOGopis := ""
			endif
			
			// generisi sifru robe + match code
			gen_r_sif()
			
			// uzmi broj naloga
			nBr_nal := _n_br_nal()
			
			// filuj sve tabele sa brojem naloga
			f_p_br_nal( nBr_nal )
			
			// brisi viska operacije
			del_op_error()
			
			// azuriraj nalog
			if azur_nalog(cLOGopis) == 1
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


// vrati box sa poljem opis
function get_box_opis(cOpis)
private GetList:={}

cOpis := SPACE(150)

Box(,1,60)
	@ m_x + 1, m_y + 2 SAY "Opis promjene:" GET cOpis VALID !EMPTY(cOpis) PICT "@S40"
	read
BoxC()

if LastKey()==K_ESC
	return 0
endif

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

// vrati marker naloga
set_p_marker( nBr_nal, "" )

select p_rnal

return .t.


// ------------------------------
// brisanje stavke
// ------------------------------
static function br_stavku()
local nTArea := SELECT()
local lDelete := .f.

if Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
	return lDelete
endif

nBr_nal := field->br_nal
nR_br := field->r_br

if RECCOUNT2() <> 0
	delete
	lDelete := .t.
endif

if lDelete
	select p_rnst
	set filter to
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

	if FOUND()
		do while !EOF() .and. field->br_nal == nBr_nal ;
			.and. field->r_br == nR_br
		
			delete
			skip
		enddo
	endif

	select p_rnop
	set filter to
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0)

	if FOUND()
		do while !EOF() .and. field->br_nal == nBr_nal ;
			.and. field->r_br == nR_br
		
			delete
			skip
		enddo
	endif
endif

select (nTArea)
return lDelete


