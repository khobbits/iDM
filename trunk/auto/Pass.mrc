;## These methods deal with the text events of users trying to log in

on *:TEXT:id*:?: msgauth $nick $address $2-
on *:TEXT:auth*:?: msgauth $nick $address $2-

alias msgauth {
  if ($1 == -sbnc) return
  if ($update) { notice $1 $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ($3) {
    auth $1 $2 notice $1 Nickserv authentication accepted, you are now logged in.  We now use nickserv for accounts, so your password is no longer needed.
  }
  else {
    auth $1 $2 notice $1 Nickserv authentication accepted, you are now logged in.
  }
}

;## These methods deal with actually logging in and out on command

;alias unauth {
;  if (!$1) { putlog Syntax Error: unauth <nickname> - $1- | halt }
;  db.set user login $1 0
;}

alias auth {
  if (!$3) { putlog Syntax Error: auth <nickname> <address> <command> - $1- | halt }
  if ($islogged($1,$2,3) == 1) {
    $3-
  }
}

alias auth_success {
  if (!$3) { putlog Syntax Error: auth_success <nickname> <address> <command> - $1- | halt }
  db.set user login $1 $ctime
  db.set user address $1 $2
  $3-
}

;## This does the catching of the notice

on *:notice:*:?: {
  if ($nick == nickserv) && ($1 == STATUS) {
    if (%idm.nsfail. [ $+ [ $2 ] ] != $null) {
      if ($3 == 3) {
        %idm.nscheck. [ $+ [ $2 ] ]
      }
      elseif ($3 == 0) {
        if (%idm.nsfail0. [ $+ [ $2 ] ] != $null) {
          %idm.nsfail0. [ $+ [ $2 ] ]
        } 
        else {
          %idm.nsfail. [ $+ [ $2 ] ]
        }
      }
      else {
        %idm.nsfail. [ $+ [ $2 ] ]
      }
      .unset %idm.nscheck. [ $+ [ $2 ] ]
      .unset %idm.nsfail. [ $+ [ $2 ] ]
      .unset %idm.nsfail0. [ $+ [ $2 ] ]
    }
  }
}

;## two methods to call the auth system from inside a script.

alias islogged {
  ; $1 = nickname
  ; $2 = address
  ; $3 = [optional] if user is not logged, should auth be attempted
  ; 0/null = no attempt - Script just returns 1 or 0 from logged in
  ; 1 = silent login attempt - Script returns 1 or 0 from logged in + if fail it attempts slient login
  ; 2 = login attempt - Script returns 1 if logged in, 0 if not logged in, tries to log user in and gives user feedback
  ; 3 = login attempt - Script returns 1 if logged in, halt if not logged in, 0 if login not attempted, tries to log user in and gives user feedback
  if (!$2) { putlog Syntax Error: islogged <nickname> <address> [option] - $1- | halt }

  db.hget >islogged user $1 login address

  var %login $hget(>islogged,login)
  var %address $hget(>islogged,address)

  var %threshold $calc($ctime - (60*240))
  if ((%address == $2) && (%login > %threshold)) {
    db.set user login $1 $ctime
    return 1
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60))
  if (%nsattempt > %threshold) { return 0 }

  if (!$3) { return 0 }

  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime
  if ($3 == 1) {
    set %idm.nscheck. [ $+ [ $1 ] ] noop
    set %idm.nsfail. [ $+ [ $1 ] ] noop
    ns status $1
    return 0
  }

  set %idm.nscheck. [ $+ [ $1 ] ] auth_success $1 $2 notice $1 Nickserv authentication accepted, you should now be logged in.
  set %idm.nsfail. [ $+ [ $1 ] ] notice $1 Before you can use this feature you need to be identifed to nickserv.  Type "/msg $me id" to check your account.
  set %idm.nsfail0. [ $+ [ $1 ] ] notice $1 To use iDM you need to have a nickname registered with nickserv.  To register type: /nickserv register and follow the instructions.
  ns status $1

  if ($3 == 3) { halt }
  return 0
}

alias logcheck {
  ; $1 = nickname
  ; $2 = address
  ; $3 = channel
  ; $4- = command to call on success
  ; [optional] create a $4.fail to catch a failed auth
  ; [optional] create a $4.fail0 to catch an unreged failed auth
  if (!$4) { putlog Syntax Error: /logcheck <nickname> <address> <channel> <command on success>  | halt }

  if ($islogged($1,$2,0) == 1) {
    $4 $1 $2 $3 $5-
    return
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60))

  set %idm.nscheck. [ $+ [ $1 ] ] auth_success $1 $2 $4 $1 $2 $3 $5-
  if ($isalias($4 $+ .fail)) {
    set %idm.nsfail. [ $+ [ $1 ] ] $4 $+ .fail $1 $2 $3 $5-
    if ($isalias($4 $+ .fail0)) {
      set %idm.nsfail0. [ $+ [ $1 ] ] $4 $+ .fail0 $1 $2 $3 $5-
    }
  }
  else {
    set %idm.nsfail. [ $+ [ $1 ] ] notice $1 Before you can use this feature you need to be identifed to nickserv.  Type "/msg $me id" to check your account.
    set %idm.nsfail0. [ $+ [ $1 ] ] notice $1 To use iDM you need to have a nickname registered with nickserv.  To register type: /nickserv register and follow the instruction.
  }

  if (%nsattempt > %threshold) {
    %idm.nsfail. [ $+ [ $1 ] ]
    return
  }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime
  ns status $1
  return
}

ON $*:TEXT:/^[!@.]dmlog/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  tokenize 32 $1 $iif($2,$2-,$nick)
  var %sql SELECT * FROM user_log WHERE user = $db.safe($2) UNION SELECT * FROM user_log_archive WHERE user = $db.safe($2) ORDER BY date DESC LIMIT 8
  var %res $db.query(%sql)
  while ($db.query_row(%res, >dmlog)) {
    var %dmlog %dmlog  $logtype($hget(>dmlog,type),$hget(>dmlog,data)) @ $time($hget(>dmlog,date),hh:nn)) $s2(|)
  }
  db.query_end %res
  if (!%dmlog) { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Recent Activity) User $s2($1) has no recent activity }
  else { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo($2) $left(%dmlog,-2) }
}


alias logtype {
  if ($1 == 1) return KO'd $2
  elseif ($1 == 2) return Got KO'd by $2
  elseif ($1 == 3) return Took money from $2
  elseif ($1 == 4) return Got robbed by $2
  elseif ($1 == 5) return Collected $2
  elseif ($1 == 6) return Bought a $2
  elseif ($1 == 7) return Sold a $2
  elseif ($1 == 8) return $2 penalty
  else return Found $2
}
