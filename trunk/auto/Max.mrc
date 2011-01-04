;;  This alias calculates the max hit of an attack, with and without item bonuses
;;  This alias is used by: !max
alias max {
  ; $1 = attack
  if ($1 == $null) { putlog Syntax Error: attack (1) - $db.safe($1-) | halt }
  var %dbdmg = $dmg($1, 3h)
  if ($1 == dh) { var %dbdmg = $dmg($1, 1h) }
  if ($1 == dh9) { tokenize 32 dh | var %dbdmg = $dmg($1, 3h) }
  var %dbhits = $dmg($1,hits)
  var %dbbonus = $dmg($1, atkbonus)
  if (%dbbonus == n) { return $dmg.ratio(%dbhits,%dbdmg,0,1) $dmg.ratio(%dbhits,%dbdmg,4,1) }
  elseif ($dmg($1,type) == range) {
    ;Normal Archer Ring _or_Accumulator Both
    return $dmg.ratio(%dbhits,%dbdmg,0,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,4,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,8,%dbbonus)
  }
  elseif ($dmg($1,type) == magic) {
    ;Normal Voidmage_or_MagesBook_or_GodCape Two_Bonuses Three_Bonuses
    return $dmg.ratio(%dbhits,%dbdmg,0,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,4,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,8,%dbbonus)
  }
  else {
    ;Normal Barrowgloves Firecape Both
    return $dmg.ratio(%dbhits,%dbdmg,0,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,4,%dbbonus) $dmg.ratio(%dbhits,%dbdmg,8,%dbbonus)
  }
}

;;  This alias calculates the damage 'pattern', and will return the max damage hit pattern.
;;  This alias is used by: $max (!max)
alias dmg.ratio {
  ; $1 = hit pattern - 1-1-1
  ; $2 = max hit
  ; $3 = attack bonus
  ; $4 = bonus toggle
  if ($4 == $null) { putlog Syntax Error: dmg.ratio (4) - $db.safe($1-) | halt }
  var %hits
  var %i = 0
  while (%i < $numtok($1,45)) {
    var %hitp $gettok($1,%i,45)
    if (%hitp < 1) { var %hitp 1 } 
    inc %i
    var %hits $iif(%hits,%hits $+ -) $+ $ceil($calc(($2 + ($3 * $4)) / %hitp))
  }
  return %hits
}

;;  These alias's are used as accessors for database values

alias attack { return $iif($dmg($1,name),$true,$false) }
alias ispvp { return $iif($dmg($1,pvp),$true,$false) }
alias isgwd { return $iif($dmg($1,gwd),$true,$false) }
alias isweapon {
  var %wep $dmg($1,item)
  return $iif(%wep,%wep,$false)
}
alias specused { return $calc($dmg($1,spec) * 25) }
alias poisoner { return $dmg($1,poison) $dmg($1,poisonamount) }
alias freezer { return $dmg($1,freeze) }
alias healer { return $dmg($1,heal) $dmg($1,healamount) }

