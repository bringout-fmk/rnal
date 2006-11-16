#include "\dev\fmk\rnal\rnal.ch"

// variables

static art_id
static el_gr_id
static l_auto_tab

// ----------------------------------------------
// otvara formu za definisanje elemenata
// input: nArt_id - id artikla
// output: art_desc update u articles
// ----------------------------------------------
function s_elements( nArt_id )
local i
local nX
local nY
local nRet := 1
private nEl_id := 0
private nEl_gr_id := 0
private ImeKol
private Kol

art_id := nArt_id
l_auto_tab := .f.

Box(,21,77)

@ m_x, m_y + 25 SAY " DEFINISANJE ELEMENATA ARTIKLA "
@ m_x + 20, m_y + 1 SAY REPLICATE("Í", 77)
@ m_x + 17, m_y + 1 SAY "<c+N> nova"
@ m_x + 18, m_y + 1 SAY "<F2> ispravka"
@ m_x + 19, m_y + 1 SAY "<c+T> brisi"
@ m_x + 21, m_y + 15 SAY "<TAB> - browse tabela"

for i:=1 to 19
	@ m_x + i, m_y + 21 SAY "º"
next

select e_att
go top
select e_aops
go top
select elements
go top
m_y += 21

do while .t.
	
	
	if ALIAS() == "ELEMENTS"
		
		nX := 16
		nY := 20
		m_y -= 21
		@ m_x + 1, m_y + 2 SAY "** elementi"
		elem_kol(@ImeKol, @Kol)
		elem_filter( art_id )

	elseif ALIAS() == "E_ATT"
		
		nX := 10
		nY := 56
		m_y += 21
		@ m_x + 1, m_y + 2 SAY "** atributi"
		e_att_kol(@ImeKol, @Kol)
		e_att_filter(nEl_id)
	
	elseif ALIAS() == "E_AOPS"
	
		nX := 10
		nY := 56
		m_x += 10
		@ m_x + 1, m_y + 2 SAY "** dod.operacije"
		e_aops_kol(@ImeKol, @Kol)
		e_aops_filter(nEl_id)
	
	endif
	
	
	ObjDbedit("elem", nX, nY, {|Ch| elem_hand(Ch)}, "", "",,,,,1)

	if ALIAS() == "ELEMENTS"
		m_x -= 10
	endif

	if LastKey() == K_ESC
	
		select articles
		// generisi naziv artikla i update-uj
		nRet := _art_set_descr( art_id )
		go top

		exit
		
	endif

enddo

BoxC()

return nRet


static function auto_tab()
altd()
if l_auto_tab == .t.
	KEYBOARD K_TAB
	l_auto_tab := .f.
endif
return



// ----------------------------------------------------
// postavlja filter na tabelu ELEMENTS po polju ART_ID
// nArt_id - artikal id
// ----------------------------------------------------
static function elem_filter( nArt_id ) 
local cFilter
cFilter := "art_id == " + artid_str( nArt_id )
set filter to &cFilter
go top
return


// ---------------------------------------------------
// postavlja filter na tabelu E_ATT po polju EL_ID
//  nEl_id - element id
// ---------------------------------------------------
static function e_att_filter(nEl_id)
local cFilter := "el_id == " + elid_str(nEl_id)
set filter to &cFilter
go top
return


// ---------------------------------------------------
// postavlja filter na tabelu E_AOPS po polju EL_ID
//  nEl_id - element id
// ---------------------------------------------------
static function e_aops_filter(nEl_id)
local cFilter := "el_id == " + elid_str(nEl_id)
set filter to &cFilter
go top
return





