on *:start: {
  if (*-Startup* iswm $cmdline) {
    echo -s This bot was started by systemreboot.
    loadbot 0
  }
  elseif (*-Auto* iswm $cmdline) {
    set %botnum $botnum
    echo -s This bot was started by autostart. Bot %botnum
    loadbot %botnum
  }
  else {
    load -rv scripts\vars.ini
    echo -s This bot was started manually.
  }
  ddeserver off
  ;dll scripts\medit.dll Load
}

alias botnum {
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (*-Startup* iswm $cmdline) { var %botnum 1 }
  if (%botnum == $null) { return }
  return %botnum
}

alias loadbot {
  if ($1 == 0) {
    .timer 1 15 run "mirc.exe" -Auto2
    .timer 1 30 run "mirc.exe" -Auto3
    .timer 1 45 run "mirc.exe" -Auto4
    .timer 1 60 run "mirc.exe" -Auto5
  }
  if ($1 == 1 || $1 == 0) {
    echo -a loading bot1
    load -rv scripts\bot1var.ini
    mnick iDM
    anick iDM[OFF]
    server idm-bot.com 12000 idmhub:Sp4rh4wk`Gh0$t`B0t
  }
  elseif ($1 == 2) {
    echo -a loading bot2
    load -rv scripts\bot2var.ini
    server idm-bot.com 12000 idmpk:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmba:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmal:Sp4rh4wk`Gh0$t`B0t
  }
  elseif ($1 == 3) {
    echo -a loading bot3
    load -rv scripts\bot3var.ini
    server idm-bot.com 12000 idmfu:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmsn:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmbu:Sp4rh4wk`Gh0$t`B0t
  }
  elseif ($1 == 4) {
    echo -a loading bot4
    load -rv scripts\bot4var.ini
    server idm-bot.com 12000 idmbe:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmla:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmeu:Sp4rh4wk`Gh0$t`B0t
  }
  elseif ($1 == 5) {
    echo -a loading bot5
    load -rv scripts\bot5var.ini
    server idm-bot.com 12000 idmll:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmus:Sp4rh4wk`Gh0$t`B0t
    server -m idm-bot.com 12000 idmgo:Sp4rh4wk`Gh0$t`B0t
  }
}