;;  This alias (re)loads the weapon database into hashcache.
;;  This alias is used by $dmg.hget ($dmg)
alias dmg.hload {
  if ($hget(>weapon)) { hfree >weapon }
  hmake >weapon 50
  var %sql SELECT * FROM weapon
  var %res $db.query(%sql)
  var %i 0
  while ($db.query_row(%res, >row)) {
    inc %i
    hadd >weapon $hget(>row, weapon) $+ .name $hget(>row, name)
    hadd >weapon $hget(>row, weapon) $+ .item $hget(>row, item)
    hadd >weapon $hget(>row, weapon) $+ .pvp $hget(>row, pvp)
    hadd >weapon $hget(>row, weapon) $+ .0l $gettok($hget(>row, range),1,44)
    hadd >weapon $hget(>row, weapon) $+ .0h $gettok($hget(>row, range),2,44)
    hadd >weapon $hget(>row, weapon) $+ .1l $gettok($hget(>row, low),1,44)
    hadd >weapon $hget(>row, weapon) $+ .1h $gettok($hget(>row, low),2,44)
    hadd >weapon $hget(>row, weapon) $+ .2l $gettok($hget(>row, mid),1,44)
    hadd >weapon $hget(>row, weapon) $+ .2h $gettok($hget(>row, mid),2,44)
    hadd >weapon $hget(>row, weapon) $+ .3l $gettok($hget(>row, high),1,44)
    hadd >weapon $hget(>row, weapon) $+ .3h $gettok($hget(>row, high),2,44)
    hadd >weapon $hget(>row, weapon) $+ .hits $hget(>row, hits)
    hadd >weapon $hget(>row, weapon) $+ .type $hget(>row, type)
    hadd >weapon $hget(>row, weapon) $+ .gwd $hget(>row, gwd)
    hadd >weapon $hget(>row, weapon) $+ .atkbonus $hget(>row, atkbonus)
    hadd >weapon $hget(>row, weapon) $+ .defbonus $hget(>row, defbonus)
    hadd >weapon $hget(>row, weapon) $+ .spec $hget(>row, spec)
    hadd >weapon $hget(>row, weapon) $+ .poison $hget(>row, poisonchance)
    hadd >weapon $hget(>row, weapon) $+ .poisonamount $hget(>row, poisonamount)
    hadd >weapon $hget(>row, weapon) $+ .freeze $hget(>row, freeze)
    hadd >weapon $hget(>row, weapon) $+ .heal $hget(>row, healchance)
    hadd >weapon $hget(>row, weapon) $+ .healamount $hget(>row, healamount)
    hadd >weapon $hget(>row, weapon) $+ .splash $hget(>row, splash)
    hadd >weapon $hget(>row, weapon) $+ .what $hget(>row, what)
    hadd >weapon $hget(>row, weapon) $+ .effect $hget(>row, effect)
    hadd >weapon list. $+ %i $hget(>row, weapon)
    var %list $iif(%list,%list $+ $chr(44)) $+ $hget(>row, weapon)
  }
  hadd >weapon list %list
  hadd >weapon list.0 %i
  mysql_free %res
}

;;  This alias will return the db values related to an attack.  This will load the weapons db into hashcache.
;;  This alias is used by: $dmg
alias dmg.hget {
  if (!$hget(>weapon)) { dmg.hload }
  tokenize 32 $1- 0
  return $hget(>weapon,$1 $+ . $+ $2)
}

;;  This alias is the main accessor for database values.  This method allows access to the database using multiple methods.
;;  This alias is used by: $accuracy $atkbonus $hit $damage $enablec $disablec !max !hitchance !attack
alias dmg {
  ; $1 = attack
  ; ?$2? = value
  if ($1 == $null) { putlog Syntax Error: dmg (1) - $db.safe($1-) | halt }
  if (($prop) && ($2 isnum)) return $dmg.hget($dmg.hget($gettok($1,1,95),$2),$prop)
  if ($2 != $null) return $dmg.hget($gettok($1,1,95),$2)
  if (($1 != $null) && ($1 != list)) return $iif($dmg.hget($gettok($1,1,95),name),1,0)
  return $hget(>weapon,list)

}

;;  This alias is used to calculate the accuracy bonus for an attack
;;  This alias is used by: $hit (!attack)
alias accuracy {
  ;1 is Attack
  ;2 is Attackee
  if ($istok(melee mage range,$hget($2,laststyle),32)) {
    if ($dmg($1,type) == melee) {
      if ($hget($2,laststyle) == melee) return 0
      elseif ($hget($2,laststyle) == mage) return -1
      elseif ($hget($2,laststyle) == range) return 1
    }
    elseif ($dmg($1,type) == magic) {
      if ($hget($2,laststyle) == melee) return 1
      elseif ($hget($2,laststyle) == mage) return 0
      elseif ($hget($2,laststyle) == range) return -1
    }
    elseif ($dmg($1,type) == range) {
      if ($hget($2,laststyle) == melee) return -1
      elseif ($hget($2,laststyle) == mage) return 1
      elseif ($hget($2,laststyle) == range) return 0
    }
  }
  return 0
}

;;  This alias is used to calculate the attack bonus for an attack
;;  This alias is used by: $hit (!attack) 
alias atkbonus {
  ;1 is Weapon
  ;2 is hashtable
  if ($dmg($1,atkbonus) == 0) { return 0 }
  if ($dmg($1,atkbonus) == n) { return n }
  if ($dmg($1,type) == magic) { var %atk $calc($iif($hget($2,godcape),4,0)) + $iif($hget($2,mbook),4,0) }
  elseif ($dmg($1,type) == range) { var %atk $calc($iif($hget($2,archer),4,0) + $iif($hget($2,accumulator),4,0)) }
  elseif ($dmg($1,type) == melee) { var %atk $calc($iif($hget($2,firecape),4,0) + $iif($hget($2,bgloves),4,0)) }
  return %atk
}

