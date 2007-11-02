#include "\dev\fmk\rnal\rnal.ch"

// variables
static _status
static __sort
static __filter

// ------------------------------------------
// lista dokumenata....
//  nStatus - "1" otoreni ili "2" zatvoreni
// ------------------------------------------
function frm_lst_docs( nStatus )

_status := nStatus

o_tables( .f. )

tbl_list()

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_list()
local cFooter
local cHeader
local nSort := 3
local nBoxX := 22
local nBoxY := 77

if lst_args( @nSort ) == 0
	
	return 0
	
endif

private ImeKol
private Kol

cFooter := "Pregled azuriranih naloga..."
cHeader := ""

Box(, nBoxX, nBoxY)

// setuj box opis...
_set_box( nBoxX, nBoxY )

// setuj sort...
_set_sort()

go top

set_a_kol(@ImeKol, @Kol)

ObjDbedit("lstnal", nBoxX, nBoxY, {|| key_handler() }, cHeader, cFooter, , , , , 4)

BoxC()

close all

return 1



// ---------------------------------------------------
// setovanje sorta prema static varijabli __sort
// ---------------------------------------------------
static function _set_sort()
local cSort

cSort := ALLTRIM(STR( __sort ))

select docs
set order to tag &cSort

return



// ------------------------------------------
// setovanje boxa
// nBoxX - box x koord.
// nBoxY - box y koord.
// ------------------------------------------
static function _set_box( nBoxX, nBoxY )
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

@ m_x + (nBoxX-1), m_y + 2 SAY cLine1
@ m_x + (nBoxX), m_y + 2 SAY cLine2

return



// -------------------------------------------------
// otvori formu sa uslovima te postavi filtere
// nSort - sort prikaza...
// -------------------------------------------------
static function lst_args( nSort )
local nX := 1
local nBoxX := 21
local nBoxY := 70
local dDateFrom := CToD("")
local dDateTo := DATE()
local dDvrDFrom := CTOD("")
local dDvrDTo := CTOD("")
local cCustomer := PADR("", 10)
local nCustomer := VAL(STR(0, 10))
local cContact := PADR("", 10)
local nContact := VAL(STR(0, 10))
local nOperater := VAL(STR(0, 3))
local cOperater := PADR("", 3)
local cShowRejected := "N"
local nRet := 1
local cFilter
// color header
local cColor1 := "BG+/B"
// color help
local cHelpClr := "GR+/B"

// parametri - iscitaj 
private cSection:="L"
private cHistory:=" "
private aHistory:={}
O_PARAMS

RPar("d1", @dDateFrom)
RPar("d2", @dDateTo)
RPar("d3", @dDvrDFrom)
RPar("d4", @dDvrDTo)
RPar("c1", @cCustomer)
RPar("c2", @cContact)
RPar("o1", @nOperater)
RPar("s1", @nSort)
RPar("s2", @cShowRejected)

Box( , nBoxX, nBoxY)

@ m_x + nX, m_y + 1 SAY PADL("**** uslovi pregleda dokumenata", nBoxY - 2 ) COLOR cColor1

nX += 2

@ m_x + nX, m_y + 2 SAY PADL( "Narucioc (prazno-svi):", 25 ) GET cCustomer VALID {|| EMPTY(cCustomer) .or. s_customers( @cCustomer, cCustomer), set_var(@nCustomer, @cCustomer),  show_it( g_cust_desc(nCustomer) ) } WHEN set_opc_box(nBoxX, 60, "narucioc naloga, pretrazi sifrarnik", nil, nil, cHelpClr )

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Kontakt (prazno-svi):", 25) GET cContact VALID {|| EMPTY(cContact) .or. s_contacts( @cContact, nCustomer, cContact ), set_var(@nContact, @cContact), show_it( g_cont_desc( nContact ) ) } WHEN set_opc_box( nBoxX, 60, "kontakt osoba naloga, pretrazi sifrarnik", nil, nil, cHelpClr )

