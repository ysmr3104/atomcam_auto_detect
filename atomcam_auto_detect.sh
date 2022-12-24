#!/bin/sh
# ------------------------------------------------------------------------------
# 環境設定
# ------------------------------------------------------------------------------
curr_directory="`pwd`"
temp_directory="${HOME}/Downloads/atomcam"
atomcam_directory="${HOME}/Downloads/atomcam_images"
meteor_detect_directory="${HOME}/projects/meteor-detect"
meteor_detect_atomcam="${meteor_detect_directory}/atomcam.py"
file_movlist="movlist.txt"
file_lighten="_lighten.jpg"
file_detected_mov="_detected.mp4"
file_detect_list="detected.txt"
image_directory="images"
host_name="atomcam.local"
http_user='user'
http_pass='passwd'
atom_dirctory="sdcard/record"
time_out=10
retry_count=3
target_hour_prev_date="22 23"
target_hour_curr_date="00 01 02 03 04 05"

# ------------------------------------------------------------------------------
# 引数制御
# ------------------------------------------------------------------------------
while getopts h:s:u:v-: opt; do
    # OPTARG を = の位置で分割して opt と optarg に代入
    optarg="$OPTARG"
    if [[ "$opt" = - ]]; then
        opt="-${OPTARG%%=*}"
        optarg="${OPTARG/${OPTARG%%=*}/}"
        optarg="${optarg#=}"

        if [[ -z "$optarg" ]] && [[ ! "${!OPTIND}" = -* ]]; then
            optarg="${!OPTIND}"
            shift
        fi
    fi

    case "-$opt" in
        -h|--host)
            host_name="$optarg"
            ;;
        -d|--date)
            input_date="$optarg"
            ;;
        -v|--version)
            echo 'v0.0.0'
            exit
            ;;
        --)
            break
            ;;
        -\?)
            exit 1
            ;;
        --*)
            echo "$0: illegal option -- ${opt##-}" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))



# ------------------------------------------------------------------------------
# 作業フォルダをクリアして移動
# ------------------------------------------------------------------------------
# rm -rf ${temp_directory}
# mkdir ${temp_directory}
# cd ${temp_directory}

# ------------------------------------------------------------------------------
# 開始メッセージ
# ------------------------------------------------------------------------------
since_timestamp=`date +"%Y-%m-%d %H:%M:%S"`
echo -e "□-----------------------------------------------------------------------------□"
echo -e "□　ATOM CamからWgetにて動画ファイルをダウンロードしmeteor-detectで流星検出を行います"
echo -e "□"
echo -e "□　- 入力日付\t\t\t"${input_date}
echo -e "□　- ATOM Camホスト名\t"
echo -e "□　- ダウンロードフォルダ\t"${temp_directory}
echo -e "□　- 画像動画出力フォルダ\t"${atomcam_directory}
echo -e "□"
echo -e "□ 開始時刻\t"${since_timestamp}
echo -e "□"

# ------------------------------------------------------------------------------
# 日付をセット
# ------------------------------------------------------------------------------
# 日付の入力があれば採用・無ければ当日
if [ ! -z "${input_date}" ];  
then  
    target_curr_date=${input_date}
else
    target_curr_date=`date '+%Y%m%d'`
fi
# 前日の日付を取得
target_prev_date=`date -v-1d -j -f "%Y%m%d" "${target_curr_date}" +"%Y%m%d"`

# ------------------------------------------------------------------------------
# 検出対象時間の取得
# ------------------------------------------------------------------------------
target_hours=""
for hour in ${target_hour_prev_date}
do
    target_hours="${target_hours}${target_prev_date}/${hour}:"
done
for hour in ${target_hour_curr_date}
do
    target_hours="${target_hours}${target_curr_date}/${hour}":
done
target_hour_list=`echo ${target_hours} | perl -pe 's/:/ /g'`

echo "□　以下の時間を対象にダウンロード・検出を行います"
echo ${target_hour_list} | perl -pe 's/ /\n/g'
sleep 1

# ------------------------------------------------------------------------------
# wgetでファイルをダウンロード
# ------------------------------------------------------------------------------
echo "□　ダウンロードを開始します"
echo "□　- 保存ディレクトリ：${temp_directory}/${host_name}/${atom_dirctory}"

