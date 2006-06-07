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


// -------------------------------------
// set parametre pri pokretanju modula
// ------------------------------------
function s_params()

// procitaj globalne - kparams
read_g_params()

return


// --------------------------------------
// --------------------------------------
function ed_g_params()

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
	write_g_params()
endif

return


// --------------------------------------
// --------------------------------------
function read_g_params()
*{
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

function write_g_params()
*{

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



