#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// procedura azuriranja naloga
// -------------------------------------------

function azur_nalog(cOpis)
local nBr_nal
local cStat

o_rnal(.t.)

// skloni filtere
select p_rnop
set filter to

select p_rnst
set filter to

select p_rnal
set filter to

go top

if RECCOUNT2() == 0
	return 0
endif

nBr_nal := p_rnal->br_nal
cStat := p_rnal->rec_zak

if cStat <> "P" .and. !nalog_exist( nBr_nal )
	MsgBeep("Nalog " + ALLTRIM(STR( nBr_nal )) + " nije moguce azurirati !!!")
	return 0
endif

MsgO("Azuriranje naloga u toku...")
Beep(1)

if cStat == "P"
	// logiraj deltu
	rnal_delta( nBr_nal, cOpis )
	
	// brisi kumulativ
	b_kumulativ( nBr_nal )
endif

// azuriraj maticnu tabelu RNAL
a_rnal( nBr_nal , cStat )
// azuriranje stavki RNST
a_rnst( nBr_nal )
// azuriraj operacije RNOP
a_rnop( nBr_nal )

if cStat <> "P"
	// logiraj promjene
	a_rnlog( nBr_nal, cOpis )
endif

// sve je ok brisi pripremu
select p_rnal
zap
select p_rnop
zap
select p_rnst
zap

use

Beep(1)

o_rnal(.t.)

MsgC()

return 1



// ------------------------------------------
// azuriranje RNAL
// ------------------------------------------
static function a_rnal( nBr_nal , cStat )
local nPTrec
local nKTrec

select p_rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

// ako je bio povrat
if cStat <> "P"
	skip
	nPTrec := RecNo()
	skip -1
	Scatter("z")

	// pronadji
	select rnal
	set order to tag "br_nal_z"
	go top
	seek s_br_nal(nBr_nal) + "Z"
	select rnal
	Scatter()
	_rec_zak := ""
	Gather("z")
	select p_rnal
	go (nPTrec)
endif

do while !eof() .and. ( p_rnal->br_nal == nBr_nal )
	Scatter()
	select rnal
	append blank
	_rec_zak := ""
	Gather()
	select p_rnal
	skip
enddo

return

// ------------------------------------------
// azuriranje RNST
// ------------------------------------------
static function a_rnst( nBr_nal )

select p_rnst

if RECCOUNT2() == 0
	return
endif

set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. ( p_rnst->br_nal == nBr_nal )
	Scatter()
	
	select rnst
	append blank
		
	Gather()
	
	select p_rnst
	skip
enddo

return



// ------------------------------------------
// azuriranje RNOP
// ------------------------------------------
static function a_rnop( nBr_nal )

select p_rnop

if RECCOUNT2() == 0
	return
endif

set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

do while !EOF() .and. ( p_rnop->br_nal == nBr_nal )
	
	if !EMPTY(ALLTRIM(p_rnop->rn_instr))
		
		Scatter()
		
		select rnop
		append blank
		
		Gather()
	endif
	
	select p_rnop
	skip
enddo

return

// -------------------------------------------
// procedura povrata naloga u pripremu
// -------------------------------------------
function pov_nalog( nBr_nal )

o_rnal(.t.)

select rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if !Found()
	MsgBeep("Nalog " + ALLTRIM(STR(nBr_nal)) + " ne postoji !!!")
	select p_rnal
	return 0
endif

select p_rnal

if RECCOUNT2() > 0
	MsgBeep("U pripremi postoji dokument#ne moze se izvrsiti povrat#operacija prekinuta !")
	return 0
endif

MsgO("Vrsim povrat dokumenta u pripremu....")

// setuj realizovano na ""
set_real_marker( nBr_nal, "" )

// povrat maticne tabele RNAL
p_rnal( nBr_nal )

// povrat stavki RNST
p_rnst( nBr_nal )

// povrat operacija RNOP
p_rnop( nBr_nal ) 

// markiraj povrat u RNAL
set_p_marker( nBr_nal, "P" )


select rnal
use

o_rnal(.t.)

MsgC()

return 1

// ----------------------------------------
// markiraj povrat....
// ----------------------------------------
function set_p_marker(nBr_nal, cMark)
local nTArea
nTArea := SELECT()

select rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if FOUND()
	Scatter()
	_rec_zak := cMark
	Gather()
endif

select (nTArea)
return

// ----------------------------------------
// markiraj realizacija marker....
// ----------------------------------------
function set_real_marker(nBr_nal, cMark)
local nTArea
nTArea := SELECT()

select rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if FOUND()
	Scatter()
	_rn_real := cMark
	Gather()
endif

select (nTArea)
return


// ------------------------------------
// vrati marker naloga
// ------------------------------------
function get_p_marker()
local cMark
cMark := field->rec_zak
return cMark