for target_hour in ${target_hour_list}
do
    accesss_url="http://${host_name}/${atom_dirctory}/${target_hour}/"
    wget \
        --continue \
        --timestamping \
        --recursive \
        --no-parent \
        --timeout=${time_out} \
        --retry-connrefused \
        --tries=${retry_count} \
        --http-user=${http_user} \
        --http-passwd=${http_pass} \
        --directory-prefix=${temp_directory} \
        ${accesss_url}
done

# ------------------------------------------------------------------------------
# mp4ファイルリスト作成
# ------------------------------------------------------------------------------
find -s ${temp_directory}/${host_name}/${atom_dirctory} \
    -type f -name "*.mp4" | perl -pe 's/^/file /g' > ${atomcam_directory}/${target_curr_date}/${file_movlist}

mov_count=`cat ${atomcam_directory}/${target_curr_date}/${file_movlist} | wc -l`
echo "□"
echo "□　${mov_count}個の動画をダウンロードしました"
echo "□"

# ------------------------------------------------------------------------------
# detect-meteor
# ------------------------------------------------------------------------------
echo "□"
echo "□　流星検出を開始します"
echo "□　- 入力ディレクトリ：${temp_directory}/${host_name}/${atom_dirctory}"
echo "□　- 出力ディレクトリ：${atomcam_directory}/${target_curr_date}"
echo "□"
sleep 10

source ${meteor_detect_directory}/.venv/bin/activate
for target_hour in ${target_hour_list}
do
    # 対象日時を日付と時に分解
    date=`echo ${target_hour} | awk -F"/" '{print $1}'`
    hour=`echo ${target_hour} | awk -F"/" '{print $2}'`

    # meteor-detectを実行
    ${meteor_detect_atomcam} \
        -i ${temp_directory}/${host_name}/${atom_dirctory} \
        -o ${atomcam_directory}/${target_curr_date} \
        -d ${date} -h ${hour}
done
deactivate

# ------------------------------------------------------------------------------
# 比較明合成画像作成
# ------------------------------------------------------------------------------
echo "□"
echo "□　比較明合成画像を作成します"
echo "□　- 出力画像ファイル：${atomcam_directory}/${target_curr_date}/${file_lighten}"
echo "□"
sleep 10

target_files=`find -s ${atomcam_directory}/${target_curr_date} -type f -name "*.jpg" | grep -v ${file_lighten} | perl -pe 's/\n/ /g'`
convert -colorspace rgb -size 1920x1080 xc:black ${atomcam_directory}/${target_curr_date}/${file_lighten}
for target_file in ${target_files}
do
    convert ${atomcam_directory}/${target_curr_date}/${file_lighten} ${target_file} \
        -gravity center \
        -compose lighten \
        -composite \
        ${atomcam_directory}/${target_curr_date}/${file_lighten}
done

# ------------------------------------------------------------------------------
# 検出動画結合
# ------------------------------------------------------------------------------
echo "□"
echo "□　検出動画の連続動画を作成します"
echo "□"

# ffmpegの結合が相対パスでないと動作しないため移動
cd ${atomcam_directory}
find -s ${target_curr_date} -type f -name "*.mp4" | grep -v ${file_detected_mov} | perl -pe 's/^/file /g' > ${file_detect_list}

echo "□　- 出力動画リスト："
cat ${atomcam_directory}/${file_detect_list}
echo "□"

# 動画を結合する
ffmpeg -y -f concat \
    -i ${file_detect_list} \
    -c copy ${target_curr_date}/tmp_${file_detected_mov}
mv -f ${file_detect_list} ${target_curr_date}/

# 動画を変換する
ffmpeg -y -i ${target_curr_date}/tmp_${file_detected_mov} -f mp4 -vcodec libx264 ${target_curr_date}/${file_detected_mov}
rm -rf ${target_curr_date}/tmp_${file_detected_mov}

# ディレクトリを戻る
cd ${curr_directory}

echo "□　- 出力動画ファイル：${atomcam_directory}/${target_curr_date}/${file_detected_mov}"
echo "□"

# ------------------------------------------------------------------------------
# 終了メッセージ
# ------------------------------------------------------------------------------
until_timestamp=`date +"%Y-%m-%d %H:%M:%S"`
echo "□ 開始時刻\t${since_timestamp}"
echo "□ 終了時刻\t${until_timestamp}"
