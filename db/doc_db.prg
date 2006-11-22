#include "\dev\fmk\rnal\rnal.ch"


// variables

static __doc_no
static __doc_stat



// -------------------------------------------
// azuriranje dokumenta u kumulativnu bazu
// -------------------------------------------
function doc_insert()

o_tables(.t.)

// skloni filtere
select _docs
set filter to

select _doc_it
set filter to

select _doc_ops
set filter to

select _docs
go top

if RECCOUNT2() == 0
	return 0
endif

__doc_no := _docs->doc_no
__doc_stat := _docs->doc_status

if __doc_stat < 2 .and. !doc_exist( __doc_no )
	MsgBeep("Nalog " + ALLTRIM(STR( __doc_no )) + " nije moguce azurirati !!!")
	return 0
endif

MsgO("Azuriranje naloga u toku...")

Beep(1)

// doc busy....
if __doc_stat == 2
	
	// napravi deltu dokumenta
	doc_delta( __doc_no )
	
	// brisi dokument iz kumulativa
	doc_erase( __doc_no )
	
endif

// azuriranje tabele _DOCS
_docs_insert( __doc_no  )

// azuriranje tabele _DOC_IT
_doc_it_insert( __doc_no )

// azuriranje tabele _DOC_OPS
_doc_op_insert( __doc_no )

if __doc_stat <> 2

	// logiraj promjene na dokumentu
	doc_logit( __doc_no )
	
endif

// sve je ok brisi pripremu
select _docs
zap
select _doc_it
zap
select _doc_ops
zap

use

Beep(1)

o_tables(.t.)

MsgC()

return 1



// --------------------------------------------------
// azuriranje DOCS
// --------------------------------------------------
static function _docs_insert( nDoc_no )

select _docs
set order to tag "1"
go top

// uzmi iz _docs stavke...
Scatter("d")
	
// pronadji zauzeti slog ( 3 + nDoc_no )
select docs
set order to tag "2"
go top
seek d_busy() + docno_str( nDoc_no )

Scatter()

_doc_status := 0

Gather("d")

set order to tag "1"

return


// ------------------------------------------
// azuriranje tabele _DOC_IT
// ------------------------------------------
static function _doc_it_insert( nDoc_no )

select _doc_it

if RECCOUNT2() == 0
	return
endif

set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. ( field->doc_no == nDoc_no )
	
	Scatter()
	
	select doc_it
	
	append blank
		
	Gather()
	
	select _doc_it
	
	skip
	
enddo

return



// ------------------------------------------
// azuriranje tabele _DOC_OP
// ------------------------------------------
static function _doc_op_insert( nDoc_no )

select _doc_ops

if RECCOUNT2() == 0
	return
endif

set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. ( field->doc_no == nDoc_no )
	
	// ako ima operacija...
	if field->aop_id + field->aop_att_id <> 0
		
		Scatter()
		
		select doc_ops
		append blank
		
		Gather()
	endif
	
	select _doc_ops
	skip
enddo

return



// -------------------------------------------
// procedura povrata dokumenta u pripremu...
// -------------------------------------------
function doc_2__doc( nDoc_no )

o_tables(.t.)

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if !Found()
	MsgBeep("Nalog " + ALLTRIM(STR( nDoc_no )) + " ne postoji !!!")
	select _docs
	return 0
endif

select _docs

if RECCOUNT2() > 0
	MsgBeep("U pripremi vec postoji dokument#ne moze se izvrsiti povrat#operacija prekinuta !")
	return 0
endif

MsgO("Vrsim povrat dokumenta u pripremu....")

// povrat maticne tabele RNAL
_docs_erase( nDoc_no )

// povrat stavki RNST
_doc_it_erase( nDoc_no )

// povrat operacija RNOP
_doc_op_erase( nDoc_no ) 

// markiraj da je dokument busy
set_busy_marker( nDoc_no, .t. )

select docs
use

o_tables(.t.)

MsgC()

return 1


// ----------------------------------------
// markiranje statusa dokumenta busy
// nDoc_no - dokument broj
// lMark - .t. -> setuj, .f. -> ukini
// ----------------------------------------
function set_busy_marker( nDoc_no, lMark )
local nTArea
nTArea := SELECT()

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
	
	Scatter()
	
	if lMark == .t.
		_doc_status := 3
	else
		_doc_status := 0
	endif
	
	Gather()
	
endif

select (nTArea)
return



// ------------------------------------
// provjerava da li je dokument zauzet
// ------------------------------------
function is_doc_busy()
local lRet := .f.
if field->doc_status == 3
	lRet := .t.
endif
return lRet



//----------------------------------------------
// povrat dokumenta iz tabele DOCS
//----------------------------------------------
static function _docs_erase( nDoc_no )

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
	
	select docs
		
	Scatter()
		
	// setuj na rejected...
	_doc_status := 2
		
	select _docs
		
	APPEND BLANK
		
	Gather()
endif

select docs

return


