#include "\dev\fmk\rnal\rnal.ch"

// variables

// novi dokument, bool
static l_new
static _doc
static _doc_it
static l_auto_tab

// ---------------------------------------------
// edit dokument
// lNewDoc - novi dokument .t. or .f.
// ---------------------------------------------
function ed_document( lNewDoc )

if lNewDoc == nil
	lNewDoc := .f.
endif

l_new := lNewDoc

// otvori radne i pripremne tabele...
o_tables(.t.)

// otvori unos dokumenta
_document()

return



// ---------------------------------------------
// otvara unos novog dokumenta
// ---------------------------------------------
static function _document()
local cHeader
local cFooter
local i
local nX
local nY
local nRet := 1
private ImeKol
private Kol

Box(, 22, 77)

l_auto_tab := .f.

select _doc_it
go top
select _doc_ops
go top
select _docs
go top
_doc := _docs->doc_no

// ispisi header i footer
header_footer()

m_y += 50
m_x += 6

do while .t.

	if ALIAS() == "_DOCS"
		
		nX := 6
		nY := 78
		
		m_x -= 6
		m_y -= 50
		
		@ m_x + 1, m_y + 2 SAY "*** osnovni podaci" COLOR "I"
		
		docs_kol(@ImeKol, @Kol)
		
	elseif ALIAS() == "_DOC_IT"

		nX := 15
		nY := 49
		
		m_x += 6
		
		@ m_x + 1, m_y + 2 SAY "*** stavke naloga" COLOR "I"
		
		docit_kol(@ImeKol, @Kol)

	elseif ALIAS() == "_DOC_OPS"

		nX := 15
		nY := 28
		
		m_y += 50
		
		@ m_x + 1, m_y + 2 SAY "*** dod.oper." COLOR "I"
		
		docop_kol(@ImeKol, @Kol)
		
	endif
	
	ObjDBedit("docum", nX, nY, {|Ch| key_handler(Ch)},"","",,,,,1)

	if ALIAS() == "_DOCS"
		
		//m_x -= 6
		//m_y -= 50
		
	endif

	if LastKey() == K_ESC
	
		exit
	
	endif

enddo

BoxC()

return nRet



// -----------------------------------------------
// prikazi header i footer 
// -----------------------------------------------
static function header_footer()
local nTArea := SELECT()
local cHeader
local cFooter

cFooter := "<TAB> browse tabela |<c+N> nova stavka..."

cHeader := "dok.broj: "
cHeader += doc_str( _doc )
cHeader += SPACE(5)

if l_new
	cHeader += "UNOS NOVOG DOKUMENTA"
else
	cHeader += "DORADA DOKUMENTA"
endif

cHeader += SPACE(5)
cHeader += "operater: "
cHeader += ALLTRIM( goModul:oDataBase:cUser )

@ m_x, m_y + 2 SAY cHeader
@ m_x + 6, m_y + 1 SAY REPLICATE("Í", 78)
@ m_x + 21, m_y + 1 SAY REPLICATE("Í", 78)
@ m_x + 22, m_y + 1 SAY cFooter

for i:=7 to 20
	@ m_x + i, m_y + 50 SAY "º"
next

select (nTArea)

return



