#include "\dev\fmk\rnal\rnal.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

function TDBRNalNew()
local oObj

oObj:=TDBRNal():new()
oObj:self:=oObj
oObj:cName:="RNAL"
oObj:lAdmin:=.f.
return oObj


#include "class(y).ch"
CREATE CLASS TDBRNal INHERIT TDB 
	EXPORTED:
	var self
	method skloniSezonu	
	method install	
	method setgaDBFs	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn
	method scan
END CLASS


method dummy
return


// TDBePdv::skloniSez(string cSezona, bool finverse, bool fda, bool lNulirati, bool fRS)
method skloniSezonu(cSezona, finverse, fda, lNulirati, fRS)
local cScr

save screen to cScr

if fda==nil
	fDA:=.f.
endif
if finverse==nil
  	finverse:=.f.
endif
if lNulirati==nil
  	lNulirati:=.f.
endif
if fRS==nil
  	// mrezna radna stanica , sezona je otvorena
  	fRS:=.f.
endif

if fRS // radna stanica
  	if file(ToUnix(PRIVPATH+cSezona+"\P_RNAL.DBF"))
      		// nema se sta raditi ......., pripr.dbf u sezoni postoji !
      		return
  	endif
  	aFilesK:={}
  	aFilesS:={}
  	aFilesP:={}
endif

if KLevel<>"0"
	MsgBeep("Nemate pravo na koristenje ove opcije")
endif

cls

if fRS
	// mrezna radna stanica
	? "Formiranje DBF-ova u privatnom direktoriju, RS ...."
endif

?

if finverse
 	? "Prenos iz  sezonskih direktorija u radne podatke"
else
	? "Prenos radnih podataka u sezonske direktorije"
endif
?

