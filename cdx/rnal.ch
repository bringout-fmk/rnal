// priprema tabele
#xcommand O_P_RNAL     => select (F_P_RNAL);   usex (PRIVPATH+"P_RNAL") ; set order to tag "brnal"

#xcommand O_P_RNOP     => select (F_P_RNOP);   usex (PRIVPATH+"P_RNOP") ; set order to tag "brnal"

// kumulativ tabele
#xcommand O_RNAL     => select (F_RNAL);   use (KUMPATH+"RNAL") ; set order to tag "brnal"
#xcommand O_RNOP     => select (F_RNOP);   use (KUMPATH+"RNOP") ; set order to tag "brnal"

// sifrarnik tabele
#xcommand O_S_RNKA   => select(F_S_RNKA);  use  (SIFPATH+"S_RNKA") ; set order to tag "id"
#xcommand O_S_RNOP   => select(F_S_RNOP);  use  (SIFPATH+"S_RNOP") ; set order to tag "id"

