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

o_tables( .f. )

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
cLine2 += PADR("<K> Lista kontakata", nOptLen)
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
local nCustomer := VAL(STR(0, 10))
local nContact := VAL(STR(0, 10))
local cTblList := "D"
local cShowRejected := "N"
local nRet := 1
local cFilter

Box( ,10, 70)
	
@ m_x + nX, m_y + 2 SAY "Datum od " GET dDateFrom
@ m_x + nX, col() + 2 SAY "do" GET dDateTo

nX += 2

@ m_x + nX, m_y + 2 SAY "Narucioc (prazno-svi) " GET nCustomer VALID {|| nCustomer == 0 .or. s_customers( @nCustomer), show_it( g_cust_desc(nCustomer) ) }

nX += 1

@ m_x + nX, m_y + 2 SAY "Kontakt (prazno-svi) " GET nContact VALID {|| nContact == 0 .or. s_contacts( @nContact ), show_it( g_cont_desc( nContact ) ) }

nX += 2

@ m_x + nX, m_y + 2 SAY "Tabelarni pregled (D/N) " GET cTblList VALID cTblList $ "DN" PICT "@!"

if _status == 2

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Prikaz i ponistenih dokumenata (D/N) " GET cShowRejected VALID cShowRejected $ "DN" PICT "@!"

endif

read

BoxC()

if cTblList == "N"
	nRet := 2
endif

ESC_RETURN 0

cFilter := gen_filter(dDateFrom, ;
			dDateTo, ;
			nCustomer, ;
			nContact, ;
			cShowRejected )

set_f_kol(cFilter)

return nRet



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter( dDateFrom, dDateTo, ;
			nCustomer, nContact, cShReject )
local nClosed := 1
local cFilter := ""

if _status == 1
	// samo otvoreni nalozi
	cFilter += "doc_status == 3 .or. doc_status == 0"
else
	// samo zatvoreni nalozi
	cFilter += "doc_status == 1"
	
	// prikazi i ponistene
	if cShReject == "D"
		cFilter += " .or. doc_status == 2"
	endif
	
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

if nContact <> 0
	cFilter += " .and. cont_id == " + contid_str(nContact)
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
local cTmpFilter := DBFILTER()

if ( _status == 2 )
	if ( UPPER(CHR(Ch)) $ "ZP" )
		return DE_CONT
	endif
endif
	
do case
	// stampa naloga
	case (Ch == K_CTRL_P)
		
		if Pitanje(, "Stampati nalog (D/N) ?", "D") == "D"
			
			nDoc_no := docs->doc_no
			nTRec := RecNo()
			
			set filter to
			
			st_nalpr( .f., nDoc_no )
			
			select docs
			
			set_f_kol( cTmpFilter )
			
			go (nTRec)
			
			return DE_REFRESH
		endif
		
		select docs
		return DE_CONT
	
	// pregled kontakata.... naloga
	case ( UPPER(CHR(Ch)) == "K" )
		
		select docs 
		
		doc_cont_view( docs->doc_no )
		
		select docs
		
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
			
			nTRec := RecNo()
			nDoc_no := docs->doc_no
			
			if doc_2__doc( nDoc_no ) == 1
				
				MsgBeep("Nalog otvoren!#Prelazim u pripremu##Pritisni nesto za nastavak...")
				
			endif
			
			select docs
			go (nTRec)
			
			// otvori i obradi pripremu
			ed_document( .f. )
			
			select docs
			set_f_kol(cTmpFilter)
			
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
			if _g_doc_status( @nDoc_status, @cDesc ) == 1
				
				nTRec := RecNo()
				nDoc_no := docs->doc_no
			
				set_doc_marker( nDoc_no, nDoc_status )
				
				// logiraj zatvaranje...
				log_closed( nDoc_no, cDesc, nDoc_status )
				
				MsgBeep("Nalog zatvoren !!!")
			
				select doks
				set_f_kol(cTmpFilter)
				select docs
				
				return DE_REFRESH
				
			else
			
				MsgBeep("Setovanje statusa obavezno !!!")
				select docs
				return DE_CONT
				
			endif
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
		
		nTRec := RECNO()
		
		if is_doc_busy()
			
			msg_busy_doc()
			select docs
			return DE_CONT
			
		endif
		
		nDoc_no := docs->doc_no
		
		m_changes( nDoc_no )
		
		if LastKey() == K_ESC
			Ch := 0
		endif
	
		select docs
		go (nTRec)
		
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

