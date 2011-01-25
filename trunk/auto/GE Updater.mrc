on $*:TEXT:/^[!@.]geupdate/Si:%staffchans: {
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
    if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
    if ($hget(>geupdate)) { 
      if ($2 == stop) {
        msgsafe $staffchan $logo(GE UPDATE) Update stopped. - Duration: $duration($calc($ctime - $hget(>geupdate,t)))
        hfree >geupdate
        sockclose pu
        .timerpu2 off
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
  sockopen pu itemdb-rs.runescape.com 80
}
on *:sockopen:pu:{ 
  if ($hget(>geupdate,id) <= $hget(>geupdate,max)) {
    hadd >geupdate item $getitem($hget(>geupdate,id))
    hadd >geupdate price $getprice($hget(>geupdate,id))
    hadd >geupdate name $getname($hget(>geupdate,id))
    if ($hget(>geupdate,item) == 0) { hinc >geupdate id 1 | pu2 | return }
    sockwrite -nt $sockname GET /viewitem.ws?obj= $+ $hget(>geupdate,item) HTTP/1.1
    sockwrite -nt $sockname Host: itemdb-rs.runescape.com
    sockwrite -nt $sockname $crlf
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
  if (<b>Market price:</b> * iswm %ge) {
    var %price $remove(%ge,<b>Market price:</b> )
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
      putlog $logo(GE UPDATE) %price is not a number @ http://itemdb-rs.runescape.com/viewitem.ws?obj= $+ $hget(>geupdate,item)
    }
    hinc >geupdate id 1
    sockclose pu
    .timerpu2 1 1 pu2 
  }
  elseif (The item you were trying to view could not be found. isin %ge) { 
    hinc >geupdate id 1
    msgsafe $staffchan $logo(GE UPDATE) Error: http://itemdb-rs.runescape.com/viewitem.ws?obj= $+ $hget(>geupdate,item) does not exist.
    sockclose pu
    .timerpu2 1 1 pu2 
  }
  elseif (</html> isin %ge) { 
    putlog $logo(GE UPDATE) Error: http://itemdb-rs.runescape.com/viewitem.ws?obj= $+ $hget(>geupdate,item) did not return a valid match.
    sockclose pu
    .timerpu2 1 1 pu2 
  }
}
on *:sockclose:pu: {
  pu2
}
alias -l pu2 {
  if ($sock(pu)) { sockclose pu }
  .timerpucheck 1 15 pu3
  sockopen pu itemdb-rs.runescape.com 80
}
alias -l pu3 {
  putlog $logo(GE UPDATE) Error: Socket timeout.  Status: $iif($sock(pu),$sock(pu).pause,Closed) Restarting.
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
  dbcheck
  var %sql = SELECT `id` FROM `drops` WHERE `id` != 0 ORDER BY `id` DESC LIMIT $1 $+ ,1
  return $iif($db.select(%sql,id) === $null,0,$v1)
}
alias -l getprice {
  dbcheck
  var %sql = SELECT `price` FROM `drops` WHERE `id` != 0 ORDER BY `id` DESC LIMIT $1 $+ ,1
  return $iif($db.select(%sql,price) === $null,0,$v1)
}
alias -l getname {
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
  dbcheck
  var %sql = UPDATE `drops` SET `price` = $2 WHERE `id` = $1
  return $db.exec(%sql)
}
