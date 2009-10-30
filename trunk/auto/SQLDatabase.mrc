alias writeini {
  dbformat writedb $1-
}

alias readini {
  return $dbformat(readdb,$1-)
}

alias remini {
  dbformat remdb $1-
}

alias ini {
  return $dbformat(listdb,$1-)
}

alias updateini {
  dbformat updatedb $1-
}

alias createini {
  dbformat createtable $1
}

alias dbcheck {
  if (!%db) {
    dbinit
  }
}

alias dbformat {
  dbcheck
  tokenize 32 $lower($1-)
  var %string = $remove($2,-n) $3-
  %string = $remove(%string,.ini,.txt)
  %string = $replace(%string,$chr(32) $+ $chr(32),$chr(32))
  tokenize 32 $1 %string
  if ($1 == readdb) {
    return $readdb($2,$3,$4)
  }
  elseif ($1 == listdb) {
    return $listdb($2,$3,$4)
  }
  else {
    $1 $2 $3 $4 $5-
  }
}

alias db.safe {
  return $sqlite_qt($sqlite_escape_string($1-))
}

alias db.quote {
  return $sqlite_qt($1-)
}

alias db.select {
  dbcheck
  var %sql = $1
  var %col = $2
  var %request = $sqlite_query(%db, %sql)
  if (%request) {
    var %result = $sqlite_result(%request, %col)
    sqlite_free %request
    if (%debugq == $me) echo 12 -s Query %sql returned %result
    return %result
  }
  else {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
    return $null
  }
}

alias db.query {
  dbcheck
  var %sql = $1
  var %request = $sqlite_query(%db, %sql)
  if (%request) {
    if (%debugq == $me) echo 12 -s Query %sql returned token %request
    return %request
  }
  else {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
    return $null
  }
}

alias db.query_row_data {
  var %request = $1
  var %col = $2
  var %result = $sqlite_fetch_field( %request, %col )
  if (%debugq == $me) echo 12 -s Fetched column %col - Result %result
  return %result
}

alias db.query_row {
  var %request = $1
  var %htable = $2
  var %result = $sqlite_fetch_row( %request, %htable )
  return %result
}

alias db.query_num_rows {
  var %request = $1
  var %result = $sqlite_num_rows(%request)
  return %result
}

alias db.query_end {
  var %request = $1
  sqlite_free %request
}

alias db.exec {
  dbcheck
  var %sql = $1-
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
    return $null
  }
  if (%debugq == $me) echo 12 -s Query %sql executed
  return 1
}

alias remdb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3-)
  var %sql = DELETE FROM $sqlite_qt(%table)
  if (%key1 != $null) {
    %sql = %sql WHERE c1 = $sqlite_qt(%key1)
    if (%key2 != $null) {
      %sql = %sql AND c2 = $sqlite_qt(%key2)
    }
  }  
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
  }
  if (%debugq == $me) echo 5 -s Query %sql executed
}

alias writedb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %key3 = $sqlite_escape_string($4-)
  var %sql = REPLACE INTO $sqlite_qt(%table) VALUES ( $sqlite_qt(%key1) , $sqlite_qt(%key2) , $sqlite_qt(%key3) )
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
  }
  if (%debugq == $me) echo 3 -s Query %sql executed
}

alias updatedb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  if (%key2 == $null) {
    var %sql = UPDATE $sqlite_qt(%table) SET c3 = c3 $3 WHERE c1 = $sqlite_qt(%key1) 
  }
  else {
    var %sql = UPDATE $sqlite_qt(%table) SET c3 = c3 $4- WHERE c1 = $sqlite_qt(%key1) AND c2 = $sqlite_qt(%key2)
  }
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
  }
  if ($sqlite_changes(%db) < 1) && ($abs($4-) isnum) {
    var %sql = INSERT INTO $sqlite_qt(%table) VALUES ( $sqlite_qt(%key1) , $sqlite_qt(%key2) , $abs($4-) )
    if (!$sqlite_exec(%db, %sql)) {
      echo 4 -s Error executing query: %sqlite_errstr - Query %sql
    }
  }
  if (%debugq == $me) echo 14 -s Query %sql executed
}

alias insertdb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %key3 = $sqlite_escape_string($4-)
  var %sql = INSERT INTO $sqlite_qt(%table) VALUES ( $sqlite_qt(%key1) , $sqlite_qt(%key2) , $sqlite_qt(%key3) )
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
  }
}

alias readdb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %key3 = $sqlite_escape_string($4)

  var %sql = SELECT * FROM $sqlite_qt(%table) WHERE c1 = $sqlite_qt(%key1) AND c2 = $sqlite_qt(%key2)
  if (%key3 != $null) { %sql = %sql AND c3 = $sqlite_qt(%key3) }
  var %request = $sqlite_query(%db, %sql)
  if (%request) {
    var %result = $sqlite_fetch_field(%request, c3)
    sqlite_free %request
    if (%debugq == $me) echo 7 -s Query %sql returned %result
    return %result
  }
  else {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
    return $null
  }
}

alias listdb {
  var %table = $lower($1)
  if ($$2 == 0) {
    var %sql = SELECT DISTINCT c1 FROM $sqlite_qt(%table)
    var %numrow = 1
  }
  elseif ($2 isnum && $3 == $null) {
    var %sql = SELECT DISTINCT c1 FROM $sqlite_qt(%table)
    var %limit = $calc($2 -1) $+ ,1
    var %column = c1
  }
  else {    
    var %sql = SELECT * FROM $sqlite_qt(%table)
    if ($2 !isnum) { var %key1 = = $sqlite_qt($sqlite_escape_string($2)) }
    else { var %key1 = = (SELECT DISTINCT c1 FROM $sqlite_qt(%table) LIMIT $calc($2 -1) $+ ,1) }
    var %column = c2
    if ($3 == 0) { var %numrow = 1 }
    elseif ($3 isnum) { var %limit = $calc($3 -1) $+ ,1 }
    else { 
      if ($sqlite_escape_string($3)) {
        var %key2 = = $sqlite_qt($sqlite_escape_string($3)) 
      }
    }
  }
  if (%key1 != $null) {
    %sql = %sql WHERE c1 %key1
    if (%key2 != $null) { %sql = %sql AND c2 %key2 }
  }
  else {
    if (%key2 != $null) { %sql = %sql WHERE c2 = $sqlite_qt(%key2) }
  }
  if (%limit != $null) { %sql = %sql LIMIT %limit }
  var %request = $sqlite_query(%db, %sql)
  if (%request) {
    if (%numrow == 1) { var %result = $sqlite_num_rows(%request) }
    else { var %result = $sqlite_fetch_field(%request, %column) }
    sqlite_free %request
    if (%debugq == $me) echo 6 -s Query %sql returned %result
    return %result
  }
  else {
    echo 4 -s Error executing query: %sqlite_errstr - Query %sql
    return $null
  }
}

alias createtable {
  var %sql = CREATE $iif($2 == temp,TEMP) TABLE IF NOT EXISTS ' $+ $lower($1) $+ ' (c1, c2, c3, PRIMARY KEY (c1, c2))
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error: %sqlite_errstr - Query %sql
    halt 
  }
}

on *:START: {
  load -rs " $+ $mircdirsqllite/msqlite.mrc"
  dbinit
}

alias dbinit {
  set %db $sqlite_open($mircdirdatabase/idm.db)
  if (!%db) {
    echo 4 -s Error: %sqlite_errstr
    return
  } 
  else {
    echo 4 -s SQLDB LOADED
  }
}
