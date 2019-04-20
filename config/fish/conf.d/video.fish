#ffmpeg

function ffac3
  if test (count $argv) -eq 0
    exit 1
  else if test (count $argv) -eq 1
    set -l output (basename $argv .mkv).conv.mkv
    ffmpeg -i $argv -map 0 -codec copy -acodec eac3 -ab 640k -max_muxing_queue_size 99999 $output
    and trash $argv; and mv $output $argv
  else
    for input in $argv
      set -l output (basename $input .mkv).conv.mkv
      ffmpeg -i $input -map 0 -codec copy -acodec eac3 -ab 640k -max_muxing_queue_size 99999 $output
      and trash $input; and mv $output $input
    end
  end
end

function ffaac
  if test (count $argv) -eq 0
    exit 1
  else if test (count $argv) -eq 1
    set -l output (basename $argv .mkv).conv.mkv
    ffmpeg -i $argv -map 0 -codec copy -acodec aac_at -aq 7 -max_muxing_queue_size 99999 $output
    and trash $argv; and mv $output $argv
  else
    for input in $argv
      set -l output (basename $input .mkv).conv.mkv
      ffmpeg -i $input -map 0 -codec copy -acodec aac_at -aq 7 -max_muxing_queue_size 99999 $output
      and trash $input; and mv $output $input
    end
  end
end

function fflac
  if test (count $argv) -eq 0
    exit 1
  else if test (count $argv) -eq 1
    set -l output (basename $argv .mkv).conv.mkv
    ffmpeg -i $argv -map 0 -codec copy -acodec flac -max_muxing_queue_size 99999 $output
    and trash $argv; and mv $output $argv
  else
    for input in $argv
      set -l output (basename $input .mkv).conv.mkv
      ffmpeg -i $input -map 0 -codec copy -acodec flac -max_muxing_queue_size 99999 $output
      and trash $input; and mv $output $input
    end
  end
end

function mp42mkv
  if test (count $argv) -eq 0
    exit 1
  else if test (count $argv) -eq 1
    set -l output (basename $argv .mp4).mkv
    mkvmerge -o $output $argv
    and trash $argv
  else
    for input in $argv
      set -l output (basename $argv .mp4).mkv 
      mkvmerge -o $output $input
      and trash $argv
    end
  end
end

function mkv2mp4
  if test (count $argv) -eq 0
    exit 1
  else if test (count $argv) -eq 1
    set -l output (basename $argv .mkv).mp4
    ffmpeg -i $argv -c copy -c:s mov_text $output
    and trash $argv
  else
    for input in $argv
      set -l output (basename $argv .mkv).mp4
      ffmpeg -i $input -c copy -c:s mov_text $output
      and trash $input
    end
  end
end

function srt
  switch (echo $argv)
    case "*.mkv"
      set name (basename $argv | cut -f 1 -d '.')

      mkvmerge --default-language eng -o $name.conv.mkv $argv --forced-track 0 $name.srt
      and trash $argv
      and trash $name.srt
      and mv $name.conv.mkv $name.mkv
  case "*.mp4"
      set name (basename $argv | cut -f 1 -d '.')

      mp4box -add $name.srt:txtflags=0xC0000000:lang=eng $argv -out $name.conv.mp4
      and trash $argv
      and trash $name.srt
      and mv $name.conv.mp4 $name.mp4
  case "*.srt"
      set name (basename $argv | cut -f 1 -d '.')

      mkvmerge --default-language eng -o $name.conv.mkv $argv --forced-track 0 $name.srt
      and trash $argv
      and trash $name.srt
      and mv $name.conv.mkv $name.mkv
  end
end

function nosrt
  if test (count $argv) -eq 0
    exit 1
  else if test (count $argv) -eq 1
    set -l output (basename $argv .mkv).conv.mkv
    mkvmerge -o $output -S -M $argv
    and trash $argv; and mv $output $argv
  else
    for input in $argv
      set -l output (basename $input .mkv).conv.mkv
      mkvmerge -o $output -S -M $input
      and trash $input; and mv $output $input
    end
  end
end


function 0x
  rename -N ...01 -X -e '$_ = "0x$N"' $argv
end
function 1x
  rename -N ...01 -X -e '$_ = "1x$N"' $argv
end
function 2x
  rename -N ...01 -X -e '$_ = "2x$N"' $argv
end
function 3x
  rename -N ...01 -X -e '$_ = "3x$N"' $argv
end
function 4x
  rename -N ...01 -X -e '$_ = "4x$N"' $argv
end
function 5x
  rename -N ...01 -X -e '$_ = "5x$N"' $argv
end
function 6x
  rename -N ...01 -X -e '$_ = "6x$N"' $argv
end
function 7x
  rename -N ...01 -X -e '$_ = "7x$N"' $argv
end
function 8x
  rename -N ...01 -X -e '$_ = "8x$N"' $argv
end
function 9x
  rename -N ...01 -X -e '$_ = "9x$N"' $argv
end

function removie
  rename -s ":" " -" -s "[" "(" -s "]" ")" $argv
end

function mkvforced
  for i in **.mkv; mkvpropedit "$PWD/$i" --edit track:s1 --set flag-forced=1 --set flag-enabled=1; end
end

function mkveng
  for i in **.mkv; mkvpropedit "$PWD/$i" --edit track:a1 --set language=eng --edit track:s1 --set language=eng; end
end
