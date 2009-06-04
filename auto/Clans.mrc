on $*:TEXT:/^[!@.]delmem/Si:*: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }
  if (!$.readini(Personalclan.ini,Person,$nick)) { notice $nick You need to make a clan before you can kick any members. !startclan name of clan. | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !delmem member. | halt }
  if ($2 == $nick) { notice $nick $logo(ERROR) You can't kick yourself silly! Type: !leave to part your clan / cancel it. | halt }
  if (!$.readini(money.ini,money,$2)) { notice $nick $logo(ERROR) $remove($2,$chr(36),$chr(37)) doesn't seem to have ever used iDM. | halt }
  if ($gettok($.readini(Personalclan.ini,Person,$nick),2,58) != owner) { notice $nick You have to be the clan owner to do this. | halt }
  if ($.readini(clans.ini,clan,$nick) != $.readini(clans.ini,clan,$2)) { notice $nick $logo(ERROR) $s1($2) isn't in your clan. | halt }
  if ($gettok($.readini(Personalclan.ini,Person,$nick),2,58) == owner) { 
    notice $nick $logo(CLANS) $s1($2) has been kicked from your clan. 
    $iif($address($2,2),notice $2,ms send $2) You have been kicked from your iDM clan by $nick $+ .
    remini -n Personalclan.ini Person $2
    remini -n Clans.ini Clan $2
    remini -n Clannames.ini $gettok($.readini(Personalclan.ini,Person,$nick),1,58) $2
  }
}
on $*:TEXT:/^[!@.]addmem/Si:*: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }
  if (!$.readini(Personalclan.ini,Person,$nick)) { notice $nick You need to make a clan before you can start adding members. !startclan name of clan. | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !addclan new member. | halt }
  if (!$.readini(money.ini,money,$2)) { notice $nick $logo(ERROR) $remove($2,$chr(36),$chr(37)) doesn't seem to have ever used iDM. | halt }
  if ($.readini(Personalclan.ini,Person,$remove($2,$chr(36),$chr(37)))) { notice $nick $logo(ERROR) $remove($2,$chr(36),$chr(37)) is already part of a clan ( $+ $gettok($.readini(Personalclan.ini,Person,$remove($2,$chr(36),$chr(37))),1,58) $+ ). | halt }
  if ($gettok($.readini(Personalclan.ini,Person,$nick),2,58) != owner) { notice $nick You have to be the clan owner to do this. | halt }
  set %invite [ $+ [ $2 ] ] $gettok($.readini(Personalclan.ini,Person,$nick),1,58)
  notice $nick $logo(CLAN) $2 has been sent a request to join $s2($gettok($.readini(Personalclan.ini,Person,$nick),1,58)) $+ .
  $iif($address($2,2),notice $2,ms send $2) You've been asked to join $s1($gettok($.readini(Personalclan.ini,Person,$remove($nick,$chr(36),$chr(37))),1,58)) $+ $chr(44) requested by $nick $+ . Type !joinclan $gettok($.readini(Personalclan.ini,Person,$remove($nick,$chr(36),$chr(37))),1,58) to accept. 
}
on $*:TEXT:/^[!@.]joinclan/Si:*: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ )  (Don't use your RuneScape password) | halt }
  if ($.readini(Personalclan.ini,Person,$nick)) { notice $nick You're already in a clan ( $+ $gettok($.readini(Personalclan.ini,Person,$nick),1,58) $+ ). | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !joinclan clan to join. | halt }
  if (%invite [ $+ [ $nick ] ] != $2) { notice $nick $logo(ERROR) You don't have an invite to join this clan. | halt }
  writeini Personalclan.ini Person $nick $2
  writeini Clans.ini Clan $nick $2
  writeini Clannames.ini $2 $nick on
  notice $nick $logo(CLAN) You've joined $s2($2) $+ .
  unset %invite [ $+ [ $nick ] ]
}
on $*:TEXT:/^[!@.]startclan/Si:*: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ )  (Don't use your RuneScape password) | halt }
  if (!$2) { notice $nick $logo(ERROR) Type !startclan clan name. | halt }
  if ($.ini(Clannames.ini,$remove($2,$chr(36),$chr(37)))) { notice $nick $logo(ERROR) Clan name $qt($remove($2,$chr(36),$chr(37))) already taken. | halt }
  if ($.readini(Personalclan.ini,Person,$nick)) { notice $nick You're already in a clan ( $+ $gettok($.readini(Personalclan.ini,Person,$nick),1,58) $+ ). | halt }
  writeini Personalclan.ini Person $nick $remove($2,$chr(36),$chr(37)) $+ :owner
  writeini Clans.ini Clan $nick $remove($2,$chr(36),$chr(37))
  writeini Clannames.ini $remove($2,$chr(36),$chr(37)) $nick on
  notice $nick $logo(CLAN) Your clan $qt($remove($2,$chr(36),$chr(37))) has been created. To add users to it, type !addclan new member.
}
on $*:TEXT:/^[!@.]leave/Si:*: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }
  if (!$.readini(Personalclan.ini,Person,$nick)) { notice $nick You're not in a clan. !startclan name of clan. | halt }
  if ($gettok($.readini(Personalclan.ini,Person,$nick),2,58) == owner) { notice $nick $logo(CLAN) Your clan has been deleted. | deleteclan $gettok($.readini(Personalclan.ini,Person,$nick),1,58) | halt }
  notice $nick $logo(CLAN) You've left your clan $s2($gettok($.readini(Personalclan.ini,Person,$nick),1,58)) $+ .
  remini -n Personalclan.ini Person $nick
  remini -n Clans.ini Clan $nick
  remini -n Clannames.ini $gettok($.readini(Personalclan.ini,Person,$nick),1,58) $nick
}
on $*:TEXT:/^[!@.]share/Si:*: { 
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) | halt }
  if (!$.readini(Personalclan.ini,Person,$nick)) { notice $nick You're not in a clan. !startclan name of clan. | halt }
  if ($gettok($.readini(Personalclan.ini,Person,$nick),2,58) != owner) { notice $nick You're not the owner of $s2($gettok($.readini(Personalclan.ini,Person,$nick),1,58)) $+ . | halt }
  if ($2 == on) { notice $nick $logo(CLAN) The drop share option for your clan is now on.
    writeini Clannames.ini $gettok($.readini(Personalclan.ini,Person,$nick),1,58)) Share on
  }
  if ($2 == off) { notice $nick $logo(CLAN) The drop share option for your clan has been disabled.
    remini -n Clannames.ini $gettok($.readini(Personalclan.ini,Person,$nick),1,58)) Share
  }
}
alias deleteclan {
  remini Clannames.ini $1
  if ($1) {
    var %sql = DELETE FROM 'clans' WHERE c3 = $db.safe($1)
    db.exec %sql
    var %sql = DELETE FROM 'personalclan' WHERE c3 = $db.safe($1) OR c3 = $db.safe($1 $+ :owner)
    db.exec %sql
  }
}