// ---------------------------------------------
// setuje matricu kolona tabele _DOCS
// ---------------------------------------------
static function docs_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {PADC("Narucioc", 20), {|| PADR(g_cust_desc( cust_id ), 18) + ".."}, "cust_id" })
AADD(aImeKol, {PADC("Datum", 8), {|| doc_date}, "doc_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADC("Dat.isp", 8), {|| doc_dvr_date}, "doc_dvr_date" })
AADD(aImeKol, {"Vr.isp", {|| PADR(doc_dvr_time, 5)}, "doc_dvr_time"  })
AADD(aImeKol, {"Mj.isp", {|| PADR(doc_ship_place,10)}, "doc_ship_place" })
AADD(aImeKol, {"Kontakt", {|| PADR(g_cont_desc( cont_id ), 8) + ".." }, "cont_id" })
AADD(aImeKol, {"Kont.opis", {|| PADR(cont_add_desc, 18) + ".."}, "cont_add_desc" })
AADD(aImeKol, {"Vrsta p.", {|| doc_pay_id}, "doc_pay_id" })
AADD(aImeKol, {"Prioritet", {|| doc_priority}, "doc_priority" })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_IT
// ---------------------------------------------
static function docit_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"R.br", {|| doc_it_no }, "doc_it_no" })
AADD(aImeKol, {"Artikal", {|| PADR(g_art_desc( art_id ), 18) + ".." }, "art_id" })
AADD(aImeKol, {"sirina", {|| TRANSFORM(doc_it_width, PIC_DIM()) }, "doc_it_width" })
AADD(aImeKol, {"visina", {|| TRANSFORM(doc_it_heigh, PIC_DIM()) }, "doc_it_heigh" })
AADD(aImeKol, {"kol.", {|| TRANSFORM(doc_it_qtty, PIC_QTTY()) }, "doc_it_qtty" })


for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_OP
// ---------------------------------------------
static function docop_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"dod.oper", {|| PADR(g_aop_desc( aop_id ),10) }, "aop_id"})
AADD(aImeKol, {"atr.dod.oper", {|| PADR( g_aop_att_desc( aop_att_id ), 10 )}, "aop_att_id" })
AADD(aImeKol, {"dod.opis", {|| PADR(doc_op_desc, 15) + ".."}, "doc_op_desc" })

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return




// ---------------------------------------------
// obrada dogadjaja na tipke tastature
// ---------------------------------------------
static function key_handler()
local nRet := DE_CONT
local nX := m_x
local nY := m_y
local GetList := {}
local nRec := RecNo()
local nDocNoNew := 0
local cDesc := ""

do case 

	// automatski tab
	case l_auto_tab == .t.

		KEYBOARD CHR(K_TAB)
		l_auto_tab := .f.
		return DE_REFRESH

	// browse tabele
	case Ch == K_TAB

		if ALIAS() == "_DOCS"
			
			select _doc_it
			nRet := DE_ABORT
			
		elseif ALIAS() == "_DOC_IT"
			
			select _doc_ops
			nRet := DE_ABORT

		elseif ALIAS() == "_DOC_OPS"

			select _docs
			nRet := DE_ABORT
			
		endif

	// nove stavke
	case Ch == K_CTRL_N
	
		nRet := DE_CONT

		if ALIAS() == "_DOCS"
		
			if e_doc_main_data( .t. ) == 1
			
				select _docs
				nRet := DE_REFRESH
				l_auto_tab := .t.

			endif
			
			select _docs
			
		elseif ALIAS() == "_DOC_IT"

			select _docs
			if RECCOUNT2() == 0
				MsgBeep("Nema definisanog naloga !!!")
				select _doc_it
				return DE_CONT
			endif
			
			select _doc_it
			
			if e_doc_item( _doc, .t. ) <> 0
			
				select _doc_it
				nRet := DE_REFRESH

			endif
			
			select _doc_it
	
		elseif ALIAS() == "_DOC_OPS"

			select _docs
			if RECCOUNT2() == 0
				MsgBeep("Nema definisanog naloga !!!")
				select _doc_ops
				return DE_CONT
			endif
			
			select _doc_ops
			
			if e_doc_ops( _doc, .t. ) <> 0
			
				select _doc_ops
				nRet := DE_REFRESH

			endif
			
			select _doc_ops
			
		endif
				
	case Ch == K_F2
	
		nRet := DE_CONT
		
		if RECCOUNT2() == 0
			return nRet
		endif
		
		if ALIAS() == "_DOCS"
		
			if e_doc_main_data( .f. ) == 1
			
				select _docs
				nRet := DE_REFRESH

			endif

			select _docs
		
		elseif ALIAS() == "_DOC_IT"

			if e_doc_item( _doc, .f. ) <> 0
			
				select _doc_it
				nRet := DE_REFRESH

			endif

			select _doc_it
	
		elseif ALIAS() == "_DOC_OPS"

			if e_doc_ops( _doc, .f. ) <> 0
			
				select _doc_ops
				nRet := DE_REFRESH

			endif

			select _doc_ops
	
		endif
	
	case Ch == K_CTRL_T

		nRet := DE_CONT
		
		if ALIAS() == "_DOCS"
			
			if docs_delete() == 1
			
				l_auto_tab := .t.
				KEYBOARD CHR(K_TAB)
				nRet := DE_REFRESH
				
			endif
			
		elseif ALIAS() == "_DOC_IT"

			if docit_delete() == 1
				
				nRet := DE_REFRESH
				
			endif

		elseif ALIAS() == "_DOC_OPS"

			if docop_delete() == 1
			
				nRet := DE_REFRESH
			
			endif
			
		endif
	
	case Ch == K_ALT_A
		
		nRet := DE_CONT
		
		if ALIAS() == "_DOCS" .and. RECCOUNT2() <> 0 .and. ;
			Pitanje(,"Izvrsiti azuriranje dokumenta (D/N) ?", "D") == "D"

		
			// busy....
			if field->doc_status == 3
				_g_doc_desc( @cDesc )
			endif
			
			// uzmi novi broj dokumenta
			nDocNoNew := _new_doc_no()

			// filuj sve tabele sa novim brojem
			fill__doc_no( nDocNoNew )
			
			if doc_insert( cDesc ) == 1
				
				select _docs
				l_auto_tab := .t.
				KEYBOARD CHR(K_TAB)
				nRet := DE_REFRESH
						
			endif
		
		elseif ALIAS() <> "_DOCS"
			Msgbeep("Pozicionirajte se na tabelu osnovnih podataka")
		
		endif
		
		return nRet

	case Ch == K_CTRL_P

		// stampa naloga
		nTArea := SELECT()
		
		select _docs
		
		// uzmi novi broj dokumenta
		nDocNoNew := _new_doc_no()

		// filuj sve tabele sa novim brojem
		fill__doc_no( nDocNoNew )
		
		select _docs
		go top
		
		st_nalpr( .t. , _docs->doc_no )
		
		select (nTArea)
		go top

		nRet := DE_CONT
	
