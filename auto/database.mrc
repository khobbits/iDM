;alias write {
;  dbformat writedb $1-
;}

;alias reed {
;  return $dbformat(readdb,$1-)
;}

alias writeini {
  dbformat writedb $1-
}

alias reedini {
  return $dbformat(readdb,$1-)
}

alias remini {
  dbformat remdb $1-
}

alias dbformat {
  var %string = $remove($2-3,-n,.ini,.txt) $4
  %string = $replace(%string,$chr(32) $+ $chr(32),$chr(32))
  if ($1 == readdb) {
    return $readdb(%string)
  }
  else {
    $1 %string
  }
}

alias remdb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %sql = DELETE FROM ' $+ %table $+ ' WHERE c1 LIKE ' $+ %key1 $+ ' AND c2 LIKE ' $+ %key2 $+ '
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr
  }
}

alias writedb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %key3 = $sqlite_escape_string($4-)
  var %sql = REPLACE INTO ' $+ %table $+ ' VALUES ( ' $+ %key1 $+ ', ' $+ %key2 $+ ', ' $+ %key3 $+ ' )
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr
  }
}

alias insertdb {
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %key3 = $sqlite_escape_string($4-)
  var %sql = INSERT INTO ' $+ %table $+ ' VALUES ( ' $+ %key1 $+ ', ' $+ %key2 $+ ', ' $+ %key3 $+ ' )
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error executing query: %sqlite_errstr
  }
}

alias readdb {
  tokenize 32 $1-
  var %table = $lower($1)
  var %key1 = $sqlite_escape_string($2)
  var %key2 = $sqlite_escape_string($3)
  var %key3 = $sqlite_escape_string($3)
  var %sql = SELECT * FROM ' $+ %table $+ ' WHERE c1 LIKE ' $+ %key1 $+ ' AND c2 LIKE ' $+ %key2 $+ '
  if ($key3 != $null) {
    %sql = %sql AND c3 LIKE ' $+ %key3 $+ '

  }
  var %request = $sqlite_query(%db, %sql)
  if (%request) {
    var %result = $sqlite_fetch_field(%request, c3)
    sqlite_free %request
    return %result
  }
  else {
    echo 4 -s Error executing query: %sqlite_errstr
    return $null
  }
}

alias createtable {
  var %sql = CREATE TABLE IF NOT EXISTS ' $+ $lower($1) $+ ' (c1, c2, c3, PRIMARY KEY (c1, c2))
  if (!$sqlite_exec(%db, %sql)) {
    echo 4 -s Error: %sqlite_errstr
    halt 
  }
}

on *:START: {
  load -rs $mircdir/sqllite/msqlite.mrc
  set %db $sqlite_open(idm.db)
  if (!%db) {
    echo 4 -s Error: %sqlite_errstr
    return
    } else {
    echo 4 -s MYSQL LOADED
  }
}

alias exportini {
  createtable $$1
  set %ex.file $1 $+ .ini
  set %ex.table $1
  set %ex.section NULL
  filter -fk %ex.file exportiniline *

  echo -s Exported $1
}
alias exportiniline {
  if ([*] iswm $1) {
    set %ex.section $remove($1,[,])
    return
  }
  insertdb %ex.table %ex.section $gettok($1,1,61) $gettok($1,2,61)
}

alias exportiniall {
  sqlite_close %db
  unset %db
  set %db $sqlite_open_memory(idm.db)
  if (%db) {
    echo -a Memory database created and opened successfully.
  }
  else {
    echo -a Error opening a memory database: %sqlite_errstr
    halt
  }
  timer 1 1 exportinibatch1
}
alias exportinibatch1 {
  exportini admins
  exportini blacklist
  exportini clannames
  exportini clans
  exportini clantracker
  exportini events
  exportini exceptions
  exportini ignore
  exportini lent
  exportini login
  exportini onoff
  exportini personalclan
  exportini positions
  exportini set
  exportini sitems
  exportini status
  exportini totalwins
  timer 1 1 exportinibatch2
}

alias exportinibatch2 {
  exportini passes
  exportini pvp
  timer 1 1 exportinibatch3
}
alias exportinibatch3 {
  exportini equipment
  exportini wins
  timer 1 1 exportinibatch4
}
alias exportinibatch4 {
  exportini losses  
  exportini money
  timer 1 1 exportinibatch5
}
alias exportinibatch5 {
  sqlite_write_to_file %db idm.db
  set %db $sqlite_open(idm.db)
}
