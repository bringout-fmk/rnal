#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// lista dokumenata....
//  nStatus - "1" otoreni ili "2" zatvoreni
// ------------------------------------------
function frm_lst_docs( nStatus )
local nTblRet

o_tables(.f.)

nTblRet := tbl_lista( nStatus )

if nTblRet == 1
	return
elseif nTblRet == 2
	MsgBeep("report: lista naloga...")
endif

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_lista(nStatus)
local cFooter
local nLstRet

nLstRet := lst_uslovi(nStatus)

if nLstRet == 2
	return 2
elseif nLstRet == 0
	return 0
endif

private ImeKol
private Kol

cFooter := "Pregled azuriranih naloga..."

Box(, 20, 77)

set_box_dno(nStatus)

select docs
set order to tag "1"
go top

set_a_kol(@ImeKol, @Kol, nStatus)

ObjDbedit("lstnal", 20, 77, {|| k_handler(nStatus) }, "", cFooter, , , , , 2)

BoxC()

close all
return 1

// ------------------------------------------
// setovanje dna boxa
// ------------------------------------------
static function set_box_dno(nStatus)
local cLine1 := ""
local cLine2 := ""
local nOpcLen := 24
local cOpcSep := "| "

cLine1 := PADR("<D> Dorada naloga", nOpcLen)
cLine1 += cOpcSep

if ( nStatus == 1 )
	cLine1 += PADR("<Z> Zatvori nalog", nOpcLen)
	cLine1 += cOpcSep
	cLine1 += PADR("<P> Promjene", nOpcLen)
endif

// druga linija je zajednicka
cLine2 := PADR("<c-P> Stampa naloga", nOpcLen)
cLine2 += cOpcSep
cLine2 += PADR("<c-O> Stampa otpremnice", nOpcLen)
cLine2 += cOpcSep
cLine2 += PADR("<L> Lista promjena", nOpcLen)

@ m_x + 19, m_y + 2 SAY cLine1
@ m_x + 20, m_y + 2 SAY cLine2

return



// -------------------------------------------------
// otvori formu sa uslovima te postavi filtere
// -------------------------------------------------
static function lst_uslovi(nStatus)
local nX := 2
local dDatOd := CToD("")
local dDatDo := DATE()
local cTblLista := "D"
local nRet := 1
local cFilter

Box( ,10, 70)
	
@ m_x + nX, m_y + 2 SAY "Datum od " GET dDatOd
@ m_x + nX, col() + 2 SAY "do" GET dDatDo

nX += 2

@ m_x + nX, m_y + 2 SAY "Tabelarni pregled (D/N) " GET cTblLista VALID cTblLista $ "DN" PICT "@!"

read

BoxC()

if cTblLista == "N"
	nRet := 2
endif

ESC_RETURN 0

cFilter := gen_filter(nStatus, dDatOd, dDatDo)

set_f_kol(cFilter)

return nRet



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter(nStatus, dDatOd, dDatDo)
local nClosed := 1
local cFilter := ""

if nStatus == 1
	// samo otvoreni nalozi
	cFilter += "doc_status == 2 .or. doc_status == 3 .or. doc_status == 0 "
else
	// samo zatvoreni nalozi
	cFilter += "doc_status == 1"
endif

if !EMPTY(dDatOd)
	cFilter += " .and. doc_date >= " + Cm2Str(dDatOd)
endif
if !Empty(dDatDo)
	cFilter += " .and. doc_date <= " + Cm2Str(dDatDo)
endif

return cFilter



// ------------------------------------------------
// setovanje filtera prema uslovima
// ------------------------------------------------
static function set_f_kol(cFilter)
select docs
set order to tag "1"
set filter to &cFilter
set relation to cust_id into customs
go top

return



// ---------------------------------------------
// pregled - key handler
// ---------------------------------------------
static function k_handler(nStatus)
local nBr_nal
local cNal_real
local cTblFilt
local cLOG_opis
	
if ( nStatus == 2 )
	if ( UPPER(CHR(Ch)) $ "ZP")
		return DE_CONT
	endif
endif
	
