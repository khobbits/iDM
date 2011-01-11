;;  This alias (re)loads the gwd database into hashcache.
;;  This alias is used by $gwd.hget
alias gwd.hload {
  if ($hget(>gwd)) { hfree >gwd }
  hmake >gwd 20
  var %sql SELECT * FROM gwd
  var %res $db.query(%sql)
  var %i 0
  while ($db.query_row(%res, >row)) {
    inc %i
    hadd >gwd $hget(>row, user) $+ .name $hget(>row, name)
    hadd >gwd $hget(>row, user) $+ .alt $hget(>row, alt)
    hadd >gwd $hget(>row, user) $+ .weapon $hget(>row, weapon)
    hadd >gwd $hget(>row, user) $+ .nomelee $hget(>row, nomelee)
    hadd >gwd $hget(>row, user) $+ .norange $hget(>row, norange)
    hadd >gwd $hget(>row, user) $+ .nomagic $hget(>row, nomagic)
    hadd >gwd $hget(>row, user) $+ .next $hget(>row, next)
    hadd >gwd $hget(>row, user) $+ .disabled $hget(>row, disabled)
    hadd >gwd $hget(>row, user) $+ .hp $hget(>row, hp)
    hadd >gwd $hget(>row, user) $+ .droprate $hget(>row, droprate)
    hadd >gwd list. $+ %i $hget(>row, user)
    var %list $iif(%list,%list $+ $chr(44)) $+ $hget(>row, user)
  }
  hadd >gwd list %list
  hadd >gwd list.0 %i
  mysql_free %res
}

alias gwd.hget {
  ; $1 = god
  ; ?$2? = value
  if ($1 == $null) { putlog Syntax Error: gwd.hget (1) - $db.safe($1-) | halt }
  if (!$hget(>gwd)) { gwd.hload }
  if (($prop) && ($2 isnum)) return $hget(>gwd,$hget(>gwd,$gettok($1,1,95) $+ . $+ $2) $+ . $+ $prop)
  if ($2 != $null) return $hget(>gwd,$gettok($1,1,95) $+ . $+ $2)
  if (($1 != $null) && ($1 != list)) return $iif($hget(>gwd,$gettok($1,1,95) $+ . $+ name),1,0)
  return $hget(>gwd,list)
}

alias gwd.npc {
  var %i 1
  while ($gwd.hget(list,%i)) {
    if (($dmg($gwd.hget(list,%i).weapon,item) == gwd) && ($gwd.hget(list,%i).disabled == 0)) {
      var %gwd $addtok(%gwd,$gwd.hget(list,%i),32)
      var %gwdalt $addtok(%gwdalt,$gwd.hget(list,%i).alt,32)
    }
    inc %i
  }
  echo -a %gwd - %gwdalt - $numtok(%gwd,32)
  if ($wildtok(%gwd,$1 $+ *,0,32) > 0) {
      return $wildtok(%gwd,$1 $+ *,1,32)
  }
  elseif ($wildtok(%gwdalt,$1 $+ *,0,32) > 0) {
      return $gettok(%gwd,$findtok(%gwdalt,$wildtok(%gwdalt,$1 $+ *,1,32),1,32),32)
  } 
  else {
    return $gettok(%gwd,$r(1,$numtok(%gwd,32)),32)
  }
}

alias gwd.hp {
  ; $1 = gwd
  ; $2 = number of players
  if ($gwd.hget($1,hp) == n) {
    return $calc(( 120 * $2 ) + ( 60 * $ceil($calc( $2 ^ 1.7 ) ) ) )
  }
  elseif ($gwd.hget($1,hp) == n/2) {
    return $calc(( 100 * $2 ) + ( 40 * $ceil($calc( $2 ^ 1.7 ) ) ) )
  }
  elseif ($gwd.hget($1,hp) == n/3) {
    return $calc(( 80 * $2 ) + ( 20 * $ceil($calc( $2 ^ 1.7 ) ) ) )
  }
  else {
    return $gwd.hget($1,hp) 
  }
}

alias gwd.init {
  ; $1 = chan
  ; $2 = reinit
  hadd $1 gwd.plist $hget($1,players)
  echo -a running gwd.init and resetting players to  $hget($1,players)
  hadd $1 gwd.turn $hget($1,players)
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %e = $hget($1,players), %x = 1
  while (%x <= $gettok(%e,0,44)) {
    ;loop through players and init them
    var %px $gettok(%e,%x,44)
    if (!$2) {
      init.player %px $1 1
      hadd %px g $hget($1,gwd.npc)
    }
    else {
      ;hadd %px sp $calc($hget(%px,sp) + 2)
      ;if ($hget(%px,sp) > 4) hadd %px sp 4 
    }
    
    inc %x
  }
  init.player <gwd> $+ $1 $1 0
  hadd <gwd> $+ $1 hp $gwd.hp($hget($1,gwd.npc),$numtok($hget($1,players),44))
  hadd <gwd> $+ $1 mhp $gwd.hp($hget($1,gwd.npc),$numtok($hget($1,players),44))
  hadd <gwd> $+ $1 npc 1
  hadd $1 gwd.time $ctime 
  hadd $1 gwd.healed 0
  if ($2) msgsafe $1 $logo(GWD) Appearing over the corpse spawns $+($s1($gwd.hget($hget($1,gwd.npc),name)),.) Everyone make your attacks, $s1($gwd.hget($hget($1,gwd.npc),name)) will hit in $+($s2(30 seconds),.) 
  else msgsafe $1 $logo(GWD) $lower($1) is ready to raid $+($s1($hget($1,gwd.npc)),.) Everyone make your attacks, $s1($gwd.hget($hget($1,gwd.npc),name)) will hit in $+($s2(30 seconds),.)
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
    var %att $gwd.hget($hget($1,gwd.npc),weapon)
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
    gwd.damage $1 $2 $3 $4 $5
  }
  else { damage $1 $2 $3 $4 }
  if ($hget($2,hp) < 1) { 
    if ($gwd.hget($hget($4,gwd.npc),next)) {
      hadd $4 gwd.npc $v1     
      gwd.init $4 $2
      halt   
    }
    else {
      dead $4 $2 $1
      halt
    } 
  }
}

alias gwd.damage {
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
    if (%mhp1 > %hp1) { 
      var %healed 1    
      $iif($calc($floor(%hp1) + $floor($calc(%hit / $gettok($healer($3),2,32)))) > %mhp1,set %hp1 %mhp1,inc %hp1 $floor($calc(%hit / $gettok($healer($3),2,32))))
      hadd %px hp %hp1 
      if ($numtok(%target,44) < 5) { var %h %h $s1(%px) $remove($hpbar($hget(%px,hp),$hget(%px,mhp)),HP) }
      else { var %h %h $s1(%px) $remove($hpbar2($hget(%px,hp),$hget(%px,mhp)),HP) }
    }
    else { var %target $remtok(%target,%px,1,44) } 
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