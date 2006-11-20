#include "\dev\fmk\rnal\rnal.ch"




// ----------------------------------------------------------------------
// Kreiranje pomocne tabele za parametre 
// pretrage kod unosa naloga
// 
// _FND_PAR.DBF
//  
// -------------------------------------------------------------------
// fnd_..no | fnd_..type | fnd_str | fnd_att | fnd_val_1 | fnd_val_2 |...
// -------------------------------------------------------------------
//        1 |   NAZ      | stakl...|         |           |           |
//        2 | MATCH_CODE | LWE4... |         |           |           |
//        3 |   ATTRIB   |         |    1    |    1      |           |
//        4 |   ATTRIB   |         |    5    |    11     |     12    |
// -------------------------------------------------------------------
// ----------------------------------------------------------------------

function _cre_fnd_par()
local cFndDbf := "_FND_PAR"
local aDbf := {}

if !FILE(PRIVPATH + cFndDbf + ".DBF")
	
	AADD(aDbf, { "fnd_par_no", "N", 4, 0})
	AADD(aDbf, { "fnd_par_type", "C", 10, 0})
	AADD(aDbf, { "fnd_str", "C", 100, 0})
	AADD(aDbf, { "fnd_att", "N", 10, 0})
	AADD(aDbf, { "fnd_val_1", "N", 10, 0})
	AADD(aDbf, { "fnd_val_2", "N", 10, 0})
	AADD(aDbf, { "fnd_val_3", "N", 10, 0})

	DBcreate2(PRIVPATH + cFndDbf + ".DBF", aDbf)

endif

CREATE_INDEX("1", "STR(fnd_par_no, 4)", PRIVPATH + cFndDbf, .t.)

O__FND_PAR
select _fnd_par

// ako je prazna tabela dodaj init podatke....
if RECCOUNT2() == 0

	append blank
	replace fnd_par_no with 1
	replace fnd_par_type with "ART_DESC"
	
	append blank
	replace fnd_par_no with 2
	replace fnd_par_type with "MATCH_CODE"
	
	append blank
	replace fnd_par_no with 3
	replace fnd_par_type with "EL_ATT"

	append blank
	replace fnd_par_no with 4
	replace fnd_par_type with "EL_ADD_OP"

endif

return


// ------------------------------------------------
// otvara TBrowse objekat _fnd_par
// 
// ------------------------------------------------
function _fnd_par_get()
local nArea
local nTArea
local GetList:={}
local nBoxX := 12
local nBoxY := 77
local cHeader := ""
local cFooter := ""
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Uslovi za pretragu artikala"

select _fnd_par 
go top

Box(, nBoxX, nBoxY)

@ m_x + nBoxX, m_y + 2 SAY "<c-N> Nova stavka | <c-T> Brisi | <c-F9> Brisi sve"

set_a_kol(@ImeKol, @Kol)

// setuj varijable direktnog moda....
private bGoreRed:=NIL
private bDoleRed:=NIL
private bDodajRed:=NIL
private fTBNoviRed:=.f. 
private TBCanClose:=.t. 
private TBAppend:="N"  
private bZaglavlje:=NIL
private TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
private nTBLine:=1      
private nTBLastLine:=1  
private TBPomjerise:="" 
private TBScatter:="N"  

ObjDbedit("fnd_par", nBoxX, nBoxY, {|Ch| key_handler(Ch)}, cHeader, cFooter,,,,,1)

BoxC()

select (nTArea)

return 1
  


// ------------------------------------------
// key handler nad tabelom
// ------------------------------------------
static function key_handler()
local nTRec := RECNO()

if ( Ch == K_CTRL_T .or. Ch == K_CTRL_F9 ) .and. RecCount2() == 0
	return DE_CONT
endif

// setuj direktni edit mod
if gTBDir=="N"
	gTBDir:="D"
        select _fnd_par
        DaTBDirektni()
endif

do case
	case (Ch == K_ESC) 
		
		gTBDir:="N"
        	NeTBDirektni()

	case (Ch == K_CTRL_T)
	
		if Pitanje(, "Zelite izbrisati ovu stavku ?","D")=="D"
      			
			delete
      			return DE_REFRESH
			
      		endif
     		
		return DE_CONT
		
	case (Ch == K_CTRL_F9)

		if Pitanje(, "Izbrisati sve stavke iz tabele ?", "N") == "D"
			
			go top
			do while !EOF()
				delete
				skip
			enddo
			
			return DE_REFRESH
		endif
		
		return DE_CONT
	
	case (Ch == K_CTRL_N)
		
		gTbDir:="N"
		NeTBDirektni()
		
		//dodaj novi parametar u _fnd_par
		_add_fnd_par( _new_fnd_par() )
		go top
		
		return DE_REFRESH
	
	case ( Ch == K_ALT_F )
		
		// zapocni pretragu prema unesenim vrijednostima
		gTBDir:="N"
        	NeTBDirektni()
		return DE_ABORT
	
