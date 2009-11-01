alias dbcheck {
  if (!%db) {
    dbinit
  }
}

; Secures the db from exploits through injection.
alias db.safe {
  return $mysql_qt($mysql_real_escape_string(%db,$lower($1-)))
}

; Adds the quotes around a table or column define
alias db.tquote {
  return ` $+ $lower($1-) $+ `
}

; This is a convience function to return a single cell from a table
alias db.get {
  dbcheck
  tokenize 32 $replace($lower($1-),$chr(32) $+ $chr(32),$chr(32))
  var %sql = SELECT * FROM $db.tquote($1) WHERE user = $db.safe($3)
  var %col = $2
  return $db.select(%sql,%col)
}

; This function retrieves a single cell from a database and returns the value
alias db.select {
  dbcheck
  var %sql = $1
  var %col = $2
  var %request = $mysql_query(%db, %sql)
  if (%request) {
    var %result = $mysql_result(%request, %col)
    mysql_free %request
    if (%debugq == $me) echo 12 -s Query %sql returned %result
    return %result
  }
  else {
    mysqlderror Error executing query: %mysql_errstr - Query %sql
    return $null
  }
}

; These functions are used to get more complicated results from the db
alias db.query {
  dbcheck
  var %sql = $1
  var %request = $mysql_query(%db, %sql)
  if (%request) {
    if (%debugq == $me) echo 12 -s Query %sql returned token %request
    return %request
  }
  else {
    mysqlderror Error executing query: %mysql_errstr - Query %sql
    return $null
  }
}

alias db.query_row_data {
  var %request = $1
  var %col = $2
  var %result = $mysql_fetch_field( %request, %col )
  if (%debugq == $me) echo 12 -s Fetched column %col - Result %result
  return %result
}

alias db.query_row {
  var %request = $1
  var %htable = $2
  var %result = $mysql_fetch_row( %request, %htable )
  return %result
}

alias db.query_num_rows {
  var %request = $1
  var %result = $mysql_num_rows(%request)
  return %result
}

alias db.query_end {
  var %request = $1
  mysql_free %request
}

; This is the convience function used to write single values to the db or update an existing value
alias db.set {
  dbcheck
  tokenize 32 $replace($lower($1-),$chr(32) $+ $chr(32),$chr(32))
  if (($5 isnum) && (($4 == +) || ($4 == -))) {
    var %sql = INSERT INTO $db.tquote($1) ( user , $2 ) VALUES (  $db.safe($3) , $db.safe($5-) ) ON DUPLICATE KEY UPDATE $2 = $2 $4 $db.safe($5-)
    return $db.exec(%sql)
  }
  elseif ($4) {
    var %sql = INSERT INTO $db.tquote($1) ( user , $2 ) VALUES (  $db.safe($3) , $db.safe($4-) ) ON DUPLICATE KEY UPDATE $2 = $db.safe($4-)
    return $db.exec(%sql)
  }
  else {
    mysqlderror Syntax Error: /db.set <table> <column> <user> <value>
    return 0
  }
}

; This is the raw db exec function used to run any sql
alias db.exec {
  dbcheck
  var %sql = $1-
  if (!$mysql_exec(%db, %sql)) {
    mysqlderror Error executing query: %mysql_errstr - Query %sql
    return $null
  }
  if (%debugq == $me) echo 12 -s Query %sql executed
  return 1
}

alias mysqlderror {
  echo 4 -s $1-
  sbnc tcl putmainlog {3BotError4 $1- }
}

alias createtable {
  var %sql = CREATE $iif($2 == temp,TEMP) TABLE IF NOT EXISTS ` $+ $lower($1) $+ ` (c1, c2, c3, PRIMARY KEY (c1, c2))
  if (!$mysql_exec(%db, %sql)) {
    mysqlderror Error: %mysql_errstr - Query %sql
    halt
  }
}

on *:START: {
  load -rs " $+ $mircdirmysql/mmysql.mrc"
  dbinit
}

alias dbinit {
  var %host = baka.khobbits.co.uk
  var %user = idm
  var %pass = Sp4rh4wk`Gh0$t`
  var %database = idm

  set %db $mysql_connect(%host, %user, %pass)
  if (!%db) {
    mysqlderror Error: %mysql_errstr
    return
  }
  else {
    if (!$mysql_select_db(%db, %database)) {
      echo 4 -a Failed selecting database %database
      mysql_close %db
      return
    }
    echo 4 -s SQLDB LOADED
  }
}
