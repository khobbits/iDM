ON $*:TEXT:/^[!@.]ticket$/Si:#: {
  if ($chan == #idm || $chan == $staffchan) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if ($jackpot(disabled) == 1) { notice $nick $logo(ERROR) Jackpot is currently disabled, please try again shortly | halt }
  if (%jpupdate == 1) { notice $nick $logo(ERROR) You are unable to purchase a jackpot ticket at this time, please try again shortly. | halt }
  if ($isbanned($nick)) { halt }
  if ($nick ison #idm.staff) { halt }
  if ($islogged($nick,$address,0)) {
    buy-ticket $nick
  }
  else {
    notice $nick Attempting iDM login using Nickserv authentication...
    logcheck $nick $address buy-ticket $nick
  }
}

alias buy-ticket {
  if ($db.user.get(equip_item,ticket,$1) == 0) {
    if ($db.user.get(user,money,$1) >= $jackpot(tixprice)) {
      db.user.set equip_item ticket $1 1
      db.user.set equip_item tixname $1 $1
      db.user.set user money $1 - $jackpot(tixprice)       
      db.exec UPDATE drops SET price = price + $db.safe($jackpot(tixprice)) WHERE item = 'jackpot'
      notice $1 $logo(Jackpot) You just purchased a ticket for the upcoming jackpot. The next jackpot is in $s1($jackpot(next)) $+ .
    }
    else notice $1 $logo(ERROR) You currently do not have the required amount ( $+ $price($jackpot(tixprice)) $+ ) to purchase a jackpot ticket.
  }
  else notice $1 $logo(ERROR) You currently already own a jackpot ticket. Next jackpot is in $s1($jackpot(next)) $+ .
}

ON $*:TEXT:/^[!@.](jp|jackpot)$/Si:#: {
  if ($chan == #idm || $chan == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if ($jackpot(disabled) == 1) { notice $nick $logo(ERROR) Jackpot is currently disabled, please try again shortly | halt }
  if ($nick(#iDM,$nick,ohv) || $nick(#iDM.Support,$nick,ohv)) {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Jackpot) The current jackpot is $s1($jackpot(total)), the next jackpot is in $s1($jackpot(next)) $+ . $&
      $s1($jackpot(players)) players have purchased a ticket.
  } 
  else {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Jackpot) The current jackpot is $s1($jackpot(total)), the next jackpot is in $s1($jackpot(next)) $+ .
  }
}

ON $*:TEXT:/^[!@.](last|l)(jp|jackpot)$/Si:#: {
  if ($chan == #idm || $chan == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if ($jackpot(disabled) == 1) { notice $nick $logo(ERROR) Jackpot is currently disabled, please try again shortly | halt }
  $iif($left($1,1) == @,msgsafe $chan,notice $nick) $jackpot(lastjp)
}

ON $*:TEXT:/^[!@.](jp|jackpot)(stats|stat)/Si:#: {
  if ($chan == #idm || $chan == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if ($jackpot(disabled) == 1) { notice $nick $logo(ERROR) Jackpot is currently disabled, please try again shortly | halt }
  if ($2) $iif($left($1,1) == @,msgsafe $chan,notice $nick) $jp-stats($2)
  else {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $jp-stats
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $jackpot(lastjp)
  }
}

alias jackpot {
  if ($1 == next) return $duration($calc($iif($time(HH) & 1,0,3600) + ((59 - $time(nn)) *60) + $calc(60 - $time(ss))))
  elseif ($1 == hour) {
    if ($time(HH) < 22) return $calc($time(HH) + 2) $+ :00
    else return 00:00
  }  
  elseif ($1 == total) return $price($db.get(drops,price,item,jackpot))
  elseif ($1 = total-long) return $db.get(drops,price,item,jackpot)
  elseif ($1 == players) {
    var %sql = SELECT count(DISTINCT user.userid) as count FROM user_alt INNER JOIN user ON user_alt.userid=user.userid INNER JOIN equip_item ON user.userid=equip_item.userid WHERE banned = '0' AND ticket = '1'
    var %result = $db.query(%sql)
    if ($db.query_row(%result,>count)) return $hget(>count,count)
    else return -1
  }
  elseif ($1 == lastjp) {
    if ($hget(lastjp,user)) return $logo(LastJP) The last jackpot of $s1($price($hget(lastjp,amount))) was won by $s1($hget(lastjp,user))
    else {
      var %sql = SELECT * FROM jackpots ORDER BY date DESC LIMIT 1
      var %result = $db.query(%sql)
      if ($db.query_row(%result,>lastjp)) { 
        hadd -mu120 lastjp user $hget(>lastjp,user) 
        hadd -mu120 lastjp amount $hget(>lastjp,amount)
        return $logo(LastJP) The last jackpot of $s1($price($hget(lastjp,amount))) was won by $s1($hget(lastjp,user))
      }
      else { 
        hadd -mu120 lastjp user N/A
        hadd -mu120 lastjp amount N/A 
        return $logo(LastJP) The last jackpot of $s1($price($hget(lastjp,amount))) was won by $s1($hget(lastjp,user))
      }
    }
  }
  elseif ($1 == min) return 10
  elseif ($1 == drop-percent) return 1.25
  elseif ($1 == tixprice) return 250000000
  elseif ($1 == disabled) return 0
  else return 0
}


alias jp-stats {
  if ($1) {
    var %hname jp- $+ $1
    if ($hget(%hname,count)) {
      if ($v1 > 0) return $logo(JP-Stats) $s1($1) has won a total of $s1($hget(%hname,count)) jackpots totaling $s1($price($hget(%hname,total))) with an average of $s1($price($hget(%hname,average))) $+ . Last win $s1($duration($calc($ctime - $hget(%hname,date)),2)) ago.
      else return $logo(JP-Stats) $s1($1) has never won a jackpot.
    }
    else {
      var %sql = SELECT max(date) as date,count(amount) as count,round(avg(amount)) as average,sum(amount) as total FROM jackpots WHERE user = $db.safe($1) ORDER BY date DESC LIMIT 1
      var %result = $db.query(%sql)
      if ($db.query_row(%result,>jpstats)) { 
        if ($hget(>jpstats,count) > 0) {
          hadd -mu120 %hname date $hget(>jpstats,date)
          hadd -mu120 %hname count $hget(>jpstats,count)
          hadd -mu120 %hname total $hget(>jpstats,total)
          hadd -mu120 %hname average $hget(>jpstats,average)
          return $logo(JP-Stats) $s1($1) has won a total of $s1($hget(%hname,count)) jackpots totaling $s1($price($hget(%hname,total))) with an average of $s1($price($hget(%hname,average))) $+ . Last win $s1($duration($calc($ctime - $hget(%hname,date)),2)) ago.
        }
        else {
          hadd -mu120 %hname count 0
          hadd -mu120 %hname total 0
          hadd -mu120 %hname average 0
          return $logo(JP-Stats) $s1($1) has never won a jackpot.
        }
      }
      else return $logo(JP-Stats) $s1($1) has never won a jackpot.
    }
  }
  else {
    if ($hget(@jpstats,count)) return $logo(JP-Stats) There has been a total of $s1($hget(@jpstats,count)) jackpots totaling $s1($price($hget(@jpstats,total))) with an average of $s1($price($hget(@jpstats,average))) $+ .
    else {
      var %sql = SELECT count(amount) as count,round(avg(amount)) as average,sum(amount) as total FROM jackpots LIMIT 1
      var %result = $db.query(%sql)
      if ($db.query_row(%result,>jpstats)) { 
        hadd -mu120 @jpstats count $hget(>jpstats,count)
        hadd -mu120 @jpstats total $hget(>jpstats,total)
        hadd -mu120 @jpstats average $hget(>jpstats,average)
        return $logo(JP-Stats) There has been a total of $s1($hget(@jpstats,count)) jackpots totaling $s1($price($hget(@jpstats,total))) with an average of $s1($price($hget(@jpstats,average))) $+ .
      }
      else return $logo(JP-Stats) $s1($1) has never won a jackpot.
    }
  }
}

alias special-jp {
  if ($day == Monday) return 00
  elseif ($day == Tuesday) return 10
  elseif ($day == Wednesday) return 14
  elseif ($day == Thursday) return 12
  elseif ($day == Friday) return 20
  elseif ($day == Saturday) return 18
  elseif ($day == Sunday) return 8
  else return 20
}

alias run-jackpot {
  ; Run Anti-idle before sending out JP message
  sbnc tcl antiidle

  ; Temp lockout of buying jackpot tickets so no errors return
  set -u30 %jpupdate 1

  if ($jackpot(players) >= $jackpot(min)) {
    ; Picking a winner
    var %sql = SELECT DISTINCT equip_item.tixname FROM user_alt INNER JOIN user ON user_alt.userid=user.userid INNER JOIN equip_item ON user.userid=equip_item.userid WHERE banned = '0' AND ticket = '1' ORDER BY rand() LIMIT 10
    var %result = $db.query(%sql)
    var %rows = $calc($db.query_num_rows(%result) - 1)
    if ($db.query_row(%result,>jp,$r(0,%rows))) { var %winner $hget(>jp,tixname) }
    else { msg #idm.staff $logo(Jackpot) ERROR -- Unable to pick winner | halt }
    db.query_end %result

    ; Announce + award winner
    if ($time(HH) == $special-jp) {
      putlog perform jp-amsg $logo(Jackpot) The special jackpot has been won! The wheel has landed on $s1(%winner) and they have won $s1($jackpot(total)) and $s1(20) cookies!
      db.user.set user money %winner + $jackpot(total-long)
      db.user.set equip_staff cookies %winner + 20
      userlog jackpot %winner $jackpot(total-long)
      db.exec INSERT INTO jackpots ( `user` , `date`, `amount` ) VALUES ( $db.safe(%winner) $+ , $db.safe($ctime) $+ , $db.safe($jackpot(total-long)) )
    }
    else {
      putlog perform jp-amsg $logo(Jackpot) The jackpot has been won! The wheel has landed on $s1(%winner) and they have won $s1($jackpot(total)) $+ !
      db.user.set user money %winner + $jackpot(total-long)
      userlog jackpot %winner $jackpot(total-long)
      db.exec INSERT INTO jackpots ( `user` , `date`, `amount` ) VALUES ( $db.safe(%winner) $+ , $db.safe($ctime) $+ , $db.safe($jackpot(total-long)) )
    }

    ; Resetting tables
    db.exec UPDATE equip_item SET ticket = '0', tixname = '0' WHERE ticket = '1'

    ; Resetting jackpot
    db.exec UPDATE drops SET price = '0' WHERE item = 'jackpot'

    ; Start new timer
    .timerjp -o $jackpot(hour) 1 1 /run-jackpot

    ; Msg #iDM.Support stats
    msgsafe $supportchan $jp-stats(%winner)
  }
  else {
    ;db.exec UPDATE drops SET price = price + '10000000000' WHERE item = 'jackpot'
    putlog perform jp-amsg $logo(Jackpot) The minimum number of players ( $+ $jackpot(min) $+ ) was not reached. Carrying over the jackpot, the current jackpot is $s1($jackpot(total)) $+ .
    .timerjp -o $jackpot(hour) 1 1 /run-jackpot
  }
}

alias jp-amsg {
  var %ac 1, %tc $chan(0)
  if ($me != iDM) {
    while (%ac <= %tc) {
      if (!$istok(#idm #idm.staff #idm.support #stats,$chan(%ac),32)) var %c %c $chan(%ac)
      inc %ac
    }
    if ($len(%c) >= 2) msg $replace(%c,$chr(32),$chr(44)) $1-
  }
  else amsg $1-
}