endcase

m_x := nX
m_y := nY

return nRet

// ----------------------------------------
// vraca box sa opisom
// ----------------------------------------
function _g_doc_desc( cDesc )
local GetList := {}

Box(,3, 70)
	cDesc := SPACE(150)
	@ m_x + 2, m_y + 2 SAY "Opis:" GET cDesc VALID !EMPTY(cDesc) PICT "@S60"
	read
BoxC()

ESC_RETURN 0

return 1



// --------------------------------------------
// opcija brisanja dokumenta
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docs_delete( lSilent )
if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati nalog iz pripreme (D/N) ?!???", "N") == "N"
	return 0
endif

// brisi dokument
delete

select _doc_it
go top
do while !EOF()
	delete
	skip
enddo

select _doc_ops
go top
do while !EOF()
	delete
	skip
enddo

select _docs
go top

return 1


// --------------------------------------------
// opcija brisanja stavke naloga
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docit_delete( lSilent )
local nDoc_it_no

if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
	return 0
endif

nDoc_it_no := field->doc_it_no

delete

select _doc_ops
set order to tag "1"
go top
seek doc_str( _doc ) + docit_str( nDoc_it_no )

do while !EOF() .and. field->doc_no == _doc ;
		.and. field->doc_it_no == nDoc_it_no

	delete
	skip
enddo

select _doc_it

return 1


// --------------------------------------------
// opcija brisanja operacije
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docop_delete( lSilent )
if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
	return 0
endif

delete

return 1



// --------------------------------
// vraca string za doc_no
// --------------------------------
function doc_str(nNo)
return STR(nNo, 10)


// --------------------------------
// vraca string za doc_it_no
// --------------------------------
function docit_str(nNo)
return STR(nNo, 4)


// --------------------------------
// vraca string za doc_op_no
// --------------------------------
function docop_str(nNo)
return STR(nNo, 4)



