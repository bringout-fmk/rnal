#include "\dev\fmk\rnal\rnal.ch"

// variables

static l_new_ops
static _doc
static __item_no
static __art_id
static __art_type
static _form_article
static _a_elem

// ------------------------------------------
// unos ispravka operacija naloga
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// nItem_no - stavka broj
// nArt_id - artikal id
// ------------------------------------------
function e_doc_ops( nDoc_no, lNew, nArt_id, nItem_no )
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
__art_id := nArt_id
_from_article := .f.

if nItem_no > 0
	_from_article := .t.
endif

// napuni matricu sa elementima artikla
_g_art_elements( @_a_elem, __art_id )

__art_type := LEN(_a_elem)

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
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna obavezna", nGetBoxY - 2) COLOR "BG+/B"

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
local nLeft := 27
local cAop := ""
local cAopAtt := ""

if l_new_ops

	_doc_no := _doc
	_doc_op_no := inc_docop( _doc )
	_doc_it_el_no := 0
	_aop_id := 0
	_aop_att_id := 0
	_doc_op_desc := PADR("", LEN(_doc_op_desc))
	_doc_it_no := __item_no
	
	cAop := PADR("", 10)
	cAopAtt := PADR("", 10)

else
	
	cAop := PADL( STR(_aop_id, 10), 10 )
	cAopAtt := PADL( STR(_aop_att_id, 10), 10 )
	
endif


nX += 2

@ m_x + nX, m_y + 2 SAY PADL("r.br operacije (*):", nLeft) GET _doc_op_no WHEN {|| set_opc_box( nBoxX, 50 ), _doc_op_no == 0 }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("odnosi se na stavku (*):", nLeft) GET _doc_it_no VALID {|| _item_range( _doc_it_no ) .and. show_it( g_item_desc( _doc_it_no ), 26 )} WHEN {|| set_opc_box( nBoxX, 50, "ova operacija ce se odnositi", "eksplicitno na unesenu stavku"), _from_article == .f. }
	
nX += 1
	
@ m_x + nX, m_y + 2 SAY PADL(" -> element stavke (*):", nLeft) GET _doc_it_el_no VALID {|| get_it_element( @_doc_it_el_no ), show_it( get_elem_desc( _a_elem, _doc_it_el_no ), 26 ) } WHEN {|| _g_art_elements( @_a_elem, _g_art_it_no( _doc_it_no) ), set_opc_box( nBoxX, 50, "odnosi se na odredjeni element stavke", "") }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("dodatna operacija (*):", nLeft) GET cAop VALID {|| s_aops( @cAop, cAop ), set_var(@_aop_id, @cAop) , show_it( g_aop_desc( _aop_id ), 20) } WHEN set_opc_box( nBoxX, 50, "odaberi dodatnu operaciju", "0 - otvori sifrarnik")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("atribut dod. operacije:", nLeft) GET cAopAtt VALID {|| s_aops_att(@cAopAtt, _aop_id, cAopAtt ), set_var(@_aop_att_id, @cAopAtt), show_it(g_aop_att_desc( _aop_att_id ), 20) } WHEN set_opc_box( nBoxX, 50, "odaberi atribut dodatne operacije", "99 - otvori sifrarnik")

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("dodatni opis:", nLeft) GET _doc_op_desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "dodatni opis vezan uz navedene", "operacije" )


read

ESC_RETURN 0

return 1


// --------------------------------------------
// vraca opis iz matrice - opis elementa
// --------------------------------------------
function get_elem_desc( aElem, nVal, nLen )
local xRet := ""
local nChoice

if nLen == nil
	nLen := 17
endif

nChoice := ASCAN( aElem, {|xVal| xVal[1] == nVal } )

if nChoice > 0
	xRet := aElem[ nChoice, 2 ]
endif

xRet := PADR(xRet, nLen)

return xRet


// --------------------------------------------------
// vraca arr sa elementima artikla...
// --------------------------------------------------
function get_it_element( nDoc_it_e_id )
local nXX := m_x
local nYY := m_y

if nDoc_it_e_id > 0
	return .t.
endif

// odaberi element
nDoc_it_e_id := _pick_element( _a_elem )

m_x := nXX
m_y := nYY

return .t.


// -----------------------------------------
// uzmi element...
// -----------------------------------------
static function _pick_element( aElem )
local nChoice := 1
local nRet
local i
local cPom
private GetList:={}
private izbor := 1
private opc := {}
private opcexe := {}

for i:=1 to LEN(aElem)

	cPom := PADL( ALLTRIM(STR(i)) + ")", 3 ) + " " + PADR( aElem[i, 2] , 40 )
	
	AADD(opc, cPom)
	AADD(opcexe, {|| nChoice := izbor, izbor := 0 })
	
next

Menu_sc("izbor")

if LastKey() == K_ESC

	nChoice := 0
	nRet := 0
	
else
	nRet := aElem[ nChoice, 1 ]
endif

return nRet

// ---------------------------------------------
// da li je stavka u rangu stavki tabele
// ---------------------------------------------
static function _item_range( nItemNo )
local lRet := .t.
local nTArea := SELECT()
local nDocItRec 

select _doc_it

nDocItRec := _doc_it->(RECCOUNT2())

if nItemNo > nDocItRec .or. nItemNo <= 0
	lRet := .f.
endif

select (nTArea)

if lRet == .f.
	MsgBeep("Nepostojeca stavka naloga !!!##Nalog sadrzi " + ;
		ALLTRIM(STR(nDocItRec)) + " stavki.")
endif

return lRet


// --------------------------------------------
// vrati opis odnosi se na stavku
// --------------------------------------------
static function g_item_desc( doc_it_no )
local xRet := ""
xRet := "na " + ALLTRIM(STR(doc_it_no)) + " stavku naloga"
return xRet


// ---------------------------------------------
// vraca artikal za stavku
// ---------------------------------------------
static function _g_art_it_no( nDoc_it_no )
local nArt_id := 0
local nTArea := SELECT()
local nTRec := RECNO()

select _doc_it
set order to tag "1"
seek docno_str( _doc) + docit_str( nDoc_it_no )

if FOUND()
	nArt_id  := field->art_id
endif

select (nTArea)
go (nTRec)

return nArt_id



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