//----------------------------------------------
// povrat RNAL
//----------------------------------------------
static function p_rnal(nBr_nal)
select rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	// dodaj u pripremu dokument
	do while !EOF() .and. (br_nal == nBr_nal)
	
		select rnal
		Scatter()
		
		// ako je rn otvoreni ili zatvoreni, setuj R - razrada
		if _rn_status $ "OZ"
			_rn_status := "R"
		endif
		
		_rec_zak := "P"
		
		select p_rnal
		
		APPEND BLANK
		Gather()
	
		select rnal
		skip
	enddo
endif

return


//----------------------------------------------
// povrat RNST
//----------------------------------------------
static function p_rnst(nBr_nal)
select rnst
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	// dodaj u pripremu dokument
	do while !EOF() .and. (br_nal == nBr_nal)
	
		select rnst
		Scatter()
	
		select p_rnst
		
		APPEND BLANK
		Gather()
	
		select rnst
		skip
	enddo
endif

return



//----------------------------------------------
// povrat RNOP
//----------------------------------------------
static function p_rnop(nBr_nal)

select rnop
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	// dodaj u pripremu dokument
	do while !EOF() .and. (br_nal == nBr_nal)
	
		select rnop
		Scatter()
	
		select p_rnop
		APPEND BLANK
		Gather()
	
		select rnop
		skip
	enddo
endif

return



//----------------------------------------
// brisi nalog iz kumulativa
//----------------------------------------
static function b_kumulativ(nBr_nal)

// RNAL
select rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	do while !eof() .and. (br_nal == nBr_nal)
		DELETE
		SKIP	
	enddo
endif

// RNST
select rnst
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	do while !eof() .and. (br_nal == nBr_nal)
		DELETE
		SKIP
	enddo
endif

// RNOP
select rnop
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	do while !eof() .and. (br_nal == nBr_nal)
		DELETE
		SKIP
	enddo
endif

return



//----------------------------------------------
// Zatvaranje naloga rnal->rn_status == "Z"
//----------------------------------------------
function z_rnal(nBr_nal, cRealise)
local nTArea
local dDatum := DATE()
local cVrijeme := TIME()
local cOperater := goModul:oDatabase:cUser

nTArea := SELECT()

select rnal
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal)

if Found()
	// setuj status na zatvoreno
	do while !EOF() .and. (field->br_nal == nBr_nal)
		
		Scatter()
		
		_rn_status := "Z"
		_rn_real := cRealise
		
		Gather()
		
		skip
	enddo
else
	return 0
endif

// zatvaranje naloga....
log_zatvori(nBr_nal, cOperater, "", cRealise)

select (nTArea)

return 1


//---------------------------------------------
// vraca sljedeci redni broj stavke naloga
//---------------------------------------------
function next_r_br()
local nLastRbr
local nRecNo := RECNO()
PushWa()
select p_rnst
set order to tag "br_nal"
go bottom
nLastRbr := field->r_br
PopWa()
go (nRecNo)
return nLastRbr + 1



// -------------------------------------------
// vraca sljedeci podbroj u tabeli
// -------------------------------------------
function next_p_br(nBr_nal, nR_br)
local nLastPbr := 0

PushWa()
select p_rnst
set order to tag "br_nal"
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. field->br_nal == nBr_nal;
                .and. field->r_br == nR_br

	nLastPbr := field->p_br
	
	skip
enddo

PopWa()

return nLastPBr + 1


//-----------------------------------------
// vraca sljedeci broj radnog naloga
//-----------------------------------------
function next_br_nal()

PushWa()
select rnal
set order to tag "br_nal"
go bottom

nLastRbr := br_nal

PopWa()

return nLastRbr + 1



//--------------------------------------------
// da li postoji isti broj naloga u gl.tabeli
//--------------------------------------------
function nalog_exist(nBrNal)
local nArea
local lRet := .f.

nArea := SELECT()

select RNAL
set order to tag "br_nal_z"
go top
seek s_br_nal(nBrNal) + "Z"

if Found()
	lRet := .t.
endif

select (nArea)

return lRet


// -----------------------------------------
// novi broj naloga
// mrezni rad....
// -----------------------------------------
function _n_br_nal(lNovi)
local nTArea
local nNewBrNal

nTArea := SELECT()
select p_rnal
go top

if ( p_rnal->br_nal <> 0 .or. EOF() )
	// vec postoji odredjen broj
   	return p_rnal->br_nal
endif

// novi nalog
// koji nema svog broja, u pripremi
select rnal

if !rnal->(FLOCK())
	nTime := 80     
	// daj mu 10 sekundi
      	do while nTime > 0
        	InkeySc(.125)
         	nTime --
         	if rnal->(FLOCK())
            		exit
         	endif
      	enddo
      	if nTime == 0 .AND. ! rnal->(FLOCK())
        	Beep (4)
         	Msg ("Nemoguce odrediti broj dokumenta!#Ne mogu pristupiti bazi!")
         	return 0
      	endif
