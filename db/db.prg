#include "rnal.ch"

 
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
fNul:=.f.
Skloni(PRIVPATH,"_DOCS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_IT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_IT2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
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
Skloni(KUMPATH,"DOCS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_IT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_IT2.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_LOG.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_LIT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

fnul := .f.

// prenesi ali ne prazni, ovo su parametri...
Skloni(KUMPATH,"KPARAMS.DBF",cSezona,finverse,fda,fnul)

// sifrarnik
Skloni(SIFPATH,"AOPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"AOPS_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ARTICLES.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ELEMENTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_AOPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GROUPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GR_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GR_VAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"CUSTOMS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OBJECTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"RAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"CONTACTS.DBF",cSezona,finverse,fda,fnul)
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
AADD(gaDBFs, { F__DOCS, "_DOCS", P_PRIVPATH  } )
AADD(gaDBFs, { F__DOC_IT, "_DOC_IT", P_PRIVPATH  } )
AADD(gaDBFs, { F__DOC_IT2, "_DOC_IT2", P_PRIVPATH  } )
AADD(gaDBFs, { F__DOC_OPS, "_DOC_OPS", P_PRIVPATH  } )

// kumpath
AADD(gaDBFs, { F_DOCS, "DOCS", P_KUMPATH  } )
AADD(gaDBFs, { F_DOC_IT, "DOC_IT", P_KUMPATH  } )
AADD(gaDBFs, { F_DOC_IT2, "DOC_IT2", P_KUMPATH  } )
AADD(gaDBFs, { F_DOC_OPS, "DOC_OPS", P_KUMPATH  } )
AADD(gaDBFs, { F_DOC_LOG, "DOC_LOG", P_KUMPATH  } )
AADD(gaDBFs, { F_DOC_LIT, "DOC_LIT", P_KUMPATH  } )

// sifpath
AADD(gaDBFs, { F_E_GROUPS, "E_GROUPS", P_SIFPATH } )
AADD(gaDBFs, { F_E_GR_ATT, "E_GR_ATT", P_SIFPATH } )
AADD(gaDBFs, { F_E_GR_VAL, "E_GR_VAL", P_SIFPATH } )
AADD(gaDBFs, { F_AOPS, "AOPS", P_SIFPATH } )
AADD(gaDBFs, { F_AOPS_ATT, "AOPS_ATT", P_SIFPATH } )
AADD(gaDBFs, { F_ARTICLES, "ARTICLES", P_SIFPATH } )
AADD(gaDBFs, { F_ELEMENTS, "ELEMENTS", P_SIFPATH } )
AADD(gaDBFs, { F_E_AOPS, "E_AOPS", P_SIFPATH } )
AADD(gaDBFs, { F_E_ATT, "E_ATT", P_SIFPATH } )
AADD(gaDBFs, { F_CUSTOMS, "CUSTOMS", P_SIFPATH } )
AADD(gaDBFs, { F_CONTACTS, "CONTACTS", P_SIFPATH } )
AADD(gaDBFs, { F_OBJECTS, "OBJECTS", P_SIFPATH } )
AADD(gaDBFs, { F_RAL, "RAL", P_SIFPATH } )

return

method install()
ISC_START(goModul,.f.)
return


// ----------------------------------------
// metoda kreiranja tabela
//  nArea - podrucje
// ----------------------------------------
method kreiraj(nArea)

if (nArea == nil)
	nArea:=-1
endif

Beep(1)

if (nArea <> -1)
	CreSystemDb( nArea )
endif

cre_tbls(nArea, "DOCS")
cre_tbls(nArea, "_DOCS")
cre_tbls(nArea, "DOC_IT")
cre_tbls(nArea, "_DOC_IT")
cre_tbls(nArea, "DOC_OPS")
cre_tbls(nArea, "_DOC_OPS")
cre_tbls(nArea, "DOC_IT2")
cre_tbls(nArea, "_DOC_IT2")
cre_tbls(nArea, "DOC_LOG")
cre_tbls(nArea, "DOC_LIT")
cre_tbls(nArea, "ARTICLES")
cre_tbls(nArea, "ELEMENTS")
cre_tbls(nArea, "E_AOPS")
cre_tbls(nArea, "E_ATT")
cre_tbls(nArea, "E_GROUPS")
cre_tbls(nArea, "E_GR_ATT")
cre_tbls(nArea, "E_GR_VAL")
cre_tbls(nArea, "AOPS")
cre_tbls(nArea, "AOPS_ATT")
cre_tbls(nArea, "CUSTOMS")
cre_tbls(nArea, "CONTACTS")
cre_tbls(nArea, "OBJECTS")
cre_sifk(nArea)

// kreiranje tabele pretraga parametri
_cre_fnd_par()

// kreiraj relacije
cre_relation()

// kreiraj pravila : RULES
cre_fmkrules()

// kreiraj pravila : RULES cdx files
c_rule_cdx()

// kreiraj tabelu "RAL"
c_tbl_ral()

return


// ----------------------------------------------
// vraca matricu sa strukturom tabele DOCS
//   aDBF := {...}
// ----------------------------------------------
function a_docs()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_date", "D", 8, 0 })
AADD(aDBf,{ "doc_time", "C", 8, 0 })
AADD(aDBf,{ "doc_dvr_date", "D", 8, 0 })
AADD(aDBf,{ "doc_dvr_time", "C", 8,  0 })
AADD(aDBf,{ "doc_ship_place", "C", 200, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "cont_id", "N", 10, 0 })
AADD(aDBf,{ "obj_id", "N", 10, 0 })
AADD(aDBf,{ "cont_add_desc", "C", 200, 0 })
AADD(aDBf,{ "doc_pay_id", "N", 4, 0 })
AADD(aDBf,{ "doc_paid", "C", 1, 0 })
AADD(aDBf,{ "doc_pay_desc", "C", 100, 0 })
AADD(aDBf,{ "doc_priority", "N", 4, 0 })
AADD(aDBf,{ "doc_desc", "C", 200, 0 })
AADD(aDBf,{ "doc_sh_desc", "C", 100, 0 })
AADD(aDBf,{ "doc_status", "N", 2, 0 })
AADD(aDBf,{ "operater_id", "N", 3, 0 })
AADD(aDBf,{ "doc_in_fmk", "N", 1, 0 })
AADD(aDBf,{ "fmk_doc", "C", 150, 0 })

return aDbf



// ----------------------------------------------
// vraca matricu sa strukturom tabele DOC_IT
//   aDBF := {...}
// ----------------------------------------------
function a_doc_it()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_it_no", "N", 4, 0 })
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "doc_it_width", "N", 15,  5 })
AADD(aDBf,{ "doc_it_heihg", "N", 15,  5 })
AADD(aDBf,{ "doc_it_qtty",  "N", 15,  5 })
AADD(aDBf,{ "doc_it_altt",  "N", 15,  5 })
AADD(aDBf,{ "doc_acity",  "C", 50,  5 })
AADD(aDBf,{ "doc_it_schema",  "C", 1,  0 })
AADD(aDBf,{ "doc_it_desc",  "C", 150,  0 })
AADD(aDBf,{ "doc_it_type",  "C", 1,  0 })
AADD(aDBf,{ "doc_it_w2", "N", 15,  5 })
AADD(aDBf,{ "doc_it_h2", "N", 15,  5 })
AADD(aDBf,{ "doc_it_pos", "C", 20,  0 })

