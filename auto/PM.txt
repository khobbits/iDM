on *:TEXT:*:?: {
  inc -u3 %pm.spam 
  close -m $nick
}
