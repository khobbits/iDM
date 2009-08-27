on *:text:!beer*:#: {
  msg $chan Welcome to the nickserv account test system - islogin reports $iif($islogin($nick) == $true,true,$iif($v1 == $false,false,null))
  logincheck $nick beercheck $2-
  logout $nick
}

alias beercheck {
  var %nick = $1
  var %address = $2
  var %chan = $3
  tokenize 32 $4-
  msg %chan Hello %nick you passed, heres a beer for you $iif($1,and $1-)
}

alias beercheck.fail {
  var %nick = $1
  var %address = $2
  var %chan = $3
  tokenize 32 $4-
  msg %chan Hello %nick you failed the ns check, i can only serve you soft drinks.  Here is a coke for you $iif($1,and $1-)
}

;===

alias islogin {
  ; $1 = nick
  ; [$2 = success]
  ; [$3 = fail]
  if ($.readini(login.ini,login,$1) == $address($1,0)) { 
    return $true
  }
  else {
    if (%logindelay. [ $+ [ $1 ] ] == $true) {
      return $false
    }
    else {
      noop $checklogin($1,$2,$3)
      return $null
    }
  }
}

alias logincheck {
  ; $1 = nick
  ; $2- = success
  var %2 = $2 $nick $address $chan $3-
  if ($isalias($2 $+ .fail)) { 
    %3 = $2 $+ .fail $nick $address $chan $3-
    if ($isalias($2 $+ .recheck)) { %4 = $2 $+ .recheck $nick $address $chan $3- }
    else { %4 = $2 $+ .fail $nick $address $chan $3- }
  }
  else {
    var %3 = notice $1 Sorry but you need to be identified to use this command, identify to nickserv and try later. 
    var %4 = notice $1 You need to be identified to use this command, type !login to recheck.
  }
  if ($islogin($1,%2,%3) == $true)  {
    $2 $nick $address $chan $3-
  } 
  elseif ($v1 == $false)  {
    %4
  }
}

alias logout {
  remini login.ini Login $1
}

;===

alias checklogin {
  if ($3) {
    appendc %idm.nscheck. [ $+ [ $1 ] ] $2
    appendc %idm.nsfail. [ $+ [ $1 ] ] $3
  }
  else {
    appendc %idm.nscheck. [ $+ [ $1 ] ] noop
    appendc %idm.nsfail. [ $+ [ $1 ] ] noop
  }
  ns status $1
}


on *:notice:*:?: {
  if ($nick == nickserv) && ($1 == STATUS) {
    if (%idm.nsfail. [ $+ [ $2 ] ] != $null) {
      if ($3 == 3) {
        loginsuccess $2
        %idm.nscheck. [ $+ [ $2 ] ]
      }
      else {
        set -u30 %logindelay. [ $+ [ $2 ] ] $true
        %idm.nsfail. [ $+ [ $2 ] ]
      }
      unset %idm.nscheck. [ $+ [ $2 ] ]
      unset %idm.nsfail. [ $+ [ $2 ] ]
    }
  }
}

alias loginsuccess {
  writeini login.ini Login $1 $address($1,0)
}

;====

alias randuserpass {
  var %i = 1,%pass
  while (%i <= 6) {
    inc %i
    set %pass %pass $+ $rand(a,z)
  }
  return %pass
}

alias changepass {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($2 != $.readini(Passes.ini,Passes,$nick)) { notice $nick Your old password was incorrect. | halt }
  checkregpm $nick changeuserpass $nick $2 $3
}

alias changeuserpass {
  ; $1 = nickname
  ; $2 = oldpass
  ; $3 = newpass
  if ($2 != $.readini(Passes.ini,Passes,$1)) { notice $1 Your old password was incorrect. | return }
  notice $1 You have changed your password. Your new password is $s2($remove($strip($3),$chr(36),$chr(37))) $+ .
  remini Passes.ini Passes $1
  writeini Passes.ini Passes $1 $remove($strip($3),$chr(36),$chr(37))
  remini login.ini Login $1
  writeini login.ini Login $1 true
}
