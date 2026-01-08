#!/usr/bin/bash

function show-usage {
    echo "USAGE:"
    echo "    probo.sh --track [-d DESCRIPTION] STATUS RUNFILE..."
    echo "    probo.sh --log RUNFILE..."
    echo "    probo.sh --ls"
    echo "    probo.sh --report [-c CONF_FILE]"
}

function generate-burndown-data-file-raw {
    local DAT_FILE="$1"
    local TODAY=$(date '+%Y-%m-%d')
    local REST1=$(find . -name '*.testcase.md' | wc -l)    # 基準線用残数
    local REST2=$REST1                                     # 実績用残数
    echo "日付	期待値	消化数	Fail数	基準線	実績" > "${DAT_FILE}"
    for LINE in ${PRUEBA_SCHEDULE}
    do
        local DATE=$(echo      "$LINE" | cut -d , -f 1)
        local ESTIMATED=$(echo "$LINE" | cut -d , -f 2)
        local COUNT=""
        local NGCNT=""
        REST1=$((REST1 - ESTIMATED))
        if [ "$TODAY" "<" "$DATE" ]; then
            REST2=""
        else
            COUNT=$(find . -name '*.testrun.md' | xargs grep "## ${DATE}-.*\.PASS" | wc -l)
            NGCNT=$(find . -name '*.testrun.md' | xargs grep "## ${DATE}-.*\.FAIL" | wc -l)
            REST2=$((REST2 - COUNT))
        fi
        echo "${DATE}	${ESTIMATED}	${COUNT}	${NGCNT}	${REST1}	${REST2}" >> "${DAT_FILE}"
    done
}

function generate-summary-data-file-raw {
    local OUT_FILE="$1"
    echo "GROUP	READY	BLOCK	RUN	OTHER	FAIL	PASS	TOTAL" > "${OUT_FILE}"
    for GROUP in ${PRUEBA_GROUPS}
    do
        pushd ${GROUP} > /dev/null
        COUNTS=(0 0 0 0 0 0 0)    # READY,BLOCK,RUN,OTHER,FAIL,PASS,TOTAL
        for RUN_FILE in $(ls *.testrun.md)
        do
            RESULT=$(grep '^## ....-..-..-' ${RUN_FILE} | tail -1 | cut -d. -f2)
            case "${RESULT}" in
                READY ) COUNTS[0]=$((COUNTS[0] + 1));;
                BLOCK ) COUNTS[1]=$((COUNTS[1] + 1));;
                RUN )   COUNTS[2]=$((COUNTS[2] + 1));;
                FAIL )  COUNTS[4]=$((COUNTS[4] + 1));;
                PASS )  COUNTS[5]=$((COUNTS[5] + 1));;
                * )     COUNTS[3]=$((COUNTS[3] + 1));;
            esac
            COUNTS[6]=$((COUNTS[6] + 1))
        done
        echo "${GROUP}	${COUNTS[0]}	${COUNTS[1]}	${COUNTS[2]}	${COUNTS[3]}	${COUNTS[4]}	${COUNTS[5]}	${COUNTS[6]}" >> ../"${OUT_FILE}"
        popd > /dev/null
    done
}

function generate-status-file-raw {
	local OUT_FILE="$1"
    echo "GROUP	CASE	TIMESTAMP	STATUS	DESRIPTION" > $OUT_FILE
    for GROUP in ${PRUEBA_GROUPS}
    do
        pushd ${GROUP} > /dev/null
        for RUN_FILE in $(ls *.testrun.md)
        do
            NUMBER=$(echo "$RUN_FILE" | cut -d. -f1)
            TAIL=$(grep '^## ....-..-..-' ${RUN_FILE} | tail -1)
            TIMESTAMP=$(echo ${TAIL:3} | cut -d. -f1 | perl -pe 's@^(....)-(..)-(..)-(..)-(..)@\1/\2/\3 \4:\5@')
            STATUS=$(echo ${TAIL} | cut -d. -f2)
            DESCRIPTION=$(echo ${TAIL} | cut -d. -f3)
            echo "${GROUP}	${NUMBER}	${TIMESTAMP}	${STATUS}	${DESCRIPTION}" >> ../$OUT_FILE
        done
        popd > /dev/null
    done
}

