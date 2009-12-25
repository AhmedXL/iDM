on $*:TEXT:/^[!@.]money/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$2) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($nick) $+ $isbanned($nick) $money($nick) $clan($nick) $s1(Profile) $+ : http://idm-bot.com/u/ $+ $webstrip($nick,1) 
  }
  if ($2) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($2) $+ $isbanned($2) $money($2) $clan($2) $s1(Profile) $+ : http://idm-bot.com/u/ $+ $webstrip($2,1) 
  }
}

on $*:TEXT:/^[!@.]equip/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if (!$2) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($nick) $+ $isbanned($nick) $equipment($nick) $iif($db.get(equip_item,specpot,$nick),$s1(Spec Pots) $+ : $v1)
    if ($sitems($nick)) || ($pvp($nick)) $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($nick) $+ $isbanned($nick) $iif($sitems($nick),$s1(Special Items) $+ : $sitems($nick)) $iif($pvp($nick),$s1(PvP Items) $+ : $pvp($nick))
  }
  if ($2) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($2) $+ $isbanned($2) $equipment($2) $iif($db.get(equip_item,specpot,$2),$s1(Spec Pots) $+ : $v1)
    if ($sitems($2)) || ($pvp($2)) $iif($left($1,1) == @,msgsafe #,notice $nick) $logo($2) $+ $isbanned($2) $iif($sitems($2),$s1(Special Items) $+ : $sitems($2)) $iif($pvp($2),$s1(PvP Items) $+ : $pvp($2))
  }
}

alias money {
  db.hget userm user $1

  var %money = $hget(userm,money)
  var %rank = $rank(money,$1)
  var %wins = $hget(userm,wins)
  var %losses = $hget(userm,losses)
  var %ratio = $s1(W/L Ratio) $+ :  $s2($round($calc(%wins / %losses),2)) ( $+ $s2($+($round($calc(%wins / $calc(%wins + %losses) *100),1),$chr(37)))) $+ )

  return $s1(Money) $+ : $iif(%money,$s2($bytes($v1,bd)) $+ gp ( $+ %rank $+ ),$s2(0) $+ gp) $iif($maxstake(%money),$s1(Max Stake) $+ : $s2($price($maxstake(%money)))) $s1(Wins) $+ : $iif(%wins,$s2($bytes($v1,bd)),$s2(0)) $s1(Losses) $+ : $iif(%losses,$s2($bytes($v1,bd)),$s2(0)) %ratio
}

alias equipment {
  db.hget equipit equip_item $1
  db.hget equipar equip_armour $1

  if ($hget(equipit,ags)) { var %e %e AGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,bgs)) { var %e %e BGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,sgs)) { var %e %e SGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,zgs)) { var %e %e ZGS $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,dclaws)) { var %e %e Dragon:Claws $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,mudkip)) { var %e %e Mudkip $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }

  if ($hget(equipar,accumulator)) { var %e %e Accumulator $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,void)) { var %e %e Void:Ranged $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,void-mage)) { var %e %e Void:Mage $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,mbook)) { var %e %e Mage's:Book $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,godcape)) { var %e %e God:Cape $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,bgloves)) { var %e %e Barrow:Gloves $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,firecape)) { var %e %e Fire:Cape $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipar,elshield)) { var %e %e Elysian:Shield $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }

  if ($hget(equipit,wealth)) { var %e %e Wealth $+ $iif($v1 > 1,$+($chr(40),$v1,$chr(41))) }
  if ($hget(equipit,clue)) { var %e %e Clue:Scroll }
  if ($hget(equipit,snow)) { var %e %e Snow:Globe }

  return $s1(Equipment) $+ : $iif(%e,$replace(%e,$chr(32),$chr(44) $+ $chr(32),$chr(58),$chr(32)),None)
}

alias clan {
  if ($getclanname($1)) { return $s1(Clan) $+ : $s2($v1) }
}

