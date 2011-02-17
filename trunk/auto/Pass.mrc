;## These methods deal with the text events of users trying to log in

on *:TEXT:id*:?: msgauth $nick $address $2-
on *:TEXT:auth*:?: msgauth $nick $address $2-

alias msgauth {
  if ($1 == -sbnc) return
  if ($update) { notice $1 $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  unset %idm.nsattempt. [ $+ [ $1 ] ]
  if ($3) {
    logcheck $1 $2 notice1 Nickserv authentication accepted, you are now logged in.  We now use nickserv for accounts, so your password is no longer needed.
  }
  else {
    logcheck $1 $2 notice1 Nickserv authentication accepted, you are now logged in.
  }
  if ($isbanned($1)) { notice $nick This account has been suspended, for help appealing visit $supportchan }
}

;## This method deals with actually logging in

alias notice1 { notice $1 $3- }

alias auth_success {
  if (!$1) { putlog Syntax Error: auth_success <nickname> [address] - $1- | halt }
  db.user.set user login $1 $ctime
  if ($2) db.user.set user address $1 $2
}

;## This does the catching of the notice

on *:notice:*:?: {
  if ($nick == nickserv) && ($1 == STATUS) {
    if (%idm.nsfail. [ $+ [ $2 ] ] != $null) {
      if ($3 == 3) {
        tokenize 32 %idm.nscheck. [ $+ [ $2 ] ]
        auth_success $2 $3
        $1-
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
      ; Warn could be overwitten by above tokenize
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
  ; 0 = Script returns either 1 or 0, the user is either logged in or not.
  ; 1 = Script returns either 1 or 0, script triggers a silent login attempt, user is not notified.
  ; 2 = Script returns either 1 or 0, script triggers a login attempt, user is notified.
  ; 3 = Script returns either 1 or 0, script triggers a login attempt, user is notified, halts further script execution if user is not logged in.
  if (!$2) { putlog Syntax Error: islogged <nickname> <address> [option] - $1- | halt }

  db.user.hash >islogged user $1 login address
  var %login $hget(>islogged,login)
  var %address $hget(>islogged,address)

  if ((%login !isnum) || (%login < 1)) {
    db.exec insert into user (login) values ('1') on duplicate key update login = '1'
    if (!$db.user.id($1)) { db.exec insert into user_alt (userid, user) values ( $mysql_insert_id(%db) , $db.safe($1) ) } 
  }

  var %threshold $calc($ctime - (60*240))
  if ((%address == $2) && (%login > %threshold)) {
    auth_success $1
    return 1
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60))
  if (%nsattempt > %threshold) { return 0 }
  if (!$3) { return 0 }
  if ($3 == 1) {
    set %idm.nsattempt. [ $+ [ $1 ] ] $ctime
    set %idm.nscheck. [ $+ [ $1 ] ] noop $1 $2
    set %idm.nsfail. [ $+ [ $1 ] ] noop
    set %idm.nsfail0. [ $+ [ $1 ] ] noop
    ns status $1
    return 0
  }

  logcheck $1 $2 notice1 $1 Nickserv authentication accepted, you should now be logged in.
  if ($3 == 3) { halt }
  return 0
}

alias logcheck {
  ; $1 = nickname
  ; $2 = address
  ; $3- = command to call on success called as <command> <nickname> <address> [$4-]
  ; [optional] create a $3.fail to catch a failed auth, default error message if not supplied
  ; [optional] create a $3.fail0 to catch an unreged failed auth, default error message if not supplied
  if (!$3) { putlog Syntax Error: /logcheck <nickname> <address> <command on success>  | halt }

  if ($islogged($1,$2,0) == 1) {
    $3 $1 $2 $4-
    return
  }

  set %idm.nscheck. [ $+ [ $1 ] ] $3 $1 $2 $4-
  if ($isalias($3 $+ .fail)) {
    set %idm.nsfail. [ $+ [ $1 ] ] $3 $+ .fail $1 $2 $4-
    if ($isalias($3 $+ .fail0)) {
      set %idm.nsfail0. [ $+ [ $1 ] ] $3 $+ .fail0 $1 $2 $4-
    }
  }
  else {
    set %idm.nsfail. [ $+ [ $1 ] ] notice $1 Before you can use this feature you need to be identifed to nickserv.  Type "/msg $me id" to recheck your account.
    set %idm.nsfail0. [ $+ [ $1 ] ] notice $1 To use iDM you need to have a nickname registered with nickserv.  To register type: /nickserv register and follow the instruction.
  }

  var %nsattempt = %idm.nsattempt. [ $+ [ $1 ] ]
  var %threshold $calc($ctime - (60))
  if (%nsattempt > %threshold) {
    %idm.nsfail. [ $+ [ $1 ] ]
    return
  }
  set %idm.nsattempt. [ $+ [ $1 ] ] $ctime
  ns status $1
  return
}

on $*:TEXT:/^[!@.](store|buy|sell|account)/Si:#: {
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if (($2 == -s) || ($2 == -m) || ($2 == -n) || ($2 == -short)) { var %flag 1 }
  else { var %flag 0 }
  if (account isin $1) { logcheck $nick $address accountlink %flag $logo(Account) }
  else { logcheck $nick $address accountlink %flag $logo(Store) You can buy and sell items in the !account panel: }
}

alias accountlink { notice $1 $4- $accounturl($1,$3) }

alias accounturl {
  if ($2) { var %code $right($calc($ticks * $ctime * $rand(1,9)),9) }
  else { var %code $md5($ticks $+ $1) }
  db.set urlmap account code %code $1
  db.set urlmap hostmask code %code $address($1,3)
  return http://idm-bot.com/account/ $+ %code
}