function get-image-type-from-filename {
    local IMG_TYPE="${1##*.}"    # 最後のピリオドまでを削除
    case "$IMG_TYPE" in
        svg )   ;;
        png )   ;;
        gif )   ;;
        jpeg )  ;;
        jpg )   IMG_TYPE="jpeg";;
        * )     IMG_TYPE="";;
    esac
    echo "$IMG_TYPE"
}

function make-burndown-gpfile {
    local OUT_FILE="$1"
    local DAT_FILE="$2"
    local IMG_TYPE="$3"    # svg|png|jpeg|gif
    local IMG_SIZE="$4"    # 'width,height'
    local TOP_Y1="$5"
    local TOP_Y2="$6"

    if [ "$IMG_TYPE" == "svg" ]; then
        echo "set terminal ${IMG_TYPE} size ${IMG_SIZE} fixed background rgb \"white\"" > ${OUT_FILE}
    else
        echo "set terminal ${IMG_TYPE} size ${IMG_SIZE} background rgb \"white\"" > ${OUT_FILE}
    fi
    
    cat >> "${OUT_FILE}" <<EOF
set datafile separator ","

# x軸が日付データであることを宣言
set xdata time
# 入力データの書式（例: 年/月/日）
set timefmt "%Y-%m-%d"
# グラフ軸の表示書式（例: 月/日）
set format x "%m/%d"

set yrange [0:${TOP_Y1}]

# 第2軸（y2軸）のメモリを表示するように設定
set ytics nomirror
set y2tics
set grid
set y2range [0:${TOP_Y2}]

# 棒グラフの幅を調整（任意）
set boxwidth 0.2 relative
set style fill solid 0.75

# 描画の実行
plot "${DAT_FILE}" using 1:2 with linespoints pt 5 ps 0.5 linecolor rgb "gray" title "GuideLine", \\
     "${DAT_FILE}" using 1:3 with linespoints pt 7 ps 0.5 linecolor rgb "blue" title "Pass", \\
     "${DAT_FILE}" using 1:4 with boxes       axes x1y2   linecolor rgb "red"  title "Fail"
EOF
}

function make-burndown-image {
    local DAT_FILE="$1"
    local OUT_FILE="$2"
    local IMG_TYPE="$3"
    local IMG_W="$4"
    local IMG_H="$5"
    # DAT_FILE を走査して TOP_Y1/TOP_Y2 を割り出す
    local TOP_Y1=$(cat $DAT_FILE | cut -d, -f2 | sort -g | tail -1)    # line graph
    local TOP_Y2=$(cat $DAT_FILE | cut -d, -f4 | sort -g | tail -1)    # Fail
    TOP_Y1=$((TOP_Y1 + 10))
    TOP_Y2=$((TOP_Y2 * 10))
    # gnuplot 設定ファイルを作成
    make-burndown-gpfile "$$.tmp.gp" "$DAT_FILE" ${IMG_TYPE} "$IMG_W,$IMG_H" $TOP_Y1 $TOP_Y2
    gnuplot "$$.tmp.gp" > "${OUT_FILE}"
    rm -f "$$.tmp.gp"
}

