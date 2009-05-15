on *:TEXT:!*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($right($1,-1) == specpot) { 
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) {
      if (!$readini(Equipment.ini,specpot,$nick)) { notice $nick You don't have any specpots. | halt }
      if ($($+(%,sp,$player($nick,#),#),2) == 4) { notice $nick You already have a full special bar. | halt }
      set $+(%,sp,$player($nick,#),#) 4
      writeini -n equipment.ini specpot $nick $calc($readini(equipment.ini,specpot,$nick) -1)
      msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.
      set %turn [ $+ [ # ] ] $iif($player($nick,#) == 1,2,1)
      halt
    } 
  }
  if ($attack($right($1,-1))) {
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) {
      if ($calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2)) { 
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($readini(OnOff.ini,#,$right($1,-1))) { notice $nick $logo(ERROR) This command has been disabled for this channel. | halt }
      if (%frozen [ $+ [ $nick ] ] == on) && ($max(m,$right($1,-1))) { 
        notice $nick You're frozen and can't use melee.
        halt 
      }
      if ($ini(pvp.ini,$right($1,-1))) {
        if (!$readini(pvp.ini,$right($1,-1),$nick)) {
          notice $nick You don't have this weapon.
          halt
        }
      }
      if ($ini(equipment.ini,$replace($right($1,-1),surf,mudkip))) {
        if (!$readini(equipment.ini,$replace($right($1,-1),surf,mudkip),$nick)) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      damage $nick $iif($nick == %p1 [ $+ [ # ] ],%p2 [ $+ [ # ] ],$v2) $right($1,-1) #
    }
  }
}
alias damage {
  ;1 is person attacking
  ;2 is other person
  ;3 is weapon
  ;4 is chan
  if ($ini(pvp.ini,$3)) {
    if ($readini(PvP.ini,$3,$1) < 1) { remini -n PvP.ini $1 $3 }
    elseif ($readini(PvP.ini,$3,$1) >= 1) { writeini -n PvP.ini $3 $1 $calc($readini(PvP.ini,$3,$1) -1) }
  }
  if ($3 != dh) { 
    var %hit [ $+ [ $4 ] ] $hit($3,$1,$2) 
  }
  elseif ($3 == dh) {
    if ($($+(%,hp,$player($1,$4),$4),2) < 10) { var %hit [ $+ [ $4 ] ] $hit(d_h9,$1,$2) }
    else var %hit [ $+ [ $4 ] ] $hit(d_h10,$1,$2)
  }
  if (!$gettok(%hit [ $+ [ $4 ] ],2,32)) && ($($+(%,hp,$player($2,$4),$4),2) < %hit [ $+ [ $4 ] ]) {
    var %hit [ $+ [ $4 ] ] $($+(%,hp,$player($2,$4),$4),2)
    set $+(%,hp,$player($2,$4),$4) 0
  }
  else {
    dec $+(%,hp,$player($2,$4),$4) $calc($replace(%hit [ $+ [ $4 ] ],$chr(32),$chr(43)))
  }
  unset $+(%,frozen,$1)
  if ($freezer($3)) { 
    var %freeze [ $+ [ $4 ] ] $r(1,$v1) 
  }
  if (%freeze [ $+ [ $4 ] ] == 1) { 
    if (%hit [ $+ [ $4 ] ] >= 1) {
      set $+(%,frozen,$2) on 
      notice $2 You have been frozen and can't use melee!
    }
  }
  if ($gettok($healer($3),1,32)) {
    var %heal [ $+ [ $4 ] ] $r(1,$v1)
  }
  if (%heal [ $+ [ $4 ] ] == 1) {
    $iif($calc($floor($($+(%,hp,$player($1,$4),$4),2)) + $floor($calc($($+(%,hit,$4),2) / $gettok($healer($3),2,32)))) > 99,set $+(%,hp,$player($1,$4),$4) 99,inc $+(%,hp,$player($1,$4),$4) $floor($calc($($+(%,hit,$4),2) / $gettok($healer($3),2,32))))
  }
  if ($readini(sitems.ini,belong,$1)) && ($r(1,100) <= 3) { 
    var %sitem.belong [ $+ [ $4 ] ] on
  }
  if ($3 == dds) {
    if ($readini(sitems.ini,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) {
      set $+(%,pois,$player($2,$4),$4) 6
    }
    elseif (!$readini(sitems.ini,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) && ($r(1,100) <= 33) {
      set $+(%,pois,$player($2,$4),$4) 6
    }
  }
  if ($($+(%,pois,$player($2,$4),$4),2) >= 1) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < $($+(%,pois,$player($2,$4),$4),2),$($v1,2),$($+(%,pois,$player($2,$4),$4),2))
    dec $+(%,pois,$player($2,$4),$4)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
    ;msg $4 $logo(DM) $s1($2) is 03poisoned, and lost $s2(%extra [ $+ [ $4 ] ]) HP. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  goto displaymsg
  :displaymsg
  if ($3 == vlong) { 
    msg $4 $logo(DM) $s1($1) slashes their Vesta's longsword at $s1($2) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == vspear) {
    msg $4 $logo(DM) $s1($1) 12freezes $s1($2) using a Vesta's spear, and hits $s2(%hit [ $+ [ $chan ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == statius) {
    msg $4 $logo(DM) $s1($1) critically hits $s1($2) with a Statius's warhammer, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == mjavelin) {
    msg $4 $logo(DM) $s1($1) throws a Morrigan's javelin at $s1($2) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == sgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($2) and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($2) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == ags) {
    msg $4 $logo(DM) $s1($1) spins around and slashes at $s1($2) with an Armadyl godsword, speccing $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == zgs) {
    msg $4 $logo(DM) $s1($1) attempts to freeze $s1($2) $iif(%freeze [ $+ [ $4 ] ] == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == bgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($2) and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == guth) {
    msg $4 $logo(DM) $s1($1) $iif(%heal [ $+ [ $4 ] ] == 1,09HEALS on,fails to heal on) $s1($2) $iif(%heal [ $+ [ $4 ] ] == 1,and hits,but hits) $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($2) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == blood) {
    msg $4 $logo(DM) $s1($1) casts blood barrage on $s1($2) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $s1($2) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == ice) {
    msg $4 $logo(DM) $s1($1) casts ice barrage on $s1($2) $iif(%freeze [ $+ [ $4 ] ] == 1,(12FROZEN)) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,surrounding them in an ice cube $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == cbow) {
    msg $4 $logo(DM) $s1($1) $iif(%cbowspec [ $+ [ $1 ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1($2) with a rune c'bow, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
    unset %cbowspec [ $+ [ $1 ] ]
  }
  if ($3 == dbow) {
    msg $4 $logo(DM) $s1($1) fires two dragon arrows towards $s1($2) $+ , speccing  $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == whip) {
    msg $4 $logo(DM) $s1($1) slashes $s1($2) with their abyssal whip, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dds) {
    msg $4 $logo(DM) $s1($1) stabs $s1($2) with a dragon dagger, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dclaws) {
    msg $4 $logo(DM) $s1($1) scratches $s1($2) with their dragon claws, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],4,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == surf) {
    msg $4 $logo(DM) $s1($1) summons their mudkip, surfing at $s1($2) $+ , hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == gmaul) {
    msg $4 $logo(DM) $s1($1) whacks $s1($2) with their granite maul, speccing $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dh) {
    msg $4 $logo(DM) $s1($1) crushes $s1($2) with their great axe, and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dscim) {
    msg $4 $logo(DM) $s1($1) slices $s1($2) with their dragon scimitar, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dlong) {
    msg $4 $logo(DM) $s1($1) stabs $s1($2) with a dragon longsword, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dmace) {
    msg $4 $logo(DM) $s1($1) crushes $s1($2) with a dragon mace, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($3 == dhally) {
    msg $4 $logo(DM) $s1($1) slashes $s1($2) with their dragon halberd, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($specused($3)) { 
    dec $+(%,sp,$player($1,$4),$4) $calc($specused($3) /25) 
    notice $1 Specbar: $iif($($+(%,sp,$player($1,$4),$4),2) < 1,0,$gettok(25 50 75 100,$($+(%,sp,$player($1,$4),$4),2),32)) $+ $chr(37)
  }
  if (%sitem.belong [ $+ [ $4 ] ] == on) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < 10,$($v1,2),10)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
    msg $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra [ $+ [ $4 ] ]) extra damage. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($readini(sitems.ini,kh,$2)) && ($r(1,100) <= 3) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    inc $+(%,hp,$player($2,$4),$4) $calc($replace(%hit [ $+ [ $4 ] ],$chr(32),$chr(43)))
    msg $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the attack. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
    set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
  }
  if ($readini(sitems.ini,allegra,$2)) && ($r(1,100) <= 3) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %allegra.heal [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) >= 89,$calc(99- $($+(%,hp,$player($2,$4),$4),2)),10)
    inc $+(%,hp,$player($2,$4),$4) %allegra.heal [ $+ [ $4 ] ]
    msg $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%allegra.heal [ $+ [ $4 ] ]) HP. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
  }
  if ($($+(%,hp,$player($2,$4),$4),2) < 1) { 
    if ($readini(sitems.ini,beau,$2)) && ($r(1,100) <= 6) { 
      set $+(%,hp,$player($2,$4),$4) 1
      msg $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2))
      set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
      halt
    }
    dead $4 $2 $1
    halt 
  }
  set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
}
alias player {
  if ($1 == %p1 [ $+ [ $2 ] ]) { return 1 }
  if ($1 == %p2 [ $+ [ $2 ] ]) { return 2 }
}

alias hit {
  var %acc [ $+ [ $2 ] ] $r(1,100)
  var %atk [ $+ [ $2 ] ] $calc($iif($readini(Equipment.ini,Firecape,$2),5,0) + $iif($readini(Equipment.ini,bgloves,$2),3,0))
  var %def [ $+ [ $2 ] ] $iif($readini(Equipment.ini,elshield,$3),$calc($r(85,99) / 100),1)
  var %ratk [ $+ [ $2 ] ] $calc($iif($readini(Equipment.ini,void,$2),5,0) + $iif($readini(Equipment.ini,accumulator,$2),5,0))
  var %matk [ $+ [ $2 ] ] $calc($iif($readini(Equipment.ini,void-mage,$2),5,0) + $iif($readini(Equipment.ini,mbook,$2),5,0))
  goto $1
  :whip
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dds
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,20) $r(5,20)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :ags
  if (%acc [ $+ [ $2 ] ] isnum 1-2) return 0
  if (%acc [ $+ [ $2 ] ] isnum 3-20) return $r(1,20)
  if (%acc [ $+ [ $2 ] ] isnum 21-100) return $floor($calc($r(21,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :cbow
  if (%acc [ $+ [ $2 ] ] isnum 1-15) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 16-30) return $r(11,20)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) {
    if (%acc [ $+ [ $2 ] ] isnum 98-100) && ($readini(Equipment.ini,void,$2) || $readini(Equipment.ini,accumulator,$2)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(60,69) | halt }
    return $floor($calc($r(21,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  }
  :dbow
  if (%acc [ $+ [ $2 ] ] isnum 1-8) return 8 8
  if (%acc [ $+ [ $2 ] ] isnum 9-50) return $r(9,20) $r(9,20)
  if (%acc [ $+ [ $2 ] ] isnum 51-100) return $floor($calc($r(21,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(21,$calc($gettok($gettok($max(r,$1),1,32),1,45) + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :bgs
  if (%acc [ $+ [ $2 ] ] isnum 1-5) return 0
  if (%acc [ $+ [ $2 ] ] isnum 6-35) return $r(1,35)
  if (%acc [ $+ [ $2 ] ] isnum 36-100) return $floor($calc($r(36,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :sgs
  if (%acc [ $+ [ $2 ] ] isnum 1-7) return 0
  if (%acc [ $+ [ $2 ] ] isnum 8-23) return $r(1,15)
  if (%acc [ $+ [ $2 ] ] isnum 24-100) return $floor($calc($r(16,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :gmaul
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return $r(0,8) $r(0,8) $r(0,8)
  if (%acc [ $+ [ $2 ] ] isnum 4-40) return $r(1,12) $r(1,12) $r(1,12)
  if (%acc [ $+ [ $2 ] ] isnum 41-100) return $floor($calc($r(13,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $ceil($calc($(,%atk [ $+ [ $2 ] ]) / 2)))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(13,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $ceil($calc($(,%atk [ $+ [ $2 ] ]) / 2)))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(13,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $ceil($calc($(,%atk [ $+ [ $2 ] ]) / 2)))) * $(,%def [ $+ [ $2 ] ])))
  :guth
  if (%acc [ $+ [ $2 ] ] isnum 1-5) return 0
  if (%acc [ $+ [ $2 ] ] isnum 6-13) return $r(1,20)
  if (%acc [ $+ [ $2 ] ] isnum 14-100) return $floor($calc($r(11,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :ice
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return 0
  if (%acc [ $+ [ $2 ] ] isnum 4-30) return $r(1,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $r(16,$calc($gettok($gettok($max(ma,$1),1,32),1,45) + $(,%matk [ $+ [ $2 ] ])))
  :zgs
  if (%acc [ $+ [ $2 ] ] isnum 1-5) return 0
  if (%acc [ $+ [ $2 ] ] isnum 6-30) return $r(1,22)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(23,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :blood
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return 0
  if (%acc [ $+ [ $2 ] ] isnum 4-30) return $r(1,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $r(16,$calc($gettok($gettok($max(ma,$1),1,32),1,45) + $(,%matk [ $+ [ $2 ] ])))
  :surf
  if (%acc [ $+ [ $2 ] ] isnum 1-20) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 21-30) return $r(11,15)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $r(16,$gettok($gettok($max(m,$1),1,32),1,45))
  :dclaws
  var %dclaws $r(18,24) $floor($calc($r(20,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  var %dclaws2 $ceil($calc($gettok(%dclaws,1,32) / 2)) $ceil($calc($gettok(%dclaws,2,32) / 2))
  var %dclaws3 $ceil($calc($gettok(%dclaws2,1,32) / 2)) $ceil($calc($gettok(%dclaws2,2,32) / 2))
  var %dclaws4 $ceil($calc($gettok(%dclaws3,1,32) / 2)) $ceil($calc($gettok(%dclaws3,2,32) / 2))
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return 0 0 0 0
  if (%acc [ $+ [ $2 ] ] isnum 4-55) return $gettok(%dclaws,1,32) $gettok(%dclaws2,1,32) $gettok(%dclaws3,1,32) $gettok(%dclaws4,1,32)
  if (%acc [ $+ [ $2 ] ] isnum 56-100) return $gettok(%dclaws,2,32) $gettok(%dclaws2,2,32) $gettok(%dclaws3,2,32) $gettok(%dclaws4,2,32)
  :dmace
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-60) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 61-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dscim
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dlong
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :dhally
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return 0 0
  if (%acc [ $+ [ $2 ] ] isnum 5-30) return $r(5,25) $r(5,25)
  if (%acc [ $+ [ $2 ] ] isnum 31-100) return $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ]))) $floor($calc($r(26,$calc($gettok($gettok($max(m,$1),1,32),1,45) + %atk [ $+ [ $2 ] ])) * $(,%def [ $+ [ $2 ] ])))
  :d_h9
  return $floor($calc($r(0,$calc(75 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :d_h10
  return $floor($calc($r(0,$calc(40 + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :vlong
  if (%acc [ $+ [ $2 ] ] isnum 1-2) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 3-25) return $r(10,35)
  if (%acc [ $+ [ $2 ] ] isnum 26-100) return $floor($calc($r(30,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ])))))
  :statius
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return $r(0,15)
  if (%acc [ $+ [ $2 ] ] isnum 5-25) return $r(15,35)
  if (%acc [ $+ [ $2 ] ] isnum 26-100) return $floor($calc($r(30,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :vspear
  if (%acc [ $+ [ $2 ] ] isnum 1-3) return $r(0,10)
  if (%acc [ $+ [ $2 ] ] isnum 4-20) return $r(11,35)
  if (%acc [ $+ [ $2 ] ] isnum 21-100) return $floor($calc($r(35,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%atk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
  :mjavelin
  if (%acc [ $+ [ $2 ] ] isnum 1-4) return $r(0,7)
  if (%acc [ $+ [ $2 ] ] isnum 5-38) return $r(8,25)
  if (%acc [ $+ [ $2 ] ] isnum 39-100) return $floor($calc($r(25,$calc($gettok($gettok($max(m,$1),1,32),1,45) + $(,%ratk [ $+ [ $2 ] ]))) * $(,%def [ $+ [ $2 ] ])))
}
