#include "\dev\fmk\rnal\rnal.ch"

// variables

static l_new_ops
static _doc
static __item_no

// ------------------------------------------
// unos ispravka operacija naloga
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// nItem_no - stavka broj
// ------------------------------------------
function e_doc_ops( nDoc_no, lNew, nItem_no )
local nX := m_x
local nY := m_y
local nGetBoxX := 16
local nGetBoxY := 70
local cBoxNaz := "unos dodatnih operacija stavke"
local nRet := 0
local nFuncRet := 0
private GetList:={}

if nItem_no == nil
	nItem_no := 0
endif

_doc := nDoc_no
__item_no := nItem_no

if lNew == nil
	lNew := .t.
endif

l_new_ops := lNew

if l_new_ops == .f.
	cBoxNaz := "ispravka dodatne operacije stavke"
endif

select _doc_ops

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos dodatnih operacija naloga")

set_opc_box( nGetBoxX, 50 )

@ m_x + 1, m_y + 2 SAY PADL("***** " + cBoxNaz, nGetBoxY - 2)
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna nije obavezna", nGetBoxY - 2) COLOR "BG+/B"

Scatter()

do while .t.

	nFuncRet := _e_box_item( nGetBoxX, nGetBoxY )
	
	if nFuncRet == 1
		
		select _doc_ops
		
		if l_new_ops
			append blank
		endif
		
		Gather()
		
		if l_new_ops
			loop
		endif
		
	endif
	
	BoxC()
	select _doc_ops
	
	nRet := RECCOUNT2()
	
	exit

enddo

select _docs

m_x := nX
m_y := nY

return nRet


// -------------------------------------------------
// forma za unos podataka 
// -------------------------------------------------
static function _e_box_item( nBoxX, nBoxY )
local nX := 1
local nLeft := 22

if l_new_ops

	_doc_no := _doc
	_doc_op_no := inc_docop( _doc )
	_aop_id := 0
	_aop_att_id := 0
	_doc_op_desc := PADR("", LEN(_doc_op_desc))
	
endif

_doc_it_no := __item_no

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("r.br stavke:", nLeft) GET _doc_op_no WHEN set_opc_box( nBoxX, 50 )

if __item_no == 0

	nX += 2

	@ m_x + nX, m_y + 2 SAY PADL("odnosi se na stavku:", nLeft) GET _doc_it_no VALID {|| _doc_it_no >= 0 .and. show_it( g_item_desc( _doc_it_no ), 30 )} WHEN set_opc_box( nBoxX, 50, "ova operacija ce se odnositi", "eksplicitno na unesenu stavku")

endif

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("d.operacija:", nLeft) GET _aop_id VALID {|| s_aops( @_aop_id ), show_it( g_aop_desc( _aop_id )) } WHEN set_opc_box( nBoxX, 50, "odaberi dodatnu operaciju", "0 - otvori sifrarnik")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("atr.d.operacije (*):", nLeft) GET _aop_att_id VALID {|| _aop_att_id == 0 .or. s_aops_att(@_aop_att_id, _aop_id ), show_it(g_aop_att_desc( _aop_att_id )) } WHEN set_opc_box( nBoxX, 50, "odaberi atribut dodatne operacije", "99 - otvori sifrarnik")

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("dodatni opis (*):", nLeft) GET _doc_op_desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "dodatni opis vezan uz navedene", "operacije" )


read

ESC_RETURN 0

return 1


// --------------------------------------------
// vrati opis odnosi se na stavku
// --------------------------------------------
static function g_item_desc( doc_it_no )
local xRet := ""
if doc_it_no == 0
	xRet := "na sve stavke"
else
	xRet := "na " + ALLTRIM(STR(doc_it_no)) + " stavku naloga"
endif
return xRet


// -------------------------------------------
// uvecaj broj stavke naloga
// -------------------------------------------
function inc_docop( nDoc_no )
local nTArea := SELECT()
local nTRec := RECNO()
local nRet := 0

select _doc_ops
go top
set order to tag "1"
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no
	nRet := field->doc_op_no
	skip
enddo

nRet += 1

select (nTArea)
go (nTRec)

return nRet





