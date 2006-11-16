#include "\dev\fmk\rnal\rnal.ch"

// variables

static l_new_doc
static _oper_id
static _doc

// -------------------------------------------------
// unos / ispravka osnovnih podataka dokumenta
// lNew - nova stavka .t. or .f.
// -------------------------------------------------
function e_doc_main_data( lNew )
local nRecCnt := 0
local GetList:={}
local nGetBoxX := 18
local nGetBoxY := 70

nRecCnt := RECCOUNT2()

if lNew .and. nRecCnt == 1
	MsgBeep("Vec postoji definisan nalog !!!#Dodavanje novih stavki onemoguceno!")
	return 0
endif

l_new_doc := lNew

_oper_id := GetUserID()

select _docs

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos osnovnih podataka naloga")

Scatter()
_doc := _doc_no

if _e_box_main( nGetBoxX, nGetBoxY ) == 0

	select _docs
	BoxC()
	return 0
	
endif

BoxC()

select _docs

if l_new_doc
	append blank
endif
   
Gather()

return 1


// ---------------------------------------------
// forma  unosa podataka
// ---------------------------------------------
static function _e_box_main( nBoxX, nBoxY )
local nX := 1
local nLeft := 20

// setuj def.vrijednosti polja za novi dokument
if l_new_doc

	_doc_date := DATE()
	_doc_dvr_date := DATE() + 2
	_doc_dvr_time := PADR(TIME(), 8)
	_doc_ship_place := SPACE( LEN(_doc_ship_place) )
	_doc_priority := 2
	_doc_pay_id := 1

endif

// set vrijednosti polja koja se uvijek mijenjaju
_operater_id := _oper_id


// unos podataka...


@ m_x + nX, m_y + 2 SAY "Datum naloga:" GET _doc_date 

@ m_x + nX, col() + 25 SAY "dokument:"
@ m_x + nX, col() + 1 SAY doc_str( _doc ) COLOR "I"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Narucioc:", nLeft) GET _cust_id VALID {|| s_customers(@_cust_id), show_it( g_cust_desc( _cust_id ) ) } 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Datum isporuke:", nLeft) GET _doc_dvr_date

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Vrijeme isporuke:", nLeft) GET _doc_dvr_time VALID !EMPTY(_doc_dvr_time)

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Mjesto isporuke:", nLeft) GET _doc_ship_place VALID !EMPTY(_doc_ship_place) PICT "@S46"
@ m_x + nX, col() SAY ">" COLOR "I"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Kontakt osoba:", nLeft) GET _cont_id VALID {|| s_contacts(@_cont_id, _cust_id), show_it( g_cont_desc( _cont_id ) ) }

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("dodatni opis: (*)", nLeft + 2 ) GET _cont_add_desc PICT "@S44"
@ m_x + nX, col() SAY ">" COLOR "I"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Prioritet:", nLeft) GET _doc_priority VALID (_doc_priority > 0 .and. _doc_priority < 4) PICT "9"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Vrsta placanja:", nLeft) GET _doc_pay_id VALID (_doc_pay_id > 0 .and. _doc_pay_id < 3) PICT "9"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Dod.opis naloga (*):", nLeft) GET _doc_desc PICT "@S46"
@ m_x + nX, col() SAY ">" COLOR "I"


@ m_x + nBoxX, m_y + 2 SAY PADL("(*) popuna nije obavezna", nBoxY - 2 )

read

ESC_RETURN 0

return 1




