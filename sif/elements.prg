#include "\dev\fmk\rnal\rnal.ch"

// variables

static art_id
static el_gr_id
static l_auto_tab
static __el_schema

// ----------------------------------------------
// otvara formu za definisanje elemenata
// input: nArt_id - id artikla
// input: nArtType - tip artikla (jednostruko, visestruko...)
// output: art_desc update u articles
// ----------------------------------------------
function s_elements( nArt_id, lNew, nArtType )
local i
local nX
local nY
local nRet := 1
local cCol2 := "W+/G"
local cLineClr := "GR+/B"
local cSchClr := "R+/W"
local lRuleRet := .t.
private nEl_id := 0
private nEl_gr_id := 0
private ImeKol
private Kol

if lNew == nil
	lNew := .f.
endif

// ako ga nema definisanog ili ako je OSTALO onda je 0 - sve ide po starom
if nArtType == nil
	nArtType := 0
endif

art_id := nArt_id
l_auto_tab := .f.

__el_schema := "----"

if nArtType <> 0
	// automatski generisi shemu elemenata
	__el_schema := auto_el_gen( nArt_id, nArtType )
endif


Box(,21,77)

@ m_x, m_y + 15 SAY " DEFINISANJE ELEMENATA ARTIKLA: " + artid_str(art_id) + " "
@ m_x + 20, m_y + 1 SAY REPLICATE("Í", 77) COLOR cLineClr
@ m_x + 16, m_y + 1 SAY "<c+N> nova"
@ m_x + 17, m_y + 1 SAY "<F2> ispravka"
@ m_x + 18, m_y + 1 SAY "<c+T> brisi"
@ m_x + 21, m_y + 1 SAY "<TAB>-brow.tabela | <ESC> snimi "

// na dnu dodaj i schemu da se zna sta se pravi...

@ m_x + 21, col() + 2 SAY "|"
@ m_x + 21, col() + 1 SAY "shema: "
@ m_x + 21, col() + 1 SAY PADR( STRTRAN( __el_schema, "#", "-" ), 25 ) ;
			COLOR cSchClr


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

	
	// uzmi matricu artikla......
	// te provjeri pravilo......
	
	// pomocna matrica...
	aTmp := {}
	nTmpArea := SELECT()

	// uzmi podatke u matricu....
	_art_set_descr( art_id , lNew, .f., @aTmp, .t. )

	select (nTmpArea)


	// provjeri pravilo....
	// Samo na <> ESC, problem sa TBrowse...
	if LastKey() <> K_ESC
		
		nTmpX := m_x
	
		lRuleRet := rule_articles( aTmp )
	
		m_x := nTmpX
	
		select ( nTmpArea )
		
	endif
	
	// pomjeri koordinatu
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



// ------------------------------------------------
// automatska shema elemenata prema tip artikla
// ------------------------------------------------
static function auto_el_gen( nArt_id, nArtType )
local nTArea := SELECT()
local cSchema
local aSchema
local cSep := "#"

// iz pravila mi izvuci shemu za kreiranje artikla po tipu
// shema je: G#F#G - za dvostruko
//           G - za jednostruko
//           G#F#G#F#G - trostruko itd... itd...
//

cSchema := _get_el_schema( nArtType )

// aschema[1] = G
// aschema[2] = F
// aschema[3] = G
// ......

aSchema := TokToNiz( cSchema, cSep )


for i := 1 to LEN(aSchema)

	// dodaj element...
	// tipa = aSchema[i] = G ili F ili ????
	select elements
	
	elem_edit( nArt_id, .t., ALLTRIM( aSchema[i] ), i )
	
next

select (nTArea)

return cSchema



// -----------------------------------------------------
// vraca schemu za pojedini tip aritkla
// povezi se sa pravilima....
// -----------------------------------------------------
static function _get_el_schema( nArtType )
local cSchema := ""
local aTmp 

altd()

// uzmi u matricu pravila....
aTmp := r_el_schema( nArtType )

// ima pravila ?
if LEN( aTmp ) > 0

	// sad za sada uzmi prvo pravilo !
	//
	// aTmp[1,1] = "G#F#G"    pravilo 1
	// aTmp[1,2] = "G#F#G#G"  pravilo 2
	// .... itd...
	// moze biti vise pravila za jedan tip
	
	cSchema := aTmp[1, 1]

else

     // default pravila...
     do case
	
	// jednostruko staklo
	case nArtType == 1
		cSchema := "G"
		
	// dvostruko staklo
	case nArtType == 2
		cSchema := "G#F#G"
		
	// visestruko staklo
	case nArtType == 3
		cSchema := "G#F#G#F#G"
		
     endcase

     msgbeep("Pravilo za ovaj tip ne postoji, koristim default#" + STRTRAN(cSchema, "#", "-" ))

endif

return cSchema




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

