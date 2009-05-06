alias bind {
  if (!$1) || ($1 == off) { bindip off | halt }
  if ($1 isnum 1-7) { bindip on $gettok($iplistlol,$1,58) }
  if ($1 > 7) { echo Error: No IP found with that ID. Please select a number between 1 and 7, or off to disable. | halt }
}
alias iplistlol {
  return 66.90.87.84:66.90.87.85:66.90.87.86:66.90.87.87:66.90.87.88:66.90.85.27:66.90.85.26
}