# speech-to-ipa
pretty ambitious

## How to get it running.

First setup Kaldi

Docs found at: http://kaldi-asr.org/doc/feat.html

### Linux Mint 19 Tara

I also need to add libs:

```
$ sudo aptitude install libfst-tools
```

### General setup:

Install deps:

```
$ cd tools
$ cat INSTALL
```

```
$ cd src
$ cat INSTALL
```

Then clone this project into kaldi/egs/speech-to-ipa

Make the symlinks to the other examples so we can use their scripts:

```
 $ ln -sf ../wsj/s5/utils utils
 $ ln -sf ../wsj/s5/steps steps
```

Run the script

```
 $ ./run.sh
```

## Extras, to record 16khz files:
rec -c 1 -r 16000 -b 16 1_2_3.wav
rec -c 1 -r 16000 -b 16 1_6_3.wav
rec -c 1 -r 16000 -b 16 2_3_4.wav
rec -c 1 -r 16000 -b 16 3_4_5.wav
rec -c 1 -r 16000 -b 16 4_5_6.wav
rec -c 1 -r 16000 -b 16 6_7_8.wav
rec -c 1 -r 16000 -b 16 7_3_2.wav
rec -c 1 -r 16000 -b 16 7_6_5.wav
rec -c 1 -r 16000 -b 16 7_8_9.wav
rec -c 1 -r 16000 -b 16 9_8_7.wav

## Convert to 16khz
```
 $ ffmpeg -i 1.wav -acodec pcm_s16le -ac 1 -ar 16000 1-16.wav
```

## get file info
```
 $ soxi 1.wav
```