function make-summary-gpfile {
    local OUT_FILE="$1"
    local DAT_FILE="$2"
    local IMG_TYPE="$3"    # svg|png|jpeg|gif
    local IMG_SIZE="$4"    # 'width,height'

    if [ "$IMG_TYPE" == "svg" ]; then
        echo "set terminal ${IMG_TYPE} size ${IMG_SIZE} fixed background rgb \"white\"" > ${OUT_FILE}
    else
        echo "set terminal ${IMG_TYPE} size ${IMG_SIZE} background rgb \"white\"" > ${OUT_FILE}
    fi
    
    cat >> "${OUT_FILE}" <<EOF
set datafile separator ","

# 角度を「度」に設定
set angles degrees

# グラフを正方形にする（円が楕円にならないようにする）
set size ratio -1

# 塗りつぶしの設定
set style fill solid 1.0 border lt -1
#set style fill solid 1.0 noborder

# 軸や目盛りを非表示にする（任意）
unset tics
unset border

# ラベルを表示する位置の半径（外半径が1の場合、0.7くらいが適当）
r_label = 0.7

set lt 1 lc rgb "gray"
set lt 2 lc rgb "purple"
set lt 3 lc rgb "#98FB98"
set lt 4 lc rgb "pink"
set lt 5 lc rgb "blue"
set lt 6 lc rgb "cyan"

set yrange [-1.1:1.1]
set xrange [-1.1:1.1]  # x軸も同様に広げるとバランスが良くなります

# 画像の右下（完全に端）に配置
set key outside bottom right

# 描画の実行
# using 1:2:3:4:5:6 は (x:y:radius:begin:end:color) に対応
plot "${DAT_FILE}" using 1:2:3:4:5:6 with circles lc variable notitle, \\
     keyentry with boxes lt 1 title "READY", \\
     keyentry with boxes lt 2 title "BLOCK", \\
     keyentry with boxes lt 3 title "OTHER", \\
     keyentry with boxes lt 4 title "FAIL", \\
     keyentry with boxes lt 5 title "RUN", \\
     keyentry with boxes lt 6 title "PASS", \\
     "${DAT_FILE}" using \\
     (\$1 + r_label * cos((\$4+\$5)/2.0)) : \\
     (\$2 + r_label * sin((\$4+\$5)/2.0)) : \\
     (stringcolumn(7)) with labels center font ",12" tc rgb "black" notitle
EOF
}

function ins-pt {
    local NUM="$1"
    if [ "${#NUM}" -eq 1 ]; then
        echo "0.$NUM"
    else
        echo "${NUM%?}.${NUM#${NUM%?}}"
    fi
}

function make-summary-image {
    local OUT_FILE="$1"
    local IMG_TYPE="$2"
    local IMG_W="$3"
    local IMG_H="$4"
    local CASES=("$5" "$6" "$7" "$8" "$9" "${10}") # READY,BLOCK,OTHER,FAIL,RUN,PASS

    local N_TOTAL=$((CASES[0] + CASES[1] + CASES[2] + CASES[3] + CASES[4] + CASES[5]))
    local DEG1=0

    echo "# 中心X  中心Y  半径  開始角  終了角  色番号  表示する値" >  "$$.tmp.dat"
    for ((i=0; i<6; i++)) do
        local DEGREE=$((CASES[i] * 3600 / N_TOTAL))
        if [ "${CASES[i]}" -ne 0 ]; then
            local DEG2=$((DEG1 + DEGREE))
            echo "0,0,1,$(ins-pt ${DEG1}),$(ins-pt ${DEG2}),$((i + 1)),${CASES[i]}" >> "$$.tmp.dat"
            DEG1=${DEG2}
        fi
    done

    # gnuplot 設定ファイルを作成
    make-summary-gpfile "$$.tmp.gp" "$$.tmp.dat" ${IMG_TYPE} "$IMG_W,$IMG_H"
    gnuplot "$$.tmp.gp" > "${OUT_FILE}"
    rm -f "$$.tmp.gp"
    rm -f "$$.tmp.dat"
}

function graph-summary {
    local OUT_FILE="$1"
    COUNTS=(0 0 0 0 0 0)    # READY,BLOCK,FAIL,RUN,PASS,OTHER
    for GROUP in ${PRUEBA_GROUPS}
    do
        pushd ${GROUP} > /dev/null
        for RUN_FILE in $(ls *.testrun.md)
        do
            RESULT=$(grep '^## ....-..-..-' ${RUN_FILE} | tail -1 | cut -d. -f2)
            case "${RESULT}" in
                READY ) COUNTS[0]=$((COUNTS[0] + 1));;
                BLOCK ) COUNTS[1]=$((COUNTS[1] + 1));;
                FAIL )  COUNTS[2]=$((COUNTS[2] + 1));;
                RUN )   COUNTS[3]=$((COUNTS[3] + 1));;
                PASS )  COUNTS[4]=$((COUNTS[4] + 1));;
                * )     COUNTS[5]=$((COUNTS[5] + 1));;
            esac
        done
        popd > /dev/null
    done
    IMG_TYPE=$(get-image-type-from-filename "$OUT_FILE")
    make-summary-image "$OUT_FILE" $IMG_TYPE $SUMGRAPH_WIDTH $SUMGRAPH_HEIGHT \
                       ${COUNTS[0]} ${COUNTS[1]} ${COUNTS[5]} ${COUNTS[2]} ${COUNTS[3]} ${COUNTS[4]}
    rm -f ${DAT_FILE}
}

