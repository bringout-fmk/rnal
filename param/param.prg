#include "\dev\fmk\rnal\rnal.ch"

/*
* ----------------------------------------------------------------
*                             Copyright Sigma-com software 2006
* ----------------------------------------------------------------
*/

// zaokruzenje iznos
static gZAO_IZN
// zaokruzenje cijena
static gZAO_CIJ
// picture iznos
static gPIC_IZN
// picture cijena
static gPIC_CIJ


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
gPIC_CIJ:= PADR(gPIC_CIJ, 20)

nX:=1
Box(, 15, 70)

 set cursor on
 /*
 @ m_x + nX, m_y+2 SAY "1. Zaokruzenje ***"
 nX++
 
 @ m_x + nX , m_y+2 SAY PADL("iznos ", 30)   GET gZAO_IZN PICT "9"
 nX++
 
 @ m_x + nX, m_y+2 SAY PADL("cijena ", 30)   GET gZAO_CIJ PICT "9"
 nX += 2
 
 @ m_x + nX, m_y+2 SAY PADL(" podaci na pdv prijavi ", 30)   GET gZAO_PDV PICT "9"
 nX += 2

 @ m_x + nX, m_y+2 SAY "2. Prikaz ***"
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL(" iznos ", 30)   GET gPIC_IZN
 nX ++
 
 @ m_x + nX, m_y+2 SAY PADL(" cijena ", 30)   GET gPIC_CIJ
 nX ++

 */
 READ

BoxC()

gPIC_IZN := ALLTRIM(gPIC_IZN)
gPIC_CIJ := ALLTRIM(gPIC_CIJ)

if lastkey()<>K_ESC
	write_g_params()
endif

return


// --------------------------------------
// --------------------------------------
function read_g_params()
*{
gZAO_IZN := 2
gZAO_CIJ := 3
gZAO_PDV := 0
gPIC_IZN := "9999999.99"
gPIC_CIJ := "9999999.99"

SELECT F_KPARAMS

if !used()
	O_KPARAMS
endif
private cSection:="5"
private cHistory:=" "
private aHistory:={}

RPar("Z1", @gZAO_IZN)
RPar("Z2", @gZAO_CIJ)
RPar("Z3", @gZAO_PDV)

RPar("P1", @gPIC_IZN)
RPar("P2", @gPIC_CIJ)

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

WPar("Z1", gZAO_IZN)
WPar("Z2", gZAO_CIJ)
WPar("Z3", gZAO_PDV)

WPar("P1", gPIC_IZN)
WPar("P2", gPIC_CIJ)

close

return


// -------------------------------
// -------------------------------
function ZAO_IZN(xVal)

if xVal <> nil
	gZAO_IZN := xVal
endif

return gZAO_IZN

// -------------------------------
// -------------------------------
function ZAO_CIJ(xVal)

if xVal <> nil
	gZAO_CIJ := xVal
endif

return gZAO_CIJ

// -------------------------------
// -------------------------------
function PIC_IZN(xVal)
if xVal <> nil
	gPIC_IZN := xVal
endif
return gPIC_IZN

// -------------------------------
// -------------------------------
function PIC_CIJ(xVal)
if xVal <> nil
	gPIC_CIJ := xVal
endif
return gPIC_CIJ