return aDbf


// ----------------------------------------------
// vraca matricu sa strukturom tabele DOC_IT2
//   aDBF := {...}
// ----------------------------------------------
function a_doc_it2()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_it_no", "N", 4, 0 })
AADD(aDBf,{ "it_no", "N", 4, 0 })
AADD(aDBf,{ "art_id", "C", 10, 0 })
AADD(aDBf,{ "doc_it_qtt",  "N", 15,  5 })
AADD(aDBf,{ "doc_it_q2",  "N", 15,  5 })
AADD(aDBf,{ "doc_it_pri", "N", 15,  5 })
AADD(aDBf,{ "sh_desc", "C", 100,  0 })
AADD(aDBf,{ "desc", "C", 200,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele DOC_OPS
//   aDBF := {...}
// --------------------------------------------------
function a_doc_ops()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_it_no", "N", 4, 0 })
AADD(aDBf,{ "doc_it_el_no", "N", 10, 0 })
AADD(aDBf,{ "doc_op_no", "N", 4, 0 })
AADD(aDBf,{ "aop_id", "N", 10,  0 })
AADD(aDBf,{ "aop_att_id", "N", 10,  0 })
AADD(aDBf,{ "aop_value", "C", 150,  0 })
AADD(aDBf,{ "doc_op_desc", "C", 150,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele DOC_LOG
//   aDBF := {...}
// --------------------------------------------------
function a_doc_log()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_log_no", "N", 10, 0 })
AADD(aDBf,{ "doc_log_date", "D", 8, 0 })
AADD(aDBf,{ "doc_log_time", "C", 8, 0 })
AADD(aDBf,{ "operater_id", "N", 3,  0 })
AADD(aDBf,{ "doc_log_type", "C", 3,  0 })
AADD(aDBf,{ "doc_log_desc", "C", 100,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele DOCS_LOG_ITEMS
//   aDBF := {...}
// --------------------------------------------------
function a_doc_lit()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_log_no", "N", 10, 0 })
AADD(aDBf,{ "doc_lit_no", "N", 4, 0 })
AADD(aDBf,{ "doc_lit_action", "C", 1, 0 })
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "char_1", "C", 100,  0 })
AADD(aDBf,{ "char_2", "C", 100,  0 })
AADD(aDBf,{ "char_3", "C", 100,  0 })
AADD(aDBf,{ "num_1", "N", 15,  5 })
AADD(aDBf,{ "num_2", "N", 15,  5 })
AADD(aDBf,{ "num_3", "N", 15,  5 })
AADD(aDBf,{ "int_1", "N", 10,  0 })
AADD(aDBf,{ "int_2", "N", 10,  0 })
AADD(aDBf,{ "int_3", "N", 10,  0 })
AADD(aDBf,{ "int_4", "N", 10,  0 })
AADD(aDBf,{ "int_5", "N", 10,  0 })
AADD(aDBf,{ "date_1", "D", 8,  0 })
AADD(aDBf,{ "date_2", "D", 8,  0 })
AADD(aDBf,{ "date_3", "D", 8,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele ARTICLES
//   aDBF := {...}
// --------------------------------------------------
function a_articles()
local aDbf

aDbf:={}
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "art_desc", "C", 100, 0 })
AADD(aDBf,{ "art_full_desc", "C", 250, 0 })
AADD(aDBf,{ "art_lab_desc", "C", 200, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele ELEMENTS
//   aDBF := {...}
// --------------------------------------------------
function a_elements()
local aDbf

aDbf:={}
AADD(aDBf,{ "el_id", "N", 10, 0 })
AADD(aDBf,{ "el_no", "N", 4, 0 })
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_id", "N", 10, 0 })

return aDbf



// --------------------------------------------------
// vraca matricu sa strukturom tabele E_ATT
//   aDBF := {...}
// --------------------------------------------------
function a_e_att()
local aDbf

aDbf:={}
AADD(aDBf,{ "el_att_id", "N", 10, 0 })
AADD(aDBf,{ "el_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_at_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_vl_id", "N", 10, 0 })

return aDbf



// --------------------------------------------------
// vraca matricu sa strukturom tabele E_AOPS
//   aDBF := {...}
// --------------------------------------------------
function a_e_aops()
local aDbf

aDbf:={}
AADD(aDBf,{ "el_op_id", "N", 10, 0 })
AADD(aDBf,{ "el_id", "N", 10, 0 })
AADD(aDBf,{ "aop_id", "N", 10, 0 })
AADD(aDBf,{ "aop_att_id", "N", 10, 0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele E_GROUPS
//   aDBF := {...}
// --------------------------------------------------
function a_e_groups()
local aDbf

aDbf:={}
AADD(aDBf,{ "e_gr_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_desc", "C", 100, 0 })
AADD(aDBf,{ "e_gr_full_desc", "C", 100, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf



// --------------------------------------------------
// vraca matricu sa strukturom tabele E_GR_ATT
//   aDBF := {...}
// --------------------------------------------------
function a_e_gr_att()
local aDbf

aDbf:={}
AADD(aDBf,{ "e_gr_at_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_at_desc", "C", 100, 0 })
AADD(aDBf,{ "e_gr_at_required", "C", 1, 0 })
AADD(aDBf,{ "in_art_desc", "C", 1, 0 })
AADD(aDBf,{ "e_gr_at_joker", "C", 20, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf



// ------------------------------------------------------
// vraca matricu sa strukturom tabele E_GR_VAL
//   aDBF := {...}
// ------------------------------------------------------
function a_e_gr_val()
local aDbf

aDbf:={}
AADD(aDBf,{ "e_gr_vl_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_at_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_vl_desc", "C", 100, 0 })
AADD(aDBf,{ "e_gr_vl_full", "C", 100, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele AOPS
//   aDBF := {...}
// ------------------------------------------------------
function a_aops()
local aDbf

aDbf:={}
AADD(aDBf,{ "aop_id", "N", 10, 0 })
AADD(aDBf,{ "aop_desc", "C", 100, 0 })
AADD(aDBf,{ "aop_full_desc", "C", 100, 0 })
AADD(aDBf,{ "in_art_desc", "C", 1, 0 })
AADD(aDBf,{ "aop_joker", "C", 20, 0 })
AADD(aDBf,{ "aop_unit", "C", 10, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele AOPS_ATT
//   aDBF := {...}
// ------------------------------------------------------
function a_aops_att()
local aDbf

aDbf:={}
AADD(aDBf,{ "aop_att_id", "N", 10, 0 })
AADD(aDBf,{ "aop_id", "N", 10, 0 })
AADD(aDBf,{ "aop_att_desc", "C", 100, 0 })
AADD(aDBf,{ "aop_att_full", "C", 100, 0 })
AADD(aDBf,{ "in_art_desc", "C", 1, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele CUSTOMS
//   aDBF := {...}
// ------------------------------------------------------
function a_customs()
local aDbf

aDbf:={}
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "cust_desc", "C", 250, 0 })
AADD(aDBf,{ "cust_addr", "C", 50, 0 })
AADD(aDBf,{ "cust_tel", "C", 100, 0 })
AADD(aDBf,{ "cust_ident_no", "C", 13, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele CONTACTS
//   aDBF := {...}
// ------------------------------------------------------
function a_contacts()
local aDbf

aDbf:={}
AADD(aDBf,{ "cont_id", "N", 10, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "cont_desc", "C", 150, 0 })
AADD(aDBf,{ "cont_tel", "C", 100, 0 })
AADD(aDBf,{ "cont_add_desc", "C", 250, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele OBJECTS
//   aDBF := {...}
// ------------------------------------------------------
function a_objects()
local aDbf

aDbf:={}
AADD(aDBf,{ "obj_id", "N", 10, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "obj_desc", "C", 150, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ---------------------------------------------
// vraca strukturu tabele SIFK
// ---------------------------------------------
function a_sifk(aDbf)
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


// ------------------------------------------------
// kreiranje tabela
//  nArea - podrucje
//  cTable - naziv tabele
// ------------------------------------------------
function cre_tbls(nArea, cTable)
local nArea2 := 0
local aDbf
local cPath := KUMPATH

do case 
	case cTable == "DOCS"
		nArea2 := F_DOCS
	case cTable == "_DOCS"
		nArea2 := F__DOCS
	case cTable == "DOC_IT"
		nArea2 := F_DOC_IT
	case cTable == "_DOC_IT"
		nArea2 := F__DOC_IT
	case cTable == "DOC_IT2"
		nArea2 := F_DOC_IT2
	case cTable == "_DOC_IT2"
		nArea2 := F__DOC_IT2
	case cTable == "DOC_OPS"
		nArea2 := F_DOC_OPS
	case cTable == "_DOC_OPS"
		nArea2 := F__DOC_OPS
	case cTable == "DOC_LOG"
		nArea2 := F_DOC_LOG
	case cTable == "DOC_LIT"
		nArea2 := F_DOC_LIT
	case cTable == "E_GROUPS"
		nArea2 := F_E_GROUPS
	case cTable == "E_GR_ATT"
		nArea2 := F_E_GR_ATT
	case cTable == "E_GR_VAL"
		nArea2 := F_E_GR_VAL
	case cTable == "AOPS"
		nArea2 := F_AOPS
	case cTable == "AOPS_ATT"
		nArea2 := F_AOPS_ATT
	case cTable == "ARTICLES"
		nArea2 := F_ARTICLES
	case cTable == "ELEMENTS"
		nArea2 := F_ELEMENTS
	case cTable == "E_AOPS"
		nArea2 := F_E_AOPS
	case cTable == "E_ATT"
		nArea2 := F_E_ATT
	case cTable == "CUSTOMS"
		nArea2 := F_CUSTOMS
	case cTable == "CONTACTS"
		nArea2 := F_CONTACTS
	case cTable == "OBJECTS"
		nArea2 := F_OBJECTS
endcase

if (nArea==-1 .or. nArea == nArea2)
	do case 
		case cTable == "DOCS" 
			aDbf := a_docs()
			cPath := KUMPATH
			
		case cTable == "_DOCS"
			aDbf := a_docs()
			cPath := PRIVPATH
			
		case cTable == "DOC_IT" 
			aDbf := a_doc_it()
			cPath := KUMPATH
			
		case cTable == "_DOC_IT"
			aDbf := a_doc_it()
			cPath := PRIVPATH
		
		case cTable == "DOC_IT2"
			aDbf := a_doc_it2()
			cPath := KUMPATH

		case cTable == "_DOC_IT2"
			aDbf := a_doc_it2()
			cPath := PRIVPATH
		
		case cTable == "DOC_OPS" 
			aDbf := a_doc_ops()
			cPath := KUMPATH
			
		case cTable == "_DOC_OPS"
			aDbf := a_doc_ops()
			cPath := PRIVPATH
			
		case cTable == "DOC_LOG"
			aDbf := a_doc_log()
			cPath := KUMPATH
			
		case cTable == "DOC_LIT"
			aDbf := a_doc_lit()
			cPath := KUMPATH
			
		case cTable == "ARTICLES"
			aDbf := a_articles()
			cPath := SIFPATH
			
		case cTable == "ELEMENTS"
			aDbf := a_elements()
			cPath := SIFPATH
			
		case cTable == "E_AOPS"
			aDbf := a_e_aops()
			cPath := SIFPATH
			
		case cTable == "E_ATT"
			aDbf := a_e_att()
			cPath := SIFPATH
			
		case cTable == "E_GROUPS"
			aDbf := a_e_groups()
			cPath := SIFPATH
			
		case cTable == "E_GR_ATT"
			aDbf := a_e_gr_att()
			cPath := SIFPATH
			
		case cTable == "E_GR_VAL"
			aDbf := a_e_gr_val()
			cPath := SIFPATH
			
		case cTable == "CUSTOMS"
			aDbf := a_customs()
			cPath := SIFPATH
			
		case cTable == "CONTACTS"
			aDbf := a_contacts()
			cPath := SIFPATH
			
		case cTable == "OBJECTS"
			aDbf := a_objects()
			cPath := SIFPATH
			
		case cTable == "AOPS"
			aDbf := a_aops()
			cPath := SIFPATH
			
		case cTable == "AOPS_ATT"
			aDbf := a_aops_att()
			cPath := SIFPATH
			
	endcase
	
	// dodaj backslash
	AddBS(@cPath)
	
	if !FILE(cPath + cTable + ".DBF")
		DBcreate2(cPath + cTable + ".DBF", aDbf)
	endif

	do case 
		case (nArea2 == F_DOCS) .or. (nArea2 == F__DOCS)
			CREATE_INDEX("1", "STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("A", "STR(doc_status,2)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(doc_priority,4)+DTOS(doc_date)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(doc_priority,4)+DTOS(doc_dvr_date)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("D1", "DTOS(doc_date)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("D2", "DTOS(doc_dvr_date)+STR(doc_no,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_IT) .or. (nArea2 == F__DOC_IT)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(art_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(art_id,10)+STR(doc_no,10)+STR(doc_it_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(doc_no,10)+STR(art_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_IT2) .or. (nArea2 == F__DOC_IT2)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(it_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("2", "art_id+STR(doc_no,10)+STR(doc_it_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(doc_no,10)+art_id", cPath + cTable, .t.)
	
		case (nArea2 == F_DOC_OPS) .or. (nArea2 == F__DOC_OPS)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_op_no,4)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_LOG)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_log_no,10)+DTOS(doc_log_date)+doc_log_time", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(doc_no,10)+doc_log_type+STR(doc_log_no,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_LIT)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_log_no,10)+STR(doc_lit_no,10)", cPath + cTable, .t.)
		case (nArea2 == F_ARTICLES)
			CREATE_INDEX("1", "STR(art_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "PADR(art_desc,100)", cPath + cTable, .t.)
		case (nArea2 == F_ELEMENTS)
			CREATE_INDEX("1", "STR(art_id,10)+STR(el_no,4)+STR(el_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(el_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_E_AOPS)
			CREATE_INDEX("1", "STR(el_id,10)+STR(el_op_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(el_op_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_E_ATT)
		  	CREATE_INDEX("1", "STR(el_id,10)+STR(el_att_id,10)", cPath + cTable, .t.)
		  	CREATE_INDEX("2", "STR(el_att_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_E_GROUPS)
		  	CREATE_INDEX("1", "STR(e_gr_id,10)", cPath + cTable, .t.)
		  	CREATE_INDEX("2", "PADR(e_gr_desc,20)", cPath + cTable, .t.)
		
		case (nArea2 == F_CUSTOMS)
			CREATE_INDEX("1", "STR(cust_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_CONTACTS)
			CREATE_INDEX("1", "STR(cont_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(cust_id,10)+STR(cont_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(cust_id,10)+cont_desc", cPath + cTable, .t.)
			CREATE_INDEX("4", "cont_desc", cPath + cTable, .t.)
		
		case (nArea2 == F_OBJECTS)
			CREATE_INDEX("1", "STR(obj_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(cust_id,10)+STR(obj_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(cust_id,10)+obj_desc", cPath + cTable, .t.)
			CREATE_INDEX("4", "obj_desc", cPath + cTable, .t.)
	
		case (nArea2 == F_AOPS)
			CREATE_INDEX("1", "STR(aop_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_AOPS_ATT)
			CREATE_INDEX("1","STR(aop_att_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2","STR(aop_id,10)+STR(aop_att_id,10)", cPath + cTable, .t.)
		
		case (nArea2 == F_E_GR_ATT)
			CREATE_INDEX("1","STR(e_gr_at_id,10,0)", cPath + cTable, .t.)
			CREATE_INDEX("2","STR(e_gr_id,10,0)+e_gr_at_re+STR(e_gr_at_id,10)", cPath + cTable, .t.)
		
		case (nArea2 == F_E_GR_VAL)
			CREATE_INDEX("1","STR(e_gr_vl_id,10,0)", cPath + cTable, .t.)
			CREATE_INDEX("2","STR(e_gr_at_id,10,0)+STR(e_gr_vl_id,10,0)", cPath + cTable, .t.)
		
	endcase
endif
return 



// --------------------------------
// kreiranje tabele SIFK
// --------------------------------
function cre_sifk(nArea)
local cTbl

if (nArea==-1 .or. nArea == F_SIFK)

	aDbf := a_sifk()
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

if i==F_DOCS .or. i==F__DOCS
	lIdiDalje:=.t.
endif

if i==F_DOC_IT .or. i==F__DOC_IT
	lIdiDalje:=.t.
endif

if i==F_DOC_IT2 .or. i==F__DOC_IT2
	lIdiDalje:=.t.
endif

if i==F_DOC_OPS .or. i==F__DOC_OPS
	lIdiDalje:=.t.
endif

if i==F_DOC_LOG .or. i==F_DOC_LIT
	lIdiDalje:=.t.
endif

if i==F_ARTICLES .or. i==F_ELEMENTS .or. i==F_E_AOPS .or. i==F_E_ATT
	lIdiDalje:=.t.
endif

if i==F_E_GROUPS .or. i==F_E_GR_ATT .or. i==F_E_GR_VAL
	lIdiDalje:=.t.
endif

if i==F_CUSTOMS .or. i==F_CONTACTS .or. i==F_OBJECTS
	lIdiDalje:=.t.
endif

if i==F_AOPS .or. i==F_AOPS_ATT
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
 
aKum  := { F_DOCS, F_DOC_IT, F_DOC_OPS, F_DOC_LOG, F_DOC_LIT }
aPriv := { F__DOCS, F__DOC_IT, F__DOC_OPS }
aSif  := { F_AOPS, F_AOPS_ATT, F_E_GROUPS, F_E_GR_ATT, F_E_GR_VAL, F_ARTICLES, F_ELEMENTS, F_E_AOPS, F_E_ATT, F_OBJECTS, F_CUSTOMS, F_CONTACTS }

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



