on *:INVITE:#: {
  if ($me != iDM) { halt }
  if (%invig. [ $+ [ # ] ]) { halt }
  if (%loottimer) { msgsafe $nick Invite is disabled because GE database is updating. Please wait several minutes. | halt }
  if (%inv.spam [ $+ [ $nick ] ]) { halt }
  if ((!%inv.spam [ $+ [ $nick ] ]) && ($db.get(blist,reason,#))) {
    notice $nick Channel has been blacklisted. (Reason: $v1 $iif($db.get(blist,who,#),By: $v1) $+ )
    inc -u10 %inv.spam [ $+ [ $nick ] ]
    halt
  }
  sbnc joinbot $chan $nick
}

alias botsonline {
  if ($me !ison #idm.staff) { return $me }
  var %a 1
  while ($nick(#idm.staff,%a)) {
    if ($istok($botnames,$nick(#idm.staff,%a),46)) {
      var %b %b $nick(#idm.staff,%a)
    }
    inc %a
  }
  return %b
}

alias botnames {
  return iDM.iDM[US].iDM[LL].iDM[BA].iDM[PK].iDM[AL].iDM[BU].iDM[FU].iDM[SN].iDM[BE].iDM[LA].iDM[EU]
}

CTCP *:*join*:?: {
  if ($nick == iDM) {
    if ($me ison $2) { halt }
    set %raw322 [ $+ [ $2 ] ] $3 | $+(.timerlist,$2) 1 0.5 .list $2 | $+(.timerinvalidnick,$2) 1 4 modesp $2 | set -u5 %raw47345 [ $+ [ $2 ] ] $3
  }
}
alias modesp {
  if (!%raw322 [ $+ [ $1 ] ]) || ($numtok(%raw322 [ $+ [ $1 ] ],32) == 2) { Halt }
  join $1 | set %raw322 [ $+ [ $1 ] ] %raw322 [ $+ [ $1 ] ] on on
}

on *:JOIN:#:{
  if ($nick == $me) {
    if (%raw322 [ $+ [ # ] ]) && ($numtok(%raw322 [ $+ [ # ] ],32) == 2) { unset %raw322 [ $+ [ # ] ] }
    if (%forcedj. [ $+ [ # ] ]) {
      unset %forcedj. [ $+ [ # ] ]
    }
    else {
      if (# != #idm && # != #idm.Staff) {
        if (u isincs $chan(#).mode) {
          part # You currently have +u set you need to remove it before I will join
        }
        else {
          $+(.timerlimit5,#) 1 1 limit5 # $deltok(%raw322 [ $+ [ # ] ],2-3,32)
          .timer 1 1 scanbots $chan
        }
      }
    }
  }
  else {
    if ($nick(#,0) < 5) && (!$istok(#idm #idm.staff #idm.support #idm.help #tank #istake #idm.elites #dm.newbies,#,32)) {
      part # Parting channel. Need 5 or more people to have iDM.
      return
    }
    if (# != #idm && # != #idm.Staff) || ($me == iDM) {
      if ($isbanned($nick)) { halt }
      var %dmrank $ranks(money,$nick)
      if ($db.get(admins,position,$address($nick,3)) = admins) {
        msgsafe # $logo(ADMIN) $+($upper($left($position($nick),1)),$lower($right($position($nick),-1))) $nick has joined the channel.
      }
      elseif ($db.get(admins,position,$address($nick,3))) {
        msgsafe # $logo(SUPPORT) Bot support $nick has joined the channel.
      }
      elseif (%dmrank <= 12) {
        msgsafe # $logo(TOP12) iDM player $nick is ranked $ord(%dmrank) in the top 12.
      }
      elseif ((# == #idm.support) || (# == #idm.help)) {
        logcheck $nick $address $chan supportjointitle
      }
    } 
  }
}

alias supportjointitle.fail supportjointitle $1 $2 $3 4NOT IDENTIFIED
alias supportjointitle.fail0 supportjointitle $1 $2 $3 4NOT REGISTERED
alias supportjointitle {
  db.hget userinfo user $1
  msg +#idm.support $logo(Acc-Info) User: $s2($nick) Money: $s2($iif($hget(userinfo,money),$price($v1),0)) W/L: $s2($iif($hget(userinfo,wins),$bytes($v1,db),0)) $+ / $+ $s2($iif($hget(userinfo,losses),$bytes($v1,db),0)) InDM?: $iif($hget(userinfo,indm),3YES,4NO) Excluded?: $iif($hget(userinfo,exclude),3YES,4NO) Logged-In?: $iif($islogged($1,$2,0),03 $+ $gmt($v1,dd/mm) $+ ,4NO) $4-
  ignoreinfo $1 $1 msg +#idm.support $logo(Acc-Info)
}

on $*:TEXT:/^[!@.]title/Si:#: {
  if (# != #idm && # != #idm.Staff) || ($me == iDM) {
    if ($isbanned($nick)) { halt }
    var %dmrank $ranks(money,$nick)
    if ($db.get(admins,position,$address($nick,3)) = admins) {
      msgsafe # $logo(ADMIN) $+($upper($left($position($nick),1)),$lower($right($position($nick),-1))) $nick is on the channel.
    }
    elseif ($db.get(admins,position,$address($nick,3))) {
      msgsafe # $logo(SUPPORT) Bot support $nick is on the channel.
    }
    elseif (%dmrank <= 12) {
      msgsafe # $logo(TOP12) iDM player $nick is ranked $ord(%dmrank) in the top 12.
    }
  }
}

alias limit5 {
  if ($istok(#idm #idm.staff #idm.support #idm.help #tank #istake #idm.elites #dm.newbies,$1,32)) { halt }
  if ($nick($1,0) < 5) { msgsafe $1 $logo(ERROR) $1 only has $nick($1,0) $iif($nick($1,0) == 1,person.,people.) 5 or more is needed to have iDM join. | part $1 | unset %raw322 [ $+ [ $1 ] ] | Halt }
  if (!$1) || (!$2) { halt }
  msgsafe $1 $entrymsg($1,$2) | idmstaff invite $1 $2 | unset %raw322 [ $+ [ $1 ] ]
}

alias scanbots {
  if (# == #idm || # == #idm.Staff) { halt }
  var %a 1
  while (%a <= $nick($1,0)) {
    if ($istok($botnames,$nick($1,%a),46)) && ($nick($1,%a) != $me) {
      part $1 Bot already in channel. ( $+ $nick($1,%a) $+ )
      halt
    }
    inc %a
  }
}

alias position {
  if ($db.get(admins,title,$address($nick,3))) {
    return $v1
    halt
  }
  return Bot admin
}

raw 322:*:{
  if ($numtok(%raw322 [ $+ [ $2 ] ],32) == 1) {
    if ($3 < 4) {
      notice %raw322 [ $+ [ $2 ] ] $logo(ERROR) $2 only has $3 people. 4 or more is needed to have iDM join.
      unset %raw322 [ $+ [ $2 ] ]
    }
    else {
      $+(.timerinvalidnick,$2) off
      set %raw322 [ $+ [ $2 ] ] %raw322 [ $+ [ $2 ] ] on
      join $2
      idmstaff invite $2 $gettok(%raw322 [ $+ [ $2 ] ],1,32) 
      $+(.timer,$2) 1 1 msgsafe $2 $entrymsg($2,$gettok(%raw322 [ $+ [ $2 ] ],1,32))
    }
  }
}

raw 323:*:{ /window -h "Channels list" }
raw 474:*: { if (%raw47345 [ $+ [ $2 ] ]) {
    msgsafe %raw47345 [ $+ [ $2 ] ] $logo(ERROR) I'm currently banned from $2 so im unable to join. | unset %raw47345 [ $+ [ $2 ] ]
  }
}
raw 475:*: { if (%raw47345 [ $+ [ $2 ] ]) {
    msgsafe %raw47345 [ $+ [ $2 ] ] $logo(ERROR) $2 has mode +k enabled so im unable to join. Please type: /mode $2 -k and re-invite me | unset %raw47345 [ $+ [ $2 ] ]
  }
}
alias idmstaff {
  if ($1 == invite) { msgsafe $secondchan $logo(INVITE) $s1($3) invited me into $s2($2) }
}
alias entrymsgsafe {
  return $logo(INVITE) Thanks for inviting iDM $chr(91) $+ Bot tag - $s1($bottag) $+ $chr(93) into $s2($1) $+ $iif($2,$chr(44) $s1($2) $+ .,.) An op must type !part $me to part me. Forums: 12http://forum.idm-bot.com/ Rules: 12http://r.idm-bot.com/rules $botnews
}
alias botnews {
  return News: New site features + changes to !money -- !dmnews for more
}

on $*:TEXT:/^[!@.]dmnews/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  notice $nick $logo(News #1) Login changes -> http://r.idm-bot.com/efn2
  notice $nick $logo(News #2) Request a channel blacklist by visiting #iDM.Support Note: Channel owners + admins ONLY
}


alias bottag {
  tokenize 32 $iif($1,$1-,$me)
  if ($1 == iDM) { return iDM | halt }
  else { return $remove($1,idm[,$chr(93)) | halt }
}
