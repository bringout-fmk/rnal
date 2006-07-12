// priprema tabele
#xcommand O_P_RNAL     => select (F_P_RNAL);   usex (PRIVPATH+"P_RNAL") ; set order to tag "br_nal"
#xcommand O_P_RNOP     => select (F_P_RNOP);   usex (PRIVPATH+"P_RNOP") ; set order to tag "br_nal"
#xcommand O_P_RNST     => select (F_P_RNST);   usex (PRIVPATH+"P_RNST") ; set order to tag "br_nal"

// print tabele
#xcommand O_T_RNST     => select (F_T_RNST);   usex (PRIVPATH+"T_RNST") ; set order to tag "br_nal"
#xcommand O_T_RNOP     => select (F_T_RNOP);   usex (PRIVPATH+"T_RNOP") ; set order to tag "br_nal"
#xcommand O_T_PARS     => select (F_T_PARS);   usex (PRIVPATH+"T_PARS") ; set order to tag "id_par"

// kumulativ tabele
#xcommand O_RNAL     => select (F_RNAL);   use (KUMPATH+"RNAL") ; set order to tag "br_nal"
#xcommand O_RNST     => select (F_RNST);   use (KUMPATH+"RNST") ; set order to tag "br_nal"
#xcommand O_RNOP     => select (F_RNOP);   use (KUMPATH+"RNOP") ; set order to tag "br_nal"
#xcommand O_RNLOG    => select (F_RNLOG);  use (KUMPATH+"RNLOG") ; set order to tag "br_nal"
#xcommand O_LOGIT    => select (F_LOGIT);  use (KUMPATH+"RNLOG_IT") ; set order to tag "br_nal"

// sifrarnik tabele
#xcommand O_S_RNKA   => select(F_S_RNKA);  use  (SIFPATH+"S_RNKA") ; set order to tag "id"
#xcommand O_S_RNOP   => select(F_S_RNOP);  use  (SIFPATH+"S_RNOP") ; set order to tag "id"
#xcommand O_S_TIPOVI => select(F_S_TIPOVI);  use  (SIFPATH+"S_TIPOVI") ; set order to tag "id"

