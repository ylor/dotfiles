function recomic
  rename -S "_" " " *.cb*

  if test (count *.cb*) -lt 10
      rename -v 's/\d+/sprintf("%01d",$&)/e' *.cb*
    else if test (count *.cb*) -lt 100
      rename -v 's/\d+/sprintf("%02d",$&)/e' *.cb*
    else
      rename -v 's/\d+/sprintf("%03d",$&)/e' *.cb*
  end

  rename -v 's/ \(.*\)\./\./' *.cb*
  rename -d " GetComics.INFO" *.cb*
end

function _2sp
  rename -S "_" " " $argv
end

function sp2_
  rename -S " " "_" $argv
end

function cbr2cbz
  for CBR in *.cbr
    set -l BASE (basename "$CBR" .cbr)
    set -l CBZ "$BASE".cbz
    set -l TMP "tmp-$BASE"
  
    mkdir $TMP; and cd $TMP
    printf $BASE
    printf "...decompressing cbr"
    unrar x ../"$CBR" > /dev/null
    printf "...compressing cbz..."
    zip -r -9 ../"$CBZ" . > /dev/null 
    and cd ..; and mv "$CBR" "$TMP"; and trash "$TMP"
    printf "done\r\n";
  end
end
