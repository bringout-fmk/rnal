#include "\dev\fmk\rnal\rnal.ch"

static art_id


function s_elements(nArt_id)
local i
local nX
local nY
private nEl_id := 0
private ImeKol
private Kol

art_id := nArt_id

Box(,21,77)

@ m_x, m_y + 20 SAY "---- DEFINISANJE ELEMENATA ARTIKLA -----"
@ m_x + 20, m_y + 1 SAY REPLICATE("Í", 77)
@ m_x + 21, m_y + 1 SAY "<TAB> - kroz tabele..."

for i:=1 to 19
	@ m_x + i, m_y + 39 SAY "º"
next

select e_att
go top
select e_aops
go top
select elements
go top
m_y += 40

do while .t.

	if ALIAS() == "ELEMENTS"
		
		nX := 21
		nY := 38
		m_y -= 40
		elem_kol(@ImeKol, @Kol)

	elseif ALIAS() == "E_ATT"
		
		nX := 10
		nY := 38
		m_y += 40
		e_att_kol(@ImeKol, @Kol)
		e_att_filter(nEl_id)
	
	elseif ALIAS() == "E_AOPS"
	
		nX := 10
		nY := 38
		//m_y += 40
		m_x += 10
		e_aop_kol(@ImeKol, @Kol)
		e_aop_filter(nEl_id)
	
	endif
	
	ObjDbedit("elem", nX, nY, {|Ch| elem_hand(Ch)}, "", "",,,,,1)

	if ALIAS() == "ELEMENTS"
		m_x -= 10
	endif

	if LastKey() == K_ESC
		exit
	endif

enddo

BoxC()

return




// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function elem_kol(aImeKol, aKol, nArt_id)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| el_id}, "el_id", {|| _inc_id(@wel_id, "EL_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Artikal", 10), {|| g_art_desc( art_id ) }, "art_id", {|| .t.}, {|| wart_id := nArt_id } })
AADD(aImeKol, {PADC("Grupa", 10), {|| g_e_gr_desc( e_gr_id ) }, "e_gr_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


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
	
	case Ch == K_TAB
		
		// browse kroz tabele
		
		if ALIAS() == "E_ATT"
			select e_aops
			go top
		elseif ALIAS() == "ELEMENTS"
			select e_att
			go top
		elseif ALIAS() == "E_AOPS"
			select elements
			go top
		endif
		nRet := DE_ABORT
	
	case Ch == K_CTRL_N
	
		// nove stavke

		if ALIAS() == "ELEMENTS"
			
			nRet := elem_new( art_id )
			
		elseif ALIAS() == "E_ATT"
		
		elseif ALIAS() == "E_AOPS"
		
		endif
	
endcase

m_x := nX
m_y := nY

return nRet


// -------------------------------
// convert el_id to string
// -------------------------------
function elid_str(nId)
return STR(nId, 10)



static function elem_new(nArt_id)
local GetList:={}
local nEl_id := 0

_inc_id(@nEl_id, "EL_ID")

Scatter()

_el_id := nEl_id
_art_id := nArt_id

Box(,3,60)
	@ m_x + 1, m_y + 2 SAY "ID:" + elid_str(_el_id)
	@ m_x + 2, m_y + 2 SAY "Artikal:" + artid_str(_art_id)
	@ m_x + 3, m_y + 2 SAY "Grupa:" GET _e_gr_id VALID s_e_groups(@_e_gr_id)
	read
BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

append blank
Gather()

return DE_REFRESH



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function e_att_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| el_att_id}, "el_att_id", {|| _inc_id(@wel_att_id, "EL_ATT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Element", 10), {|| el_id }, "art_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADC("Vrijed.", 10), {|| g_e_gr_vl_desc( e_gr_vl_id ) }, "e_gr_vl_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


static function e_att_filter(nEl_id)
local cFilter := "el_id == " + elid_str(nEl_id)
set filter to &cFilter
return




// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function e_aop_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| el_op_id}, "el_op_id", {|| _inc_id(@wel_op_id, "EL_OP_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Element", 10), {|| el_id }, "el_id", {|| .t.}, {|| .t. } })
AADD(aImeKol, {PADC("Dod.oper.", 10), {|| g_aop_desc( aop_id ) }, "aop_id"})
AADD(aImeKol, {PADC("Atrib.d.op", 10), {|| g_aop_att_desc( aop_att_id ) }, "aop_att_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



static function e_aop_filter(nEl_id)
local cFilter := "el_id == " + elid_str(nEl_id)
set filter to &cFilter
return









