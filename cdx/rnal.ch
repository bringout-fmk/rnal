// komande za otvaranje tabela


// -------------------------------------
// PRIVPATH
// -------------------------------------

#xcommand O__DOCS => select (F__DOCS); usex (PRIVPATH + "_DOCS"); set order to tag "1"
#xcommand O__DOC_IT => select (F__DOC_IT); usex (PRIVPATH + "_DOC_IT"); set order to tag "1"
#xcommand O__DOC_OPS => select (F__DOC_OPS); usex (PRIVPATH + "_DOCS_OP"); set order to tag "1"
#xcommand O_T_DOCS => select (F_T_DOCS); usex (PRIVPATH + "T_DOCS"); set order to tag "1"
#xcommand O_T_DOC_OPS => select (F_T_DOC_OPS); usex (PRIVPATH + "T_DOC_OPS"); set order to tag "1"
#xcommand O_T_PARS => select (F_T_PARS); usex (PRIVPATH + "T_PARS"); set order to tag "id_par"


// -----------------------------------
// KUMPATH
// -----------------------------------

#xcommand O_DOCS => select (F_DOCS); use (KUMPATH + "DOCS"); set order to tag "1"
#xcommand O_DOC_IT => select (F_DOC_IT); use (KUMPATH + "DOC_IT"); set order to tag "1"
#xcommand O_DOC_OPS => select (F_DOC_OPS); use (KUMPATH + "DOC_OPS"); set order to tag "1"
#xcommand O_DOC_LOG => select (F_DOC_LOG); use (KUMPATH + "DOC_LOG"); set order to tag "1"
#xcommand O_DOC_LIT => select (F_DOC_LIT); use (KUMPATH + "DOC_LIT"); set order to tag "1"


// -------------------------------------
// SIFPATH
// -------------------------------------

#xcommand O_E_GROUPS => select(F_E_GROUPS); use (SIFPATH + "E_GROUPS"); set order to tag "1"
#xcommand O_CUSTOMS => select(F_CUSTOMS); use (SIFPATH + "CUSTOMS"); set order to tag "1"
#xcommand O_CONTACTS => select(F_CONTACTS); use (SIFPATH + "CONTACTS"); set order to tag "1"
#xcommand O_E_GR_ATT => select(F_E_GR_ATT); use (SIFPATH + "E_GR_ATT"); set order to tag "1"
#xcommand O_E_GR_VAL => select(F_E_GR_VAL); use (SIFPATH+"E_GR_VAL"); set order to tag "1"
#xcommand O_AOPS => select(F_AOPS); use (SIFPATH + "AOPS"); set order to tag "1"
#xcommand O_AOPS_ATT => select(F_AOPS_ATT); use (SIFPATH + "AOPS_ATT"); set order to tag "1"
#xcommand O_ARTICLES => select(F_ARTICLES); use (SIFPATH + "ARTICLES"); set order to tag "1"
#xcommand O_ELEMENTS => select(F_ELEMENTS); use (SIFPATH + "ELEMENTS"); set order to tag "1"
#xcommand O_E_AOPS => select(F_E_AOPS); use (SIFPATH + "E_AOPS"); set order to tag "1"
#xcommand O_E_ATT => select(F_E_ATT); use (SIFPATH + "E_ATT"); set order to tag "1"



