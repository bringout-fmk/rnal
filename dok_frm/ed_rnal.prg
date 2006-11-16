#include "\dev\fmk\rnal\rnal.ch"


// ---------------------------------------------
// edit radni nalog
// lDorada - dorada naloga
// ---------------------------------------------
function ed_rnal()

// otvori tabele
o_tables(.t.)

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
@ m_x+18,m_y+2 SAY "<c-N> Novi nalog      | <ENT> Ispravi stavku     | <a-A> Azuriranje naloga"
@ m_x+19,m_y+2 SAY "<c-P> Stampa naloga   | <c-O> Stampa otpremnice  |"
@ m_x+20,m_y+2 SAY "<c-T> Brisi nalog     | "

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
AADD(aImeKol, {"Dat.n.", {|| dat_nal}, "dat_nal", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp", {|| dat_isp}, "dat_isp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Mj.isp", {|| PADR(mj_isp, 20)}, "mj_isp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp", {|| vr_isp}, "vr_isp", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kupac", {|| say_item_mc(F_PARTN, "PARTN", idpartner)}, "idpartner", {|| .t.}, {|| .t.} })

aKol:={}

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// obrada sve stavke 
// ---------------------------------------------
static function nalog_item(lNova)
local cStatus

cStatus := rec_zak

// ako status nije "POVRAT"
// otvori masku za unos osnovnih podataka naloga...
if cStatus <> "P"
 
   UsTipke()

   Box(, 21, 77, .f., "Unos novih stavki")
  
   Scatter()

   if RECCOUNT2() == 0
   	// radi se o potpuno novoj stavci
	if g_nal_header(lNova) == 0
		select p_rnal
		BoxC()
		return 1
	endif
   else
   	// radi se o postojecoj stavci u tabeli
	if g_nal_header(.f.) == 0
		select p_rnal
		BoxC()
		return 1
	endif
   endif
   
   Gather()
	
   select p_rnal
   
   BoxC()

endif

if lNova == .t.
	// otvori unos stavki naloga....
	g_nal_item(lNova)
endif

select p_rnal

return 1


// ---------------------------------------
// obradi stavku naloga
// ---------------------------------------
function g_nal_item(lNovi)
return g_item_unos(lNovi)


// ---------------------------------------
// obradi header naloga
// ---------------------------------------
function g_nal_header(lNovi)
local nX := 2
local nPartX 
local nPartY
local cLine

_operater := goModul:oDatabase:cUser

if lNovi
	//_br_nal := next_br_nal()
	_br_nal := 0
	_dat_nal := DATE()
	_dat_isp := DATE()
	_hitnost := " "
	_idpartner := SPACE(LEN(idpartner))
	_vr_isp := PADR( LEFT( TIME(), 5 ), 8 )
	_mj_isp := SPACE(100)
	_k_ime := SPACE(40)
	_k_tel := SPACE(60)
	_k_opis := SPACE(100)
	_dod_opis := SPACE(150)
	_montaza := " "
	_vr_plac := " "
	if _rn_status == " "
		_rn_status := "O"
	endif
endif

set cursor on

@ m_x, m_y + 45 SAY "Operater: " + PADR( _operater , 20)

@ m_x + nX, m_y + 2 SAY "Broj naloga:" GET _br_nal PICT "999999999" WHEN _br_nal <> 0

@ m_x + nX, col() + 4 SAY "Datum naloga:" GET _dat_nal VALID !EMPTY(_dat_nal)

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

@ m_x + nX, m_y + 2 SAY "  Datum isporuke:" GET _dat_isp VALID !EMPTY(_dat_isp)

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

@ m_x + nX, m_y + 2 SAY "Prioritet:" GET _hitnost VALID val_priority(@_hitnost) PICT "9"

@ m_x + nX, col() + 2 SAY "Placanje:" GET _vr_plac VALID val_plac(@_vr_plac) PICT "9"

@ m_x + nX, col() + 2 SAY "Montaza (D/N):" GET _montaza VALID val_d_n(@_montaza) PICT "@!"

nX += 1

@ m_x + nX, m_y + 1 SAY cLine

read

ESC_RETURN 0

nX += 1

@ m_x + nX, m_y + 2 SAY "  Dodatni podaci naloga:" GET _dod_opis VALID !EMPTY(_dod_opis) PICT "@S40"

read

ESC_RETURN 0

if lNovi
	append blank
endif

return 1


// ---------------------------------------------
// tabela RNAL keyboard handler 
// ---------------------------------------------
static function k_handler()
local nBr_nal
local cLOGopis

if (Ch==K_ENTER .or. Ch==K_CTRL_P .or. Ch==K_CTRL_F9) ;
	.and. reccount2()==0
	
	return DE_CONT
endif

do case
	
	// ispravka naloga....
	case (Ch == K_ENTER)
		SELECT P_RNAL
  		if reccount2() == 0
			return DE_CONT
		endif
		
		Scatter()
  		if nalog_item(.f.) == 1
			Gather()
			RETURN DE_REFRESH
		endif
		return DE_CONT
		
	// unos novog naloga
	case (Ch == K_CTRL_N)
		SELECT P_RNAL
		if reccount2() == 1
			MsgBeep("U pripremi vec postoji nalog!#Azurirajte ga!")
			return DE_CONT
		endif
		nalog_item(.t.)
		return DE_REFRESH
		
	// brisanje naloga
	case (Ch  == K_CTRL_F9)
        	SELECT P_RNAL
		if br_sve_zapise()
			return DE_REFRESH
		endif
		return DE_CONT
	
	// pregled stavki naloga...
	case ( UPPER(CHR(Ch)) == "S" )
		// pregled stavki naloga
		SELECT P_RNAL
		if RECCOUNT2() == 0
			return DE_CONT
		endif
		g_nal_item(.f.)
		SELECT P_RNAL
		return DE_CONT

	// stampa naloga
	case Ch==K_CTRL_P
		if nal_integritet()
			select p_rnal
			go top
			
			nBr_nal := _n_br_nal()
			f_p_br_nal( nBr_nal )
			
			st_nalpr( .t., nBr_nal )
			select p_rnal
			return DE_REFRESH
		endif
		return DE_CONT
		
	// azuriranje naloga
	case Ch==K_ALT_A
		
		if !nal_integritet()
			return DE_CONT
		endif
		
		select p_rnal
		go top
		
		if Pitanje(, "Azurirati nalog (D/N)?", "D") == "D"
			
			// opis prije azuriranja
			if get_p_marker() == "P"
				if get_box_promjena(@cLOGopis) == 0
					return DE_CONT
				endif
			else
				cLOGopis := ""
			endif
			
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

	// izlazak iz pripreme....
	case ( Ch == K_ESC )
		select p_rnal
		if RECCOUNT2() <> 0
			MsgBeep("Nalog u pripremi ostavljen za doradu!")
		endif
		return DE_CONT 

endcase

return DE_CONT


// --------------------------------------
// vrati box sa poljem opis
// --------------------------------------
function get_box_promjena(cOpis)
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

// brisi marker naloga
del_rnal_z( nBr_nal )

// vrati marker naloga
set_p_marker( nBr_nal, "" )

select p_rnal

return .t.



