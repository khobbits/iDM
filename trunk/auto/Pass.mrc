on *:TEXT:id*:?: msgauth $nick
on *:TEXT:auth*:?: msgauth $nick
on *:TEXT:logout*:?: msgunauth $nick

alias msgauth {
  auth $nick notice $nick Authentication accepted, you are now logged in.
}

alias msgunauth {
  unauth $1
  notice $1 You are now logged out.
}

alias unauth {
  db.set user login $1 0
}

alias auth {
  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %qthreshold $calc($ctime - (5))
  if (%nsattempt > %qthreshold) { halt }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime
  auth_checkreg $1 auth_success $1 $2-
}

alias auth_success {
  db.set user login $1 $ctime
  $2-
}

alias auth_checkreg {
  set %idm.nscheck. [ $+ [ $1 ] ] $2-
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
  ; $2 = [optional] if user is not logged, should auth be attempted
  ;      0/null = no attempt; 1 = silent login attempt; 2 = login attempt; 3 = halt + login attempt;

  var %login $db.get(user,login,$1)
  var %threshold $calc($ctime - (60*30))
  if (%login > %threshold) {
    db.set user login $1 $ctime
    return 1
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60*5))
  var %qthreshold $calc($ctime - (5))
  if (%nsattempt > %qthreshold) { halt }
  if (%nsattempt > %threshold) { return 0 }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime


  if (!$2) { return 0 }
  if ($2 == 1) {
    set %idm.nscheck. [ $+ [ $1 ] ] noop
    set %idm.nsfail. [ $+ [ $1 ] ] noop
    ns status $1
  }
  auth_checkreg $1 auth_success $1 notice $nick Authentication attempt succeeded, you should now be logged in.
  if ($2 == 3) { halt }
  return 0
}

alias logcheck {
  ; $1 = nickname
  ; $2 = command to call on success
  ; [optional] create a $2.fail to catch a failed auth
  if ($islogged($1,0) == 1) {
    $2-
    return
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60*5))
  var %qthreshold $calc($ctime - (5))
  if (%nsattempt > %qthreshold) { halt }

  set %idm.nscheck. [ $+ [ $1 ] ] $2 $nick $address $chan $3-
  if ($isalias($2 $+ .fail)) {
    set %idm.nsfail. [ $+ [ $1 ] ] $2 $+ .fail $nick $address $chan $3-
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