do case
	// stampa naloga
	case (Ch == K_CTRL_P)
		/*
		if Pitanje(, "Stampati nalog (D/N) ?", "D") == "D"
			nBr_nal := rnal->br_nal
			nTRec := RecNo()
			cTblFilt := DBFilter()
			set filter to
			st_nalpr( .f., nBr_nal )
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			return DE_REFRESH
		endif
		SELECT RNAL
		*/
		return DE_CONT
	// stampa otpremnice
	case ( Ch == K_CTRL_O )
		/*
		if Pitanje(,"Stampati otpremicu (D/N ?)", "D") == "D"
			nBr_nal := rnal->br_nal
			nTRec := RecNo()
			cTblFilt := DBFilter()
			set filter to
			st_otpremnica(.f., nBr_nal)
			SELECT RNAL
			set_f_kol(cTblFilt)
			GO (nTRec)
			return DE_REFRESH
		endif
		SELECT RNAL
		*/
		RETURN DE_CONT
		
	// otvaranje naloga za doradu
	case (UPPER(CHR(Ch)) == "D")
		// provjeri marker
		if is_doc_busy()
			// vec neko radi povrat
			MsgBeep("Nalog vec doradjuje drugi operater!#Dorada naloga onemogucena!")
			SELECT docs
			return DE_CONT
		endif
		
		if Pitanje(, "Otvoriti nalog radi dorade (D/N) ?", "N") == "D"
			
			nTRec := RecNo()
			nDoc_no := docs->doc_no
			cTblFilt := DBFilter()
			set filter to
			
			if doc_2__doc( nDoc_no ) == 1
				
				// logiraj otvaranje
				//log_otvori( nBr_nal )
				
				MsgBeep("Nalog otvoren!")
				
			endif
			
			SELECT DOCS
			set_f_kol(cTblFilt)
			GO (nTRec)
			
			// otvori i obradi pripremu
			ed_document( .f. )
			
			SELECT DOCS
			set_f_kol(cTblFilt)
			//GO (nTRec)
			
			RETURN DE_REFRESH
		endif
		
		SELECT DOCS
		RETURN DE_CONT

	// zatvaranje naloga
	case (UPPER(CHR(Ch)) == "Z")
		
		if is_doc_busy()
			MsgBeep("Neko doradjuje ovaj nalog! #Zatvaranje onemoguceno!")
			select DOCS
			return DE_CONT
		endif
			
		if Pitanje(, "Zatvoriti nalog (D/N) ?", "N") == "D"
					
			//g_doc_status(@cNal_real)
			
			nTRec := RecNo()
			nDoc_no := docs->doc_no
			cTblFilt := DBFilter()
			
			set filter to
			
			//if z_rnal(nBr_nal, cNal_real) == 1
			//	MsgBeep("Nalog zatvoren !")
			//endif
			
			SELECT DOCS
			set_f_kol(cTblFilt)
			
			//GO (nTRec)
			
			RETURN DE_REFRESH
		endif
		
		SELECT DOCS
		RETURN DE_CONT
	
	// lista promjena na nalogu
	case (UPPER(CHR(Ch)) == "L")
		
		nDoc_no := docs->doc_no
		
		//frm_lst_rnlog(nDoc_no)
		
		RETURN DE_CONT

	// promjene na nalogu
	case (UPPER(CHR(Ch)) == "P" )
		
		if is_doc_busy()
			MsgBeep("Neko vec doradjuje ovaj nalog!#Promjene onemogucene!")
			select docs
			return DE_CONT
		endif
		
		nDoc_no := docs->doc_no
		
		m_changes(nDoc_no)
		
		select docs
		
		return DE_REFRESH

endcase

return DE_CONT


// ------------------------------------------------
// setuj status naloga realizovan, ponisten
// ------------------------------------------------
static function g_nal_status(cNalStatus)
cNalStatus := "R"
Beep(2)
Box(,4, 50)
	@ m_x + 1, m_y + 2 SAY "Trenutni status naloga je:"
	@ m_x + 2, m_y + 2 SAY "   - realizovan (R)"
	@ m_x + 3, m_y + 2 SAY "   -   ponisten (X)"
	@ m_x + 4, m_y + 2 SAY "postavi trenutni status na:" GET cNalStatus VALID cNalStatus $ "RX" PICT "@!"
	read
BoxC()

return


// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol, nStatus)
aImeKol := {}

AADD(aImeKol, {PADC("Dok.br",10), {|| doc_no }, "doc_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Narucioc", {|| PADR(g_cust_desc(cust_id), 30) }, "cust_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Datum", {|| doc_date }, "doc_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp." , {|| doc_dvr_date }, "doc_dvr_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp." , {|| doc_dvr_time }, "doc_dvr_time", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kontakt" , {|| PADR(g_cont_desc(cont_id), 20) }, "cont_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Prioritet" , {|| PADR(doc_priority,10) }, "doc_priority", {|| .t.}, {|| .t.} })

aKol:={}

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return





