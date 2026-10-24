#!/bin/sh
out=/music/brown_noise.flac
tmp=/music/.brown_noise.tmp.flac


[ -f "$out" ] && exit 0
ffmpeg -y -f lavfi \
  -i "anoisesrc=color=brown:amplitude=0.4:duration=5:sample_rate=44100,highpass=f=100" \
  -ac 1 -c:a flac "$tmp" &&
mv "$tmp" "$out"
timeout 30 sh -c 'until mpc update; do sleep 1; done'
