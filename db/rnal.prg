#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// procedura azuriranja naloga
// cLog_opis - opis za tabelu loga
// -------------------------------------------
function azur_nalog(cLog_opis)
local nBr_nal
local cStat

if (cLog_opis == nil)
	cLog_opis := ""
endif

o_rnal(.t.)

select p_rnop
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

// azuriraj stavke RNAL
a_rnal( nBr_nal , cStat )
// azuriraj stavke RNOP
a_rnop( nBr_nal )
// dodaj u RNLOG
a_rnlog( nBr_nal, cLog_opis )

// sve je ok brisi pripremu
select p_rnal
zap
select p_rnop
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
seek STR(nBr_nal, 10, 0)

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
	seek STR(nBr_nal, 10, 0) + "Z"
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
// azuriranje RNOP
// ------------------------------------------
static function a_rnop( nBr_nal )

select p_rnop

if RECCOUNT2() == 0
	return
endif

set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. ( p_rnop->br_nal == nBr_nal )
	if !EMPTY(p_rnop->rn_instr)
		
		Scatter()
		
		select rnop
		append blank
		
		Gather()
	endif
	select p_rnop
	skip
enddo

return

// ------------------------------------------
// azuriranje RNLOG
// ------------------------------------------
static function a_rnlog( nBr_nal, cLOGOpis )
local dLog_date := DATE()
local cLog_time := TIME()
local dDat_isp := DATE() 
local nU_neto:=0
local nExpired:=0
local nU_ukupno:=0
local nLOGR_br
local cPom:=""
local cRn_status

select rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. ( rnal->br_nal == nBr_nal )
	nU_neto += rnal->neto
	nU_ukupno += rnal->z_ukupno
	cRn_status := rnal->rn_status
	dDat_isp := rnal->datisp
	skip
enddo

// nadji sljedeci redni broj u log tabeli za nalog
nLOGR_br := n_log_rbr( nBr_nal )

// provjeri datum isporuke
if ( dLOG_date > dDat_isp ) .and. cRn_status <> "O"
	nExpired := dLog_date - dDat_isp
endif

select rnlog
append blank
replace br_nal with nBr_nal
replace r_br with nLOGR_br
replace log_datum with dLog_date
replace log_time with cLog_time
replace rn_status with cRn_status
replace rn_expired with nExpired
replace rn_ukupno with nU_ukupno
replace rn_neto with nU_neto

// obrada opisa pri azuriranju
if cRn_status $ "O"
	cPom := "Otvoren nalog"
elseif cRn_status == "R"
	cPom := ""
elseif cRn_status == "Z"
	cPom := "Zatvoren nalog"
endif

if cLOGOpis == nil
	cLOGOpis := ""
endif

cPom += cLOGOpis

if EMPTY(cPom)
	cPom := "-"
endif

replace log_opis with cPom

return


// -------------------------------------------
// procedura povrata naloga u pripremu
// -------------------------------------------
function pov_nalog( nBr_nal )

o_rnal(.t.)

select rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

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

// povrat RNAL
p_rnal( nBr_nal )

// povrat RNOP
p_rnop( nBr_nal ) 

// logiranje dogadjaja
// ovdje to ne treba ??????
// a_rnlog( nBr_nal, cLog_opis )

// brisi kumulativ
b_kumulativ( nBr_nal )

select rnal
use

o_rnal(.t.)

MsgC()

return 1



//----------------------------------------------
// povrat RNAL
//----------------------------------------------
static function p_rnal(nBr_nal)

select rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

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
// povrat RNOP
//----------------------------------------------
static function p_rnop(nBr_nal)

select rnop
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

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
seek STR(nBr_nal, 10, 0)
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
seek STR(nBr_nal, 10, 0)
if Found()
	do while !eof() .and. (br_nal == nBr_nal)
		DELETE
		SKIP
	enddo
endif

return


// azuriranje novog statusa direktno u tabelu RNLOG
function log_new_status(nBr_nal, cLOGopis)
local nTArea
local nTRec
local cDbFilt

nTArea := SELECT()
nTRec := recno()
cDbFilt := DBFilter()

// privremeno skini filter
if !Empty(cDbFilt)
	set filter to
endif

select rnlog
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