nX += 2

@ m_x + nX, m_y + 2 SAY PADL( "Datum naloga od:", 18) GET dDateFrom WHEN set_opc_box( nBoxX, 60 )
@ m_x + nX, col() + 1 SAY "do:" GET dDateTo WHEN set_opc_box( nBoxX, 60 )

if _status == 1
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY PADL( "Datum isporuke od:", 18 ) GET dDvrDFrom WHEN set_opc_box( nBoxX, 60 )
	@ m_x + nX, col() + 1 SAY "do:" GET dDvrDTo WHEN set_opc_box( nBoxX, 60 )

endif

nX += 2

@ m_x + nX, m_y + 2 SAY "Operater (prazno-svi):" GET nOperater VALID {|| nOperater == 0 .or. p_users(@nOperater), show_it( getusername( nOperater ), 20 ) } WHEN set_opc_box( nBoxX, 60, "pretraga po operateru", "99 - otvori sifrarnik", nil, cHelpClr )

nX += 2

@ m_x + nX, m_y + 2 SAY "***** sort pregleda:" GET nSort VALID _val_sort( nSort ) PICT "9" WHEN set_opc_box( nBoxX, 60, "nacin sortiranja pregleda dokumenata", nil, nil, cHelpClr )

nX += 1

@ m_x + nX, m_y + 2 SAY " * (1) broj dokumenta" COLOR cColor1

nX += 1

@ m_x + nX, m_y + 2 SAY " * (2) prioritet + datum dokumenta + broj dokumenta" COLOR cColor1

nX += 1

@ m_x + nX, m_y + 2 SAY " * (3) prioritet + datum isporuke + broj dokumenta" COLOR cColor1

//nX += 1
//@ m_x + nX, m_y + 2 SAY " * (4) ..." COLOR cColor1

if _status == 2

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Prikaz ponistenih dokumenata (D/N)?" GET cShowRejected VALID cShowRejected $ "DN" PICT "@!" WHEN set_opc_box( nBoxX, 60, "pored zatvorenih naloga", "prikazi i ponistene", nil, cHelpClr )

endif

read

BoxC()

__sort := nSort

if LastKey() == K_ESC
	return 0
endif

// parametri - snimi
private cSection:="L"
private cHistory:=" "
private aHistory:={}
O_PARAMS

WPar("d1", dDateFrom)
WPar("d2", dDateTo)
WPar("d3", dDvrDFrom)
WPar("d4", dDvrDTo)
WPar("c1", cCustomer)
WPar("c2", cContact)
WPar("o1", nOperater)
WPar("s1", nSort)
WPar("s2", cShowRejected)

// generisi filter
cFilter := gen_filter(dDateFrom, ;
			dDateTo, ;
			dDvrDFrom, ;
			dDvrDTo, ;
			nCustomer, ;
			nContact, ;
			nOperater, ;
			cShowRejected )


__filter := cFilter

// setuj filter
set_f_kol(cFilter)

return nRet



// ------------------------------------------
// validacija unosa sorta...
// ------------------------------------------
static function _val_sort( nSort )
if nSort >= 1 .and. nSort <= 3
	return .t.
endif
MsgBeep("Sort je u rangu od 1 do 3 !!!")
return .f.



// ---------------------------------
// generise string filtera
// ---------------------------------
static function gen_filter( dDateFrom, dDateTo, dDvrDFrom, dDvrDTo, ;
			nCustomer, nContact, nOper, cShReject )
local nClosed := 1
local cFilter := ""

if _status == 1
	// samo otvoreni nalozi
	cFilter += "(doc_status == 0 .or. doc_status > 2)"
else
	// samo zatvoreni nalozi
	cFilter += "doc_status == 1"
	
	// prikazi i ponistene
	if cShReject == "D"
		cFilter := "( " + cFilter +  " .or. doc_status == 2 )"
	endif
	
