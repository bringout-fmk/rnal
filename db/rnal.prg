#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// procedura azuriranja naloga
// -------------------------------------------
function azur_nalog()
local nBr_nal

o_rnal(.t.)

select p_rnal
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
a_rnal()
// azuriraj stavke RNOP
a_rnop()

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
static function a_rnal()
do while !eof()
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
static function a_rnop()

select p_rnop
go top

if RECCOUNT2() == 0
	return
endif

do while !EOF()
	if !EMPTY(field->rn_instr)
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
seek STR(nBr_nal, 8, 0)

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

return


//----------------------------------------------
// povrat RNOP
//----------------------------------------------
static function p_rnop(nBr_nal)

select rnop
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

return


//----------------------------------------
// brisi nalog iz kumulativa
//----------------------------------------
static function b_kumulativ(nBr_nal)
local nTRec

// RNAL
select rnal
hseek STR(nBr_nal, 8, 0)
do while !eof() .and. (br_nal == nBr_nal)
	
	SKIP
	// sljedeci zapis
	nTRec := RECNO()
	SKIP -1
	
	DELETE
	// idi na sljedeci
	go nTRec
	
enddo

// RNOP
select rnop
hseek STR(nBr_nal, 8, 0)
do while !eof() .and. (br_nal == nBr_nal)
	
	SKIP
	// sljedeci zapis
	nTRec := RECNO()
	SKIP -1
	
	DELETE
	// idi na sljedeci
	go nTRec
	
enddo

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
hseek STR(nBrNal,8,0)

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

nTRec := RecNo()
xRet := 0

select rnal
set order to tag "br_nal"
go top
seek STR(nBr_nal, 8, 0)

if Found()
	do while !EOF() .and. ( field->br_nal == nBr_nal )
		xRet += field->d_ukupno
		skip
	enddo
endif

go (nTRec)

return xRet