//----------------------------------------------
// povrat tabele DOC_IT
//----------------------------------------------
static function _doc_it_erase( nDoc_no )

select doc_it
set order to tag "1"
go top

seek docno_str( nDoc_no )

if FOUND()
	
	// dodaj u pripremu dokument
	do while !EOF() .and. ( field->doc_no == nDoc_no )
	
		select doc_it
		
		Scatter()
	
		select _doc_it
		
		APPEND BLANK
		
		Gather()
	
		select doc_it
		
		skip
	enddo
endif

select doc_it

return



//----------------------------------------------
// povrat tabele DOC_OP
//----------------------------------------------
static function _doc_op_erase( nDoc_no )

select doc_ops
set order to tag "1"
go top

seek docno_str( nDoc_no )

if FOUND()
	
	// dodaj u pripremu dokument
	do while !EOF() .and. (field->doc_no == nDoc_no)
	
		select doc_ops
		Scatter()
	
		select _doc_ops
		APPEND BLANK
		Gather()
	
		select doc_ops
		
		skip
	enddo
	
endif

select doc_ops

return



//-----------------------------------------------
// brisi sve vezano za dokument iz kumulativa
//-----------------------------------------------
static function doc_erase( nDoc_no )

// DOCS
select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
	DELETE
endif

// DOC_IT
select doc_it
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
	do while !eof() .and. (field->doc_no == nDoc_no)
		DELETE
		SKIP
	enddo
endif

// DOC_OP
select doc_ops
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
	do while !eof() .and. (field->doc_no == nDoc_no)
		DELETE
		SKIP
	enddo
endif

return



//--------------------------------------------
// da li postoji dokument u tabeli
//--------------------------------------------
function doc_exist( nDoc_no )
local nArea
local lRet := .f.

nArea := SELECT()

select DOCS
set order to tag "2"
go top
seek d_busy() + docno_str( nDoc_no )

if FOUND()
	lRet := .t.
endif

set order to tag "1"
select (nArea)

return lRet



// -----------------------------------------
// novi broj dokumenta
// mrezni rad....
// -----------------------------------------
function _new_doc_no()
local nTArea
local nNewDocNo

nTArea := SELECT()

select _docs
go top

altd()

if ( field->doc_no <> 0 .or. EOF() )

	// vec postoji odredjen broj
   	return field->doc_no
	
endif

// novi dokument
// koji nema svog broja, u pripremi

select docs

if !docs->(FLOCK())
	
	nTime := 80     
	
	// daj mu 10 sekundi
      	do while nTime > 0
        	
		InkeySc(.125)
         	
		nTime --
         	
		if docs->(FLOCK())
        		exit
	       	endif
	enddo
	
      	if nTime == 0 .AND. ! docs->(FLOCK())
        	
		Beep (4)
         	Msg ("Nemoguce odrediti broj dokumenta!#Ne mogu pristupiti bazi!")
         	return 0
      	endif
endif

select docs
set order to tag "1"
go bottom

nNewBrNal := field->doc_no + 1

// pravi se fizicki append u bazi dokumenata da bi se sacuvalo mjesto
// za ovaj dokument
select docs

Scatter()

appblank2(.f., .f.)   

_doc_status := 3
_doc_no := nNewBrNal

Gather2()

DBUnlock()

select (nTArea)

return nNewBrNal



// ----------------------------------------------
// napuni pripremne tabele sa brojem naloga
// ----------------------------------------------
function fill__doc_no( nDoc_no )
local nTRec
local nTArea
local nAPPRec

// ako je broj 0 ne poduzimaj nista....
if ( nDoc_no == 0 )
	return
endif

nTArea := SELECT()
nTRec := RecNo()

// _DOCS
select _docs
set order to tag "1"
go top

// ako je u pripremi isti broj naloga
if ( field->doc_no == nDoc_no )
	// nemam sta raditi nista se nije mjenjalo...
	return 
endif

Scatter()
_doc_no := nDoc_no
Gather()
	

// _DOC_IT
select _doc_it
go top
do while !EOF()
	
	skip
	nAPPRec := RecNo()
	skip -1
	
	Scatter()
	_doc_no := nDoc_no
	Gather()
	
	go (nAPPRec)
enddo

// _DOC_OP
select _doc_ops
go top
do while !EOF()
	
	skip
	nAPPRec := RecNo()
	skip -1
	
	Scatter()
	_doc_no := nDoc_no
	Gather()
	
	go (nAPPRec)
enddo

select (nTArea)
go (nTRec)

return


// -----------------------------------------
// formira string za _doc_status - opened
// -----------------------------------------
static function d_opened()
return STR(0, 2)

// -----------------------------------------
// formira string za _doc_status - closed
// -----------------------------------------
static function d_closed()
return STR(1, 2)

// -----------------------------------------
// formira string za _doc_status - rejected
// -----------------------------------------
static function d_rejected()
return STR(2, 2)

// -----------------------------------------
// formira string za _doc_status - busy
// -----------------------------------------
static function d_busy()
return STR(3, 2)


