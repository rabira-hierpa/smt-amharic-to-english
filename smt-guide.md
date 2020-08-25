# Steps to model and train the translation system

### Tokenization Step

```bash
## tokenize the english corpus
$ ./mosesdecoder/scripts/tokenizer/tokenizer.perl -l en
  < ./corpous/proc.en # take proc.en corpus as a file
  > ./corpus/proc.tok.en # write the tokenized output to proc.tok.en file
## tokenize the amharic corpus
$ ./mosesdecoder/scripts/tokenizer/tokenizer.perl -l ah
  < ./corpous/proc.am # take proc.en corpus as a file
  > ./corpus/proc.tok.am # write the tokenized output to proc.tok.en file
```

### Training the Caser for Truecasing

```bash
## training the caser for English corpus
sudo ./mosesdecoder/scripts/recaser/train-truecaser.perl
  --model ./corpous/truecase-model.en # output file for the english case model
  --corpus ./corpous/proc.tok.en # input for the case learner
## training the caser for Amharic corpus
sudo ./mosesdecoder/scripts/recaser/train-truecaser.perl
  --model ./corpous/truecase-model.ah # output file for amharic case model(redundnat)
  --corpus ./corpous/proc.tok.ah # inputfile for the case learner
```

```bash
## casing the english corpus
sudo ./mosesdecoder/scripts/recaser/truecase.perl
  --model ./corpous/truecase-model.en # model config file
  < ./corpous/proc.tok.en # input for the caser
  > ./corpous/proc.true.en # output file after casing the corpus
## casing the amharic language
sudo ./mosesdecoder/scripts/recaser/truecase.perl
  --model ./corpous/truecase-model.ah # model config file
  < ./corpous/proc.tok.ah # input file for the caser
  > ./corpous/proc.true.ah # output file after casing the corpus
```

## Cleaning the corpus

```bash
## cleaning both corpus
sudo ./mosesdecoder/scripts/training/clean-corpus-n.perl
  ./corpous/proc.true ah en # take both cased files as an input
  ./corpous/proc.clean 1 80 # limit sentence lenght to 80
```

## Building the Language Model(LM)

```bash
./mosesdecoder/bin/lmplz -o 3
  < ./corpous/proc.true.en # turecased corpus input file
  > ./corpous/proc.arpa.en # the target langauge model(i.e English in our case)
  # Then we should binarise (for faster loading) the *.arpa.en file using KenLM:
  sudo ./mosesdecoder/bin/build_binary
    ./corpous/proc.arpa.en # the input file to be binarise
    ./corpous/proc.blm.en # the binary file of the language model
```

## Testing the language model

```bash
echo "የመንግሥት ሠራተኛው እንዲያውቀው ያልተደረገ ወይም ያልተገለጸለትን የጽሁፍ ማስረጃ በግል ማህደሩ ውስጥ ማስቀመጥ ክልክል ነው፡፡" |
  ./bin/query  # the echo as an input to the qurey script file
  ./corpous/proc.blm.en # the binary langauge modle file
```

## Training the translation model

```bash
## the following command is executed in the working/ directory
nohup nice # run the follwoing command in the background
../scripts/training/train-model.perl # the training script
  -root-dir train # output dir
  -corpus ../corpous/proc.clean -f ah -e en # the cleaned corpus files
  -alignment grow-diag-final-and  # word alignment
  -reordering msd-bidirectional-fe # lexicalized reordering
  -lm 0:3:$HOME/smt/corpous/proc.blm.en:8 # binary file of the language model
  -external-bin-dir ../tools # dir where GIAZ++,mkcsl and sn2cooc.out are located
  >& training.out & # write the status to trainin.out file
```

## Testing the translation system

```bash
sudo ./bin/moses -f ./working/train/model/moses.ini
```
