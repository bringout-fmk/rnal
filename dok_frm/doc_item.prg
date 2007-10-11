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
local nGetBoxX := 18
local nGetBoxY := 70
local cBoxNaz := "unos nove stavke"
local nRet := 0
local nFuncRet := 0
local cGetDOper := "N"
private GetList:={}

_doc := nDoc_no

if lNew == nil
	lNew := .t.
endif

l_new_it := lNew

if l_new_it == .f.
	cBoxNaz := "ispravka stavke"
endif

select _doc_it

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos stavki naloga")

set_opc_box(nGetBoxX, 50)

// say top, bottom
@ m_x + 1, m_y + 2 SAY PADL("***** " + cBoxNaz , nGetBoxY - 2)
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna obavezna", nGetBoxY - 2) COLOR "BG+/B"

Scatter()

do while .t.

	nFuncRet := _e_box_item( nGetBoxX, nGetBoxY, @cGetDOper )
	
	if nFuncRet == 1
		
		select _doc_it
		
		if l_new_it
			append blank
		endif
		
		Gather()
		
		if cGetDOper == "D"
			
			e_doc_ops( _doc, ;
				   lNew, ;
				   _doc_it->art_id, ;
				   _doc_it->doc_it_no )
				   
			select _doc_it
			
		endif
		
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
// cGetDOper , D - unesi dodatne operacije...
// -------------------------------------------------
static function _e_box_item( nBoxX, nBoxY, cGetDOper )
local nX := 1
local aArtArr := {}
local nTmpArea
local nLeft := 21

cGetDOper := "N"

if l_new_it
	
	_doc_no := _doc
	_doc_it_no := inc_docit( _doc )
	_doc_it_altt := 0
	_doc_acity := SPACE( LEN(_doc_acity) )

	// ako je nova stavka i vrijednost je 0, uzmi default...
	if _doc_it_altt == 0
		_doc_it_altt := gDefNVM
		_doc_acity := PADR( gDefCity, 50 )
	endif

	if _doc_it_schema == " "
		_doc_it_schema := "N"
	endif
	
endif

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("r.br stavke (*)", nLeft) GET _doc_it_no 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("ARTIKAL (*):", nLeft) GET _art_id VALID {|| s_articles( @_art_id, .f., .t. ), _set_arr(_art_id, @aArtArr) ,show_it( g_art_desc( _art_id, nil, .f. ) + ".." , 35 ) } WHEN set_opc_box( nBoxX, 50, "0 - otvori sifrarnik i pretrazi" )

read

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("shema u prilogu (D/N)? (*):", nLeft + 9) GET _doc_it_schema PICT "@!" VALID _doc_it_schema $ "DN" WHEN set_opc_box( nBoxX, 50, "da li postoji dodatna shema kao prilog")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("dod.nap.stavke:", nLeft) GET _doc_it_desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "dodatne napomene vezane za samu stavku")

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("sirina [mm] (*):", nLeft + 3) GET _doc_it_width PICT Pic_Dim() VALID val_width(_doc_it_width) .and. rule_items("DOC_IT_WIDTH", _doc_it_width, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("visina [mm] (*):", nLeft + 3) GET _doc_it_heigh PICT Pic_Dim() VALID val_heigh(_doc_it_heigh) .and. rule_items("DOC_IT_HEIGH", _doc_it_heigh, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("kolicina [kom] (*):", nLeft + 3) GET _doc_it_qtty PICT Pic_Qtty() VALID val_qtty(_doc_it_qtty) .and. rule_items("DOC_IT_QTTY", _doc_it_qtty, aArtArr ) WHEN set_opc_box( nBoxX, 50 )


nX += 1

if rule_items("DOC_IT_ALTT", _doc_it_altt, aArtArr ) <> .t.


	@ m_x + nX, m_y + 2 SAY PADL("nadm. visina [m] (*):", nLeft + 3) GET _doc_it_altt PICT "999999" VALID val_altt(_doc_it_altt) WHEN set_opc_box( nBoxX, 50, "Nadmorska visina izrazena u metrima" )

	@ m_x + nX, col() + 2 SAY "grad:" GET _doc_acity VALID !EMPTY(_doc_acity) PICT "@S20" WHEN set_opc_box(nBoxX, 50, "Grad u kojem se montira proizvod")


else
	
	// pobrisi screen na lokaciji nadmorske visine
	@ m_x + nX, m_y + 2 SAY SPACE(70)
	
endif

// ako je nova stavka obezbjedi unos operacija...
if l_new_it

	nX += 2

	@ m_x + nX, m_y + 2 SAY PADL("unesi dod.oper.stavke (D/N)? (*):", nLeft + 15) GET cGetDOper PICT "@!" VALID cGetDOper $ "DN" WHEN set_opc_box( nBoxX, 50, "unos dodatnih operacija za stavku")

endif

read

ESC_RETURN 0

return 1


// ------------------------------------
// setuj matricu sa artiklom
// ------------------------------------
static function _set_arr( nArt_id, aArr )
local nTArea := SELECT()

_art_set_descr( nArt_id, .f., .f., @aArr, .t.)

select (nTArea)

return .t.



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


// -------------------------------------
// validacija nadmorske visine
// -------------------------------------
static function val_altt( nVal )
local lRet := .f.
if nVal <> 0
	lRet := .t.
endif

val_msg(lRet, "Nadmorska visina mora biti <> 0 !")

return lRet


// ----------------------------------
// validacija visine
// ----------------------------------
static function val_width( nVal )
local lRet := .f.
if nVal >= 0 .and. nVal <= max_width()
	lRet := .t.
endif
val_msg(lRet, "!! Dozvoljeni opseg 0 - " + ALLTRIM(STR(max_width())) + " mm" )
return lRet



// ----------------------------------
// validacija sirine
// ----------------------------------
static function val_heigh( nVal )
local lRet := .f.
if nVal >= 0 .and. nVal <= max_heigh()
	lRet := .t.
endif
val_msg(lRet, "!! Dozvoljeni opseg 0 - " + ALLTRIM(STR(max_heigh())) + " mm" )
return lRet



// -------------------------------------
// poruka pri validaciji
// -------------------------------------
static function val_msg(lRet, cMsg)
if lRet == .f.
	MsgBeeP(cMsg)
endif
return 


