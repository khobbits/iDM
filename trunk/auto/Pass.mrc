on *:TEXT:id*:?: msgauth $nick $address $2-
on *:TEXT:auth*:?: msgauth $nick $address $2-
on *:TEXT:logout*:?: msgunauth $nick $address $2-

alias msgauth {
  if ($3) {
    auth $1 $2 notice $1 Authentication accepted, you are now logged in.  We now use nickserv for accounts, so your password is no longer needed.
  }
  else {
    auth $1 $2 notice $1 Authentication accepted, you are now logged in.
  }
}

alias msgunauth {
  unauth $1
  notice $1 You are now logged out.
  unset %idm.nsattempt. [ $+ [ $1 ] ]
}

alias unauth {
  if (!$1) { mysqlderror Syntax Error: unauth <nickname> - $1- | halt }
  db.set user login $1 0
}

alias auth {
  if (!$3) { mysqlderror Syntax Error: auth <nickname> <address> <command> - $1- | halt }
  db.hget islogged user $1 login address
  var %login $hget(islogged,login)
  var %address $hget(islogged,address)
  var %threshold $calc($ctime - (60*240))
  if ((%address == $2) && (%login > %threshold)) {
    db.set user login $1 $ctime
    $3-
    return
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %qthreshold $calc($ctime - (5))
  if (%nsattempt > %qthreshold) { halt }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime
  auth_checkreg $1 $2 auth_success $1 $2 $3-
}

alias auth_success {
  if (!$3) { mysqlderror Syntax Error: auth_success <nickname> <address> <command> - $1- | halt }
  db.set user login $1 $ctime
  db.set user address $1 $2
  $3-
}

alias auth_checkreg {
  set %idm.nscheck. [ $+ [ $1 ] ] $3-
  set %idm.nsfail. [ $+ [ $1 ] ] notice $1 Sorry but use this feature properly need to be identified with nickserv.  Identify and try to auth with iDM again using /msg $me id.
  ns status $1
}

on *:notice:*:?: {
  if ($nick == nickserv) && ($1 == STATUS) {
    if (%idm.nsfail. [ $+ [ $2 ] ] != $null) {
      if ($3 == 3) {
        %idm.nscheck. [ $+ [ $2 ] ]
      }
      else {
        %idm.nsfail. [ $+ [ $2 ] ]
      }
      unset %idm.nscheck. [ $+ [ $2 ] ]
      unset %idm.nsfail. [ $+ [ $2 ] ]
    }
  }
}

alias islogged {
  ; $1 = nickname
  ; $2 = address
  ; $3 = [optional] if user is not logged, should auth be attempted
  ;      0/null = no attempt; 1 = silent login attempt; 2 = login attempt; 3 = halt + login attempt;
  if (!$2) { mysqlderror Syntax Error: islogged <nickname> <address> [option] - $1- | halt }

  db.hget islogged user $1 login address

  var %login $hget(islogged,login)
  var %address $hget(islogged,address)

  var %threshold $calc($ctime - (60*240))
  if ((%address == $2) && (%login > %threshold)) {
    db.set user login $1 $ctime
    return 1
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60*10))
  var %qthreshold $calc($ctime - (5))
  if (%nsattempt > %qthreshold) { halt }
  if (%nsattempt > %threshold) { return 0 }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime

  if (!$3) { return 0 }
  if ($3 == 1) {
    set %idm.nscheck. [ $+ [ $1 ] ] noop
    set %idm.nsfail. [ $+ [ $1 ] ] noop
    ns status $1
  }
  auth_checkreg $1 $2 auth_success $1 $2 notice $1 Authentication attempt succeeded, you should now be logged in.
  if ($3 == 3) { halt }
  return 0
}

alias logcheck {
  ; $1 = nickname
  ; $2 = address
  ; $3 = channel
  ; $4- = command to call on success
  ; [optional] create a $2.fail to catch a failed auth
  if (!$4) { mysqlderror Syntax Error: /logcheck <nickname> <address> <channel> <command on success>  | halt }

  if ($islogged($1,$2,0) == 1) {
    $4 $1 $2 $3 $5-
    return
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60*5))
  var %qthreshold $calc($ctime - (5))
  if (%nsattempt > %qthreshold) { halt }

  set %idm.nscheck. [ $+ [ $1 ] ] $4 $1 $2 $3 $5-
  if ($isalias($2 $+ .fail)) {
    set %idm.nsfail. [ $+ [ $1 ] ] $4 $+ .fail $1 $2 $3 $5-
  }
  else {
    set %idm.nsfail. [ $+ [ $1 ] ] notice $1 Sorry but use this feature properly need to be identified with nickserv before using this command.  To login type /msg $me id
  }

  if (%nsattempt > %threshold) {
    %idm.nsfail. [ $+ [ $1 ] ]
    return
  }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime

  ns status $1
  return
}
