#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// procedura azuriranja naloga
// -------------------------------------------
function azur_nalog()
local nBr_nal

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

if nalog_exist( nBr_nal )
	MsgBeep("Nalog " + ALLTRIM(STR( nBr_nal )) + " vec postoji azuriran !!!")
	return 0
endif

MsgO("Azuriranje naloga u toku...")

// azuriraj stavke RNAL
a_rnal( nBr_nal )
// azuriraj stavke RNOP
a_rnop( nBr_nal )

// sve je ok brisi pripremu
select p_rnal
zap
select p_rnop
zap

use

o_rnal(.t.)

MsgC()

return 1



// ------------------------------------------
// azuriranje RNAL
// ------------------------------------------
static function a_rnal( nBr_nal )

select p_rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

do while !eof() .and. ( p_rnal->br_nal == nBr_nal )
	Scatter()
	select rnal
	append blank
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


//-----------------------------------------
// vraca sljedeci redni broj naloga
//-----------------------------------------
function next_r_br()

PushWa()
select p_rnal
set order to tag "br_nal"
go bottom
nLastRbr := r_br
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
set order to tag "br_nal"
hseek STR(nBrNal, 10, 0)

if Found()
	lRet := .t.
endif

select (nArea)

return lRet


// --------------------------------------------
// vraca ukupno m2 za nalog nBr_nal
// --------------------------------------------
function g_nal_ukupno( nBr_nal )
local xRet
local nTRec
local cFilter 

cFilter := DBFilter()

nTRec := RecNo()
xRet := 0

set filter to

select rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)

if Found()
	do while !EOF() .and. ( field->br_nal == nBr_nal )
		xRet += field->d_ukupno
		skip
	enddo
endif

set filter to &cFilter

go (nTRec)

return xRet



