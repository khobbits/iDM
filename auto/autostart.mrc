on *:start: {
  if (*-Auto* iswm $cmdline) {
    set %botnum $right($matchtok($cmdline,-Auto,1,32),1)
    echo -a This bot was started by autostart. Bot %botnum
    loadbot %botnum
  } 
  else {
    echo -a This bot was started manually.
  }
}

on *:connect: {
  if (%botnum != $null) {
    timer 1 10 msg #idm.staff Autoconnected on load.  Botnum: %botnum
    unset %botnum
  }
}

alias loadbot {
  if ($1 == 0) {
    run "mirc.exe" -Auto2
    run "mirc.exe" -Auto3
    run "mirc.exe" -Auto4
  } 
  if ($1 == 1 || $1 == 0) {
    echo -a loading bot1
    bind 6
    server idm-bot.com 12000 idmhub:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmll:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmus:Sp4rh4wk`Gh0$t`B0t
  } 
  elseif ($1 == 2) {
    echo -a loading bot2
    bind 6
    server idm-bot.com 12000 idmpk:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmba:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmal:Sp4rh4wk`Gh0$t`B0t
  } 
  elseif ($1 == 3) {
    echo -a loading bot3
    bind 7
    server idm-bot.com 12000 idmfu:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmsn:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmbu:Sp4rh4wk`Gh0$t`B0t    
  } 
  elseif ($1 == 4) {
    echo -a loading bot4
    bind 7
    server idm-bot.com 12000 idmbe:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmla:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmeu:Sp4rh4wk`Gh0$t`B0t    
  } 
}
