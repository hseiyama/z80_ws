# z80_ws

## ZASM
### 特徴
基本、Z80をアセンブルする目的で使用する。  
HEXファイルを一発で生成できる。  
※個人的には、Z80のアセンブル目的であればコレで十分  
[情報元のリンク](https://k1.spdns.de/Develop/Projects/zasm/Distributions/)
### (1) アセンブルのコマンド
$ zasm -uwxy listing_sample01.asm  
<RAM出力用>  
$ zasm -uwxy --target=ram listing_sample01.asm  
### (2) HEXをテキストに変換するまでの手順
$ zasm -uyz aki80_simple01.asm  
$ xxd -i -c 16 aki80_simple01.rom > aki80_simple01.txt  

## The Macroassembler AS
### 特徴
様々なマイコン向けを対象にアセンブルすることができる。  
（Z80, MC68000 等）  
Github等で公開されているプロジェクトで利用されているケースが多い。  
[情報元のリンク](http://john.ccac.rwth-aachen.de:8000/as/)
### (1) アセンブルのコマンド
$ asl -L AKI80mon_RevB05.asm  
$ p2hex AKI80mon_RevB05.p  
### (2) HEXをテキストに変換するまでの手順
$ asl -L AKI80mon_RevB05.asm  
$ p2bin AKI80mon_RevB05.p  
$ xxd -i -c 16 AKI80mon_RevB05.bin > AKI80mon_RevB05.txt  
