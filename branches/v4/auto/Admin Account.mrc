ON $*:TEXT:/^[!@.](r|c)?(bl(ist)?) .*/Si:%staffchans: {
  var %admrank $db.get(admins,rank,address,$address($nick,3)) < 2
  if (%admrank >= 2 && $me == iDM) { 
    if ($regex($2,/^#[a-zA-Z0-9_\-\.]*$/) && $0 >= 2) {
      if (?c* iswm $1) {
        db.hash >checkban blist $2 user who time reason expires
        if ($hget(>checkban,reason)) $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Blacklist) $s2($hget(>checkban,who)) banned $s2($2) at $s2($hget(>checkban,time)) $&
          for $s2($hget(>checkban,reason)) $iif($hget(>checkban,expires) != 0000-00-00 00:00:00, expires $s2($hget(>checkban,expires))) 
        else $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Blacklist) Channel $s2($2) is not banned.
      }
      elseif ((?r* iswm $1 || ?bl* iswm $1) && %admrank >= 3) {
        if (?r* iswm $1) {
          db.rem blist user $2
          $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Blacklist) Channel $s1($2) has been removed from blist.
        }
        elseif (?bl iswm $1) {
          if ($0 >= 3) {
            if (!$db.get(blist,reason,user,$2)) {
              db.set blist who user $2 $nick
              db.set blist reason user $2 $3-
              putlog perform part $2 This channel has been blacklisted
              $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Blacklist) Channel $s1($2) has been added to blist.
            }
            else notice $nick $logo(ERROR) Channel is already banned.
          }
          else notice $nick $logo(ERROR) Syntax !(c|r)bl <channel> [reason]
        }
      }
    }
    else notice $nick $logo(ERROR) Syntax !(c|r)bl <channel> [reason]
  }
}

ON $*:TEXT:/^[!@.](r|c)?suspend .*/Si:%staffchans: {
  var %admrank $db.get(admins,rank,address,$address($nick,3)) < 2
  if (%admrank >= 2 && $me == iDM) { 
    if ($0 >= 2) { 
      if (?c* iswm $1) {
        db.user.hash >checkban ilist $2 who time reason expires
        if ($hget(>checkban,reason)) $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Banned) $s2($hget(>checkban,who)) banned $s2($2) at $s2($hget(>checkban,time)) $&
          for $s2($hget(>checkban,reason)) $iif($hget(>checkban,expires) != 0000-00-00 00:00:00, expires $s2($hget(>checkban,expires))) 
        else $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(Banned) $s2($2) is not suspended.
      }
      elseif ((?r* iswm $1 || ?suspend* iswm $1) && %admrank >= 3) {
        if (?r* iswm $1) {
          db.exec UPDATE `user`,`user_alt` SET banned = '0' WHERE `user`.userid = `user_alt`.userid AND user = $db.safe($2)
          if ($mysql_affected_rows(%db) !== -1) {
            db.user.rem ilist $2
            $iif($left($1,1) == @,msgsafe $chan,notice $nick) Restored account $2 to its original status.
          }
          else $iif($left($1,1) == @,msgsafe $chan,notice $nick) Couldn't find account $s1($2)
        }
        elseif (?suspend iswm $1) {
          if ($0 >= 3) {
            db.exec UPDATE `user` SET banned = '1' WHERE userid = ( select `userid` from `user_alt` where `user` = $db.safe($2) )
            if ($mysql_affected_rows(%db) !== -1) {
              db.user.set ilist who $2 $nick
              db.user.set ilist reason $2 $3-
              $iif($left($1,1) == @,msgsafe $chan,notice $nick) Removed account $2 from the top scores - $3- .
            }
            else notice $nick $logo(ERROR) Couldn't find account $s1($nick)
          }
        }
        else notice $nick $logo(ERROR) Syntax !(c|r)suspend <channel> [reason]
      }
    }
    else notice $nick $logo(ERROR) Syntax !(c|r)suspend <name> [reason]
  }
}

On $*:TEXT:/^[!@.]cookie .*/Si:#: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4 && $me == iDM && $2) {
    tokenize 32 $1- 1
    if ($3 isnum) {
      db.user.set equip_staff cookies $2 + $3
      var %cookies $db.user.get(equip_staff, cookies, $2)
      msgsafe $chan $+ , $+ $staffchan $logo(Cookies) User $2 now has %cookies cookie $+ $iif(%cookies != 1,s) ( $+ $nick $+ )
    }
  }
}

On $*:TEXT:/^[!@.]((de|in)crease|define).*/Si:%staffchans: {
  if ($db.get(admins,rank,address,$address($nick,3)) == 4 && $me == iDM) {
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
    elseif ($3 == bslap || $3 == admin || $3 == sdrain) {
      var %table = equip_item
      var %item = admin
    }
    elseif (($3 == snow) || ($3 == clue) || ($3 == corr) || ($3 == arctic)) {
      var %table = equip_item
      var %item = $3
    }
    else { notice $nick Couldnt find item matching $3 $+ . Valid: money/wins/losses/snow/clue/vspear/statius/mjavelin/cookies + !store items. | halt }
    if (%sign == =) { db.user.set %table %item $2 $4 }
    else { db.user.set %table %item $2 %sign $4 }
    msgsafe $chan $logo(ACCOUNT) User $2 has been updated. %item = $db.user.get(%table, %item, $2)
    return
    :error
    notice $nick Syntax !define/increase/decrease <account> <item> <amount>
  }
}