AADD(aImeKol, {"rb", {|| el_no }, "el_no", {|| _inc_id(@wel_id, "EL_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("el.grupa", 15), {|| PADR(g_e_gr_desc( e_gr_id ), 15 ) }, "e_gr_id"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------------
// uvecaj el_no, za elemente artikla
// -----------------------------------------------
static function _inc_el_no( wel_no, nArt_id )
local nTRec
local cTBFilter := DBFILTER()

set filter to
set order to tag "1"
	
wel_no := _last_elno( nArt_id ) + 1
	
set filter to &cTBFilter
set order to tag "1"

return .t.


// -------------------------------------------
// vraca posljednji zapis za artikal
// -------------------------------------------
static function _last_elno( nArtId )
local nLast_rec := 0

go top
seek artid_str( nArtId ) + STR(9999, 4)

skip -1

if field->art_id <> nArtId
	nLast_rec := 0	
else
	nLast_rec := field->el_no
endif

return nLast_rec


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
			
			if Ch == K_ENTER	
			
				Msgbeep("Opcija onemogucena##Koristiti F2")
				nRet := DE_CONT
				
			else
				// ispravka rednog broja elementa...
				
				nRet := DE_REFRESH
				
				e_no_edit()
				
				set filter to &cTbFilter
				go top
				
			endif
			
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
//   cType - tip elementa, ako postoji automatski 
//           ga dodaje
//   nEl_no - brojac elementa
// ----------------------------------------------
static function elem_edit( nArt_id, lNewRec, cType, nEl_no )
local nEl_id := 0
local nLeft := 30
local nRet := DE_CONT
local cColor := "BG+/B"
private GetList:={}

if cType == nil
	cType := ""
endif

if !lNewRec .and. field->el_id == 0

	MsgBeep("Stavka ne postoji !!!#Koristite c-N da dodate novu!")
	return DE_REFRESH
	
endif

if lNewRec
	
	if _set_sif_id(@nEl_id, "EL_ID") == 0
		return 0
	endif

endif

Scatter()

if lNewRec

	_art_id := nArt_id

	if EMPTY( cType )
	
		// uvecaj redni broj elementa... klasicni brojac
		// brojac iz baze
		_inc_el_no( @_el_no, nArt_id )
		
	else
		
		// auto kreiranje zna za brojac
		// necemo koristiti iz baze, da ne opterecujemo rad
		// radi filtera
		
		_el_no := nEl_no
		
	endif
	
	_e_gr_id := 0
endif

if EMPTY( cType )
    
    Box(, 7, 60)

	if lNewRec
		@ m_x + 1, m_y + 2 SAY "Unos novog elementa *******" COLOR cColor
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka elementa *******" COLOR cColor
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("pozicija (rbr) elementa:", nLeft) GET _el_no VALID _el_no > 0
	
	@ m_x + 5, m_y + 2 SAY PADL("element pripada grupi:", nLeft) GET _e_gr_id VALID s_e_groups( @_e_gr_id, .t. )
	
	@ m_x + 6, m_y + 2 SAY PADL("(0 - otvori sifrarnik)", nLeft)
	
	read
    
    BoxC()

endif

if EMPTY(cType) .and. LastKey() == K_ESC .and. lNewRec

	Gather()
	delete
	
	return 0
	
endif

if !EMPTY(cType)

	// upenduj tip elementa
	_e_gr_id := g_gr_by_type( cType )

endif

Gather()

if lNewRec
	// nafiluj odmah atribute za ovu grupu...
	__fill_att__( e_gr_id, nEl_id )
	select elements
endif

return 1


// ---------------------------------------------
// ispravka rednog broja elementa
// ---------------------------------------------
static function e_no_edit()

Scatter()

Box(,1,40)

	@ m_x + 1, m_y + 2 SAY "postavi na:" GET _el_no VALID _el_no > 0 PICT "99"	
	read
    
BoxC()


if LastKey() <> K_ESC
	Gather()
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
local cElGrVal := SPACE(10)
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

	altd()

	@ m_x + 3, m_y + 2 SAY PADL("izaberi atribut elementa", nLeft) GET _e_gr_at_id VALID {|| s_e_gr_att(@_e_gr_at_id, el_gr_id, nil, .t. ), show_it( g_gr_at_desc( _e_gr_at_id ) ) } WHEN lNewRec == .t.
		
	//@ m_x + 4, m_y + 2 SAY PADL("izaberi vrijednost atributa", nLeft) GET _e_gr_vl_id VALID s_e_gr_val(@_e_gr_vl_id, _e_gr_at_id, nil, .t.  )

	@ m_x + 4, m_y + 2 SAY PADL("izaberi vrijednost atributa", nLeft) GET cElGrVal VALID {|| s_e_gr_val(@cElGrVal, _e_gr_at_id, cElGrVal, .t.  ), set_var(@_e_gr_vl_id, @cElGrVal) }


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



