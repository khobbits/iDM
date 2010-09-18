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
  db.set user login $1 $ctime
  if ($2) db.set user address $1 $2
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

  db.hget >islogged user $1 login address
  var %login $hget(>islogged,login)
  var %address $hget(>islogged,address)

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
  if (account isin $1) { logcheck $nick $address accountlink $logo(Account) }
  else { logcheck $nick $address accountlink $logo(Store) You can buy and sell items in the !account panel: }
}

alias accountlink { notice $1 $3- $accounturl($1) }

alias accounturl {
  var %code $md5($ticks $+ $1)
  db.set urlmap account %code $1
  db.set urlmap hostmask %code $address($1,3)
  return http://idm-bot.com/account/ $+ %code
}

on $*:TEXT:/^[!@.]dmlog/Si:#: {
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ($isbanned($nick)) { halt }
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
