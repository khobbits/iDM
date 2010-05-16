;## These methods deal with the text events of users trying to log in

on *:TEXT:id*:?: msgauth $nick $address $2-
on *:TEXT:auth*:?: msgauth $nick $address $2-

alias msgauth {
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
  if ($2) {
    var %sql SELECT * FROM user_event WHERE user = $db.safe($2) ORDER BY date DESC LIMIT 5
    var %res $db.query(%sql)
    while ($db.query_row(%res, >dmlog)) {
      var %dmlog %dmlog $time($hget(>dmlog,date),mm/dd/yy)) - $hget(>dmlog,event) $s2(|)
    }
    db.query_end %res
    if (!%dmlog) $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(Recent Activity) User $s2($2) has no recent activity
    else $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($2) $left(%dmlog,-2)
  }
  else {
    var %sql SELECT * FROM user_event WHERE user = $db.safe($nick) ORDER BY date DESC LIMIT 5
    var %res $db.query(%sql)
    while ($db.query_row(%res, >dmlog)) {
      var %dmlog %dmlog $time($hget(>dmlog,date),mm/dd/yy)) - $hget(>dmlog,event) $s2(|)
    }
    db.query_end %res
    if (!%dmlog) $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(Recent Activity) User $s2($nick) has no recent activity
    else $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($nick) $left(%dmlog,-2)
  }
}