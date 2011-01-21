on $*:TEXT:/^[!@.](r|c)?(bl(ist)?) .*/Si:%staffchans: {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($db.get(admins,rank,$address($nick,3)) < 3) { if (?c* !iswm $1 || ($db.get(admins,rank,$address($nick,3)) >= 2)) { halt }  }
  if ((#* !iswm $2) || (!$2)) { notice $nick Syntax !(c|r)bl <channel> [reason] | halt }
  if ((?bl* iswm $1) && ($3)) { if ($chan($2).status) { part $2 This channel has been blacklisted } }
  if ($me == iDM) {
    if (!$2) { notice $nick Syntax !(c|r)bl <channel> | halt }
    if (?c* iswm $1) || (?r* iswm $1) {
      db.hget >checkban blist $2 who time reason
      if ($hget(>checkban,reason)) { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) Admin $s2($hget(>checkban,who)) banned $s2($2) at $s2($hget(>checkban,time)) for $s2($hget(>checkban,reason)) }
      else { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) Channel $s2($2) is $s2(not) banned. | halt }
      if (?r* iswm $1) {
        db.remove blist $2
        $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) Channel $2 has been removed from blist
      }
    }
    else {
      if (!$3) { notice $nick Syntax !bl <channel> <reason> | halt }
      db.set blist who $2 $nick
      db.set blist reason $2 $3-
      $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) Channel $2 has been added to blist
    }
  }
}

on $*:TEXT:/^[!@.](r|c)?suspend.*/Si:%staffchans: {
  if ($me != iDM) { return }
  if ($db.get(admins,rank,$address($nick,3)) < 3) { if (?c* !iswm $1 || ($db.get(admins,rank,$address($nick,3)) >= 2)) { halt }  }
  if (!$2) { notice $nick Syntax: !(un)suspend <nick> [reason]. | halt }
  if ((?c* iswm $1) || (?r* iswm $1)) {
    db.hget >checkban ilist $2 who time reason
    if ($hget(>checkban,reason)) { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) Admin $s2($hget(>checkban,who)) suspended $s2($2) at $s2($hget(>checkban,time)) for $s2($hget(>checkban,reason)) }
    elseif ($db.get(user,banned,$2)) { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) User $s2($2) is suspended but with no infomation. | halt }
    else { $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(BANNED) User $s2($2) is $s2(not) suspended. | halt }

    if (?r* iswm $1) {
      db.exec UPDATE `user` SET banned = '0' WHERE user = $db.safe($2)
      if ($mysql_affected_rows(%db) !== -1) {
        db.remove ilist $2
        $iif($left($1,1) == @,msgsafe $chan,notice $nick) Restored account $2 to its original status.
      }
      else { $iif($left($1,1) == @,msgsafe $chan,notice $nick) Couldn't find account $2 }
    }
  }
  else {
    if (!$3) { notice $nick You need to supply a reason when suspending.  Syntax: !(r)suspend <nick> [reason]. | halt }
    db.exec UPDATE `user` SET banned = '1' WHERE user = $db.safe($2)
    if ($mysql_affected_rows(%db) !== -1) {
      db.set ilist who $2 $nick
      db.set ilist reason $2 $3-
      $iif($left($1,1) == @,msgsafe $chan,notice $nick) Removed account $2 from the top scores - $3- .
    }
    else { $iif($left($1,1) == @,msgsafe $chan,notice $nick) Couldn't find account $2 }
  }
}

on $*:TEXT:/^[!.]delete.*/Si:%staffchan: {
  if ($me != iDM) { return }
  if ($db.get(admins,rank,$address($nick,3)) == 4) {
    if (!$2) { notice $nick To use the delete command, type !delete nick | halt }
    if ($3 != $md5($2)) { notice $nick To confirm deletion type !delete $2 $md5($2) | halt }
    if ($deletenick($2,$nick)) { notice $nick Deleted account $2 }
    else { notice $nick Couldn't find account $2 }
  }
}

alias deletenick {
  if ($len($1) < 1) { return }
  if ($2) { var %target = notice $2 $logo(DELETE) }
  else { var %target = echo -s DELETE $1 - }
  db.exec DELETE FROM `user` WHERE user = $db.safe($1)
  if ($mysql_affected_rows(%db) === -1) { return 0 }
  var %target = %target Deleted Rows: $mysql_affected_rows(%db) user;
  db.exec DELETE FROM `equip_item` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_item;
  db.exec DELETE FROM `equip_pvp` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_pvp;
  db.exec DELETE FROM `equip_armour` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_armour;
  db.exec DELETE FROM `equip_staff` WHERE user = $db.safe($1)
  var %target = %target $mysql_affected_rows(%db) equip_staff.
  if ($isclanowner($1)) {
    deleteclan $getclanname($1)
    var %target = %target Also deleted one clan.
  }
  return 1
}

On $*:TEXT:/^[!@.]cookie .*/Si:#: {
  if ($db.get(admins,rank,$address($nick,3)) == 4 && $me == iDM && $2) {
    tokenize 32 $1- 1
    if ($3 isnum) {
      db.set equip_staff cookies $2 + $3
      var %cookies $db.get(equip_staff, cookies, $2)
      msgsafe $chan $+ , $+ $staffchan $logo(Cookies) User $2 now has %cookies cookie $+ $iif(%cookies != 1,s) ( $+ $nick $+ )
    }
  }
}

On $*:TEXT:/^[!@.]((de|in)crease|define).*/Si:%staffchans: {
  if ($db.get(admins,rank,$address($nick,3)) == 4 && $me == iDM) {
    if ($4 !isnum) { goto error }
    if (?increase iswm $1) { var %sign + }
    elseif (?decrease iswm $1) { var %sign - }
    elseif (?define iswm $1) { var %sign = }
    else { goto error }
    var %table = user
    if ($store($3) != 0) {
      var %table = $store($3,table)
      var %item = $3
    }
    elseif ($ispvp($3)) {
      var %table = equip_pvp
      var %item = $3
    }
    elseif ($3 == money) || ($3 == wins) || ($3 == losses) {
      var %item = $3
    }
    elseif ($3 == cookies) {
      var %table = equip_staff
      var %item = $3
    }
    elseif (($3 == snow) || ($3 == clue)) {
      var %table = equip_item
      var %item = $3
    }
    else { notice $nick Couldnt find item matching $3 $+ . Valid: money/wins/losses/snow/clue/vspear/statius/mjavelin/cookies + !store items. | halt }
    if (%sign == =) { db.set %table %item $2 $4 }
    else { db.set %table %item $2 %sign $4 }
    msgsafe $chan $logo(ACCOUNT) User $2 has been updated. %item = $db.get(%table, %item, $2)
    return
    :error
    notice $nick Syntax !define/increase/decrease <account> <item> <amount>
  }
}
