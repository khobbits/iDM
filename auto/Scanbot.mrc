alias scanbots {
  if (# == #iDM || # == #iDM.Staff) { halt }
  var %a 1
  while (%a <= $nick($1,0)) {
    if ($istok($botnames,$nick($1,%a),46)) && ($nick($1,%a) != $me) {
      part $1 Bot already in channel. ( $+ $nick($1,%a) $+ )
      halt
    }
    inc %a
  }
}