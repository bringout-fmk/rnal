#include "\dev\fmk\rnal\rnal.ch"

// variables

static l_new_it
static _doc


// ------------------------------------------
// unos ispravka stavki naloga.... 
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// ------------------------------------------
function e_doc_item( nDoc_no, lNew )
local nX := m_x
local nY := m_y
local nGetBoxX := 11
local nGetBoxY := 70
local nRet := 0
local nFuncRet := 0
private GetList:={}

_doc := nDoc_no

if lNew == nil
	lNew := .t.
endif

l_new_it := lNew

select _doc_it

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos stavki naloga")

Scatter()

do while .t.

	nFuncRet := _e_box_item( nGetBoxX, nGetBoxY )
	
	if nFuncRet == 1
		
		select _doc_it
		
		if l_new_it
			append blank
		endif
		
		Gather()
		
		if l_new_it
			loop
		endif
		
	endif
	
	BoxC()
	select _doc_it
	
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

if l_new_it
	_doc_no := _doc
	_doc_it_no := inc_docit( _doc )
	_doc_it_schema := "N"
endif

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("r.br stavke", nLeft) GET _doc_it_no 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("ARTIKAL:", nLeft) GET _art_id VALID {|| s_articles( @_art_id, .t. ), show_it( g_art_desc( _art_id ) + ".." , 30 ) }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("shema u prilogu (D/N):", nLeft + 6) GET _doc_it_schema PICT "@!" VALID _doc_it_schema $ "DN"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("dod.napomene:", nLeft) GET _doc_it_desc PICT "@S40"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("sirina (mm):", nLeft + 3) GET _doc_it_heigh PICT "99999.99" VALID val_heigh(_doc_it_heigh)

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("visina (mm):", nLeft + 3) GET _doc_it_width PICT "99999.99" VALID val_width(_doc_it_width)

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("kolicina:", nLeft + 3) GET _doc_it_qtty PICT "99999" VALID val_qtty(_doc_it_qtty)


read

ESC_RETURN 0

return 1



// -------------------------------------------
// uvecaj broj stavke naloga
// -------------------------------------------
function inc_docit( nDoc_no )
local nTArea := SELECT()
local nTRec := RECNO()
local nRet := 0

select _doc_it
go top
set order to tag "1"
seek doc_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no
	nRet := field->doc_it_no
	skip
enddo

nRet += 1

select (nTArea)
go (nTRec)

return nRet


// -------------------------------------
// validacija kolicine
// -------------------------------------
static function val_qtty( nVal )
local lRet := .f.
if nVal <> 0
	lRet := .t.
endif
val_msg(lRet, "Kolicina mora biti <> 0 !")
return lRet



// ----------------------------------
// validacija visine
// ----------------------------------
static function val_width( nVal )
local lRet := .f.
if nVal >= 0
	lRet := .t.
endif
val_msg(lRet, "Dimenzija mora biti >= 0 !")
return lRet



// ----------------------------------
// validacija sirine
// ----------------------------------
static function val_heigh( nVal )
local lRet := .f.
if nVal >= 0
	lRet := .t.
endif
val_msg(lRet, "Dimenzija mora biti >= 0 !")
return lRet



// -------------------------------------
// poruka pri validaciji
// -------------------------------------
static function val_msg(lRet, cMsg)
if lRet == .f.
	MsgBeeP(cMsg)
endif
return 


