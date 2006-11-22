#include "\dev\fmk\rnal\rnal.ch"

// variables

static l_new_ops
static _doc


// ------------------------------------------
// unos ispravka operacija naloga
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// ------------------------------------------
function e_doc_ops( nDoc_no, lNew )
local nX := m_x
local nY := m_y
local nGetBoxX := 10
local nGetBoxY := 70
local GetList:={}
local nRet := 0
local nFuncRet := 0

_doc := nDoc_no

if lNew == nil
	lNew := .t.
endif

l_new_ops := lNew

select _doc_ops

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos dodatnih operacija naloga")

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
local nLeft := 20

if l_new_ops
	_doc_no := _doc
	_doc_op_no := inc_docop( _doc )
endif

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("r.br stavke", nLeft) GET _doc_op_no 


nX += 2


@ m_x + nX, m_y + 2 SAY PADL("d.operacija", nLeft) GET _aop_id VALID {|| s_aops( @_aop_id ), show_it( g_aop_desc( _aop_id )) }

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("atr.d.operacije:", nLeft) GET _aop_att_id VALID {|| _aop_att_id == 0 .or. s_aops_att(@_aop_att_id, _aop_id ), show_it(g_aop_att_desc( _aop_att_id )) }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("odnosi se na stavku", nLeft) GET _doc_it_no

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("dodatni opis", nLeft) GET _doc_op_desc PICT "@S40"


read

ESC_RETURN 0

return 1



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