// privatni
fnul:=.f.
Skloni(PRIVPATH,"P_RNAL.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"P_RNOP.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if fRS
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak.."

 	restore screen from cScr
 	return
endif

if lNulirati
	fnul:=.t.
else
	fnul:=.f.
endif  

// kumulativ
fNul := .f.
Skloni(KUMPATH,"RNAL.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RNOP.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RNLOG.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

// sifrarnik
Skloni(SIFPATH,"S_RNOP.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"S_RNKA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?

Beep(4)

? "pritisni nesto za nastavak.."

restore screen from cScr
return


method setgaDBFs()
PUBLIC gaDBFs:={}

// privpath
AADD(gaDBFs, { F_P_RNAL, "P_RNAL", P_PRIVPATH  } )
AADD(gaDBFs, { F_P_RNOP, "P_RNOP", P_PRIVPATH  } )

// kumpath
AADD(gaDBFs, { F_RNAL, "RNAL", P_KUMPATH  } )
AADD(gaDBFs, { F_RNOP, "RNOP", P_KUMPATH  } )
AADD(gaDBFs, { F_RNLOG, "RNLOG", P_KUMPATH  } )

// sifpath
AADD(gaDBFs, { F_S_RNOP, "S_RNOP", P_SIFPATH } )
AADD(gaDBFs, { F_S_RNKA, "S_RNKA", P_SIFPATH } )

return

method install()
ISC_START(goModul,.f.)
return


method kreiraj(nArea)
local cImeDbf

if (nArea==nil)
	nArea:=-1
endif

Beep(1)

if (nArea<>-1)
	CreSystemDb(nArea)
endif

CreFmkSvi()
CreRoba()
CreFmkPi()

cre_tbls(nArea, "RNAL")
cre_tbls(nArea, "RNOP")
cre_tbls(nArea, "RNLOG")
cre_tbls(nArea, "P_RNAL")
cre_tbls(nArea, "P_RNOP")
cre_tbls(nArea, "S_RNOP")
cre_tbls(nArea, "S_RNKA")
cre_sifk(nArea)

return


// ----------------------------------------------
// rnal fields
// ----------------------------------------------
function g_rnal_fields()
local aDbf

aDbf:={}

// set polja tabele rnal
AADD(aDBf,{ "br_nal"     , "N" ,  10 ,  0 })
AADD(aDBf,{ "r_br"       , "N" ,   4 ,  0 })
AADD(aDBf,{ "datnal"     , "D" ,   8 ,  0 })
AADD(aDBf,{ "datisp"     , "D" ,   8 ,  0 })
AADD(aDBf,{ "vr_isp"     , "C" ,   8 ,  0 })
AADD(aDBf,{ "vr_plac"    , "C" ,   1 ,  0 })
AADD(aDBf,{ "hitnost"    , "C" ,   1 ,  0 })
AADD(aDBf,{ "idpartner"  , "C" ,   6 ,  0 })
AADD(aDBf,{ "idroba"     , "C" ,  10 ,  0 })
AADD(aDBf,{ "izo_staklo" , "C" ,   1 ,  0 })
AADD(aDBf,{ "tip_stakla" , "N" ,   2 ,  0 })
AADD(aDBf,{ "kolicina"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "debljina"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "d_sirina"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "z_sirina"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "d_visina"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "z_visina"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "d_ukupno"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "z_ukupno"   , "N" ,  15 ,  5 })
AADD(aDBf,{ "neto"       , "N" ,  15 ,  5 })
AADD(aDBf,{ "rn_status"  , "C" ,   1 ,  0 })
AADD(aDBf,{ "rn_realise" , "C" ,   1 ,  0 })
AADD(aDBf,{ "rec_zak"    , "C" ,   1 ,  0 })

return aDbf


// ----------------------------------------------
// rnlog fields
// ----------------------------------------------
function g_rlog_fields()
local aDbf

aDbf:={}

// set polja tabele rnlog
AADD(aDBf,{ "br_nal"     , "N" ,  10 ,  0 })
AADD(aDBf,{ "r_br"       , "N" ,   4 ,  0 })
AADD(aDBf,{ "log_datum"  , "D" ,   8 ,  0 })
AADD(aDBf,{ "log_time"   , "C" ,   8 ,  0 })
AADD(aDBf,{ "log_opis"   , "C" , 100 ,  5 })
AADD(aDBf,{ "rn_status"  , "C" ,   1 ,  0 })
AADD(aDBf,{ "rn_expired" , "N" ,   6 ,  0 })
AADD(aDBf,{ "rn_ukupno"  , "N" ,  15 ,  5 })
AADD(aDBf,{ "rn_neto"    , "N" ,  15 ,  5 })

return aDbf


// ----------------------------------------------
// rnop fields
// ----------------------------------------------
function g_rnop_fields()
local aDbf

aDbf:={}

// set polja tabele rnal
AADD(aDBf,{ "br_nal"     , "N" ,  10 ,  0 })
AADD(aDBf,{ "r_br"       , "N" ,   4 ,  0 })
AADD(aDBf,{ "idroba"     , "C" ,  10 ,  0 })
AADD(aDBf,{ "id_rnop"    , "C" ,   6 ,  0 })
AADD(aDBf,{ "id_rnka"    , "C" ,   6 ,  0 })
AADD(aDBf,{ "rn_instr"   , "C" , 100 ,  0 })

return aDbf


// ----------------------------------------------
// s_rnop fields
// ----------------------------------------------
function g_srnop_fields()
local aDbf

aDbf:={}

// set polja sifrarnika operacija
AADD(aDBf,{ "id"          , "C" ,   6 ,  0 })
AADD(aDBf,{ "naziv"       , "C" ,  40 ,  0 })
AADD(aDBf,{ "opis"        , "C" , 100 ,  0 })
AADD(aDBf,{ "tip_stakla"  , "C" ,  60 ,  0 })
return aDbf



// ----------------------------------------------
// s_rnka fields
// ----------------------------------------------
function g_srnka_fields()
local aDbf

aDbf:={}

// set polja sifrarnika karakteristika
AADD(aDBf,{ "id"          , "C" ,   6 ,  0 })
AADD(aDBf,{ "id_rnop"     , "C" ,   6 ,  0 })
AADD(aDBf,{ "naziv"       , "C" , 100 ,  0 })
AADD(aDBf,{ "ka_def"      , "C" , 100 ,  0 })
AADD(aDBf,{ "ka_val"      , "C" ,  20 ,  0 })
AADD(aDBf,{ "opis"        , "C" , 200 ,  0 })
return aDbf


// ---------------------------------------------
// sifk fields
// ---------------------------------------------
function g_sifk_fields(aDbf)
aDbf := {}
AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'SORT'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'Veza'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Unique'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Izvor'               , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'Uslov'               , 'C' , 100 ,  0 })
AADD(aDBf,{ 'Duzina'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Decimal'             , 'N' ,   1 ,  0 })
AADD(aDBf,{ 'Tip'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'KVALID'              , 'C' , 100 ,  0 })
AADD(aDBf,{ 'KWHEN'               , 'C' , 100 ,  0 })
AADD(aDBf,{ 'UBROWSU'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'EDKOLONA'            , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'K4'                  , 'C' ,   4 ,  0 })
return aDbf



// cre tables
function cre_tbls(nArea, cTable)
local nArea2 := 0
local aDbf
local cPath

do case 
	case cTable == "RNAL"
		nArea2 := F_RNAL
	case cTable == "RNOP"
		nArea2 := F_RNOP
	case cTable == "RNLOG"
		nArea2 := F_RNLOG
	case cTable == "S_RNOP"
		nArea2 := F_S_RNOP
	case cTable == "S_RNKA"
		nArea2 := F_S_RNKA
	case cTable == "P_RNAL"
		nArea2 := F_P_RNAL
	case cTable == "P_RNOP"
		nArea2 := F_P_RNOP
endcase

if (nArea==-1 .or. nArea == nArea2)
	do case 
		case cTable == "RNAL" .or. cTable == "P_RNAL"
			aDbf := g_rnal_fields()
		case cTable == "RNOP" .or. cTable == "P_RNOP"
			aDbf := g_rnop_fields()
		case cTable == "RNLOG"
			aDbf := g_rlog_fields()
		case cTable == "S_RNOP"
			aDbf := g_srnop_fields()
		case cTable == "S_RNKA"
			aDbf := g_srnka_fields()
	endcase

	do case 
		case (LEFT(cTable, 2) == "P_") .or. (LEFT(cTable, 2) == "T_")
			cPath := PRIVPATH
		case LEFT(cTable, 2) == "S_"
			cPath := SIFPATH
		otherwise
			cPath := KUMPATH
	endcase
	
	if !FILE(cPath + cTable + ".DBF")
		DBcreate2(cPath + cTable + ".DBF", aDbf)
	endif

	do case 
		case (nArea2 == F_P_RNAL)
			CREATE_INDEX("br_nal", "STR(br_nal,10,0)+STR(r_br,4,0)", cPath + cTable)
		case (nArea2 == F_RNAL) 
			CREATE_INDEX("br_nal", "STR(br_nal,10,0)+STR(r_br,4,0)", cPath + cTable)
			CREATE_INDEX("br_nal_z", "STR(br_nal,10,0)+rec_zak", cPath + cTable)
		case (nArea2 == F_P_RNOP)
			CREATE_INDEX("br_nal", "STR(br_nal,10,0)+STR(r_br,4,0)+idroba+id_rnop+id_rnka", cPath + cTable)
			CREATE_INDEX("rn_ka", "STR(br_nal,10,0)+STR(r_br,4,0)+idroba+id_rnka", cPath + cTable)
		case (nArea2 == F_RNOP)
			CREATE_INDEX("br_nal", "STR(br_nal,10,0)+STR(r_br,4,0)+idroba+id_rnop+id_rnka", cPath + cTable)
		case (nArea2 == F_RNLOG)
			CREATE_INDEX("br_nal", "STR(br_nal,10,0)+STR(r_br,4,0)", cPath + cTable)
		case (nArea2 == F_S_RNOP)
		  	CREATE_INDEX("id","id", cPath + cTable)
		case (nArea2 == F_S_RNKA)
		  	CREATE_INDEX("id","id", cPath + cTable)
		  	CREATE_INDEX("idop","id_rnop+id", cPath + cTable)
	endcase
endif
return 


// --------------------------------
// --------------------------------
function cre_sifk(nArea)
local cTbl

if (nArea==-1 .or. nArea == F_SIFK)

	aDbf := g_sifk_fields()
	cTbl := "SIFK"

	if !FILE( SIFPATH+ cTbl + '.DBF' )
		dbcreate2(SIFPATH+ cTbl + '.DBF', aDbf)
	endif
	
	CREATE_INDEX("ID","id+SORT+naz", SIFPATH+cTbl)
	CREATE_INDEX("ID2","id+oznaka", SIFPATH+cTbl)
	CREATE_INDEX("NAZ","naz", SIFPATH+cTbl)
endif

return


method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_RNAL .or. i==F_P_RNAL
	lIdiDalje:=.t.
endif

if i==F_RNOP .or. i==F_P_RNOP
	lIdiDalje:=.t.
endif

if i==F_RNLOG
	lIdiDalje:=.t.
endif

if i==F_S_RNOP .or. i==F_S_RNKA
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	if gAppSrv 
		? "OPEN: " + cDbfName + ".DBF"
		if !File(cDbfName + ".DBF")
			? "Fajl " + cDbfName + ".dbf ne postoji!!!"
			use
			return
		endif
	endif
	select(i)
	usex(cDbfName)
else
	use
	return
endif

return


method ostalef()
closeret
return


method konvZn()
local cIz:="7"
local cU:="8"
local aPriv:={}
local aKum:={}
local aSif:={}
local GetList:={}
local cSif:="D"
local cKum:="D"
local cPriv:="D"

if !gAppSrv
	IF !SigmaSif("KZ      ")
   		RETURN
 	ENDIF
	Box(,8,50)
  	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	READ
  	IF LASTKEY()==K_ESC
		BoxC()
		RETURN
	ENDIF
  	IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		RETURN
  	ENDIF
 	BoxC()
else
	?
	cKonvertTo:=IzFmkIni("FMK","KonvertTo","78",EXEPATH)
	
	if cKonvertTo=="78"
		cIz:="7"
		cU:="8"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	elseif cKonvertTo=="87"
		cIz:="8"
		cU:="7"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	else // pitaj
		?
		@ 10, 2 SAY "Trenutni standard (7/8)        " GET cIz VALID cIz$"78" PICT "9"
		?
		@ 11, 2 SAY "Konvertovati u standard (7/8/A)" GET cU VALID cU$"78A" PICT "@!"
		read
	endif
	cSif:="D"
	cKum:="D"
	cPriv:="D"
endif
 
aKum  := { F_RNAL, F_RNOP, F_RNLOG }
aPriv := { F_P_RNAL, F_P_RNOP }
aSif  := { F_ROBA, F_PARTN, F_S_RNKA, F_S_RNOP }

if cSif == "N"
	aSif := {}
endif
if cKum == "N"
	aKum := {}
endif
if cPriv == "N"
	aPriv := {}
endif

KZNbaza(aPriv,aKum,aSif,cIz,cU)
return


method scan
return



