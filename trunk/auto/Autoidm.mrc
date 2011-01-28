alias autoidm.acc {
  if (<idm>#idm.newbies == $1) return iDMnewbie
  if (<iDM>* iswm $1) return iDM
  if (<gwd>* iswm $1) return iDMGod
  return $1
}

alias autoidm.nick {
  if (<iDM>* iswm $1) return iDM
  if (<gwd>* iswm $1) return $gwd.hget($hget($right($1,-5),gwd.npc),name)
  return $1
}

alias autoidm.run {
  ; $1 = chan
  if (!$isdisabled($1,timeout)) {
    enddm $1
    return
  }
  autoidm.start $1
}
alias autoidm.start {
  ; $1 = chan
  if (!$hget($1)) return
  if ($hget($1,p2)) return

  var %nick $lower(<idm> $+ $1)
  var %p1 $hget($1,players)
  if (!%p1) halt
  init.chan %p1 %nick $1 $hget($1,sitems) 1
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %winloss $winloss(%nick,%p1,$2)
  var %winlossp1 $gettok(%winloss,1,45)
  var %winlossp2 $gettok(%winloss,2,45)
  var %bonus $ceil($calc( ($hget(%p1,wins) / 1000 ) + ( $hget(%p1,aikills) / 50 ) ))
  msgsafe $1 $logo(DM) $s1($autoidm.nick(%nick)) %winlossp1 (+ $+ %bonus $+ ) has accepted $s1(%p1) $+ 's %winlossp2 DM. $s1($autoidm.nick($hget($1,p1))) gets the first move.
  if ($hget($1,p1) == %nick) autoidm.turn $1
  else { .timerc $+ $1 1 60 autoidm.waiting $1 }
}

alias autoidm.turn {
  ; $1 = chan
  var %nick $lower(<idm> $+ $1)
  var %p2 $hget($1,p2)
  var %spec $hget(%nick,sp)
  var %hp $hget(%nick,hp)
  var %hp2 $hget(%p2,hp)
  if (%hp2 <= 15) var %attcmd surf
  elseif ((%hp <= 9) && (%hp2 <= 50)) var %attcmd dh
  elseif ($hget(%p2,laststyle) == melee) {
    if ($1 == #idm.newbies) { var %attcmd blood }
    elseif ($hget(%p2,poison) >= 1) || (%hp < 60) {
      if ((%hp >= 70) && (%spec >= 3) && (!$hget(%nick,frozen))) var %attcmd dclaws
      else var %attcmd blood
    }
    else var %attcmd smoke
  }
  elseif ($hget(%p2,laststyle) == mage) {
    if ((%spec >= 3) && ($hget(%p2,poison) >= 1)) var %attcmd dbow
    elseif ((%spec >= 1) && (%hp > 50)) var %attcmd mjavelin
    else var %attcmd onyx
  }
  elseif ($hget(%p2,laststyle) == range) || ($hget(%p2,laststyle) == pot) {
    if ($hget(%nick,frozen)) var %attcmd onyx
    elseif ((!$hget(%p2,poison)) && (%spec >= 1) && (%hp2 > 50)) var %attcmd dds
    elseif (%spec >= 3) {
      if ((%hp >= 50) || (%hp2 < 30)) var %attcmd dhally
      else var %attcmd sgs
    }
    elseif (%spec >= 2) {
      if ((%hp >= 50) || (%hp2 < 30)) var %attcmd dclaws
      else var %attcmd sgs
    }
    elseif (%spec >= 1) var %attcmd dds
    else var %attcmd guth
  }
  else {
    if ($1 == #idm.newbies) { var %attcmd smoke }
    else { var %attcmd mjavelin }
  }
  set -u25 %enddm [ $+ [ $1 ] ] 0
  damage %nick %p2 %attcmd $1
  if ($hget(%p2,hp) < 1) {
    dead $1 %p2 %nick
    halt
  }
  if ($specused(%attcmd)) {
    hdec %nick sp $calc($specused(%attcmd) /25)
  }
  hadd %nick frozen 0
  hadd $1 p1 %p2
  hadd $1 p2 %nick
  .timerc $+ $1 1 90 autoidm.waiting $1
}

alias autoidm.waiting {
  var %othernick = $hget($1,p1)
  if (%enddm [ $+ [ $1 ] ] != 0) {
    notice %othernick The DM will end in 40 seconds if %othernick does not make a move or !enddm. If the dm times out %othernick will lose $price($ceil($calc($db.user.get(user,money,%othernick) * 0.005)))
    set %enddm [ $+ [ $1 ] ] %othernick
    .timercw $+ $1 1 20 delaycancelw $1 %othernick
    .timerc $+ $1 1 40 delaycancel $1 %othernick
  }
}
