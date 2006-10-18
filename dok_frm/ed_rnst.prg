#include "\dev\fmk\rnal\rnal.ch"


// --------------------------------------------
// unos stavki radnog naloga
// --------------------------------------------
function g_item_unos(lNova)
local nItemFLeft := 2
local nItemQLeft := 36
local nPosLeft
local nPosRight
local nPosTop
local nPosBottom
local cItemType
local cItemGroup
private ImeKol
private Kol
private oBrowse
private bPrevOpc
private bPrevKroz
private aOptions
private bPrevUp
private bPrevDn


// setuj kolone
set_a_kol(@ImeKol, @Kol)

// setuj prikaz opcija unosa
set_a_options(@aOptions)

// setovanje opcija unosa
set_options()

Box(, 20, 77, , aOptions)

select p_rnst
go top

nPosLeft := m_y + 77
nPosRight := m_y + 1
nPosTop := m_x + 7
nPosBottom := m_x + 19

oBrowse := FormBrowse( nPosTop, nPosRight, nPosBottom, nPosLeft, ;
		ImeKol, Kol, { "Í", "Ä", "³"}, 0)
		
oBrowse:autolite:=.f.
bPrevDN := SETKEY(K_PGDN, { || dummy_func() })
bPrevUp := SETKEY(K_PGUP, { || dummy_func() })

select p_rnst
go top

Scatter()

nR_br := 0
cItemType := SPACE(10)
cItemGroup := SPACE(10)

do while .t.
	
	// novi redni broj automatski dodaj
	_r_br := next_r_br()
	// resetuj sirinu i visinu
	_item_sirina := 0
	_item_visina := 0
	
	do while !oBrowse:Stabilize() .and. ( (Ch:=INKEY()) == 0 )
	enddo

	set cursor on

	// prva kolona - filter stavke
	
	if IsRamaGlas()
		@ m_x + 2, m_y + nItemFLeft SAY say_left("Debljina (mm):", 15) GET _item_debljina PICT pic_dim()
	endif
	
	@ m_x + 3, m_y + nItemFLeft SAY say_left("Tip:", 15) GET cItemType
	@ m_x + 4, m_y + nItemFLeft SAY say_left("Grupa:", 15) GET cItemGroup
	@ m_x + 5, m_y + nItemFLeft SAY say_left("Stavka:", 15) GET _item_id
	
	// druga kolona - unos kolicine itd....
	if IsRamaGlas()
		@ m_x + 3, m_y + nItemQLeft SAY say_left("Sirina (mm):", 15) GET _item_sirina PICT pic_dim()
		@ m_x + 4, m_y + nItemQLeft SAY say_left("Visina (mm):", 15) GET _item_visina PICT pic_dim()
	endif
	
	@ m_x + 5, m_y + nItemQLeft SAY say_left("Kolicina:", 15) GET _item_kol PICT pic_kol() SEND READER:={|g| send_reader(g) }

	read

	if LASTKEY() == K_ESC
		EXIT
	endif

	select p_rnst
	
	// dodaj zapis
	append blank
	Gather()

	// sumiraj neke varijable....
	// nUkupno += ....

	// refresh oBrowse
	oBrowse:goBottom()
	oBrowse:refreshAll()
	oBrowse:dehilite()
enddo

// ukloni opcije pripreme
canc_options()

SETKEY(K_PGDN, bPrevDN)
SETKEY(K_PGUP, bPrevUP)

BoxC()

return 1


// -----------------------------------------
// prikazi tekst sa opcijom PADL
// -----------------------------------------
static function say_left(cTxt, nLeft)
if cTxt == nil
	cTxt := "-"
endif
if nLeft == nil
	nLeft := 5
endif
return PADL(cTxt, nLeft)


// ---------------------------------------------
// setovanje kolona unosa
// ---------------------------------------------
static function set_a_kol(aImeKol, aKol)
local i
aImeKol := {}
aKol := {}

AADD(aImeKol, { "R.br", { || TRANSFORM(r_br, "9999") }, "r_br"  })
AADD(aImeKol, { "Stavka", { || say_item_mc(F_ROBA, "ROBA", item_id) }, "item_id"  })
AADD(aImeKol, { "Kolicina", { || TRANSFORM(item_kol, "9999") }, "item_kol"  })

