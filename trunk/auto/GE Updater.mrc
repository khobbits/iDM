on $*:TEXT:/^[!@.]geupdate/Si:%staffchans: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4) {
    if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
    if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
    if ($hget(>geupdate)) { 
      if ($2 == stop) {
        msgsafe $staffchan $logo(GE UPDATE) Update stopped. - Duration: $duration($calc($ctime - $hget(>geupdate,t)))
        hfree >geupdate
        sockclose pu
        .timerpu off
        .timerpucheck off
      }
      else {
        msgsafe $staffchan $logo(GE UPDATE) Update is in progress. Status: $hget(>geupdate,id) $+ / $+ $hget(>geupdate,max) - Duration: $duration($calc($ctime - $hget(>geupdate,t)))
      }
    }
    elseif ($2 == start) {
      geupdate
      msgsafe $staffchan $logo(GE UPDATE) Loot update started ( $+ $time(hh:nn:ss) $+ ).
    }
    else {
      msgsafe $staffchan $logo(GE UPDATE) Update is not in progress. Syntax !geupdate [start|stop]
    }
  }
}
alias geupdate {
  hmake >geupdate
  hadd >geupdate id 0
  hadd >geupdate t $ctime
  hadd >geupdate max $getmax
  if ($sock(pu)) { sockclose pu }
  sockopen pu services.runescape.com 80
}
on *:sockopen:pu:{ 
  if ($hget(>geupdate,id) <= $hget(>geupdate,max)) {
    hadd >geupdate item $getitem($hget(>geupdate,id))
    hadd >geupdate price $getprice($hget(>geupdate,id))
    hadd >geupdate name $getname($hget(>geupdate,id))
    if ($hget(>geupdate,item) == 0) { hinc >geupdate id 1 | pu2 | return }
    sockwrite -nt $sockname GET /m=itemdb_rs/viewitem.ws?obj= $+ $hget(>geupdate,item) HTTP/1.1
    sockwrite -nt $sockname Host: services.runescape.com
    sockwrite -nt $sockname $crlf
    hadd >geupdate url http://services.runescape.com/m=itemdb_rs/viewitem.ws?obj= $+ $hget(>geupdate,item)

  }
  else { 
    sockclose pu
    .timerpucheck off
    msgsafe $staffchan $logo(GE UPDATE) Price Update Completed. Duration: $duration($calc($ctime - $hget(>geupdate,t)))
    hfree >geupdate
  }
}
on *:SOCKREAD:pu:{
  if ($sockerr) {
    msgsafe $staffchan $logo(GE UPDATE) Error: Socket failed - $sock(pu).wserr 
    sockclose pu
    halt
  }
  var %ge
  sockread %ge
  if (<b>Current guide price:</b> * iswm %ge) {
    var %price $remove(%ge,<b>Current guide price:</b> )
    var %price = $xcalc(%price)
    if (%price isnum) {
      if ($hget(>geupdate,price) != %price) {
        setitem $hget(>geupdate,item) %price
        if ($abs($calc($hget(>geupdate,price) - %price)) > $abs($calc($hget(>geupdate,price) * 0.1))) {
          putlog $logo(GE UPDATE) $hget(>geupdate,name) ( $+ $hget(>geupdate,item) $+ ) $+ 's price updated from $hget(>geupdate,price) to %price Status: $hget(>geupdate,id) $+ / $+ $hget(>geupdate,max)
        }
      }
    }
    else {
      putlog $logo(GE UPDATE) %price is not a number @ $hget(>geupdate,url)
    }
    hinc >geupdate id 1
    sockclose pu
    .timerpu2 1 1 pu2 
  }
  elseif (The item you were trying to view could not be found. isin %ge) { 
    hinc >geupdate id 1
    msgsafe $staffchan $logo(GE UPDATE) Error: $hget(>geupdate,url) does not exist.
    sockclose pu
    .timerpu2 1 1 pu2 
  }
  elseif ((</html> isin %ge) || (</body> isin %ge)) { 
    putlog $logo(GE UPDATE) Error: $hget(>geupdate,url) did not return a valid match.
    sockclose pu
    .timerpu2 1 1 pu2 
  }
}
on *:sockclose:pu: {
  pu2
}
alias -l pu2 {
  if ($hget(>geupdate)) {
    if ($sock(pu)) { sockclose pu }
    .timerpucheck 1 15 pu3
    sockopen pu services.runescape.com 80
  }
}
alias -l pu3 {
  if ($sock(pu)) {
    ;putlog $logo(GE UPDATE) Error: Socket timeout.  Read: $sock(pu).rcvd Queue: $sock(pu).rq / $sock(pu).sq Idle: $sock(pu).lr ERR: $sock(pu).wsmsg $hget(>geupdate,url)
  }
  else {
    ;putlog $logo(GE UPDATE) Error: Socket timeout.  Status: Closed $hget(>geupdate,url)
  }
  pu2
}

alias -l xcalc {
  if (($isid) && ($0 == 1)) {
    var %calc $remove($1,$chr(44))
    var %calc $regsubex(%calc,/(e|ph?i)/gi,$eval($ $+ \1,2))
    var %calc $regsubex(%calc,/([\d.]+)([kmbt])/gi,$calc($regml(1) * $eval(1 $+ $str(0,$replace($regml(2),k,3,m,6,b,9,t,12)),2)))
    var %calc $regsubex(%calc,/(abs|a?(?:sin|cos|tan)|ceil|floor|log|sgn|sqrt)\(((?:[^()]++|(?R))*)\)/gi,$eval($ $+ \1 $+ ( $+ $calc(\2) $+ ),2))
    var %calc $calc(%calc)
    return %calc
  }
}
alias -l getitem {
  if ($1 == $null) { putlog Syntax Error: getitem (1) - $db.safe($1-) | halt }
  dbcheck
  var %sql = SELECT `id` FROM `drops` WHERE `id` != 0 ORDER BY `id` DESC LIMIT $1 $+ ,1
  return $iif($db.select(%sql,id) === $null,0,$v1)
}
alias -l getprice {
  if ($1 == $null) { putlog Syntax Error: getprice (1) - $db.safe($1-) | halt }
  dbcheck
  var %sql = SELECT `price` FROM `drops` WHERE `id` != 0 ORDER BY `id` DESC LIMIT $1 $+ ,1
  return $iif($db.select(%sql,price) === $null,0,$v1)
}
alias -l getname {
  if ($1 == $null) { putlog Syntax Error: getname (1) - $db.safe($1-) | halt }
  dbcheck
  var %sql = SELECT `item` FROM `drops` WHERE `id` != 0 ORDER BY `id` DESC LIMIT $1 $+ ,1
  return $iif($db.select(%sql,item) === $null,0,$v1)
}
alias -l getmax {
  dbcheck
  var %sql = SELECT count(*) as count FROM `drops` WHERE `id` != 0
  return $iif($db.select(%sql,count) === $null,0,$v1)
}
alias -l setitem {
  if ($2 == $null) { putlog Syntax Error: setitem (2) - $db.safe($1-) | halt }
  dbcheck
  var %sql = UPDATE `drops` SET `price` = $2 WHERE `id` = $1
  return $db.exec(%sql)
}
