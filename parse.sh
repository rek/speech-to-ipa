#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

# number of parallel jobs - 1 is perfect for such a small dataset
parallelJobs=1

MODEL_DIR="exp/tri1"
DECODE_SOURCE_DIR="audio/decode"
DECODE_DIR="data/decode"
CONF_DIR="conf"

echo "#####------------------------"
echo "# Starting decode script"
echo "#####-------------------------"

if [ $# -eq 0 ]
then
        echo ""
        echo "Missing target, put a file in the $DECODE_SOURCE_DIR folder, example usage: ./parse.sh test.wav"
        echo ""
        exit 1
fi

if [ ! -f $DECODE_SOURCE_DIR/$1 ]; then
        echo "Cannot find $1 in $DECODE_SOURCE_DIR"
        exit 1
fi

for file in final.mdl graph/HCLG.fst graph/words.txt; do
        if [ ! -f $MODEL_DIR/$file ]; then
                echo ""
                echo "$MODEL_DIR/$file not found"
                echo ""
                exit 1;
        fi
done;

for app in nnet3-latgen-faster apply-cmvn lattice-scale; do
        command -v $app >/dev/null 2>&1 || { echo >&2 "$app not found, is kaldi compiled?"; exit 1; }
done;

echo ''
echo 'Setup successfully passed'
echo ''
echo 'Starting cleanup'
echo ''
rm -rf $DECODE_DIR/*

echo ''
echo 'Starting audio file meta file creation'
echo ''

# this makes the scp, spk2utt files etc
local/create-corpus.sh $DECODE_DIR $DECODE_SOURCE_DIR/$1 || exit 1;
# multi file:
# local/create-corpus.sh $DECODE_DIR $DECODE_SOURCE_DIR/$@ || exit 1;

echo ""
echo "Setup done ok"
echo ""
echo "Computing mfcc and cmvn (cmvn is not really used)"
echo ""

steps/make_mfcc.sh \
        --nj $parallelJobs \
        --mfcc-config $CONF_DIR/mfcc.conf \
        --cmd "$decode_cmd" \
        $DECODE_DIR exp/make_mfcc exp/mfcc || { echo "Unable to calculate mfcc, ensure 16kHz, 16 bit little-endian wav format or see log"; exit 1; };

steps/compute_cmvn_stats.sh $DECODE_DIR exp/make_mfcc/ exp/mfcc || exit 1;

steps/decode.sh --config conf/decode.config --nj $parallelJobs --cmd "$decode_cmd" $MODEL_DIR/graph $DECODE_DIR $MODEL_DIR/decode
echo
lattice-best-path ark:"gunzip -c $MODEL_DIR/decode/lat.1.gz |" ark,t: | int2sym.pl -f 2- $MODEL_DIR/graph/words.txt > $DECODE_DIR/decoded_text.txt
echo
echo "===== Results from test data: ====="
echo
cat $DECODE_DIR/decoded_text.txt