if IsRamaGlas()
	AADD(aImeKol, { "Sirina", { || TRANSFORM(item_sirina, PIC_DIM())}, "item_sirina"   })
	AADD(aImeKol, { "Visina", { || TRANSFORM(item_visina, PIC_DIM())}, "item_visina"   })
	AADD(aImeKol, { "Debljina", { || TRANSFORM(item_debljina, PIC_DIM())}, "item_debljina"   })
endif

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// ----------------------------------------
// setovanje opisa opcija unosa
// ----------------------------------------
static function set_a_options(aOpt)
aOpt := {}
AADD(aOpt, "<*> - Ispravka stavke")
return


// ------------------------------------------
// setovanje opcjija unosa
// ------------------------------------------
static function set_options()
bPrevOpc := SETKEY(ASC("*"), { || edit_item() })
return .t.


// ------------------------------------------
// cancel opcija unosa
// ------------------------------------------
static function canc_options()
SETKEY(ASC("*"), bPrevOpc)
return .f.


// -------------------------------------------
// ispravka stavke unosa
// -------------------------------------------
static function edit_item()
local cItemId 
local nItemKol
local nItemSir
local nItemVis
local nItemDeb
local aConds := {}
local aProcs := {}

canc_options()

OpcTipke( {"<Enter> - ispravi stavku", "<DEL> brisi stavku", "<ESC> - zavrsi"} )

oBrowse:autolite := .t.
oBrowse:configure()

cItemId := _item_id
nItemKol := _item_kol
nItemSir := _item_sirina
nItemVis := _item_visina
nItemDeb := _item_debljina

// opcije ispravke....
AADD(aConds, { |Ch| Ch == K_DEL} )
AADD(aProcs, { || delete_item(oBrowse) })

AADD(aConds, { |Ch| Ch == K_ENTER} )
AADD(aProcs, { || ed_item(oBrowse) })

ShowBrowse( oBrowse, aConds, aProcs )

oBrowse:autolite := .f.
oBrowse:dehilite()
oBrowse:stabilize()

Prozor0()

_item_id := cItemId
_item_kol := nItemKol
_item_sir := nItemSir
_item_vis := nItemVis
_item_deb := nItemDeb

set_options()

return


// ---------------------------------------------
// brisanje stavke iz pripremne tabele
// ---------------------------------------------
static function delete_item(oBrowse)
select p_rnst

if reccount2() == 0
	MsgBeep("Priprema prazna !!!")
	return DE_REFRESH
endif

beep(2)

// setuj neke varijable
// nukupno -= ....

delete

oBrowse:refreshAll()

do while !oBrowse:stable
	oBrowse:stabilize()
enddo

return (DE_REFRESH)


// ---------------------------------------------
// ispravka stavke u pripremi
// ---------------------------------------------
static function ed_item(oBrowse)
private GetList := {}

select p_rnst

if reccount2() == 0
	MsgBeep("Priprema prazna !!!!")
	return (DE_CONT)
endif

Scatter()
set cursor on

Box(, 6, 75)

@ m_x + 1, m_y + 2 SAY "    stavka: " GET _item_id
@ m_x + 2, m_y + 2 SAY "  kolicina: " GET _item_kol

read

if LASTKEY() <> K_ESC
	Gather()
endif

BoxC()

oBrowse:refreshCurrent()
do while !oBrowse:stable
	oBrowse:stabilize()
enddo

return (DE_CONT)




static function send_reader(oGet, GetList, oMenu, aMsg)
local nKey
local nRow
local nCol

if ( GetPreValSc(oGet, aMsg) )
	
	oGet:setFocus()
	
	do while ( oGet:exitState == GE_NOEXIT )
		
		if (oGet:typeOut)
			oGet:exitState := GE_ENTER
		endif
		
		do while ( oGet:exitState == GE_NOEXIT )
			nKey := INKEY(0)
			GetApplyKey( oGet, nKey, GetList, oMenu, aMsg )
			nRow := ROW()
			nCol := COL()
			DevPos(nRow, nCol)
		enddo

		if ( !GetPstValSC( oGet, aMsg ) )
			oGet:exitState := GE_NOEXIT
		endif
		
	enddo
	
	// deaktiviraj get
	oGet:killFocus()
endif
return


