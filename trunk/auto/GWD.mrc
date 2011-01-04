alias gwd.npc {
  var %gwd Corporeal Zamorak Saradomin Bandos Armadyl
  return $iif($istok(%gwd,$1,32),$1,$gettok(%gwd,$r(1,$numtok(%gwd,32)),32))
}

alias gwd.hp {
  ; $1 = number of players
  return $calc(( 100 * $1 ) + ( 50 * $ceil($calc( $1 ^ 1.6 ) ) ) )
}

alias gwd.init {
  ; $1 = chan
  hadd $1 gwd.plist $hget($1,players)
  hadd $1 gwd.turn $hget($1,players)
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %e = $hget($1,players), %x = 1
  while (%x <= $gettok(%e,0,44)) {
    ;loop through players and init them
    init.player $gettok(%e,%x,44) $1 1
    hadd $gettok(%e,%x,44) g $hget($1,gwd.npc)
    inc %x
  }
  init.player <gwd> $+ $1 $1 0
  hadd <gwd> $+ $1 hp $gwd.hp($numtok($hget($1,players),44))
  hadd <gwd> $+ $1 mhp $gwd.hp($numtok($hget($1,players),44))
  hadd <gwd> $+ $1 npc 1
  hadd $1 gwd.time $ctime 
  hadd $1 gwd.healed 0
  msgsafe $1 $logo(GWD) $lower($1) is ready to raid $+($s1($hget($1,gwd.npc)),.) Everyone make their attacks, $s1($hget($1,gwd.npc)) will hit in $+($s2(30 seconds),.)
  .timer $+ $1 1 30 gwd.npcatt $1
}

alias gwd.npcatt {
  ; $1 = chan
  if ($numtok($hget($1,gwd.turn),44) >= 1) {
    var %p2 $gettok($hget($1,gwd.turn),1,44)
    var %att smite
  }
  else {
    var %p2 $gettok($hget($1,players),$r(1,$numtok($hget($1,players),44)),44)
    var %att $hget($1,gwd.npc)
  }
  ;hits
  damage <gwd> $+ $1 %p2 %att $1
  if ($hget(%p2,hp) < 1) {
    if ($numtok($hget($1,players),44) > 1) {
      userlog loss %p2 $autoidm.acc(<gwd> $+ $1)
      db.set user losses %p2 + 1
      pcancel $1 %p2
      hadd $1 gwd.turn $hget($1,players)
      .timer $+ $1 1 30 gwd.npcatt $1
    }
    else {
      msgsafe $1 $logo(KO) $s1($autoidm.nick(<gwd> $+ $1)) has killed the last player on the team $+($s1(%p2),.) $+($s1([),Time: $s2($duration($calc($ctime - $hget($1,gwd.time)))),$s1(]))
      userlog loss %p2 $autoidm.acc(<gwd> $+ $1)
      userlog win $autoidm.acc(<gwd> $+ $1) $1
      db.set user losses %p2 + 1
      db.set user wins $autoidm.acc(<gwd> $+ $1) + 1

      var %sql = INSERT INTO loot_player (`chan`, `cash`, `bot`, `date`, `count`) VALUES ( $db.safe($1) , ' $+ 0 $+ ' , ' $+ $tag $+ ' , CURDATE(), '1' ) ON DUPLICATE KEY UPDATE count = count+1
      db.exec %sql
      set -u10 %wait. [ $+ [ $1 ] ] on
      .timer 1 10 msgsafe $1 $logo(GWD) Ready.    
      cancel $1
    }
  }
  else {
    hadd $1 gwd.turn $hget($1,players)
    hadd $1 gwd.healed 0
    .timer $+ $1 1 30 gwd.npcatt $1
  }
}

alias gwd.att {
  ;1 is person attacking
  ;2 is person attacked
  ;3 is weapon
  ;4 is chan
  ;5 is user string
  if (!$istok($hget($4,gwd.turn),$1,44)) { notice $1 $logo(GWD) You have already attacked | halt }
  var %hits $dmg($3,hits) 
  if (($isgwd($3)) && ((%hits == N) || (%hits == 0))) {
    gwddamage $1 $2 $3 $4 $5
  }
  else { damage $1 $2 $3 $4 }
  if ($hget($2,hp) < 1) { 
    dead $4 $2 $1
    halt 
  }
}