;;  This alias returns the damage breakdown that is displayed on each attack, and thus the actual damage.
;;  This alias is used by: $damage (!attack)
alias hitdmg {
  ; $1 = attack
  ; $2 = accuracy
  ; $3 = hit pattern
  ; $4 = attack bonus
  ; $5 = defense bonus
  if ($5 == $null) { putlog Syntax Error: hitdmg (5) - $db.safe($1-) | halt }
  if ($1 == dh_9) { var %ndmg 3 }
  elseif ($1 == dh_10) { var %ndmg 1 }
  elseif ($2 <= $dmg($1,0l)) { var %ndmg 1 }
  elseif ($2 <= $dmg($1,0h)) { var %ndmg 2 }
  else { var %ndmg 3 }
  var %i = 0
  while (%i < $numtok($3,45)) {
    inc %i
    var %hitp $gettok($3,%i,45)
    if (%hitp < 1) { var %hitp 1 } 
    if (%hitp == 1) {
      var %dmg = $rand($dmg($1,%ndmg $+ l),$calc($dmg($1,%ndmg $+ h) + $4)))
      var %dmg = $ceil($calc(%dmg * $5))
      var %return = %return %dmg
    }
    else {
      var %sdmg = $ceil($calc(%dmg * (1 / %hitp)))
      var %return = %return %sdmg
    }
  }
  if (%debuga == $me) putlog Debug: Hit pattern: $3 Attack Bonus: $4 Defense Bonus: $5 Min Damage: $dmg($1,%ndmg $+ l) Max Damage: $dmg($1,%ndmg $+ h) Actual Damage %return
  return %return
}

;;  This alias prepares the attack statistics for the hitdmg alias.
;;  This alias is used by: $damage (!attack)
alias hit {
  ;1 is Weapon
  ;2 is Attacker
  ;3 is Attackee
  ;4 is Chan
  if ($4 == $null) { putlog Syntax Error: hit (4) - $db.safe($1-) | halt }
  if ($accuracy($1,$3) == -1) { var %acc $r(1,80) }
  elseif ($accuracy($1,$3) == 1) { var %acc $r(15,100) }
  else { var %acc $r(1,100) }
  var %def $iif($hget($3,elshield),$calc($r(90,98) / 100),1)
  var %atk $atkbonus($1,$2)
  if (%atk == n) { 
    var %atk $calc($hget($2,$dmg($1,item)) - 1)
    if (%atk > 4) { var %atk 4 }
    if (%atk < 1) { var %atk 0 }
  }
  if ($dmg($1,defbonus) == 0) { var %def 1 }
  if (<iDM>* iswm $2) {
    inc %atk $ceil($calc( ($hget($3,wins) / 1000 ) + ( $hget($3,aikills) / 50 ) ))
  }
  elseif (<gwd>* iswm $2) {
    inc %atk $ceil($calc(( $numtok($hget($4,players),44) - 1) * 5 ))
  }
  if (%debuga == $me) putlog Debug: Weapon: $1 Attacker: $2 Attackee: $3 Chan: $4 Accuracy bonus: $accuracy($1,$3) Accuracy: %acc
  return $hitdmg($1,%acc,$dmg($1,hits),%atk,%def)
}

on $*:TEXT:/^[!@.]max/Si:#: {
  if (# == #idm) || (# == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if (!$2) { $iif($left($1,1) == @,msgsafe $chan,notice $nick) Please specify the weapon to look up. Syntax: !max whip | halt }
  var %wep $2
  if ($2 == dh9) { var %wep dh }
  if (!$attack(%wep)) {
    notice $nick $logo(ERROR) $s1(%wep) is not a recognized attack.
    halt
  }
  if (!$max(%wep)) notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
  var %msg $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(MAX) $upper($2) $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41)))
  var %msg %msg $+ $iif($2 == dh,$+($chr(32),$chr(40),use 'dh9' for <10 hp,$chr(41)))
  var %msg %msg $+ $iif($2 == dh9,$+($chr(32),$chr(40),use 'dh' for >10 hp,$chr(41)))
  var %msg %msg $+ : $dmg.breakdown($2,1) ( $+ $dmg(%wep,type) $+ )
  if ($dmg(%wep,gwd) == 1) { var %msg %msg $chr(124) GWD only attack }
  elseif ($dmg(%wep,atkbonus) == 0) { var %msg %msg $chr(124) No item bonuses }
  elseif ($dmg(%wep,atkbonus) == n) { var %msg %msg $chr(124) +1 damage for each extra item up to +4: $dmg.breakdown($2,2) }
  elseif ($dmg(%wep,type) == range) { var %msg %msg $chr(124) Archer Ring or Accumulator $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) }
  elseif ($dmg(%wep,type) == magic) { var %msg %msg $chr(124) Mage Book or God Cape $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) }
  elseif ($dmg(%wep,type) == melee) { var %msg %msg $chr(124) Barrow gloves or Fire cape $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) }
  %msg $iif($dmg(%wep,effect),$+($chr(40),$v1,$chr(41)))
}