function graph-burndown {
    # ToDo : generate-burndown-data-file-raw を利用するかたちにできそう
    local IMG_FILE="$1"
    local DAT_FILE="$$.burndown.dat"
    local TODAY=$(date '+%Y-%m-%d')
    local REST1=$(find . -name '*.testcase.md' | wc -l)    # 基準線用残数
    local REST2=$REST1                                     # 実績用残数
    for LINE in ${PRUEBA_SCHEDULE}
    do
        local DATE=$(echo      "$LINE" | cut -d , -f 1)
        local ESTIMATED=$(echo "$LINE" | cut -d , -f 2)
        local COUNT=""
        local NGCNT=""
        REST1=$((REST1 - ESTIMATED))
        if [ "$TODAY" "<" "$DATE" ]; then
            REST2=""
        else
            COUNT=$(find . -name '*.testrun.md' | xargs grep "## ${DATE}-.*\.PASS" | wc -l)
            NGCNT=$(find . -name '*.testrun.md' | xargs grep "## ${DATE}-.*\.FAIL" | wc -l)
            REST2=$((REST2 - COUNT))
        fi
        echo "${DATE},${REST1},${REST2},${NGCNT}" >> ${DAT_FILE}
    done
    IMG_TYPE=$(get-image-type-from-filename "$IMG_FILE")
    make-burndown-image "$DAT_FILE" "$IMG_FILE" $IMG_TYPE $BDCHART_WIDTH $BDCHART_HEIGHT
    rm -f ${DAT_FILE}
}

function track-runfile {

    # -d オプションの回収（あれば）
    local DESCRIPTION=""
    while getopts "d:" opt; do
        case $opt in
            d) DESCRIPTION=${OPTARG} ;;
            *) echo "ERROR : invalid option."
               return 1;;
        esac
    done
    shift $((OPTIND - 1))

    # STATUS パラメータの回収とチェック
    local STATUS="$1"
    shift
    case $STATUS in
        READY) ;;
        BLOCK) ;;
        PASS)  ;;
        FAIL)  ;;
        RUN)   ;;
        *) echo "ERROR : invalid status \"$STATUS\"."
           return 1;;
    esac

    # 追加する行の生成
    if [ ! -z "$DESCRIPTION" ]; then
        DESCRIPTION=".$DESCRIPTION"
    fi
    local TIMESTAMP=$(date '+%Y-%m-%d-%H-%M')
    local NEW_LINE="## ${TIMESTAMP}.${STATUS}${DESCRIPTION}"

    # 対象ファイルの反復と処理
    local FILE_COUNT=0
    for RUN_FILE in $@
    do
        if [ ! -e "$RUN_FILE" ]; then
            echo "ERROR : runfile $RUN_FILE is not found."
        else
            echo ""          >> "$RUN_FILE"
            echo ""          >> "$RUN_FILE"
            echo "$NEW_LINE" >> "$RUN_FILE"
            echo ""          >> "$RUN_FILE"
            FILE_COUNT=$((FILE_COUNT + 1))
        fi
    done
    echo "$FILE_COUNT file(s) updated."
}

function dump-runfile-log {
    for RUN_FILE in $@
    do
        if [ ! -e "$RUN_FILE" ]; then
            echo "ERROR : runfile $RUN_FILE is not found."
        else
            TEST_ID=$(echo "$RUN_FILE" | perl -pe 's/^(.+?)\.testrun\.md$/\1/')
            while IFS= read -r LINE; do
                TIMESTAMP=$(  echo "${LINE:3}" | cut -d. -f1)
                STATUS=$(     echo "${LINE:3}" | cut -d. -f2)
                DESCRIPTION=$(echo "${LINE:3}" | cut -d. -f3)
                echo "${TEST_ID}	${TIMESTAMP}	${STATUS}	${DESCRIPTION}"
            done < <(grep -E '^## ....-..-..-..-..\..+' "$RUN_FILE" )
        fi
    done
}