endif

nNewBrNal := next_br_nal()

// pravi se fizicki append u bazi dokumenata da bi se sacuvalo mjesto
// za ovaj dokument
select rnal
appblank2(.f., .f.)   
_rec_zak := "Z"
_br_nal := nNewBrNal
Gather2()
DBUnlock()

select (nTArea)

return nNewBrNal



// ----------------------------------------------
// napuni pripremne tabele sa brojem naloga
// ----------------------------------------------
function f_p_br_nal( nBr_nal )
local nTRec
local nTArea
local nAPPRec

// ako je broj 0 ne poduzimaj nista....
if ( nBr_nal == 0 )
	return
endif

nTArea := SELECT()
nTRec := RecNo()

// P_RNAL
select p_rnal
set order to tag "br_nal"
go top

// ako je u pripremi isti broj naloga
if ( p_rnal->br_nal == nBr_nal )
	// nemam sta raditi nista se nije mjenjalo...
	return 
endif

do while !EOF()
	skip
	nAPPRec := RecNo()
	skip -1
	
	Scatter()
	_br_nal := nBr_nal
	Gather()
	
	go (nAPPRec)
enddo


// P_RNST
select p_rnst
go top
do while !EOF()
	skip
	nAPPRec := RecNo()
	skip -1
	
	Scatter()
	_br_nal := nBr_nal
	Gather()
	
	go (nAPPRec)
enddo

// P_RNOP
select p_rnop
go top
do while !EOF()
	skip
	nAPPRec := RecNo()
	skip -1
	
	Scatter()
	_br_nal := nBr_nal
	Gather()
	
	go (nAPPRec)
enddo

select (nTArea)
go (nTRec)

return


// --------------------------------------
// pronadji i brisi RNAL "Z" zapis
// --------------------------------------
function del_rnal_z( nBr_nal )

select rnal
set order to tag "br_nal_z"
go top

seek s_br_nal(nBr_nal) + "Z"

// ako sam pronasao, brisi
if Found()
	do while !EOF() .and. field->br_nal == nBr_nal ;
			.and. field->rec_zak == "Z"
			
		delete
		skip
		
	enddo
endif

set order to

return


// ----------------------------------
// brisi operacije viska
// ----------------------------------
function del_op_error()
local nTArea
local nBr_nal
local nR_br
local nP_br
local cItemId
local cSeek

nTArea := SELECT()

// selektuj p_rnal
select p_rnst
set order to tag "br_nal"

// selektuj p_rnop
select p_rnop
set order to tag "br_nal"
go top

do while !EOF() 
	
	nBr_Nal := p_rnop->br_nal
	nR_br := p_rnop->r_br
	nP_br := p_rnop->p_br
	cItemId := p_rnop->item_id
	
	cSeek := s_br_nal(nBr_nal) + s_r_br(nR_br) + s_p_br(nP_br) + cItemId
	
	select p_rnst
	go top
	seek cSeek
	
	if !Found()
		select p_rnop
		delete
	endif
	
	select p_rnop
	skip
enddo

select (nTArea)

return



// ---------------------------------
// generisi roba match code
// ---------------------------------
function gen_r_mc(nStavka)
local cRet := ""

Box(, 2, 60)
	private GetList:={}
	cMCode := SPACE(10)
	@ m_x + 1, m_y + 2 SAY "Stavka br. " + ALLTRIM(STR(nStavka))
	@ m_x + 2, m_y + 2 SAY "Unesi match code:" GET cMCode
	read
BoxC()

if LastKey() <> K_ESC
	cRet := cMCode
endif

return cRet


// ----------------------------
// generisi naziv artikla
// ----------------------------
function gen_r_naz(nBr_nal, nR_br)
local cRet := ""
local nTArea
local cItemId

select p_rnst
set order to tag "br_nal"
go top
seek s_br_nal(nBr_nal) + s_r_br(nR_br)

do while !EOF() .and. field->br_nal == nBr_nal ;
		.and. field->r_br == nR_br
	
	cItemID := field->idroba
	select roba
	hseek cItemID
	
	if LEN(cRet) == 250
		exit
	endif
	
	if !EMPTY(cRet)
		cRet += ","
	endif
	
	cRet += ALLTRIM(LEFT(roba->naz, 40))
	
	select p_rnst
	skip 
enddo

select (nTArea)
return cRet


// ------------------------------
// generisi novi id robe
// ------------------------------
function gen_r_id()
local cRet := ""
local nTArea 
local nPom:=0
local cPom

nTArea := SELECT()

select roba
set filter to id = "XR"
set order to tag "ID"
go bottom

cPom := RIGHT(field->id, 8)

select roba
set filter to

select (nTArea)

cPom := NovaSifra(cPom)
nPom := VAL(cPom)

cRet := "XR" + PADL(ALLTRIM(STR(nPom)), 8, "0")

return cRet



