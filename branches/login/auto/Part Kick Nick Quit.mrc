on *:TEXT:!idle*:#iDM.Staff: {
  if ($.readini(admins.ini,admins,$address($nick,3))) {
    var %a = 1,%c
    while (%a <= $chan(0)) {
      if ($nick($chan(%a),$me).idle > 1800) {
        if ($chan(%a) != #iDM && $chan(%a) != #iDM.staff && $chan(%a) != #iStake && $chan(%a) != #iDM.Support) {
          part $chan(%a) This bot has been idling over 30 mins. Parting channel.
          var %c %c $chan(%a)
        }
      }
      inc %a
    } 
    if (%c) notice $nick $logo(IDLE) I have parted: %c 
    else {
      notice $nick $LOGO(IDLE) I have parted no chans.
    }
  }
}

on $*:TEXT:/^[!@.]part/Si:#: { 
  if (# == #iDM) || (# == #iDM.Staff) { halt }
  if ($2 == $me) {
    if ($nick isop # || $nick ishop #) || ($.readini(Admins.ini,Support,$address($nick,3))) {
      if (%part.spam [ $+ [ # ] ]) { halt }
      part # Part requested by $nick $+ .
      set -u10 %part.spam [ $+ [ # ] ] on
      msg #iDM.staff $logo(PART) I have parted: $chan $+ . Requested by $iif($nick,$v1,N/A) $+ .
      cancel #
    }
  }
}

on *:PART:#: {
  if ($nick(#,0) < 5) && (!$istok(#idm #idm.staff #idm.support #tank #istake,#,32)) { 
    part # Parting channel. Need 5 or more people to have iDM.
  }
  if ($nick == $me) && (!%rjoinch. [ $+ [ $me ] ]) {
    cancel #
    remini OnOff.ini #
  }
  if ($nick == %p1 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ]) {
    writeini money.ini money %p1 [ $+ [ $chan  ] ] $calc($.readini(money.ini,money,%p1 [ $+ [ $chan ] ]) - $ceil($calc($+(%,stake,#) / 2) ))
    msg # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
    cancel #
    .timer $+ # off
  }
  if ($nick == %p2 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) && (%turn [ $+ [ $chan ] ]) {
    writeini money.ini money %p2 [ $+ [ $chan  ] ] $calc($.readini(money.ini,money,%p2 [ $+ [ $chan ] ]) - $ceil($calc($+(%,stake,#) / 2) ))
    msg # $logo(DM) The stake has been canceled, because one of the players parted. $s1($nick) has lost $s2($price($ceil($calc($+(%,stake,#) / 2) ))) $+ .
    cancel #
    .timer $+ # off
  }
  if ($nick == %p1 [ $+ [ $chan ] ]) || ($nick == %p2 [ $+ [ $chan ] ]) {
    msg # $logo(DM) The DM has been canceled, because one of the players parted.
    if (%turn [ $+ [ $chan ] ]) {
      if ($enddmcatch(part,$nick,$chan,$1-) == 1) {
        var %oldmoney = $.readini(money.ini,money,$nick)
        if (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.02)))
          notice $nick You left the channel during a dm, you lose $s2($price($calc(%oldmoney - %newmoney))) cash
          write penalty.txt $timestamp $nick parted channel $chan during a dm oldcash %oldmoney newcash %newmoney
          writeini money.ini money $nick %newmoney
        }
      }
    }
    cancel #
    .timer $+ # off
  }
}

on *:QUIT: {
  if ($.readini(login.ini,login,$nick)) { remini login.ini login $nick }
  var %a 1
  while (%a <= $chan(0)) {
    if ($nick == %p1 [ $+ [ $chan(%a) ] ]) || ($nick == %p2 [ $+ [ $chan(%a) ] ]) {
      msg $chan(%a) $logo(DM) The DM has been canceled, because one of the players quit.
      if (%turn [ $+ [ $chan(%a) ] ]) {
        if ($enddmcatch(quit,$nick,$chan(%a),$1-) == 1) {
          var %oldmoney = $.readini(money.ini,money,$nick)
          if (%oldmoney > 100) {
            var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.02)))
            write penalty.txt $timestamp $nick quit during a dm oldcash %oldmoney newcash %newmoney
            writeini money.ini money $nick %newmoney
          }
        }
      }
      cancel $chan(%a)
      .timer $+ $chan(%a) off
    }
    inc %a
  }
}
on *:NICK: {
  if (!%dming [ $+ [ $nick ] ]) { halt }
  var %a = 1
  while (%a <= $chan(0)) {
    if (%stake [ $+ [ $chan(%a) ] ]) && (($nick == %p1 [ $+ [ $chan(%a) ] ]) || ($nick == %p2 [ $+ [ $chan(%a) ] ])) { msg $chan(%a) $logo(STAKE) The stake has been canceled because a player changed their nick. | cancel $chan(%a) | .timer $+ $chan(%a) off | halt }
    if ($nick == %p1 [ $+ [ $chan(%a) ] ]) {
      remini status.ini currentdm $nick
      writeini status.ini currentdm $newnick true
      unset %dming [ $+ [ $nick ] ]
      remini login.ini login $nick
      set %p1 [ $+ [ $chan(%a) ] ] $newnick | set %dming [ $+ [ $newnick ] ] on
    }
    if ($nick == %p2 [ $+ [ $chan(%a) ] ]) {
      remini status.ini currentdm $nick
      writeini status.ini currentdm $newnick true
      unset %dming [ $+ [ $nick ] ]
      remini login.ini login $nick
      set %p2 [ $+ [ $chan(%a) ] ] $newnick | set %dming [ $+ [ $newnick ] ] on
    }
    inc %a
  }
}
on *:KICK:#: {
  if ($nick(#,0) < 6) && ($knick != $me) { part # Parting channel. Need 5 or more people to have iDM. }
  if ($knick == %p1 [ $+ [ $chan ] ]) || ($knick == %p2 [ $+ [ $chan ] ]) {
    msg # $logo(DM) The DM has been ended because one of the players was kicked!
    if (%turn [ $+ [ $chan ] ]) {
      if ($enddmcatch(kick,$knick,$nick,$chan,$1-) == 1) {
        var %oldmoney = $.readini(money.ini,money,$knick)
        if (%oldmoney > 100) {
          var %newmoney = $ceil($calc(%oldmoney - (%oldmoney * 0.02)))
          notice $nick You left the channel during a dm, you lose $s2($price($calc(%oldmoney - %newmoney))) cash
          write penalty.txt  $timestamp $knick got kicked during a dm by $nick oldcash %oldmoney newcash %newmoney
          writeini money.ini money $knick %newmoney
        }
      }
    }
    cancel # 
    .timer $+ # off 
    halt 
  }
  if ($knick == $me) && (. !isin $nick) { cancel # | .timer $+ # off | msg #idm.staff $logo(KICK) I have been kicked from: $chan by $nick $+ . Reason: $1- }
}

alias enddmcatch {
  goto $1

  :part
  var %action = parted $3 for $4-
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
  return 1

  :fail
  msg #idm.staff $logo(ENDDM) $2 %action
  return 0

  :qfail
  return 0
}