endif

if !EMPTY(dDateFrom)
	cFilter += " .and. DTOS(doc_date) >= " + Cm2Str( DTOS(dDateFrom) )
endif

if !Empty(dDateTo)
	cFilter += " .and. DTOS(doc_date) <= " + Cm2Str( DTOS(dDateTo) )
endif

if !EMPTY(dDvrDFrom)
	cFilter += " .and. DTOS(doc_dvr_da) >= " + Cm2Str( DTOS(dDvrDFrom) )
endif

if !Empty(dDvrDTo)
	cFilter += " .and. DTOS(doc_dvr_da) <= " + Cm2Str( DTOS(dDvrDTo) )
endif

if nCustomer <> 0
	cFilter += " .and. cust_id == " + custid_str(nCustomer)
endif

if nContact <> 0
	cFilter += " .and. cont_id == " + contid_str(nContact)
endif

if nOper <> 0
	cFilter += " .and. operater_id == " + str( nOper, 3 )
endif

return cFilter



// ------------------------------------------------
// setovanje filtera prema uslovima
// ------------------------------------------------
static function set_f_kol(cFilter)

_set_sort()
set filter to &cFilter
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

if _status == 1

	if doc_status == 5
		// daj info o isporuci, ako je realizovan
		// TODO: uzeti datum zatvaranja iz LOG-a ili ???
		_sh_dvr_info( 0 )
	else
	
		// daj info o kasnjenju
		_sh_dvr_warr( _chk_date( doc_dvr_date ), ;
			_chk_time( doc_dvr_time ) )
	endif		
endif

// prikazi status dokumenta na pregledu
_sh_doc_status( doc_status )

// prikazi u dnu ostale informacije o nalogu...
_sh_doc_info( )

// ove opcije zabrani na statusu 2
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
	
	// stampa naloga
	case (Ch == K_CTRL_O)
		
		if Pitanje(, "Stampati obracunski list (D/N) ?", "D") == "D"
			
			nDoc_no := docs->doc_no
			nTRec := RecNo()
			
			set filter to
			
			st_obr_list( .f., nDoc_no )
			
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
		
		// provjeri ima li pravo pristupa...
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "DORADA")
			
			MsgBeep( cZabrana )
			
			select docs
			return DE_CONT
			
		endif
		
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

	// quick search......
	case (UPPER(CHR(Ch)) == "Q")

		// ima li pravo pristupa...
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "QUICKSEARCH")
			
			MsgBeep( cZabrana )

			select docs
			return DE_CONT
			
		endif
	
		// filter za quick search
		cFilt := _quick_srch_( )
		
		if !EMPTY( cFilt )
			cFilt := __filter + cFilt
			select docs
			set_f_kol( cFilt )
			select docs
			return DE_REFRESH
		else
			return DE_CONT
		endif

	// zatvaranje naloga
	case (UPPER(CHR(Ch)) == "Z")
		
		// ima li pravo pristupa...
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "ZATVORI")
			
			MsgBeep( cZabrana )

			select docs
			return DE_CONT
			
		endif
		
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
			
				select docs
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
	
	// fix - procedura ispravke statusa naloga
	case (UPPER(CHR(Ch)) == "F")
		
		// ima li pravo pristupa
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "FIXSTATUS")
			
			MsgBeep( cZabrana )
			select docs
			return DE_CONT
			
		endif
		
		if Pitanje(,"Resetovati status dokumenta (D/N) ?", "N") == "N"
			return DE_CONT
		endif
		
		if !SigmaSif("FIXSTAT")
			return DE_CONT
		endif
		
		nDoc_no := docs->doc_no
		nTRec := RECNO()
		set filter to
		
		set_doc_marker( nDoc_no, 0 )
		
		set_f_kol( cTmpFilter )
		
		go (nTRec)
		
		return DE_CONT

	// lista promjena na nalogu
	case (UPPER(CHR(Ch)) == "L")
		
		// ima li pravo pristupa
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "LOGVIEW")
			
			MsgBeep( cZabrana )
			select docs
			return DE_CONT
			
		endif
	
		nDoc_no := docs->doc_no
		
		frm_lst_log( nDoc_no )
		
		return DE_CONT

	case UPPER(CHR(Ch)) == "E"

		nRec := RECNO()
		
		nDoc_no := docs->doc_no
		
		// export dokumenta
		m_export( nDoc_no, .f., .t. )
		
		go (nRec)
		
		return DE_REFRESH

	// promjene na nalogu
	case (UPPER(CHR(Ch)) == "P" )
		
		// ima li pravo pristupa...
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "PROMJENE")
			
			MsgBeep( cZabrana )
			
			select docs
			return DE_CONT
			
		endif
		
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

