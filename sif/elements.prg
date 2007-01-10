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
function s_elements( nArt_id, lNew )
local i
local nX
local nY
local nRet := 1
local cCol2 := "W+/G"
local cLineClr := "GR+/B"
private nEl_id := 0
private nEl_gr_id := 0
private ImeKol
private Kol

if lNew == nil
	lNew := .f.
endif

art_id := nArt_id
l_auto_tab := .f.

Box(,21,77)

@ m_x, m_y + 15 SAY " DEFINISANJE ELEMENATA ARTIKLA: " + artid_str(art_id) + " "
@ m_x + 20, m_y + 1 SAY REPLICATE("Í", 77) COLOR cLineClr
@ m_x + 16, m_y + 1 SAY "<c+N> nova"
@ m_x + 17, m_y + 1 SAY "<F2> ispravka"
@ m_x + 18, m_y + 1 SAY "<c+T> brisi"
@ m_x + 21, m_y + 1 SAY "<TAB> - browse tabela  | <ESC> snimanje promjena "

// uspravna crta
for i:=1 to 19
	@ m_x + i, m_y + 21 SAY "º" COLOR cLineClr
next
// vertikalna crta
@ m_x + 10, m_y + 22 SAY REPLICATE("Í", 56) COLOR cLineClr


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
		
		_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				cCol2, ;
				"** elementi", ;
				11 )
		
		elem_kol(@ImeKol, @Kol)
		elem_filter( art_id )

	elseif ALIAS() == "E_ATT"
		
		nX := 10
		nY := 56
		m_y += 21
		
		_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				cCol2, ;
				"** atributi", ;
				20 )
		
		e_att_kol(@ImeKol, @Kol)
		e_att_filter(nEl_id)
	
	elseif ALIAS() == "E_AOPS"
	
		nX := 10
		nY := 56
		m_x += 10
		
		_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				cCol2, ;
				"** dod.operacije", ; 
				20 )
		
		e_aops_kol(@ImeKol, @Kol)
		e_aops_filter(nEl_id)
	
	endif
	
	ObjDbedit("elem", nX, nY, {|Ch| elem_hand(Ch)}, "", "",,,,,1)

	if ALIAS() == "ELEMENTS"
		m_x -= 10
	endif

	if LastKey() == K_ESC
	
		// generisi naziv artikla i update-uj artikal art_id
		select articles
		nRet := _art_set_descr( art_id, lNew )
		select articles
		
		exit
		
	endif

enddo

BoxC()

return nRet



// ------------------------------------------------------
// provjeri da li su svi atributi elementa uneseni...
// vraca 0 ili 1
// ------------------------------------------------------
static function _chk_elements( nArt_id )
local nRet := 1
local nTArea := SELECT()
local nEl_id := 0

select elements
set order to tag "1"
go top
seek artid_str( art_id )

do while !EOF() .and. field->art_id == nArt_id
	
	nEl_id := field->el_id

	select e_att
	set order to tag "1"
	go top
	seek elid_str( nEl_id )

	do while !EOF() .and. field->el_id == nEl_id
		
		// ako postoji vrijednost ok
		if field->e_gr_vl_id <> 0
		
			select e_att
			skip
			loop
			
		endif
	
		// inace izbaci da nije sve ok.
		
		nRet := 0
		
		MsgBeep("Atribut: '" + ;
			ALLTRIM(g_gr_at_desc(field->e_gr_at_id)) + ;
			"' nije definisan !!!" )
		
		select (nTArea)
		return nRet
	
	enddo

	select elements
	skip
enddo

select (nTArea)
return nRet



// ----------------------------------------------------------------
// provjerava da li vec postoji isti artikal sa istim elementima
// vraca .t. ili .f.
// ----------------------------------------------------------------
static function _art_exist()
local lRet := .f.
return lRet



// ------------------------------------
// automatski pozovi TAB
// ------------------------------------
static function auto_tab()
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

