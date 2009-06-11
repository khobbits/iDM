on $*:TEXT:/^[!.]/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($right($1,-1) == specpot) {
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) || (($.readini(gwd.ini,#,$nick)) && (%turn [ $+ [ $chan ] ] == 1)) {
      if (!$.readini(login.ini,login,$nick)) {
        notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),ident,reg) pass) $+ ) (Don't use your RuneScape password)
        halt
      }
      if (!$.readini(Equipment.ini,specpot,$nick)) { notice $nick You don't have any specpots. | halt }
      if ($($+(%,sp,$player($nick,#),#),2) == 4) { notice $nick You already have a full special bar. | halt }
      set $+(%,sp,$player($nick,#),#) 4
      updateini equipment.ini specpot $nick -1
      msg # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.
      unset %laststyle [ $+ [ # ] ]
      set %turn [ $+ [ # ] ] $iif($player($nick,#) == 1,2,1)
      halt
    }
  }
  if ($attack($right($1,-1))) {
    if ($nick == %p1 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 1) || ($nick == %p2 [ $+ [ $chan ] ] && %turn [ $+ [ $chan ] ] == 2) || (($.readini(gwd.ini,#,$nick)) && (%turn [ $+ [ $chan ] ] == 1)) {
      if ($calc($specused($right($1,-1)) /25) > $($+(%,sp,$player($nick,#),#),2)) {
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($.readini(OnOff.ini,#,$right($1,-1))) {
        notice $nick $logo(ERROR) This command has been disabled for this channel.
        halt
      }
      if (%frozen [ $+ [ $nick ] ] == on) && ($max(m,$right($1,-1))) {
        notice $nick You're frozen and can't use melee.
        halt
      }
      if ($.ini(pvp.ini,$right($1,-1))) {
        if (!$.readini(pvp.ini,$right($1,-1),$nick)) {
          notice $nick You don't have this weapon.
          halt
        }
        if (!$.readini(login.ini,login,$nick)) {
          notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password)
          halt
        }
      }
      if ($.ini(equipment.ini,$replace($right($1,-1),surf,mudkip))) {
        if (!$.readini(equipment.ini,$replace($right($1,-1),surf,mudkip),$nick)) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      set -u25 %enddm [ $+ [ $chan ] ] 0
      if ($.readini(gwd.ini,#,$nick)) && (%turn [ $+ [ $chan ] ] == 1) {
        damage $nick %gwd [ $+ [ $chan ] ] $right($1,-1) #
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
  if ($4 == #iDM.Staff) { echo -a #iDM.Staff - %hp2 [ $+ [ #idm.staff ] ] - $1- }
  if ($.ini(pvp.ini,$3)) {
    if ($.readini(PvP.ini,$3,$1) < 1) { remini -n PvP.ini $1 $3 }
    elseif ($v1 >= 1) { updateini PvP.ini $3 $1 -1 }
  }
  if ($3 != dh) {
    var %hit [ $+ [ $4 ] ] $hit($3,$1,$2,$4)
  }
  elseif ($3 == dh) {
    if ($($+(%,hp,$player($1,$4),$4),2) < 10) { var %hit [ $+ [ $4 ] ] $hit(d_h9,$1,$2,$4) }
    else var %hit [ $+ [ $4 ] ] $hit(d_h10,$1,$2,$4)
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
  if ($.readini(sitems.ini,belong,$1)) && ($r(1,100) <= 3) {
    var %sitem.belong [ $+ [ $4 ] ] on
  }
  if ($poisoner($3)) {
    var %pois.chance [ $+ [ $4 ] ] $r(1,$v1)
    if (%pois.chance [ $+ [ $4 ] ] == 1) || ($.readini(sitems.ini,snake,$1)) && (!$($+(%,pois,$player($2,$4),$4),2)) {
      if (%hit [ $+ [ $4 ] ] >= 1) {
        set $+(%,pois,$player($2,$4),$4) 6
      }
    }
  }
  if ($($+(%,pois,$player($2,$4),$4),2) >= 1) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < $($+(%,pois,$player($2,$4),$4),2),$($v1,2),$($+(%,pois,$player($2,$4),$4),2))
    dec $+(%,pois,$player($2,$4),$4)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
  }
  if ($max(m,$3)) {
    set %laststyle [ $+ [ $4 ] ] melee
  }
  elseif ($max(ma,$3)) {
    set %laststyle [ $+ [ $4 ] ] mage
  }
  elseif ($max(r,$3)) {
    set %laststyle [ $+ [ $4 ] ] range
  }
  ;;tokenize 32 $replace($1,Sara,Commander:Zilyana,Arma,Kree'arra,Bandos,General:Graardor,Zammy,K'ril:Tsutsaroth) $2-
  goto displaymsg
  :displaymsg
  if ($3 == vlong) {
    msg $4 $logo(DM) $s1($1) slashes their Vesta's longsword at $s1($replace($2,$chr(58),$chr(32))) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == vspear) {
    msg $4 $logo(DM) $s1($1) 12freezes $s1($replace($2,$chr(58),$chr(32))) using a Vesta's spear, and hits $s2(%hit [ $+ [ $chan ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == statius) {
    msg $4 $logo(DM) $s1($1) critically injures $s1($replace($2,$chr(58),$chr(32))) with a Statius's warhammer, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == mjavelin) {
    msg $4 $logo(DM) $s1($1) throws a Morrigan's javelin at $s1($replace($2,$chr(58),$chr(32))) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == sgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($replace($2,$chr(58),$chr(32))) and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == ags) {
    msg $4 $logo(DM) $s1($1) spins around and slashes at $s1($replace($2,$chr(58),$chr(32))) with an Armadyl godsword, speccing $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == zgs) {
    msg $4 $logo(DM) $s1($1) attempts to freeze $s1($replace($2,$chr(58),$chr(32))) $iif(%freeze [ $+ [ $4 ] ] == 1,and successfully 12FROZE them,but failed to) $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == bgs) {
    msg $4 $logo(DM) $s1($1) crushes their godsword down on $s1($replace($2,$chr(58),$chr(32))) and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == guth) {
    msg $4 $logo(DM) $s1($1) $iif(%heal [ $+ [ $4 ] ] == 1,09HEALS on,fails to heal on) $s1($replace($2,$chr(58),$chr(32))) $iif(%heal [ $+ [ $4 ] ] == 1,and hits,but hits) $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == blood) {
    msg $4 $logo(DM) $s1($1) casts 05blood barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == ice) {
    msg $4 $logo(DM) $s1($1) casts 12ice barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%freeze [ $+ [ $4 ] ] == 1,(12FROZEN)) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,surrounding them in an ice cube $+ $chr(44) hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == smoke) {
    msg $4 $logo(DM) $s1($1) casts 14smoke barrage on $s1($replace($2,$chr(58),$chr(32))) $iif(%hit [ $+ [ $4 ] ] == 0, and splashed $+ $iif(%extra [ $+ [ $4 ] ],$chr(32) 03 $+ $v1 $+) $+ .,hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ .) HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == cbow) {
    msg $4 $logo(DM) $s1($1) $iif(%cbowspec [ $+ [ $1 ] ],5UNLEASHES a dragon bolt special on,shoots a dragon bolt at) $s1($replace($2,$chr(58),$chr(32))) with a rune c'bow, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
    unset %cbowspec [ $+ [ $1 ] ]
  }
  if ($3 == dbow) {
    msg $4 $logo(DM) $s1($1) fires two dragon arrows towards $s1($replace($2,$chr(58),$chr(32))) $+ , speccing  $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == whip) {
    msg $4 $logo(DM) $s1($1) slashes $s1($replace($2,$chr(58),$chr(32))) with their abyssal whip, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dds) {
    msg $4 $logo(DM) $s1($1) stabs $s1($replace($2,$chr(58),$chr(32))) with a dragon dagger, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dclaws) {
    msg $4 $logo(DM) $s1($1) scratches $s1($replace($2,$chr(58),$chr(32))) with their dragon claws, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],4,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == surf) {
    msg $4 $logo(DM) $s1($1) summons their mudkip, surfing at $s1($replace($2,$chr(58),$chr(32))) $+ , hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == gmaul) {
    msg $4 $logo(DM) $s1($1) whacks $s1($replace($2,$chr(58),$chr(32))) with their granite maul, speccing $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],3,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dh) {
    msg $4 $logo(DM) $s1($1) crushes $s1($replace($2,$chr(58),$chr(32))) with their great axe, and hit $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dscim) {
    msg $4 $logo(DM) $s1($1) slices $s1($replace($2,$chr(58),$chr(32))) with their dragon scimitar, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dlong) {
    msg $4 $logo(DM) $s1($1) stabs $s1($replace($2,$chr(58),$chr(32))) with a dragon longsword, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dmace) {
    msg $4 $logo(DM) $s1($1) crushes $s1($replace($2,$chr(58),$chr(32))) with a dragon mace, hitting $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == dhally) {
    msg $4 $logo(DM) $s1($1) slashes $s1($replace($2,$chr(58),$chr(32))) with their dragon halberd, hitting $s2($gettok(%hit [ $+ [ $4 ] ],1,32)) - $s2($gettok(%hit [ $+ [ $4 ] ],2,32)) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($3 == onyx) {
    msg $4 $logo(DM) $s1($1) shoots $s1($replace($2,$chr(58),$chr(32))) with an onyx bolt, $iif(%heal [ $+ [ $4 ] ] == 1,09HEALING,hitting) a $s2(%hit [ $+ [ $4 ] ]) $+ $iif(%extra [ $+ [ $4 ] ], $chr(32) - 03 $+ $v1 $+  $+) $+ . HP $s1($replace($2,$chr(58),$chr(32))) $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp)) $iif(%heal [ $+ [ $4 ] ] == 1,- HP $s1($1) $+($chr(91),$s2($iif($($+(%,hp,$player($1,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($1,$4),$4),2)))
  }
  if ($3 == gwd) {
    msg $4 $logo(GWD) $s1($replace($1,$chr(58),$chr(32))) brutally attacks $s1($2) $+ , hitting $s2(%hit [ $+ [ $4 ] ]) $+ . HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),hp)
  }
  if ($specused($3)) {
    dec $+(%,sp,$player($1,$4),$4) $calc($specused($3) /25)
    notice $1 Specbar: $iif($($+(%,sp,$player($1,$4),$4),2) < 1,0,$gettok(25 50 75 100,$($+(%,sp,$player($1,$4),$4),2),32)) $+ $chr(37)
  }
  if (%sitem.belong [ $+ [ $4 ] ] == on) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %extra [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) < 10,$($v1,2),10)
    dec $+(%,hp,$player($2,$4),$4) %extra [ $+ [ $4 ] ]
    msg $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra [ $+ [ $4 ] ]) extra damage. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($.readini(sitems.ini,kh,$2)) && ($r(1,100) <= 3) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    inc $+(%,hp,$player($2,$4),$4) $calc($replace(%hit [ $+ [ $4 ] ],$chr(32),$chr(43)))
    msg $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the attack. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
    set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
  }
  if ($.readini(sitems.ini,allegra,$2)) && ($r(1,100) <= 3) && ($($+(%,hp,$player($2,$4),$4),2) >= 1) {
    var %allegra.heal [ $+ [ $4 ] ] $iif($($+(%,hp,$player($2,$4),$4),2) >= 89,$calc(99- $($+(%,hp,$player($2,$4),$4),2)),10)
    inc $+(%,hp,$player($2,$4),$4) %allegra.heal [ $+ [ $4 ] ]
    msg $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%allegra.heal [ $+ [ $4 ] ]) HP. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
  }
  if ($($+(%,hp,$player($2,$4),$4),2) < 1) {
    if ($.readini(sitems.ini,beau,$2)) && ($r(1,100) <= 6) {
      set $+(%,hp,$player($2,$4),$4) 1
      msg $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. HP $+($chr(91),$s2($iif($($+(%,hp,$player($2,$4),$4),2) < 1,0,$v1)),$chr(93)) $hpbar($($+(%,hp,$player($2,$4),$4),2),$iif($($+(%,gwd,$4),2),gwd,hp))
      set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
      halt
    }
    if ($istok($bosses,$2,32)) {
      gwdloot $4 $1 $2
      halt
    }
    if ($.readini(gwd.ini,$4,$2)) {
      gwdko $4 $2
      halt
    }
    dead $4 $2 $1
    halt
  }
  set %turn [ $+ [ $4 ] ] $iif($player($1,$4) == 1,2,1)
}
alias gwdloot {
  updateini wins.ini $2 +1
  var %loot A Godsword..
  msg $1 $logo(GWD) $s1($2) has defeated $s1($replace($3,$chr(58),$chr(32))) and recieved $+(03[,07 $+ %loot,,$chr(44),07Big bones,,03]) $+ .
  cancel $1
}
alias bosses {
  return Commander:Zilyana Kree'arra General:Graardor K'ril:Tsutsaroth
}
alias gwdko {
  remini gwd.ini $1 $2
  msg $1 $logo(GWD) $s1($2) has died.
  cancel $1
}
alias player {
  if ($1 == %p1 [ $+ [ $2 ] ]) { return 1 }
  if ($1 == %p2 [ $+ [ $2 ] ]) { return 2 }
}

alias accuracy {
  ;1 is Attack
  ;2 is Chan
  if ($istok(melee mage range,%laststyle [ $+ [ $2 ] ],32)) {
    if ($max(m,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) {
        return 0
      }
      elseif (%laststyle [ $+ [ $2 ] ] == mage) {
        return -1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == range) {
        return 1
      }
    }
    elseif ($max(ma,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) {
        return 1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == mage) {
        return 0
      }
      elseif (%laststyle [ $+ [ $2 ] ] == range) {
        return -1
      }
    }
    elseif ($max(r,$1)) {
      if (%laststyle [ $+ [ $2 ] ] == melee) {
        return -1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == mage) {
        return 1
      }
      elseif (%laststyle [ $+ [ $2 ] ] == range) {
        return 0
      }
    }
  }
  return 0
}

alias hit {
  ;1 is Weapon
  ;2 is Attacker
  ;3 is Attackee
  ;4 is Chan
  if ($accuracy($1,$4) == 0) {
    var %acc $r(1,100)
  }
  elseif ($accuracy($1,$4) == -1) {
    var %acc $r(1,$r(75,90))
  }
  elseif ($accuracy($1,$4) == 1) {
    var %acc $r($r(10,25),100)
  }
  var %atk $calc($iif($.readini(Equipment.ini,Firecape,$2),5,0) + $iif($.readini(Equipment.ini,bgloves,$2),3,0))
  var %def $iif($.readini(Equipment.ini,elshield,$3),$calc($r(85,99) / 100),1)
  var %ratk $calc($iif($.readini(Equipment.ini,void,$2),5,0) + $iif($.readini(Equipment.ini,accumulator,$2),5,0))
  var %matk $calc($iif($.readini(Equipment.ini,void-mage,$2),5,0) + $iif($.readini(Equipment.ini,mbook,$2),5,0))

  goto $1
  :whip
  return $hitdmg(m,whip,%acc,1,%atk,%def)
  :dds
  return $hitdmg(m,dds,%acc,2,%atk,%def)
  :ags
  return $hitdmg(m,ags,%acc,1,%atk,%def)
  :cbow
  if (%acc isnum 31-100) {
    if (%acc isnum 98-100) && ($.readini(Equipment.ini,void,$2) || $.readini(Equipment.ini,accumulator,$2)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(60,69) }
  }
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
  return $hitdmg(ma,ice,%acc,1,%matk,1)
  :zgs
  return $hitdmg(m,zgs,%acc,1,%atk,%def)
  :blood
  return $hitdmg(ma,blood,%acc,1,%matk,1)
  :smoke
  return $hitdmg(ma,smoke,%acc,1,%matk,1)
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
  :gwd
  return $r(0,50)
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