Box(, 8, 60)
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

ESC_RETURN 0

return 1


// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol, nStatus)
aImeKol := {}

AADD(aImeKol, {PADC("Dok.br",10), {|| doc_no }, "doc_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Narucioc", {|| _reject_info( doc_status ) + PADR(g_cust_desc(cust_id), 30) }, "cust_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Datum", {|| doc_date }, "doc_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp." , {|| doc_dvr_date }, "doc_dvr_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp." , {|| doc_dvr_time }, "doc_dvr_time", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Kontakt" , {|| PADR(g_cont_desc(cont_id), 20) }, "cont_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Prioritet" , {|| PADR( s_priority(doc_priority) ,10) }, "doc_priority", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.plac" , {|| PADR( s_pay_id(doc_pay_id) ,10) }, "doc_pay_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Plac." , {|| PADR( doc_paid , 4) }, "doc_paid", {|| .t.}, {|| .t.} })

aKol:={}

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// daje info o statusu naloga
// ---------------------------------------------
static function _reject_info( doc_status )
local xRet := ""
if doc_status == 2
	xRet := "(R) "
endif
return xRet


// -----------------------------------------
// daje listu kontakata naloga
// -----------------------------------------
function doc_cont_view( nDoc_no )
local aCont := {}

if _get_doc_contacts( @aCont, nDoc_no ) > 0
	show_c_list( aCont )
else
	MsgBeep("Dokument nema kontakata !!!")
endif

return


// ----------------------------------------------
// puni matricu aArr sa listom kontakata...
// ----------------------------------------------
static function _get_doc_contacts( aArr, nDoc_no )
local nC_count := 0
local nTArea := SELECT()
local cLogType := PADR("12", 3)
local nSrch := 0
local nCont_id := 0

select doc_log
set order to tag "2"
go top

seek docno_str(nDoc_no) + cLogType

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_type == cLogType

	nDoc_log_no := field->doc_log_no
	
	select doc_lit
	set order to tag "1"
	go top
	seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->doc_log_no == nDoc_log_no
			
			if field->int_1 <> 0
				
				nCont_id := field->int_1
				
				nSrch := ASCAN(aArr, {|xVal| xVal[1] == nCont_id })
				if nSrch == 0
					
					AADD(aArr, { field->int_1, g_cont_desc(field->int_1), g_cont_tel(field->int_1) })
				
					++ nC_count
				endif
			endif
		
		skip
	enddo

	select doc_log
	skip
	
enddo

select (nTArea)
return nC_count

// ----------------------------------------------
// prikazuje listu kontakata u box-u
// ----------------------------------------------
static function show_c_list( aArr )
local nX := m_x
local nY := m_y
local nBoxX := LEN(aArr) + 2
local nBoxY := 70
local i
local cGet := " "
local lShow := .t.

if LEN(aArr) == 0
	return .f.
endif

do while lShow == .t.

	Box( , nBoxX, nBoxY ) 
		
		for i:=1 to LEN(aArr)
			
			@ m_x + i, m_y + 2 SAY "(" + ALLTRIM(STR(aArr[i, 1])) + ")"
			@ m_x + i, col() + 1 SAY ", " + ALLTRIM(aArr[i, 2])
			
			@ m_x + i, col() + 1 SAY ", " + ALLTRIM(aArr[i, 3])
			
			
		next	
		
		@ m_x + LEN(aArr) + 1 , m_y + 2 GET cGet
		
		read
		
		
	BoxC()
	
	if LastKey() == K_ENTER .or. LastKey() == K_ESC
		lShow := .f.
	endif

enddo

m_x := nX
m_y := nY

return .t.