function dump-current-group-status {
    echo "CASE	TIMESTAMP	STATUS	DESRIPTION"
    for RUN_FILE in $(ls *.testrun.md)
    do
        NUMBER=$(echo "$RUN_FILE" | cut -d. -f1)
        TAIL=$(grep '^## ....-..-..-' ${RUN_FILE} | tail -1)
        TIMESTAMP=$(echo ${TAIL:3} | cut -d. -f1 | perl -pe 's@^(....)-(..)-(..)-(..)-(..)@\1/\2/\3 \4:\5@')
        STATUS=$(     echo ${TAIL} | cut -d. -f2)
        DESCRIPTION=$(echo ${TAIL} | cut -d. -f3)
        echo "${NUMBER}	${TIMESTAMP}	${STATUS}	${DESCRIPTION}"
    done
}

function generate-report-files-raw {

    GNUPLOT_FLAG="$1"

    if [ ! -z "${STATUS_FULL_FILENAME}" ]; then
        generate-status-file-raw "${STATUS_FULL_FILENAME}"
        if [ ! -z "${STATUS_PICKUP_FILENAME}" ]; then
            cat "${STATUS_FULL_FILENAME}" | grep -v '	PASS	' \
                                          | grep -v '	READY	' >  "${STATUS_PICKUP_FILENAME}"
        fi
    fi

    if [ ! -z "${BDDATA_FILENAME}" ]; then
        generate-burndown-data-file-raw "${BDDATA_FILENAME}"
    fi

    if [ ! -z "${SUMDATA_FILENAME}" ]; then
        generate-summary-data-file-raw "${SUMDATA_FILENAME}"
    fi

	# gnuplot が利用可能な場合のみグラフ生成（エラーにはしない）
    if [ $GNUPLOT_FLAG -eq 1 ]; then
    	# さらに、グラフファイル名が指定されている場合のみ実行（つまり省略可能）
        if [ ! -z "$BDCHART_FILENAME" ]; then
            graph-burndown "$BDCHART_FILENAME"
        fi
        if [ ! -z "$SUMGRAPH_FILENAME" ]; then
            graph-summary "$SUMGRAPH_FILENAME"
        fi

    fi
	return 0
}

function generate-report-files-markdown {

	# gnuplot がなければエラー
    if [ $1 -eq 0 ]; then
        echo "ERROR : gnuplot is missing."
        return 1
    fi

	# ToDo : implement...

    graph-burndown "$BDCHART_FILENAME"
    graph-summary  "$SUMGRAPH_FILENAME"
	return 0
}

MODE="$1"
shift

# conf ファイルが不要な処理
if [ "$MODE" == "--track" ]; then
    track-runfile $@
    exit 0
elif [ "$MODE" == "--log" ]; then
    dump-runfile-log $@
    exit 0
elif [ "$MODE" == "--ls" ]; then
    dump-current-group-status
    exit 0
fi



CONF_FILE="./probo.conf"

# -c オプションの回収（あれば）
while getopts "c:" opt; do
    case $opt in
        c) CONF_FILE=${OPTARG} ;;
        *) echo "ERROR : invalid option."
           return 1;;
    esac
done
shift $((OPTIND - 1))

# カレントディレクトリに conf file がなければエラー終了
if [ ! -e "$CONF_FILE" ]; then
    echo "ERROR : $CONF_FILE missing."
    exit 1
fi

source "$CONF_FILE"

if [ "$MODE" == "--report" ]; then
    case "${REPORT_TARGET}" in
        raw)      ;;
        markdown) ;;
        *) echo "ERROR : invalid REPORT_TARGET variable."
           return 1;;
    esac
    generate-report-files-${REPORT_TARGET} $(which gnuplot | wc -l)
else
    show-usage
    exit 1
fi