// ------------------------------------------
// box:: quick search
// ------------------------------------------
static function _quick_srch_()
local GetList := {}
local nX := 1
local cDesc := SPACE(150)

Box(, 5, 70, .t.)
	
	@ m_x + nX, m_y + 2 SAY "Brza pretraga naloga *******"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Unesi kratki opis naloga:" GET cDesc PICT "@S40" VALID !EMPTY( cDesc )
	
	@ m_x + nX, col() SAY ">" COLOR "I"
	
	read
BoxC()

if LastKey() == K_ESC
	xRet := ""
else
	// formiram filter
	xRet := " .and. "
	xRet += " ( " 
	xRet += cm2str(UPPER(ALLTRIM(cDesc))) 
	xRet += " $ UPPER(doc_sh_desc) " 
	xRet += " .or. " 
	xRet += cm2str(UPPER(ALLTRIM(cDesc))) 
	xRet += " $ UPPER(doc_desc) " 
	xRet += " ) " 
endif

return xRet



// -----------------------------------
// info dokument zauzet
// -----------------------------------
static function msg_busy_doc()
MsgBeep("Dokument je zauzet#Operacije onemogucene !!!")
return



// ------------------------------------------------
// setuj status naloga realizovan, ponisten, opis
// ------------------------------------------------
static function _g_doc_status( nDoc_status, cDesc )
local cStat := "R"
local nX := 1
local nBoxX := 11
local nBoxY := 60
local cColor := "BG+/B"

Beep(2)

Box(, nBoxX, nBoxY)

	cDesc := SPACE(150)
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY " **** Trenutni status naloga je:" COLOR cColor
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY SPACE(3) + "(R) realizovan" COLOR cColor
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY SPACE(3) + "(N) realizovan, nije isporucen" COLOR cColor
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY SPACE(3) + "(D) djelimicno realizovan" COLOR cColor
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY SPACE(3) + "(X) ponisten" COLOR cColor
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "postavi status na -------->" GET cStat VALID cStat $ "RXDN" PICT "@!"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Opis:" GET cDesc VALID !EMPTY(cDesc) PICT "@S50"
	
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

if cStat == "D"
	// partialy done
	nDoc_status := 4
endif

if cStat == "N"
	// closed but not delivered
	nDoc_status := 5
endif


ESC_RETURN 0

return 1




// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol, nStatus)
aImeKol := {}