alias dmg.breakdown { return $s2($gettok($max($1),$2,32)) $iif($totalhit($1,$2),$+($chr(40),$s2($v1),$chr(41))) }

alias totalhit {
  if (- isin $max($1)) { return $calc($gettok($gettok($v2,$2,32),1,45) + $gettok($gettok($v2,$2,32),2,45) + $gettok($gettok($v2,$2,32),3,45) + $gettok($gettok($v2,$2,32),4,45)) }
  return $false
}

on $*:TEXT:/^[!@.]hitchance/Si:#: {
  if (# == #idm) || (# == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
  if ((!$3) || ($3 !isnum 0-999)) { $iif($left($1,1) == @,msgsafe $chan,notice $nick) Syntax: !hitchance <weapon> <damage> | halt }
  var %wep $2
  if ($2 == dh9) { var %wep dh }
  if (!$attack(%wep)) { notice $nick $logo(ERROR) $s1(%wep) is not a recognized attack. | halt }

  db.hget >hitchance equip_armour $nick
  var %atk = $atkbonus(%wep,>hitchance), %hits = $dmg(%wep,hits), %targets = 1, %i = 1, %l = 0
  
  if (%atk == n) { 
    var %atk $calc($hget(>hitchance,$dmg(%wep,item)) - 1)
    if (%atk > 4) { var %atk 4 }
    if (%atk < 1) { var %atk 0 }
  }
  
  while (%i < $numtok(%hits,45)) {
    inc %i
    if ($gettok(%hits,%i,45) == 1) { inc %targets 1 }
    else { inc %targets $calc(1 / $gettok(%hits,%i,45)))) }
  }
  var %target = $ceil( $calc($3 / %targets) ), %lowtop = $dmg(%wep, 1h), %midtop = $dmg(%wep, 2h), %hightop = $dmg(%wep, 3h), %lowchance = 0, %midchance = 0, %highchance = 0
  var %lowbchance = $calc(($dmg(%wep,0l)) /100), %midbchance = $calc(($dmg(%wep,0h) - $dmg(%wep,0l)) /100), %highbchance = $calc((100 - $dmg(%wep,0h)) /100)
  if ($2 == dh9) { var %lowbchance = 0, %midbchance = 0, %highbchance = 1 }
  while (%l < 2) {
    if (%target <= %lowtop) { var %lowchance = $calc(((%lowtop - %target +1) / (%lowtop - $dmg(%wep, 1l) +1 )) * %lowbchance) }
    if (%target <= $dmg(%wep, 1l)) { var %lowchance = %lowbchance }
    if (%target <= %midtop) { var %midchance = $calc(((%midtop - %target +1) / (%midtop - $dmg(%wep, 2l) +1 )) * %midbchance) }
    if (%target <= $dmg(%wep, 2l)) { var %midchance = %midbchance }
    if (%target <= %hightop) { var %highchance = $calc(((%hightop - %target +1) / (%hightop - $dmg(%wep, 3l) +1 )) * %highbchance) }
    if (%target <= $dmg(%wep, 3l)) { var %highchance = %highbchance }
    if (%l = 0) var %hitchance0 $floor($calc(( %lowchance + %midchance + %highchance ) * 100))
    if (%l = 1) var %hitchance1 $floor($calc(( %lowchance + %midchance + %highchance ) * 100))
    inc %lowtop %atk
    inc %midtop %atk
    inc %hightop %atk
    inc %l
  }
  $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(HITCHANCE) $2 has $s2(%hitchance1 $+ %) chance of hitting $s1($3 $+ +) with your item bonus ( $+ %hitchance0 $+ % without).  Use !max $2 for attack details.
}