on $*:TEXT:/^[!@.]dmclan/Si:#: { 
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (!$2) { var %nick = $nick }
  else { var %nick = $2 }
  var %clan = $.readini(Clans.ini,Clan,%nick)
  if (%clan) {
    $iif($left($1,1) == @,msg #,notice $nick) $claninfo(%clan) $clanstats(%clan) (Total clans $s1($.ini(clannames.ini,0)) $+ )
    halt
  }
  notice $nick $logo(ERROR) %nick is not in a clan. | halt
}

alias claninfo {
  var $ci,%tc = 0
  var %sql = SELECT * FROM 'clans' WHERE c1 = 'clan' AND c3 = $db.safe($1)
  var %result = $db.query(%sql)
  while ($db.query_row_data(%result,c2)) {
    var %ci = %ci $v1
    inc %tc
  }
  db.query_end %result
  return $logo(CLAN) There $iif(%tc > 1,are,is) $s1(%tc) member $+ $iif(%tc > 1,s) of the clan $s2($1) $+ . $iif(%tc < 10,Members: %ci) (Lootshare: $iif($.readini(clannames.ini,$1,share) == on,$s1(on),$s2(off)) $+ )
}
alias clanstats {
  return $s1(Wins) $+ : $iif($.readini(clantracker.ini,wins,$1),$s2($v1),$s2(0)) $s1(Losses) $+ : $iif($.readini(clantracker.ini,losses,$1),$s2($v1),$s2(0)) $s1(Money) $+ : $iif($.readini(clantracker.ini,money,$1),$s2($price($v1)),$s2($price(0)))
}
alias clanrank {
  HALT
  ;I never understood how to script ranks..
}