AADD(aImeKol, {"Narucioc / kontakt", {|| PADR(g_cust_desc(cust_id), 20) + "/" + PADR(g_cont_desc(cont_id), 15) }, "cust_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Datum", {|| doc_date }, "doc_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Dat.isp." , {|| doc_dvr_date }, "doc_dvr_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.isp." , {|| doc_dvr_time }, "doc_dvr_time", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADC("Dok.br",10), {|| doc_no }, "doc_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Prioritet" , {|| PADR( s_priority(doc_priority) ,10) }, "doc_priority", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Vr.plac" , {|| PADR( s_pay_id(doc_pay_id) ,10) }, "doc_pay_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Plac." , {|| PADR( doc_paid , 4) }, "doc_paid", {|| .t.}, {|| .t.} })

aKol:={}

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ----------------------------------------
// provjeri datum isporuke...
// ----------------------------------------
static function _chk_date( dD_dvr_date )
local nDays := 0
nDays := DATE() - dD_dvr_date
return nDays


// ----------------------------------------
// provjeri vrijeme isporuke...
// ----------------------------------------
static function _chk_time( cDvr_time )
local nMinutes := 0
return nMinutes


// ------------------------------------------
// prikazi upozorenje za istek roka
// nDays - dana kasnjenja
// ------------------------------------------
static function _sh_dvr_warr( nDays, nMinutes, nX, nLen )
local cColWarr := "W/R+"
local cColOk := "GR+/B"
local cColor
local cTmp

if nX == nil
	nX := 2
endif

if nLen == nil
	nLen := 20 
endif

if nDays > 0
	cTmp := " van roka " + ALLTRIM(STR(nDays)) + " dana"
	cColor := cColWarr
else
	cTmp := " u roku"
	cColor := cColOk
endif

@ nX, m_y + 1 SAY PADR(cTmp, nLen) COLOR cColor

return



// ------------------------------------------
// prikazi info koliko dana nije preuzeta roba
// nDays - dana kasnjenja
// ------------------------------------------
static function _sh_dvr_info( nDays, nX, nLen )
local cColOk := "GR+/B"
local cColor
local cTmp := ""

if nX == nil
	nX := 2
endif

if nLen == nil
	nLen := 20 
endif

if nDays > 0
	cTmp := ALLTRIM(STR(nDays)) + " dana"
	cColor := cColOk
endif

@ nX, m_y + 1 SAY PADR(cTmp, nLen) COLOR cColor

return



// ----------------------------------------------------
// prikaz statusa dokumenta na pregledu
// ----------------------------------------------------
static function _sh_doc_status( doc_status, nX, nY )
local cTmp

if nX == nil
	nX := 2
endif

if nY == nil
	nY := 21
endif

do case

	case doc_status == 0
		
		cTmp := " otvoren"
		cColor := "GR+/B"
		
	case doc_status == 1
		
		cTmp := " realizovan"
		cColor := "GB+/B"
		
	case doc_status == 2
		
		cTmp := " ponisten"
		cColor := "W/R+"
		
	case doc_status == 3
		
		cTmp := " zauzet"
		cColor := "GR+/G+"
		
	case doc_status == 4
		
		cTmp := " realizovan dio"
		cColor := "W/G+"
		
	case doc_status == 5
		
		cTmp := "real.nije isporucen"
		cColor := "W/G+"
endcase

@ nX, nY SAY PADR( cTmp , 20 ) COLOR cColor

return


// ------------------------------------------------
// prikaz ostalih informacija o dokumentu
// ------------------------------------------------
static function _sh_doc_info( nX, nY )
local cTmp
local aTmp
local nTxtLen := 77
local cColor := "GR+/B"

if nX == nil
	nX := 19
endif

if nY == nil
	nY := 1
endif

// napuni string sa opisom
cTmp := ""
cTmp += ALLTRIM(doc_sh_desc) 
if !EMPTY(cTmp)
	cTmp += ", "
endif
cTmp += ALLTRIM(doc_desc)

// pretvori string u matricu....
aTmp := SjeciStr( cTmp, nTxtLen )

// pocisti postojece linije
@ nX + 1, nY SAY SPACE( nTxtLen ) COLOR cColor
@ nX + 2, nY SAY SPACE( nTxtLen ) COLOR cColor

// ispisi info
for i := 1 to LEN( aTmp )
	
	@ nX + i, nY SAY PADR( aTmp[i] , nTxtLen ) COLOR cColor
	
next

return


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
set filter to
select doc_lit
set filter to
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




