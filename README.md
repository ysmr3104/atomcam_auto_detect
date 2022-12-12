# atomcam_auto_detect
ATOM Cam Swingで撮影した流星を含む動画をダウンロードして検知するのを自動化したくて自分用に作成しました。
ノーサポートですが、使ってみたい方はどうぞ。

以下、自分メモを兼ねて。

## atomcam_auto_detect.sh
atomcam_toolsとmeteor-detectを利用して動画転送から流星検出・検出動画結合・比較明合成まで一気通貫に実行します。
必要なもの（それぞれ必要なものの準備方法は後述）
- atomcam_tools
- meteor-detect
- ffmpeg
- ImageMagik

## lighten_composition.sh
JPGファイルの比較明合成するところだけ切り出したシェルスクリプトです。
カレントディレクトリのみで動きます。
必要なもの
- ImageMagik

## concat_movies.sh
mp4ファイルを結合する所だけ切り出したシェルスクリプトです。
カレントディレクトリのみで動作します。
- ffmpeg


# 必要なものの準備

## ATOM Cam Swing
たぶん、ATOM Cam 2でも動きますが、Swingしか持ってないので。

### atomcam_tools
mnakada氏のatomcam_toolsをATOM Camに導入します。
リポジトリはこちら
https://github.com/mnakada/atomcam_tools

導入は↑の使用法の通りSDカードに入れて再起動するのみ

## macOSに必要なものを準備
## meteor-detect
kin-hasegawa氏のmeteor-detectをgit cloneして使っています。
リポジトリはこちら
https://github.com/kin-hasegawa/meteor-detect


### 環境構築
```
git clone https://github.com/kin-hasegawa/meteor-detect.git
cd meteor-detect
EOF > requirements.txt
numpy
opencv-python
pafy
youtube_dl
imutils
EOF
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
deactivate
```

# ffmpegをインストール
```
brew install ffmpeg
```

# ImageMagikをインストール
```
brew install imagemagick
```


# 使い方
atomcam_auto_detect.shの冒頭に設定箇所があるので環境に合わせて修正（そのうち別ファイルにする）

朝になって昨夜22時〜今朝06時の動画を処理する
```
atomcam_auto_detect.sh
```

日にちが過ぎて指定日付とその前日を処理する場合
```
atomcam_auto_detect.sh --date=20221201
```
この場合は2022-11-30 22時〜2022-12-01 06時
