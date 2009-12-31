on $*:TEXT:/^[!@.]part/Si:#: {
  if (# == #idm) || (# == #idm.Staff) { halt }
  if ($2 == $me) {
    if ($nick isop # || $nick ishop #) || ($db.get(admins,position,$address($nick,3))) {
      if (%part.spam [ $+ [ # ] ]) { halt }
      part # Part requested by $nick $+ .
      set -u10 %part.spam [ $+ [ # ] ] on
      msgsafe #idm.staff $logo(PART) I have parted: $chan $+ . Requested by $iif($nick,$v1,N/A) $+ .
      cancel #
    }
  }
}

on *:PART:#: {
  if ($nick(#,0) < 5) && (!$istok(#idm #idm.staff #idm.help #idm.support #tank #istake,#,32)) {
    part # Parting channel. Need 5 or more people to have iDM.
  }
  if ($nick == $me) && (!%rjoinch. [ $+ [ $me ] ]) {
    cancel #
  }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ]) {
    db.set user money %p1 [ $+ [ $chan  ] ] - $ceil($calc($+(%,stake,#) / 2) )
    msgsafe # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
    cancel #
    .timer $+ # off
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ]) {
    db.set user money %p2 [ $+ [ $chan  ] ] - $ceil($calc($+(%,stake,#) / 2))
    msgsafe # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
    cancel #
    .timer $+ # off
  }
  if ($nick == %p1 [ $+ [ $chan ] ]) || ($nick == %p2 [ $+ [ $chan ] ]) {
    msgsafe # $logo(DM) The DM has been canceled, because one of the players parted.
    if (%turn [ $+ [ $chan ] ]) {
      if ($enddmcatch(part,$nick,$chan,$1-) == 1) {
        var %oldmoney = $db.get(user,money,$nick)
        if (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney * 0.02))
          notice $nick You left the channel during a dm, you lose $s2($price(%newmoney)) cash
          write penalty.txt $timestamp $nick parted channel $chan during a dm oldcash %oldmoney penalty %newmoney
          db.set user money $nick - %newmoney
        }
        db.set user losses $nick + 1
      }
    }
    cancel #
    .timer $+ # off
  }
  ;  if ($1-3 == Left all channels) || ($1-2 == Part All)  || ($1 == Partall) {
  ;    unauth $nick
  ;  }
}

on *:QUIT: {
  ;  unauth $nick
  var %a 1
  while (%a <= $chan(0)) {
    if ($nick == %p1 [ $+ [ $chan(%a) ] ]) || ($nick == %p2 [ $+ [ $chan(%a) ] ]) {
      msgsafe $chan(%a) $logo(DM) The DM has been canceled, because one of the players quit.
      if (%turn [ $+ [ $chan(%a) ] ]) {
        if ($enddmcatch(quit,$nick,$chan(%a),$1-) == 1) {
          var %oldmoney = $db.get(user,money,$nick)
          if (%oldmoney > 100) {
            var %newmoney = $ceil($calc(%oldmoney * 0.01))
            write penalty.txt $timestamp $nick quit during a dm oldcash %oldmoney penalty %newmoney
            db.set user money $nick - %newmoney
          }
          db.set user losses $nick + 1
        }
      }
      cancel $chan(%a)
      .timer $+ $chan(%a) off
    }
    inc %a
  }
}
on *:NICK: {
  ;  unauth $nick
  ;  unauth $newnick
  var %a = 1
  while (%a <= $chan(0)) {
    if (%stake [ $+ [ $chan(%a) ] ]) && (($nick == %p1 [ $+ [ $chan(%a) ] ]) || ($nick == %p2 [ $+ [ $chan(%a) ] ])) {
      db.set user money $nick - $ceil($calc($+(%,stake,$chan(%a)) / 2))
      msgsafe $chan(%a) $logo(DM) The stake has been canceled, because one of the players changed their nick. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,$chan(%a)) / 2) ))) $+ .
      cancel $chan(%a)
      .timer $+ $chan(%a) off
      halt
    }
    if ($nick == %p1 [ $+ [ $chan(%a) ] ]) {
      db.set user indm $nick 0
      db.set user indm $newnick 1
      set %p1 [ $+ [ $chan(%a) ] ] $newnick
    }
    if ($nick == %p2 [ $+ [ $chan(%a) ] ]) {
      db.set user indm $nick 0
      db.set user indm $newnick 1
      set %p2 [ $+ [ $chan(%a) ] ] $newnick
    }
    inc %a
  }
}
on *:KICK:#: {
  if ($nick(#,0) < 6) && ($knick != $me) { part # Parting channel. Need 5 or more people to have iDM. }
  if ($knick == %p1 [ $+ [ $chan ] ]) || ($knick == %p2 [ $+ [ $chan ] ]) {
    msgsafe # $logo(DM) The DM has been ended because one of the players was kicked!
    if (%turn [ $+ [ $chan ] ]) {
      if ($enddmcatch(kick,$knick,$nick,$chan,$1-) == 1) {
        var %oldmoney = $db.get(user,money,$knick)
        if (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney * 0.01))
          notice $nick You left the channel during a dm, you lose $s2($price(%newmoney)) cash
          write penalty.txt $timestamp $knick got kicked during a dm by $nick oldcash %oldmoney penalty %newmoney
          db.set user money $knick - %newmoney
        }
        db.set user losses $nick + 1
      }
    }
    cancel #
    .timer $+ # off
    halt
  }
  if ($knick == $me) {
    .timer 1 15 waskicked #
    if (. !isin $nick) { msgsafe #idm.staff $logo(KICK) I have been kicked from: $chan by $nick $+ . Reason: $1- }
    elseif (shroudbnc !isin $nick) { join # | msgsafe #idm.staff $logo(REJOINING) I was kicked from $chan by $nick - $1- }
  }
}

alias waskicked {
  if ($me !ison $1) {
    cancel $1
    .timer $+ $1 off
  }
}

alias enddmcatch {
  goto $1

  :part
  var %action = parted $3 with reason " $+ $iif($4-,$4-,N/A) $+ "
  goto pass

  :quit
  var %action = quit $network & $3 ( $+ $4- $+ )
  if ($4 == Quit:) {
    goto pass
  }
  else {
    goto qfail
  }
  :kick
  var %action = was kicked from $4 by $3 for " $+ $5- $+ "
  if ($3 == $2) {
    goto pass
  }
  else {
    goto fail
  }

  :error
  reseterror
  goto fail

  #####

  :pass
  msgsafe #idm.staff $logo(ENDDM) $2 %action *
  return 1

  :fail
  msgsafe #idm.staff $logo(ENDDM) $2 %action
  return 0

  :qfail
  return 0
}