// -----------------------------------------
// kolone tabele "elements"
// -----------------------------------------
static function elem_kol(aImeKol, aKol, nArt_id)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("elem.", 8), {|| PADL(ALLTRIM(elid_str(el_id)), 8) }, "el_id", {|| _inc_id(@wel_id, "EL_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("el.grupa", 10), {|| PADR(g_e_gr_desc( e_gr_id ), 10 ) }, "e_gr_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// -----------------------------------------
// kolone tabele "e_att"
// -----------------------------------------
static function e_att_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("atribut", 10), {|| PADR(g_gr_at_desc( g_gr_att_val( e_gr_vl_id ) ), 20) }, "el_id" })
AADD(aImeKol, {PADC("vrijedost atributa", 30), {|| PADR(g_e_gr_vl_desc( e_gr_vl_id ), 30) }, "e_gr_vl_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



// -----------------------------------------
// kolone tabele "e_aops"
// -----------------------------------------
static function e_aops_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("dod.operacija", 15), {|| PADR(g_aop_desc( aop_id ), 18) }, "aop_id"})
AADD(aImeKol, {PADC("atr.dod.operacije", 20), {|| PADR(g_aop_att_desc( aop_att_id ), 32) }, "aop_att_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -------------------------------
// convert el_id to string
// -------------------------------
function elid_str(nId)
return STR(nId, 10)




// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function elem_hand()
local nX := m_x
local nY := m_y
local GetList:={}
local nRec := RecNo()
local nRet := DE_CONT

do case
	
	case l_auto_tab == .t.
	
		KEYBOARD CHR(K_TAB)
		l_auto_tab := .f.
		return DE_REFRESH
		
	case Ch == K_TAB
		
		// browse kroz tabele
		
		if ALIAS() == "E_ATT"
			
			select e_aops
			nRet := DE_ABORT
			
		elseif ALIAS() == "ELEMENTS"
			
			if field->el_id == 0
				MsgBeep("Nema unesenih elemenata !!!!")
				nRet := DE_CONT
			else
			
				nEl_id := field->el_id
				el_gr_id := field->e_gr_id
			
				select e_att
				nRet := DE_ABORT
			endif
			
		elseif ALIAS() == "E_AOPS"
			
			select elements
			nRet := DE_ABORT
			
		endif
	
	case Ch == K_CTRL_N
	
		// nove stavke

		if ALIAS() == "ELEMENTS"
			
			nRet := elem_edit( art_id , .t. )
			l_auto_tab := .t.
			
			
		elseif ALIAS() == "E_ATT"

			nRet := e_att_edit( nEl_id, .t. )
		
		elseif ALIAS() == "E_AOPS"
		
			nRet := e_aops_edit( nEl_id, .t. )
		
		endif

	case Ch == K_F2
	
		// ispravka stavki

		if ALIAS() == "ELEMENTS"
			
			nRet := elem_edit( art_id , .f. )
			
		elseif ALIAS() == "E_ATT"
			
			nRet := e_att_edit( nEl_id, .f. )
		
		elseif ALIAS() == "E_AOPS"
		
			nRet := e_aops_edit( nEl_id, .f. )
		
		endif

	
	case Ch == K_CTRL_T
	
		// brisanje stavki

		if ALIAS() == "ELEMENTS"
			
			nRet := elem_del()
			
		elseif ALIAS() == "E_ATT"

			nRet := e_att_del()
		
		elseif ALIAS() == "E_AOPS"
		
			nRet := e_aops_del()
			
		endif

endcase

m_x := nX
m_y := nY

return nRet





// ----------------------------------------------
// ispravka elementa, unos novog elementa
//   nArt_id - artikal id
//   lNewRec - novi zapis .t. or .f.
// ----------------------------------------------
static function elem_edit( nArt_id, lNewRec )
local GetList:={}
local nEl_id := 0
local nLeft := 20

if lNewRec

	_inc_id(@nEl_id, "EL_ID")

endif

Scatter()

if lNewRec

	_el_id := nEl_id
	_art_id := nArt_id
	_e_gr_id := 0
endif

Box(,4,60)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos novog elementa *******"
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka elementa *******"
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("elem.grupa", nLeft) GET _e_gr_id VALID s_e_groups(@_e_gr_id)
	
	read
BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

if lNewRec

	append blank

endif

Gather()

return DE_REFRESH





// ----------------------------------------------
// ispravka atributa elementa, unos novog
//   nEl_id - element id
//   lNewRec - novi zapis .t. or .f.
// ----------------------------------------------
static function e_att_edit( nEl_id, lNewRec )
local GetList:={}
local nLeft := 15
local nEl_att_id := 0
local nE_gr_at_id := 0

if lNewRec

	_inc_id(@nEl_att_id, "EL_ATT_ID")

endif

Scatter()

if lNewRec

	_el_att_id := nEl_att_id
	_el_id := nEl_id
	_e_gr_vl_id := 0
endif

Box(,6,65)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos novog atributa elementa *******"
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka atributa elementa *******"
	endif
	
	if !lNewRec
		// uzmi koji je atribut....
		nE_gr_at_id := g_gr_att_val( _e_gr_vl_id )
	endif

	@ m_x + 3, m_y + 2 SAY PADL("atribut grupe", nLeft) GET nE_gr_at_id VALID {|| s_e_gr_att(@nE_gr_at_id, el_gr_id), show_it( g_gr_at_desc( nE_gr_at_id ) ) }
		
	@ m_x + 4, m_y + 2 SAY PADL("vrijednost ->", nLeft) GET _e_gr_vl_id VALID s_e_gr_val(@_e_gr_vl_id, nE_gr_at_id)
	
	read
BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

if lNewRec

	append blank

endif

Gather()
go top

return DE_REFRESH



// ----------------------------------------------
// ispravka operacija elementa, unos novih
//   nEl_id - element id
//   lNewRec - novi zapis .t. or .f.
// ----------------------------------------------
static function e_aops_edit( nEl_id, lNewRec )
local GetList:={}
local nLeft := 20
local nEl_op_id := 0

if lNewRec

	_inc_id(@nEl_op_id, "EL_OP_ID")

endif

Scatter()

if lNewRec

	_el_op_id := nEl_op_id
	_el_id := nEl_id
	_aop_id := 0
	_aop_att_id := 0
endif

Box(,6,65)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos dodatnih operacija elementa *******"
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka dodatnih operacija elementa *******"
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("dodatna operacija", nLeft) GET _aop_id VALID {|| s_aops(@_aop_id), show_it( g_aop_desc( _aop_id ) ) }
		
	@ m_x + 4, m_y + 2 SAY PADL("atribut operacije", nLeft) GET _aop_att_id VALID {|| s_aops_att( @_aop_att_id, _aop_id ), show_it( g_aop_att_desc( _aop_att_id ) )  }
	
	read
BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

if lNewRec

	append blank

endif

Gather()

return DE_REFRESH




// ----------------------------------------------
// brisanje elementa
// ----------------------------------------------
static function elem_del()

if Pitanje(,"Izbrisati stavku ???", "N") == "N"
	return DE_CONT
endif

delete

return DE_REFRESH



// ----------------------------------------------
// brisanje atributa elementa
// ----------------------------------------------
static function e_att_del()

if Pitanje(,"Izbrisati stavku ???", "N") == "N"
	return DE_CONT
endif

delete

return DE_REFRESH



// ----------------------------------------------
// brisanje dodatne operacije elementa
// ----------------------------------------------
static function e_aops_del()

if Pitanje(,"Izbrisati stavku ???", "N") == "N"
	return DE_CONT
endif

delete

return DE_REFRESH