AADD(aImeKol, {"e", {|| " " }, "el_id", {|| _inc_id(@wel_id, "EL_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("el.grupa", 15), {|| PADR(g_e_gr_desc( e_gr_id ), 15 ) }, "e_gr_id"})

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

AADD(aImeKol, {PADC("atribut", 10), {|| PADR(g_gr_at_desc( e_gr_at_id, .t. ), 20) }, "e_gr_at_id" })
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
local nTRec := 0
local nRet := DE_CONT

do case
	
	case l_auto_tab == .t.
	
		KEYBOARD CHR(K_TAB)
		l_auto_tab := .f.
		return DE_REFRESH
	
	case Ch == K_TAB
		
		// browse kroz tabele
		
		if ALIAS() == "E_ATT"
			
			_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				nil, ;
				"** atributi", ;
				20 )
		
			select e_aops
			nRet := DE_ABORT
			
		elseif ALIAS() == "ELEMENTS"
			
			if field->el_id == 0
				
				MsgBeep("Nema unesenih elemenata !!!!")
				nRet := DE_CONT
				
			else
			
				_say_tbl_desc( m_x + 1, ;
					m_y + 1, ;
					nil, ;
					"** elementi", ;
					11 )
		
			
				nEl_id := field->el_id
				el_gr_id := field->e_gr_id
			
				select e_att
				nRet := DE_ABORT
				
			endif
			
		elseif ALIAS() == "E_AOPS"
			
			_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				nil, ;
				"** dod.operacije", ;
				20 )
		
			select elements
			nRet := DE_ABORT
			
		endif
	
	case Ch == K_CTRL_N
	
		// nove stavke

		cTBFilter := DBFILTER()

		if ALIAS() == "ELEMENTS"
			
			nRet := DE_REFRESH
			
			if elem_edit( art_id , .t. ) == 1
			
				l_auto_tab := .t.
				//set filter to &cTBFilter
				
			else
			
				//set filter to &cTBFilter
				go top
			
			endif
			 
		elseif ALIAS() == "E_ATT"

			nRet := DE_REFRESH
			
			if e_att_edit( nEl_id, .t. ) == 1
				//set filter to &cTBFilter
			else
				//set filter to &cTBFilter
				go top
			endif
		
		elseif ALIAS() == "E_AOPS"
		
			nRet := DE_REFRESH
		
			if e_aops_edit( nEl_id, .t. ) == 1
				//set filter to &cTBFilter
			else
				//set filter to &cTBFilter
				go top
			endif
	
		endif

	case Ch == K_F2 .or. Ch == K_ENTER
	
		// ispravka stavki
		
		cTBFilter := DBFILTER()

		if ALIAS() == "ELEMENTS"
			
			//nRet := elem_edit( art_id , .f. )
			//set filter to &cTBFilter
			//go top
			
			Msgbeep("Opcija onemogucena##Koristiti c-N ili c-T")
			nRet := DE_CONT
			
		elseif ALIAS() == "E_ATT"
			
			nRet := DE_REFRESH
			e_att_edit( nEl_id, .f. )
			set filter to &cTbFilter
			go top
		
		elseif ALIAS() == "E_AOPS"
		
			nRet := DE_REFRESH
			e_aops_edit( nEl_id, .f. )
			set filter to &cTbFilter
			go top
		
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
local nEl_id := 0
local nLeft := 25
local nRet := DE_CONT
local cColor := "BG+/B"
private GetList:={}

if !lNewRec .and. field->el_id == 0

	MsgBeep("Stavka ne postoji !!!#Koristite c-N da dodate novu!")
	return DE_REFRESH
	
endif

if lNewRec
	
	altd()
	
	if _set_sif_id(@nEl_id, "EL_ID") == 0
		return 0
	endif

endif

Scatter()

if lNewRec

	_art_id := nArt_id
	_e_gr_id := 0
endif

Box(,4,60)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos novog elementa *******" COLOR cColor
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka elementa *******" COLOR cColor
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("element pripada grupi->", nLeft) GET _e_gr_id VALID s_e_groups( @_e_gr_id, .t. )
	@ m_x + 4, m_y + 2 SAY PADL("0 - otvori sifrarnik", nLeft)
	
	read
BoxC()

if LastKey() == K_ESC .and. lNewRec

	Gather()
	delete
	
	return 0
	
endif

Gather()

if lNewRec
	// nafiluj odmah atribute za ovu grupu...
	__fill_att__( e_gr_id, nEl_id )
	select elements
endif

return 1



// ----------------------------------------------------
// filovanje tabele e_att sa atributima grupe
// ----------------------------------------------------
static function __fill_att__( __gr_id, __el_id )
local nTArea := SELECT()
local nEl_att_id := 0

select e_gr_att
set order to tag "2"
go top
seek e_gr_id_str( __gr_id ) + "*"

do while !EOF() .and. field->e_gr_id == __gr_id ;	
		.and. field->e_gr_at_re == "*"

	
	select e_att
	
	if _set_sif_id(@nEl_att_id, "EL_ATT_ID") == 0
		select e_gr_att
		loop
	endif

	Scatter()

	_el_id := __el_id
	_el_att_id := nEl_att_id
	_e_gr_at_id := e_gr_att->e_gr_at_id
	_e_gr_vl_id := 0

	Gather()
	
	select e_gr_att
	skip

enddo

select (nTArea)
return



// ----------------------------------------------
// ispravka atributa elementa, unos novog
//   nEl_id - element id
//   lNewRec - novi zapis .t. or .f.
// ----------------------------------------------
static function e_att_edit( nEl_id, lNewRec )
local nLeft := 25
local nEl_att_id := 0
local cColor := "BG+/B"
private GetList:={}

if !lNewRec .and. field->el_id == 0

	MsgBeep("Stavka ne postoji !!!#Koristite c-N da dodate novu!")
	return DE_REFRESH
	
endif

if lNewRec

	if _set_sif_id(@nEl_att_id, "EL_ATT_ID") == 0
		return 0
	endif

endif

Scatter()

if lNewRec

	_el_id := nEl_id
	_e_gr_vl_id := 0
	_e_gr_at_id := 0
endif

Box(,6,65)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos novog atributa elementa *******" COLOR cColor
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka atributa elementa *******" COLOR cColor
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("izaberi atribut elementa", nLeft) GET _e_gr_at_id VALID {|| s_e_gr_att(@_e_gr_at_id, el_gr_id, nil, .t. ), show_it( g_gr_at_desc( _e_gr_at_id ) ) } WHEN lNewRec == .t.
		
	@ m_x + 4, m_y + 2 SAY PADL("izaberi vrijednost atributa", nLeft) GET _e_gr_vl_id VALID s_e_gr_val(@_e_gr_vl_id, _e_gr_at_id, nil, .t.)
	
	@ m_x + 5, m_y + 2 SAY PADL("0 - otvori sifrarnik", nLeft)
	
	read
BoxC()

if LastKey() == K_ESC .and. lNewRec
	
	Gather()
	delete
	
	return 0
	
endif

Gather()

return 1



// ----------------------------------------------
// ispravka operacija elementa, unos novih
//   nEl_id - element id
//   lNewRec - novi zapis .t. or .f.
// ----------------------------------------------
static function e_aops_edit( nEl_id, lNewRec )
local nLeft := 25
local nEl_op_id := 0
local cColor := "BG+/B"
private GetList:={}

if !lNewRec .and. field->el_id == 0

	Msgbeep("Stavka ne postoji !!!#Koristite c-N da bi dodali novu!")
	return DE_REFRESH
	
endif

if lNewRec

	if _set_sif_id(@nEl_op_id, "EL_OP_ID") == 0
		return 0
	endif

endif

Scatter()

if lNewRec

	_el_id := nEl_id
	_aop_id := 0
	_aop_att_id := 0
endif

Box(,6,65)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos dodatnih operacija elementa *******" COLOR cColor
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka dodatnih operacija elementa *******" COLOR cColor
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("izaberi dodatnu operaciju", nLeft) GET _aop_id VALID {|| s_aops(@_aop_id, nil, .t.), show_it( g_aop_desc( _aop_id ) ) }
		
	@ m_x + 4, m_y + 2 SAY PADL("izaberi atribut operacije", nLeft) GET _aop_att_id VALID {|| s_aops_att( @_aop_att_id, _aop_id, nil, .t. ), show_it( g_aop_att_desc( _aop_att_id ) )  }
	
	@ m_x + 5, m_y + 2 SAY PADL("0 - otvori sifrarnik", nLeft)
	
	read
BoxC()

if LastKey() == K_ESC .and. lNewRec

	Gather()
	delete
	
	return 0
	
endif

Gather()

return 1




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



