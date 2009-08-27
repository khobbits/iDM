alias exportini {
  if ($2) {
    createtable $1 $2
  }
  else {
    createtable $$1
  }
  set %ex.file $1 $+ .ini
  set %ex.table $1
  set %ex.section NULL
  filter -fk %ex.file exportiniline *
  unset %ex.*
  echo -s Exported $1
}
alias exportiniline {
  if ([*] iswm $1) {
    set %ex.section $remove($1,[,])
    return
  }
  var %ex.key = $regsubex($gettok($1,1,61),/~(.+?)~/g,$+($chr(91),\1,$chr(93)))
  insertdb $lower(%ex.table) $lower(%ex.section) $lower(%ex.key) $lower($gettok($1,2,61))
}

alias exportiniall {
  sqlite_close %db
  unset %db
  set %db $sqlite_open_memory(database/idm.db)
  if (%db) {
    echo -s Memory database created and opened successfully.
  }
  else {
    echo 4 -s Error opening a memory database: %sqlite_errstr
    halt
  }
  .timer 1 1 exportinibatch1
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
  .timer 1 1 exportinibatch2
}

alias exportinibatch2 {
  exportini passes
  exportini pvp
  .timer 1 1 exportinibatch3
}
alias exportinibatch3 {
  exportini equipment
  exportini wins
  .timer 1 1 exportinibatch4
}
alias exportinibatch4 {
  exportini losses  
  exportini money
  .timer 1 1 exportinibatch5
}
alias exportinibatch5 {
  sqlite_write_to_file %db database/idm.db
  set %db $sqlite_open(database/idm.db)

  echo -a Finished Exporting ini files to .db
}