endcase

return DE_CONT


// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol:={}

AADD(aImeKol, { PADC( "Tip", 6), {|| PADR(g_fnd_par_type( fnd_par_type ), 6)} })

// edit kolone...

// string ....
AADD(aImeKol, {PADC("tekst", 30), {|| PADR(fnd_str, 30) }, "fnd_str", {|| ALLTRIM(fnd_par_type) $ "MATCH_CODE#ART_NAZ"}, {|| .t.}, "V"  })

// atribut
AADD(aImeKol, {PADC("Atribut", 10), {|| PADR(g_gr_at_desc(fnd_att), 10) }, "fnd_att", {|| ALLTRIM(fnd_par_type) $ "EL_ATT#EL_ADD_OP" }, {|| s_e_gr_att( @wfnd_att, nil, wfnd_att ) }, "V"  })

// vrijednost 1
AADD(aImeKol, {PADC("Atr.vr 1", 10), {|| PADR(g_e_gr_vl_desc(fnd_val_1), 10)}, "fnd_val_1", {|| ALLTRIM(fnd_par_type) $ "EL_ATT#EL_ADD_OP"}, {|| s_e_gr_val( @wfnd_val_1, fnd_att, wfnd_val_1 ) }, "V"  })

// vrijednost 2
AADD(aImeKol, {PADC("Atr.vr 2", 10), {|| PADR(g_e_gr_vl_desc(fnd_val_2), 10)}, "fnd_val_2", {|| ALLTRIM(fnd_par_type) $ "EL_ATT#EL_ADD_OP"}, {|| s_e_gr_val( @wfnd_val_2, fnd_att, wfnd_val_2 ) }, "V"  })

// vrijednost 3
AADD(aImeKol, {PADC("Atr.vr 3", 10), {|| PADR(g_e_gr_vl_desc(fnd_val_3), 10)}, "fnd_val_3", {|| ALLTRIM(fnd_par_type) $ "EL_ATT#EL_ADD_OP" }, {|| s_e_gr_val( @wfnd_val_3, fnd_att, wfnd_val_3 ) }, "V"  })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------------
// dodaje novi parametar u listu...
// -----------------------------------------------
static function _new_fnd_par()
local nSelection := 0
local nX := m_x
local nY := m_y
private izbor := 1
private opc := {}
private opcexe := {}

if Pitanje(,"Dodati novi parametar za pretragu ?", "D") == "N"
	return -1
endif

AADD(opc, "naziv artikla              ")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})
AADD(opc, "match code")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})
AADD(opc, "atribut")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})
AADD(opc, "dodatna operacija")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})

Menu_SC("fnd_par_add")

m_x := nX
m_y := nY

return nSelection


// ---------------------------------------------------------
// dodaje u tabelu _fnd_par novi parametar
// ---------------------------------------------------------
static function _add_fnd_par( nSelection )
local cFndParType := ""
local nTRec := RECNO()
local nFndParNo := 0

if nSelection < 0
	return 0
endif

do case 
	case nSelection == 1
		cFndParType := "ART_DESC"
	case nSelection == 2
		cFndParType := "MATCH_CODE"
	case nSelection == 3
		cFndParType := "EL_ATT"
	case nSelection == 4
		cFndParType := "EL_ADD_OP"
endcase 

select _fnd_par
set order to tag "1"
go bottom
nFndParNo := field->fnd_par_no
nFndParNo += 1

append blank

Scatter()
_fnd_par_no := nFndParNo
_fnd_par_type := PADR(cFndParType, 10)
Gather()

go (nTRec)

return 1


// --------------------------------------------
// vraca naziv parametra prema kodu
// --------------------------------------------
static function g_fnd_par_type( par_type )

par_type := ALLTRIM( par_type )

if par_type == "EL_ATT"
	return "atrib."
endif
if par_type == "EL_ADD_OP"
	return "d.oper"
endif
if par_type == "MATCH_CODE"
	return "m.code"
endif
if par_type == "ART_DESC"
	return "naziv"
endif
if EMPTY( par_type )
	return "????"
endif

return

