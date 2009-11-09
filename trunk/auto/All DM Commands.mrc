on $*:TEXT:/^[!.]/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  var %attcmd $right($1,-1)
  if (($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2)) {
    if (%attcmd == specpot) {
      if ($db.get(equip_item,specpot,$nick) < 1) { notice $nick You don't have any specpots. | halt }
      if ($($+(%,sp,$player($nick,#),#),2) == 4) { notice $nick You already have a full special bar. | halt }
      set $+(%,sp,$player($nick,#),#) 4
      db.set equip_item specpot $nick - 1
      msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.
      unset %laststyle [ $+ [ # ] ]
      unset $+(%,frozen,$nick)
      set %turn [ $+ [ # ] ] $iif($player($nick,#) == 1,2,1)
    }
    elseif ($attack(%attcmd)) {
      if ($calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2)) {
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($.readini(onoff,%attcmd,#)) {
        notice $nick $logo(ERROR) This command has been disabled for this channel.
        halt
      }
      if (%frozen [ $+ [ $nick ] ] == on) && ($max(m,%attcmd)) {
        notice $nick You're frozen and can't use melee.
        halt
      }
      if ($ispvp(%attcmd)) {
        if ($db.get(equip_pvp,%attcmd,$nick) < 1) {
          notice $nick You don't have this weapon.
          halt
        }
        db.set equip_pvp %attcmd $nick - 1
      }
      if ($isweapon($replace(%attcmd,surf,mudkip))) {
        if ($db.get(equip_item,$replace(%attcmd,surf,mudkip),$nick) < 1) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      set -u25 %enddm [ $+ [ $chan ] ] 0
      damage $nick $iif($nick == %p1 [ $+ [ # ] ],%p2 [ $+ [ # ] ],$v2) %attcmd #
    }
  }
}

alias damage {
  ;1 is person attacking
  ;2 is other person
  ;3 is weapon
  ;4 is chan

  var %hp1 $($+(%,hp,$player($1,$4),$4),2)
  var %hp2 $($+(%,hp,$player($2,$4),$4),2)

  if ($3 == dh) {
    if (%hp1 < 10) { var %hit $hit(d_h9,$1,$2,$4) }
    else { var %hit $hit(d_h10,$1,$2,$4) }
  }
  else {
    var %hit $hit($3,$1,$2,$4)
  }

  var %i = 1
  var %hitshow 
  while (%i <= $numtok(%hit,32)) {
    if (%i != 1) var %hitshow %hitshow -
    var %hitdmg $gettok(%hit,%i,32)
    if (%hp2 == 0) {
      var %hit $puttok(%hit,KO,%i,32)
      var %hitshow %hitshow 4KO
    }
    elseif (%hp2 <= %hitdmg) {
      var %hit $puttok(%hit,%hp2,%i,32)
      var %hitshow %hitshow $s2(%hp2)
      set %hp2 0
    }
    else {
      dec %hp2 %hitdmg
      var %hitshow %hitshow $s2(%hitdmg)
    }
    inc %i
  }
  var %msg $logo(DM) $s1($1)

  if (($3 == cbow) && (%cbowspec [ $+ [ $1 ] ])) {
    var %msg %msg 5UNLEASHES a dragon bolt special on $s1($replace($2,$chr(58),$chr(32)))
    unset %cbowspec [ $+ [ $1 ] ]
  } 
  else {
    var %msg %msg $doeswhat($3) $s1($replace($2,$chr(58),$chr(32)))
  }


  if ($splasher($3)) {
    if (%hitdmg == 0) {
      var %msg %msg using $attackname($3) and splashed
    }
    else {
      var %msg %msg using $attackname($3) hitting %hitshow
    }
  }
  else {
    var %msg %msg with their $attackname($3) hitting %hitshow
  }

  unset $+(%,frozen,$1)
  if ($freezer($3)) {
    var %freeze $r(1,$v1)
    if ((%freeze == 1) && (%hitdmg >= 1)) {
      set $+(%,frozen,$2) on
      notice $2 You have been frozen and can't use melee!
      var %msg %msg and successfully 12FROZE them
    }
    else {
      var %msg %msg but failed to freeze them
    }
  }

  if ($gettok($healer($3),1,32)) {
    var %heal $r(1,$v1)
    if (%heal == 1) {
      $iif($calc($floor(%hp1) + $floor($calc(%hit / $gettok($healer($3),2,32)))) > 99,set %hp1 99,inc %hp1 $floor($calc(%hit / $gettok($healer($3),2,32))))
      var %msg %msg and 09HEALING
    }
  }

  if ($poisoner($3)) {
    var %pois.chance $r(1,$v1)
    if (%pois.chance == 1) || ($db.get(equip_staff,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) {
      set $+(%,pois,$player($2,$4),$4) 6
    }
  }
  if ($($+(%,pois,$player($2,$4),$4),2) >= 1) && (%hp2 >= 1) {
    var %extra $iif(%hp2 < $($+(%,pois,$player($2,$4),$4),2),$v1,$v2)
    dec $+(%,pois,$player($2,$4),$4)
    dec %hp2 %extra
    var %msg %msg - 03 $+ %extra $+ 
  }

  if (%heal == 1) {
    var %msg %msg $+ . $s1($replace($2,$chr(58),$chr(32))) $hpbar(%hp2) - $hpbar(%hp1)
  }
  else {
    var %msg %msg $+ . $hpbar(%hp2)
  }

  msg $4 %msg 

  if ($max(m,$3)) { set %laststyle [ $+ [ $4 ] ] melee }
  elseif ($max(ma,$3)) { set %laststyle [ $+ [ $4 ] ] mage }
  elseif ($max(r,$3)) { set %laststyle [ $+ [ $4 ] ] range }

  if ($specused($3)) {
    dec $+(%,sp,$player($1,$4),$4) $calc($specused($3) /25)
    notice $1 Specbar: $iif($($+(%,sp,$player($1,$4),$4),2) < 1,0,$gettok(25 50 75 100,$($+(%,sp,$player($1,$4),$4),2),32)) $+ $chr(37)
  }

  if (%stake [ $+ [ $chan ] ] == $null) {
    var %sql SELECT * FROM `equip_staff` WHERE user = $db.safe($2)
    var %result = $db.query(%sql)
    if ($db.query_row(%result,equipstaff) === $null) { echo -s Error fetching equipment - damage $1- }
    db.query_end %result

    if ($db.get(equip_staff,belong,$1)) && ($r(1,100) < 3) && (%hp2 >= 1) {
      var %extra $iif(%hp2 < 12,$($v1,2),12)
      dec %hp2 %extra
      msg $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra) extra damage. $hpbar(%hp2)
    }
    if ($hget(equipstaff,allegra)) && ($r(1,100) < 3) && (%hp2 >= 1) {
      var %extraup $iif(%hp2 >= 84,$calc(99- %hp2),15)
      inc %hp2 %extraup
      msg $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%extraup) HP. $hpbar(%hp2)
    }
    elseif ($hget(equipstaff,kh)) && ($r(1,100) < 3) && (%hp2 >= 1) {
      inc %hp2 $calc($replace(%hit,$chr(32),$chr(43)))
      msg $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the damage. $hpbar(%hp2)
      set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
    }
    elseif ($hget(equipstaff,support)) && ($r(1,100) < 3) && (%hp2 >= 1) {
      var %temp.hit $calc($replace(%hit,$chr(32),$chr(43)))
      inc %hp2 $floor($calc(%temp.hit / 2))
      msg $4 $logo(DM) $s1($2) uses THE SUPPORTER to help defend against $s1($1) $+ 's attacks. $hpbar(%hp2)
    }
  }

  if (%hp2 < 1) {
    if ($hget(equipstaff,beau)) && ($r(1,100) < 6) && (%stake [ $+ [ $chan ] ] == $null) {
      set %hp2 1
      msg $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. $hpbar(%hp2)
    }
    else {
      dead $4 $2 $1
      halt
    }
  }

  set $+(%,hp,$player($1,$4),$4) %hp1
  set $+(%,hp,$player($2,$4),$4) %hp2
  set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
}

alias player {
  if ($1 == %p1 [ $+ [ $2 ] ]) { return 1 }
  if ($1 == %p2 [ $+ [ $2 ] ]) { return 2 }
}

alias hpbar {
  if (-* iswm $1) { tokenize 32 0 }
  elseif ($1 > 99) { tokenize 32 99 }
  return HP $+($chr(91),$s2($1),$chr(93)) $+($str($+(09,$chr(44),09,.),$floor($calc( $1 /5))),$str($+(04,$chr(44),04,.),$floor($calc((99- $1 ) /5)))) $+ 
}

alias accuracy {
  ;1 is Attack
  ;2 is Chan
  if ($istok(melee mage range,%laststyle [ $+ [ $2 ] ],32)) {
    if ($max(m,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) return 0
      elseif (%laststyle [ $+ [ $2 ] ] == mage) return -1
      elseif (%laststyle [ $+ [ $2 ] ] == range) return 1
    }
    elseif ($max(ma,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) return 1
      elseif (%laststyle [ $+ [ $2 ] ] == mage) return 0
      elseif (%laststyle [ $+ [ $2 ] ] == range) return -1
    }
    elseif ($max(r,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) return -1
      elseif (%laststyle [ $+ [ $2 ] ] == mage) return 1
      elseif (%laststyle [ $+ [ $2 ] ] == range) return 0
    }
  }
  return 0
}

alias hit {
  ;1 is Weapon
  ;2 is Attacker
  ;3 is Attackee
  ;4 is Chan
  if ($accuracy($1,$4) == -1) { var %acc $r(1,$r(75,90)) }
  elseif ($accuracy($1,$4) == 1) { var %acc $r($r(10,25),100) }
  else { var %acc $r(1,100) }

  var %sql SELECT * FROM `equip_armour` WHERE user = $db.safe($2)
  var %result = $db.query(%sql)
  if ($db.query_row(%result,equiphit) === $null) { echo -s Error fetching equipment - hit %sql }
  db.query_end %result

  var %atk $calc($iif($hget(equiphit,firecape),5,0) + $iif($hget(equiphit,bgloves),3,0))
  var %def $iif($db.get(equip_armour,elshield),$calc($r(85,99) / 100),1)
  var %ratk $calc($iif($hget(equiphit,void),5,0) + $iif($hget(equiphit,accumulator),5,0))
  var %matk $calc($iif($hget(equiphit,void-mage),5,0) + $iif($hget(equiphit,mbook),5,0) + $iif($hget(equiphit,godcape),5,0))

  goto $1
  :whip
  return $hitdmg(m,whip,%acc,1,%atk,%def)
  :dds
  return $hitdmg(m,dds,%acc,2,%atk,%def)
  :ags
  return $hitdmg(m,ags,%acc,1,%atk,%def)
  :cbow
  if (%acc isnum 98-100) && ($hget(equiphit,void) || $hget(equiphit,accumulator)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(50,65) }
  return $hitdmg(r,cbow,%acc,1,%ratk,%def)
  :dbow
  return $hitdmg(r,dbow,%acc,2,%ratk,%def)
  :bgs
  return $hitdmg(m,bgs,%acc,1,%atk,%def)
  :sgs
  return $hitdmg(m,sgs,%acc,1,%atk,%def)
  :gmaul
  return $hitdmg(m,gmaul,%acc,3,%atk,%def)
  :guth
  return $hitdmg(m,guth,%acc,1,%atk,%def)
  :ice
  return $hitdmg(ma,ice,%acc,1,%matk,%def)
  :zgs
  return $hitdmg(m,zgs,%acc,1,%atk,%def)
  :blood
  return $hitdmg(ma,blood,%acc,1,%matk,%def)
  :smoke
  return $hitdmg(ma,smoke,%acc,1,%matk,%def)
  :surf
  return $hitdmg(m,surf,%acc,1,0,1)
  :dclaws
  var %dclaws $hitdmg(m,dclaws,%acc,1,%atk,%def)
  return %dclaws $ceil($calc(%dclaws * 0.5)) $ceil($calc(%dclaws * 0.25)) $ceil($calc(%dclaws * 0.125))
  :dmace
  return $hitdmg(m,dmace,%acc,1,%atk,%def)
  :dscim
  return $hitdmg(m,dscim,%acc,1,%atk,%def)
  :dlong
  return $hitdmg(m,dlong,%acc,1,%atk,%def)
  :dhally
  return $hitdmg(m,dhally,%acc,2,%atk,%def)
  :d_h9
  return $hitdmg(m,dh9,%acc,1,%atk,%def)
  :d_h10
  return $hitdmg(m,dh,%acc,1,%atk,%def)
  :vlong
  return $hitdmg(m,vlong,%acc,1,%atk,1)
  :statius
  return $hitdmg(m,statius,%acc,1,%atk,1)
  :vspear
  return $hitdmg(m,vspear,%acc,1,%atk,%def)
  :mjavelin
  return $hitdmg(r,mjavelin,%acc,1,%ratk,%def)
  :onyx
  return $hitdmg(r,onyx,%acc,1,%ratk,%def)
}

alias hitdmg {
  ; $1 = r/ma/m
  ; $2 = attack
  ; $3 = accuracy
  ; $4 = number of hits
  ; $5 = attack bonus
  ; $6 = defense bonus
  if ($6) {
    var %acclimit $dmg($1,$2)
    if ($3 <= $gettok(%acclimit,1,32)) {
      var %ndmg $dmg($1,$2,1)
    }
    elseif ($3 <= $gettok(%acclimit,2,32)) {
      var %ndmg $dmg($1,$2,2)
    }
    else {
      var %ndmg $dmg($1,$2,3)
    }
    var %i = 0
    while (%i < $4) {
      inc %i
      var %dmg = $rand($gettok(%ndmg,1,44),$calc($gettok(%ndmg,2,44) + $5)))
      var %dmg = $ceil($calc(%dmg * $6))
      var %return = %return %dmg
    }
    return %return
  }
  return
}
