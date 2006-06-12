#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                             Copyright Sigma-com software 2006
* ----------------------------------------------------------------
*/

// picture iznos
static gPIC_IZN
// picture dimenzije
static gPIC_DIM
// picture kolicina
static gPIC_KOL


// -----------------------------------------
// set parametara pri pokretanju modula
// -----------------------------------------
function s_params()

read_fi_params()
read_zf_params()
read_doc_params()

return


// --------------------------------------
// parametri zaokruzenja, formata prikaza
// --------------------------------------
function ed_zf_params()

gPIC_IZN:= PADR(gPIC_IZN, 20)
gPIC_DIM:= PADR(gPIC_DIM, 20)
gPIC_KOL:= PADR(gPIC_KOL, 20)

nX:=1
Box(, 15, 70)

set cursor on

@ m_x + nX, m_y+2 SAY "1. Prikaz ***"
nX ++

@ m_x + nX, m_y+2 SAY PADL(" kolicina ", 30)   GET gPIC_KOL
nX ++

@ m_x + nX, m_y+2 SAY PADL(" dimenzija ", 30)   GET gPIC_DIM
nX ++

@ m_x + nX, m_y+2 SAY PADL(" iznos ", 30)   GET gPIC_IZN

read

BoxC()

gPIC_KOL := ALLTRIM(gPIC_KOL)
gPIC_DIM := ALLTRIM(gPIC_DIM)
gPIC_IZN := ALLTRIM(gPIC_IZN)

if lastkey()<>K_ESC
	write_zf_params()
endif

return


// --------------------------------------
// parametri firme
// --------------------------------------
function ed_fi_params()
local nLeft := 35

nX:=1
Box(, 20, 70)

set cursor on

@ m_x + nX, m_y+2 SAY "1. Opci podaci ***"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Puni naziv firme:", nLeft) GET gFNaziv PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Adresa firme:", nLeft) GET gFAdresa PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Id broj:", nLeft) GET gFIdBroj

nX += 2

@ m_x + nX, m_y+2 SAY "2. Dodatni podaci ***"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Telefoni:", nLeft) GET gFTelefon PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("email/web:", nLeft) GET gFEmail PICT "@S30"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Banka 1:", nLeft) GET gFBanka1 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 2:", nLeft) GET gFBanka2 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 3:", nLeft) GET gFBanka3 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 4:", nLeft) GET gFBanka4 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Banka 5:", nLeft) GET gFBanka5 PICT "@S30"

nX += 2

@ m_x + nX, m_y+2 SAY PADL("Dodatni red 1:", nLeft) GET gFPrRed1 PICT "@S30"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Dodatni red 2:", nLeft) GET gFPrRed2 PICT "@S30"


read

BoxC()

if lastkey()<>K_ESC
	write_fi_params()
endif

return


// --------------------------------------
// parametri izgleda dokumenta
// --------------------------------------
function ed_doc_params()

nX:=2
Box(, 10, 70)

set cursor on

@ m_x + nX, m_y+2 SAY PADL("Dodati redovi po listu:",35) GET gDd_redovi PICT "99"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Lijeva margina:",35) GET gDl_margina PICT "99"
nX ++

@ m_x + nX, m_y+2 SAY PADL("Gornja margina:",35) GET gDg_margina PICT "99"

read

BoxC()

if lastkey()<>K_ESC
	write_doc_params()
endif

return




// --------------------------------------
// citaj paramtre firme
// --------------------------------------
function read_fi_params()

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("F1", @gFNaziv)
RPar("F2", @gFAdresa)
RPar("F3", @gFIdBroj)
RPar("F4", @gFTelefon)
RPar("F5", @gFEmail)
RPar("F8", @gFPrRed1)
RPar("F9", @gFPrRed2)
RPar("B1", @gFBanka1)
RPar("B2", @gFBanka2)
RPar("B3", @gFBanka3)
RPar("B4", @gFBanka4)
RPar("B5", @gFBanka5)

close
return


// --------------------------------
// upisi parametre firme
// --------------------------------
function write_fi_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("F1", gFNaziv)
WPar("F2", gFAdresa)
WPar("F3", gFIdBroj)
WPar("F4", gFTelefon)
WPar("F5", gFEmail)
WPar("F8", gFPrRed1)
WPar("F9", gFPrRed2)
WPar("B1", gFBanka1)
WPar("B2", gFBanka2)
WPar("B3", gFBanka3)
WPar("B4", gFBanka4)
WPar("B5", gFBanka5)

close

return


// --------------------------------------
// citaj paramtre izgleda dokumenta
// --------------------------------------
function read_doc_params()

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("D1", @gDg_margina)
RPar("D2", @gDl_margina)
RPar("D3", @gDd_redovi)

close
return


// ----------------------------------
// upisi parametre izgleda dokumenta
// ----------------------------------
function write_doc_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("D1", gDg_margina)
WPar("D2", gDl_margina)
WPar("D3", gDd_redovi)

close

return



// --------------------------------------
// citaj podatke zaokruzenja...
// --------------------------------------
function read_zf_params()

gPIC_IZN := "9999999.99"
gPIC_DIM := "9999999.99"
gPIC_KOL := "9999999999"

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif

private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("P1", @gPIC_IZN)
RPar("P2", @gPIC_DIM)
RPar("P3", @gPIC_KOL)

close
return


// ------------------------------------
// upisi paramtre zaokruzenja
// ------------------------------------
function write_zf_params()
SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

WPar("P1", gPIC_IZN)
WPar("P2", gPIC_DIM)
WPar("P3", gPIC_KOL)

close

return



// -------------------------------
// -------------------------------
function PIC_IZN(xVal)
if xVal <> nil
	gPIC_IZN := xVal
endif
return gPIC_IZN

// -------------------------------
// -------------------------------
function PIC_DIM(xVal)
if xVal <> nil
	gPIC_DIM := xVal
endif
return gPIC_DIM


// -------------------------------
// -------------------------------
function PIC_KOL(xVal)
if xVal <> nil
	gPIC_KOL := xVal
endif
return gPIC_KOL



