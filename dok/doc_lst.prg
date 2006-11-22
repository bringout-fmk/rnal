#include "\dev\fmk\rnal\rnal.ch"


// variables
static _status


// ------------------------------------------
// lista dokumenata....
//  nStatus - "1" otoreni ili "2" zatvoreni
// ------------------------------------------
function frm_lst_docs( nStatus )
local nTblRet

_status := nStatus

o_tables(.f.)

nTblRet := tbl_list()

if nTblRet == 1
	return
elseif nTblRet == 2
	MsgBeep("report: lista naloga...")
endif

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_list()
local cFooter
local nLstRet

nLstRet := lst_args()

if nLstRet == 2
	return 2
elseif nLstRet == 0
	return 0
endif

private ImeKol
private Kol

cFooter := "Pregled azuriranih naloga..."

Box(, 20, 77)

_set_box()

select docs
set order to tag "1"
go top

set_a_kol(@ImeKol, @Kol)

ObjDbedit("lstnal", 20, 77, {|| key_handler() }, "", cFooter, , , , , 2)

BoxC()

close all
return 1



// ------------------------------------------
// setovanje boxa
// ------------------------------------------
static function _set_box()
local cLine1 := ""
local cLine2 := ""
local nOptLen := 24
local cOptSep := "| "

cLine1 := PADR("<D> Dorada naloga", nOptLen)
cLine1 += cOptSep

if ( _status == 1 )
	cLine1 += PADR("<Z> Zatvori nalog", nOptLen)
	cLine1 += cOptSep
	cLine1 += PADR("<P> Promjene", nOptLen)
endif

// druga linija je zajednicka
cLine2 := PADR("<c-P> Stampa naloga", nOptLen)
cLine2 += cOptSep
cLine2 += PADR("<c-O> Stampa otpremnice", nOptLen)
cLine2 += cOptSep
cLine2 += PADR("<L> Lista promjena", nOptLen)

@ m_x + 19, m_y + 2 SAY cLine1
@ m_x + 20, m_y + 2 SAY cLine2

return



// -------------------------------------------------
// otvori formu sa uslovima te postavi filtere
// -------------------------------------------------
static function lst_args()
local nX := 2
local dDateFrom := CToD("")
local dDateTo := DATE()
local nCustomer := VAL(STR(0,10))
local cTblList := "D"
local nRet := 1
local cFilter

Box( ,10, 70)
	
@ m_x + nX, m_y + 2 SAY "Datum od " GET dDateFrom
@ m_x + nX, col() + 2 SAY "do" GET dDateTo

nX += 2

@ m_x + nX, m_y + 2 SAY "Narucioc (prazno-svi) " GET nCustomer VALID {|| s_customers( @nCustomer), show_it( g_cust_desc(nCustomer) ) }

nX += 2

@ m_x + nX, m_y + 2 SAY "Tabelarni pregled (D/N) " GET cTblList VALID cTblList $ "DN" PICT "@!"

read

BoxC()

if cTblList == "N"
	nRet := 2
endif

ESC_RETURN 0

cFilter := gen_filter(dDateFrom, dDateTo, nCustomer)

set_f_kol(cFilter)

return nRet



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter(dDateFrom, dDateTo, nCustomer)
local nClosed := 1
local cFilter := ""

if _status == 1
	// samo otvoreni nalozi
	cFilter += "doc_status == 3 .or. doc_status == 0"
else
	// samo zatvoreni nalozi
	cFilter += "doc_status == 1 .or. doc_status == 2"
endif

if !EMPTY(dDateFrom)
	cFilter += " .and. doc_date >= " + Cm2Str(dDateFrom)
endif

if !Empty(dDateTo)
	cFilter += " .and. doc_date <= " + Cm2Str(dDateTo)
endif

if nCustomer <> 0
	cFilter += " .and. cust_id == " + custid_str(nCustomer)
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
static function key_handler()
local nDoc_no
local nDoc_status
local cDesc
local cTmpFilter

if ( _status == 2 )
	if ( UPPER(CHR(Ch)) $ "ZP" )
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
		
		// provjeri da li je zauzet
		if is_doc_busy()
			
			msg_busy_doc()
			select docs
			return DE_CONT
			
		endif
		
		if Pitanje(, "Otvoriti nalog radi dorade (D/N) ?", "N") == "D"
			
			cTmpFilter := DBFilter()
			nTRec := RecNo()
			nDoc_no := docs->doc_no
			
			if doc_2__doc( nDoc_no ) == 1
				
				// logiraj otvaranje
				//log_otvori( nBr_nal )
				
				MsgBeep("Nalog otvoren!#Prelazim u pripremu...")
				
			endif
			
			select docs
			go (nTRec)
			
			// otvori i obradi pripremu
			ed_document( .f. )
			
			select docs
			set_f_kol(cTmpFilter)
			
			go (nTRec)
			
			return DE_REFRESH
		endif
		
		select docs
		return DE_CONT

	// zatvaranje naloga
	case (UPPER(CHR(Ch)) == "Z")
		
		// provjeri da li je zauzet
		if is_doc_busy()
			
			msg_busy_doc()
			select docs
			return DE_CONT
			
		endif
			
		if Pitanje(, "Zatvoriti nalog (D/N) ?", "N") == "D"
					
			// uzmi status naloga
			_g_doc_status( @nDoc_status, @cDesc )
			
			nTRec := RecNo()
			nDoc_no := docs->doc_no
			
			set_doc_marker( nDoc_no, 1 )
			MsgBeep("Nalog zatvoren !!!")
			
			select docs
			
			return DE_REFRESH
			
		endif
		
		select docs
		return DE_CONT
	
	// lista promjena na nalogu
	case (UPPER(CHR(Ch)) == "L")
		
		nDoc_no := docs->doc_no
		
		frm_lst_log( nDoc_no )
		
		return DE_CONT

	// promjene na nalogu
	case (UPPER(CHR(Ch)) == "P" )
		
		if is_doc_busy()
			
			msg_busy_doc()
			select docs
			return DE_CONT
			
		endif
		
		nDoc_no := docs->doc_no
		
		m_changes( nDoc_no )
		
		select docs
		
		return DE_REFRESH

endcase

return DE_CONT


// -----------------------------------
// info dokument zauzet
// -----------------------------------
static function msg_busy_doc()
MsgBeep("Dokument je zauzet#Operacije onemogucene !!!")
return


// ------------------------------------------------
// setuj status naloga realizovan, ponisten, opis
// ------------------------------------------------
static function _g_doc_status(nDoc_status, cDesc)
local cStat := "R"
local nX := 1

Beep(2)

Box(,4, 50)
	cDesc := SPACE(150)
	
	@ m_x + nX, m_y + 2 SAY "Trenutni status naloga je:"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "   - realizovan (R)"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "   -   ponisten (X)"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "postavi trenutni status na:" GET cStat VALID cStat $ "RX" PICT "@!"
	
	read
	
	nX += 2
	
	if cStat == "X"
		@ m_x + nX, m_y + 2 SAY "Opis:" GET cDesc VALID !EMPTY(cDesc) PICT "@S40"
	endif
	
	read
BoxC()

if cStat == "R"
	// closed
	nDoc_status := 1
endif
if cStat == "X"
	// rejected
	nDoc_status := 2
endif


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