// ako si pronasao
if Found()
	
	select rnal
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0)
	
	cRn_status := field->rn_status
	// ako je status otvoren, promjeni ga na "R"
	if cRn_status == "O"
		// procesljaj rnal
		do while !EOF() .and. field->br_nal == nBr_nal
			Scatter()
			_rn_status := "R"
			Gather()
			skip
		enddo
	endif
	
	select rnlog
	// dodaj log
	a_rnlog(nBr_nal, cLOGOpis)
endif

select (nTArea)

// vrati filter
if !Empty(cDbFilt)
	set filter to &cDbFilt
endif

go (nTRec)

return


//----------------------------------------------
// Zatvaranje naloga rnal->rn_status == "Z"
//----------------------------------------------
function z_rnal(nBr_nal, cLog_opis, cRealise)
local nTArea

if (cLog_opis == nil)
	cLog_opis := ""
endif

nTArea := SELECT()

select rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

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

// logiraj dogadjaj
a_rnlog(nBr_nal, cLog_opis)

select (nTArea)

return 1





//---------------------------------------------
// vraca sljedeci redni broj naloga, generalni
//---------------------------------------------
function next_r_br()

PushWa()
select p_rnal
set order to tag "br_nal"
go bottom
nLastRbr := r_br
PopWa()
return nLastRbr + 1


//------------------------------------------------
// vraca sljedeci redni broj naloga u LOG tabeli
//------------------------------------------------
function n_log_rbr(nBr_nal)
local nLastRbr:=0
PushWa()
select rnlog
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)
do while !EOF() .and. (field->br_nal == nBr_nal)
	nLastRbr := field->r_br
	skip
enddo
PopWa()

return nLastRbr + 1




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
hseek STR(nBrNal, 10, 0) + "Z"

if Found()
	lRet := .t.
endif

select (nArea)

return lRet


// --------------------------------------------
// vraca ukupno m2 za nalog nBr_nal
// --------------------------------------------
function g_nal_ukupno( nBr_nal )
local xRet:=0
local nTRec
local nTArea

nTArea := SELECT()
nTRec := RecNo()

select rnlog
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

if Found()
	do while !EOF() .and. ( field->br_nal == nBr_nal )
		xRet := field->rn_ukupno
		skip
	enddo
endif

select (nTArea)
go (nTRec)

return xRet


// ------------------------------------------
// vraca broj dana isteka naloga
// ------------------------------------------
function g_nal_expired(nBr_nal)
local xRet:=0
local nTArea := SELECT()
local nExpired:=0
select rnlog
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !EOF() .and. (field->br_nal == nBr_nal)
	nExpired := field->rn_expired
	skip
enddo

xRet := nExpired

select (nTArea)
return xRet


// novi broj naloga
// mrezni rad....
function _n_br_nal(lNovi)
local nTArea
local nNoviBroj

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

nNoviBroj := next_br_nal()

// pravi se fizicki append u bazi dokumenata da bi se sacuvalo mjesto
// za ovaj dokument
select rnal
appblank2( .f., .f. )   
_rec_zak := "Z"
_br_nal := nNoviBroj
Gather2 ()
DBUnlock()

select (nTArea)

return nNoviBroj


// napuni pripremne tabele sa brojem naloga
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


// pronadji i brisi RNAL "Z" zapis
function del_rnal_z( nBr_nal )
select rnal
set order to tag "br_nal_z"
go top

seek STR(nBr_nal, 10, 0) + "Z"

// ako sam pronasao, brisi
if Found()
	do while !EOF() .and. field->br_nal == nBr_nal .and. field->rec_zak == "Z"
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
local cIdRoba
local cPom

nTArea := SELECT()

// selektuj p_rnal
select p_rnal
set order to tag "br_nal"
// selektuj p_rnop
select p_rnop
set order to tag "br_nal"
go top

do while !EOF() 
	
	nBr_Nal := p_rnop->br_nal
	nR_br := p_rnop->r_br
	cIdRoba := p_rnop->idroba
	
	cPom := STR(nBr_nal, 10, 0) + STR(nR_br, 4, 0) + cIdRoba
	
	select p_rnal
	go top
	seek cPom
	
	if !Found()
		select p_rnop
		delete
	endif
	
	select p_rnop
	skip
	
enddo

select (nTArea)

return



