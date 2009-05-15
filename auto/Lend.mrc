on *:DISCONNECT:{
  var %x = 1
  while ($ini(lent.ini,lent,%x)) {
    $+(timerlend,$v1) -p
  inc %x }
}

on *:CONNECT:{
  var %x = 1
  while ($ini(lent.ini,lent,%x)) {
    $+(timerlend,$v1) -r
  inc %x }
}

on *:TEXT:!lend*:#: {
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($3 == $nick) { halt }
  if (!$2) || (!$readini(lent.ini,lendable,$2)) { notice $nick $logo(ERROR) You can't lend this, try a real item. For example: !lend Ags Allegra | halt }
  if (!$3) || (!$3 ison $chan) { notice $nick $logo(ERROR) Please specify a nick to lend the item to someone in the channel. | halt }
  if (!$readini(login.ini,login,$nick)) { notice $nick $logo(ERROR) You must be logged in to have the capablity of lending items. | halt }
  if (!$readini(equipment.ini,$2,$nick)) { notice $nick $logo(ERROR) You currently don't have $qt($2) in your equipment. | halt }
  if ($readini(equipment.ini,$2,$3)) { notice $nick $logo(ERROR) $qt($3) already has this piece of equipment. | halt }
  if ($timer($+(lend,$nick))) || ($readini(lent.ini,lent,$nick)) { notice $nick You currently have $qt($readini(lent.ini,lent,$nick)) lent out. It will be returned in $duration($timer($+(lend,$nick)).secs) $+ . | halt }
  if ($readini(lent.ini,borrowing,$nick) == $2) { notice $nick You cannot lend $readini(lent.ini,borrowing,$nick) because it is being borrowed. | halt }
  writeini -n lent.ini Lent $nick $2
  writeini -n lent.ini Borrowing $3 $2
  remini -n equipment.ini $2 $nick
  writeini -n equipment.ini $2 $3 borrow
  $+(.timerlend,$nick) -o 1 300 itemlend $nick $2 $3
  notice $nick $logo(Lent) You have lent your $2 to $3 for 5 minutes $+ . In this period you will NOT be able to reclaim the item. You will receive a message when your item is returned!
  notice $3 $logo(Lent) $nick has lent his $2 to you for 5 minutes $+ . You will receive a message within the next 10 minutes telling you, that you can no longer use the item.
}

alias itemlend {
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  remini -n lent.ini Lent $1
  remini -n lent.ini borrowing $3
  writeini -n equipment.ini $2 $1 true
  remini -n equipment.ini $2 $3
  notice $1 $logo(Lent) $2 has successfully been retrieved from $3 $+ .
  notice $3 $logo(Lent) $2 has been returned to $1 $+ .
}