alias gwddamage {
  ;1 is person attacking
  ;2 is other person
  ;3 is weapon
  ;4 is chan
  ;5 is user string
  if ($4 == $null) { putlog Syntax Error: gwddamage (4) - $db.safe($1-) | halt }
  var %hits $dmg($3,hits)
  if (%hits == N) {
    var %target $remtok($hget($4,players),$1,1,44)
    if ($numtok($hget($4,players),44) < 1) { notice $1 $logo(GWD) Invalid target: there are no other players in this GWD. | halt }
  }
  elseif (%hits == 0) {
    var %target $5
    if (%target == $1) { notice $1 $logo(GWD) Invalid target: You cannot heal yourself. | halt }
    if (!$findtok($hget($4,players),%target,44)) { notice $1 $logo(GWD) Invalid target: %target is not in this GWD. | halt }
  }  
  else { putlog Syntax Error: gwddamage (4) - $db.safe($1-) - Parameter 3 Invalid: Not GWD attack | halt }
  
  if ($hget($4,gwd.healed) == 1) {  notice $1 $logo(GWD) A healing attack has already been used this round. | halt }
  
  var %hit $hit($3,$1,$2,$4)
  var %x = 1, %y = %target
  while (%x <= $numtok(%y,44)) {
    var %px $gettok(%y,%x,44)       
    var %hp1 $hget(%px,hp)
    var %mhp1 $hget(%px,mhp)
    if (%mhp1 > %hp1) { var %healed 1 }
    else { var %target $remtok(%target,%px,1,44) } 
    $iif($calc($floor(%hp1) + $floor($calc(%hit / $gettok($healer($3),2,32)))) > %mhp1,set %hp1 %mhp1,inc %hp1 $floor($calc(%hit / $gettok($healer($3),2,32))))
    hadd %px hp %hp1 

    if ($numtok(%target,44) < 5) { var %h %h $s1(%px) $remove($hpbar($hget(%px,hp),$hget(%px,mhp)),HP) }
    else { var %h %h $s1(%px) $remove($hpbar2($hget(%px,hp),$hget(%px,mhp)),HP) }
    inc %x
  }
  if (!%healed) { notice $1 $logo(GWD) Invalid target: $iif($numtok(%target,44) == 1,Player has,All Players have) full HP. | halt }
  hadd $4 gwd.healed 1
  var %msg $logo(GWD) $s1($autoidm.nick($1)) $replace($dmg($3,what),$eval(%p2%,0),$s1(%target),$eval(%attack%,0),$dmg($3,name)) by up to %hit HP
  if ($numtok(%target,44) > 1) {
    msgsafe $4 %msg
    var %target $1 $+ , $+ %target
    notice %target $logo(GWD) HP: %h  
  } 
  else {
    msgsafe $4 %msg - $s1(%target) $hpbar($hget(%target,hp),$hget(%target,mhp))
  }

    
}

alias gwd.turn {
  ;1 is person attacking
  ;2 is chan
  hadd $2 gwd.turn $remtok($hget($2,gwd.turn),$1,44)
  if ($numtok($hget($2,gwd.turn),44) < 1) {
    .timer $+ $2 1 5 gwd.npcatt $2
  }
  else {
    .timer $+ $2 1 30 gwd.npcatt $2
  }
}

alias autoidm.acc {
  if (<idm>#idm.newbies == $1) return iDMnewbie
  if (<iDM>* iswm $1) return iDM
  if (<gwd>* iswm $1) return iDMGod
  return $1
}

alias autoidm.nick {
  if (<iDM>* iswm $1) return iDM
  if (<gwd>* iswm $1) return $hget($right($1,-5),gwd.npc)
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
  .timerc $+ $1 1 60 autoidm.waiting $1
}

alias autoidm.waiting {
  var %othernick = $hget($1,p1)
  if (%enddm [ $+ [ $1 ] ] != 0) {
    notice %othernick The DM will end in 40 seconds if %othernick does not make a move or !enddm. If the dm times out %othernick will lose $price($ceil($calc($db.get(user,money,%othernick) * 0.005)))
    set %enddm [ $+ [ $1 ] ] %othernick
    .timercw $+ $1 1 20 delaycancelw $1 %othernick
    .timerc $+ $1 1 40 delaycancel $1 %othernick
  }
}