alias sitems {
  db.hget equips equip_staff $1

  if ($hget(equips,belong)) { var %e %e B�long:Blade }
  if ($hget(equips,allegra)) { var %e %e Allergy:Pills }
  if ($hget(equips,beau)) { var %e %e B�aumerang }
  if ($hget(equips,snake)) { var %e %e $replace(One:�yed:Trouser:Snake,e,$chr(233),E,�) }
  if ($hget(equips,kh)) { var %e %e KHonfound:Ring }
  if ($hget(equips,support)) { var %e %e The:Supporter }
  if ($hget(equips,cookies)) { var %e %e Cookies( $+ $v1 $+ ) }

  return $iif(%e,$replace(%e,$chr(32),$chr(44) $+ $chr(32),$chr(58),$chr(32)))
}

alias pvp {
  db.hget equipp equip_pvp $1

  if ($hget(equipp,vspear)) { var %e %e $+(Vesta's:Spear,$chr(91),$s1($v1),$chr(93)) }
  if ($hget(equipp,vlong)) { var %e %e $+(Vesta's:Longsword,$chr(91),$s1($v1),$chr(93)) }
  if ($hget(equipp,statius)) { var %e %e $+(Statius's:Warhammer,$chr(91),$s1($v1),$chr(93)) }
  if ($hget(equipp,MJavelin)) { var %e %e $+(Morrigan's:Javelin,$chr(91),$s1($v1),$chr(93)) }

  return $iif(%e,$replace(%e,$chr(32),$chr(44) $+ $chr(32),$chr(58),$chr(32)))
}


on $*:TEXT:/^[!@.]ViewItems$/Si:#idm.Staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    var %sql SELECT sum(belong) as belong,sum(allegra) as allegra,sum(beau) as beau,sum(snake) as snake,sum(kh) as kh,sum(if(support = '0',0,1)) as support FROM `equip_staff`
    var %result = $db.query(%sql)
    if ($db.query_row(%result,equip) === $null) { echo -s Error fetching Staff items totals. - %sql }
    db.query_end %result
    notice $nick $logo(Special Items) Belong Blade: $s2($hget(equip,belong)) Allergy Pills: $s2($hget(equip,allegra)) $&
      Beaumerang: $s2($hget(equip,beau)) One Eyed Trouser Snake: $s2($hget(equip,snake)) KHonfound Ring: $s2($hget(equip,kh)) $&
      The Supporter: $s2($hget(equip,support))
  }
}

on $*:TEXT:/^[!@.]GiveItem .*/Si:#idm.Staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    if (!$2) { notice You need to include a name you want to give your item too. }
    elseif ($whichitem($nick)) {
      var %item $v1
      if ($db.get(equip_staff,%item,$2) == 1) { notice $nick $logo(ERROR) $nick $2 already has your item | halt }
      db.set equip_staff %item $2 $iif(%item == support,$nick,1)
      notice $nick $logo(Give-Item) Gave your item to $s2($2)
    }
    else { return }
  }
}

On $*:TEXT:/^[!@.]TakeItem .*/Si:#idm.Staff,#idm.support: {
  if ($db.get(admins,position,$address($nick,3)) && $me == iDM) {
    if (!$2) { notice You need to include a name you want to give your item too. }
    elseif ($whichitem($nick)) {
      var %item $v1
      if ($db.get(equip_staff,%item,$2) == 0) { notice $nick $logo(ERROR) $nick $2 doesn't have your item | halt }
      db.set equip_staff %item $2 0
      notice $nick $logo(Take-Item) Took your item from $s2($2)
    }
    else { return }
  }
}

alias whichitem {
  if ($1 == Belongtome) { return belong }
  if ($1 == Allegra || $1 == Strychnine) { return allegra }
  if ($1 == Beau) { return beau }
  if ($1 == [PCN]Sct_Snake || $1 == [PCN]Snake`Sleep) { return snake }
  if ($1 == KHobbits) { return kh }
  if ($1 == _Ace_ || $1 == Lucas| || $1 == Lucas|H1t_V3r4c || $1 == Shinn_Gundam || $1 == Aaron``) { return support }
  return 0
}

alias webstrip {
  var %return = $1
  var %return = $strip($replace(%return,/,))
  if ($2) {
    var %return = $replace(%return,$chr(35),$wchr(23),$chr(63),$wchr(3F),$chr(38),$wchr(26),$chr(91),$wchr(5B),$chr(93),$wchr(5D))
  }
  return %return
}

alias wchr {
  return $chr(37) $+ $1
}
