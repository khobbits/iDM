on $*:TEXT:/^[!@.]top/Si:#: {
  ;if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  var %display = $iif(@* iswm $1,msg #,notice $nick)
  if ($2 !isnum 1-12) { %display $logo(ERROR) The maximum number of users you can lookup is 12. Syntax: !top 12 | halt }
  var %output $toplist(money,$2,1)
  %display $logo(TOP Money) Total DM's: $s2($bytes($.readini(totalwins.ini,totalwins,totalwins),bd)) %output
}

on $*:TEXT:/^[!@.]wtop/Si:#: {
  ;if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  var %display = $iif(@* iswm $1,msg #,notice $nick)
  if ($2 !isnum 1-12) { %display $logo(ERROR) The maximum number of users you can lookup is 12. Syntax: !wtop 12 | halt }
  var %output $toplist(wins,$2)
  %display $logo(TOP Wins) Total DM's: $s2($bytes($.readini(totalwins.ini,totalwins,totalwins),bd)) %output
}

on $*:TEXT:/^[!@.]ltop/Si:#: {
  ;if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  var %display = $iif(@* iswm $1,msg #,notice $nick)
  if ($2 !isnum 1-12) { %display $logo(ERROR) The maximum number of users you can lookup is 12. Syntax: !wtop 12 | halt }
  var %output $toplist(losses,$2)
  %display $logo(TOP Losses) Total DM's: $s2($bytes($.readini(totalwins.ini,totalwins,totalwins),bd)) %output
}


alias toplist {
  ; $1 = table
  ; $2 = number to show
  ; $3 = toggle on using K/M/B
  var %output, %i = 0
  var %sql = SELECT * FROM $db.quote($1) WHERE c1 = $db.quote($1) AND c2 NOT LIKE '~banned~%' ORDER BY c3 +0 DESC LIMIT 0, $+ $2
  var %result = $db.query(%sql)
  while ($db.query_row(%result,row)) {
    inc %i
    ;%output = %output $chr(124) $s1(%i $+ .) $hget(row,c2) $s2($price($hget(row,c3)))
    if ($3 == 1) {
      %output = %output $chr(124) %i $+ . $s1($hget(row,c2)) $s2($price($hget(row,c3)))

    }
    else {
      %output = %output $chr(124) %i $+ . $s1($hget(row,c2)) $s2($bytes($hget(row,c3),db))
    }    
  }
  db.query_end %result
  return %output
}

on $*:TEXT:/^[!@.]dmrank/Si:#: {
  tokenize 32 $1- $nick
  ;if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  var %display = $iif(@* iswm $1,msg #,notice $nick) 
  if ($2 isnum) {
    var %money = $ranks(money,$2)
    var %wins = $ranks(wins,$2)
    var %losses = $ranks(losses,$2)
    var %output = $logo(RANK) $s1(Money) $+ : $s2($gettok(%money,1,58)) with $price($gettok(%money,2,58)) $s1(Wins) $+ : $s2($gettok(%wins,1,58)) with $gettok(%wins,2,58) $s1(Losses) $+ : $s2($gettok(%losses,1,58)) with $gettok(%losses,2,58)
  } 
  else {
    var %output = $logo($2) $s1(Money) $+ : $s2($rank(money,$2)) $s1(Wins) $+ : $s2($rank(wins,$2)) $s1(Losses) $+ : $s2($rank(losses,$2))
  }
  if (%output == $null) {
    notice $nick Syntax: !rank <name>/<1 - 10000>
  }
  else {
    %display %output
  }
}

alias rank {
  ; $1 = table
  ; $2 = username
  var %rank = $ranks($1,$2)
  if (%rank == $null || %rank == 0) {
    return Unknown
  }
  else {
    return %rank $+ $iif(%rank == 1,st,$iif(%rank == 2,nd,$iif(%rank == 3,rd,th)))
  }
}

alias ranks {
  tokenize 32 $lower($1 $2)
  ; $1 = table
  ; $2 = position or username
  if ($2 isnum) {
    if ($2 isnum 1-50000) {
      var %sql = SELECT * FROM $db.quote($1) WHERE c1 = $db.quote($1) ORDER BY c3 +0 DESC LIMIT $calc($2 - 1) $+ ,1
      var %query = $db.query(%sql)
      if ($db.query_row(%query,row) == 1) {
        return $hget(row,2) $+ : $+ $hget(row,3)
      }
    }
  }
  else {
    var %sql = SELECT * FROM $db.quote($1) WHERE c1 = $db.quote($1) AND c2 = $db.quote($2) LIMIT 0,1
    if ($db.select(%sql,c3) == $null) { return Sorry user could not be found }

    var %sql = SELECT COUNT(*)+1 AS rank FROM $db.quote($1) AS r1 $&
      INNER JOIN $db.quote($1) AS r2 ON (r1.c3 +0) < (r2.c3 +0) $&
      WHERE r1.c2 = $db.quote($2)

    var %query = $db.query(%sql)
    if ($db.query_row(%query,row) == 1) {
      return $hget(row,1)
    }   
  }
  return $null
}
