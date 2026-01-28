#!/usr/bin/bash

MODE=$1
IN=$2
OUT=$3
SUFFIX=$4
CACHE=.cache

function filter-attach {
    rm -f ./${CACHE}/${OUT}.${SUFFIX}
    for FILE_NAME in `cat "${IN}"`
    do
        local TYPE=`echo "${FILE_NAME}" | perl -pe "s/^.+\.(.+)$/\1/"`
        echo -n "<li><a href=\"data:application/${TYPE};base64,"  >> ./${CACHE}/${OUT}.${SUFFIX}
        cat "${FILE_NAME}" | base64                               >> ./${CACHE}/${OUT}.${SUFFIX}
        echo "\" download=\"${FILE_NAME}\">${FILE_NAME}</a></li>" >> ./${CACHE}/${OUT}.${SUFFIX}
    done
}
function filter-embed_img {
    local FILE=`cat "${IN}"`
    local TYPE=`echo ${FILE} | perl -pe "s/^.+\.(.+)$/\1/"`
    echo -n "<img src='data:image/${TYPE};base64," > ./${CACHE}/${OUT}.${SUFFIX}
    base64 ${FILE} >> ./${CACHE}/${OUT}.${SUFFIX}
    echo "' />"  >> ./${CACHE}/${OUT}.${SUFFIX}
}
function filter-gnuplot {
    local LINENUM=`grep -n '^-\+$' ${IN} | perl -pe 's/^(\d):-+$/\1/'`
    local LINECNT=`cat ${IN} | wc -l`
    if [ ! -z "${LINENUM}" ]; then
        echo "in_file=\"${IN}.dat\"" > ${IN}.gp
        echo "out_file=\"./${CACHE}/${OUT}.svg\"" >> ${IN}.gp
        head -$((LINENUM - 1)) ${IN} >> ${IN}.gp
        tail -$((LINECNT - LINENUM)) $IN > ${IN}.dat
        gnuplot ${IN}.gp
        rm ${IN}.gp
        rm ${IN}.dat
    fi
}
function filter-kaavio {
    kaavio ${IN} > ./${CACHE}/${OUT}.${SUFFIX}
}
function filter-plantuml {
    local JAR=C:\\Users\\JXAOY32C\\bin\\plantuml-1.2025.4.jar
    local OPT=-Dfile.encoding=UTF-8
    local CFG=
    #local CFG=-config uml.theme
    cat ${IN} | java ${OPT} -jar ${JAR} ${CFG} -pipe -tsvg >> ./${CACHE}/${OUT}.${SUFFIX}
}

function epilogue-div-center {
    echo "<div align='center'>"      > ./${OUT}
    cat ./${CACHE}/${OUT}.${SUFFIX} >> ./${OUT}
    echo "</div>"                   >> ./${OUT}
}
function epilogue-list {
    echo "<ul>"                     >  ./${OUT}
    cat ./${CACHE}/${OUT}.${SUFFIX} >> ./${OUT}
    echo "</ul>"                    >> ./${OUT}
}

if [ ! -e ./${CACHE} ]; then
    mkdir ${CACHE}
fi

if [ -e ./${CACHE}/${OUT}.${SUFFIX} ]; then
    touch ./${CACHE}/${OUT}.${SUFFIX}
else
    filter-${MODE}
fi

case "${MODE}" in
    attach )    epilogue-list;;
    embed_img ) epilogue-div-center;;
    gnuplot )   epilogue-div-center;;
    kaavio )    epilogue-div-center;;
    plantuml )  epilogue-div-center;;
esac
