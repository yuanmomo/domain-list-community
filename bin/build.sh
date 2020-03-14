#!/usr/bin/env bash

current_dir=$(cd "$(dirname "$0")";pwd)
root_dir=${current_dir}/..
repo_url="github.com/yuanmomo/domain-list-community"
speedtest_xml=${current_dir}/servers-source.xml

if [[ ! $(command -v ${current_dir}/domain-list-community) ]] ; then
    echo "go build domain-list-community command ....."

    export GO111MODULE=on
    cd ${root_dir}
    go build -o ${current_dir}/domain-list-community main.go
fi

# link file to $GOPATH
if [[ ! -e "${GOPATH}/src/${repo_url}" ]] ; then
    ln -s -f "${root_dir}" "${GOPATH}"/src/${repo_url}
fi

echo "downloading speedtest file ....."
curl -L -o "${speedtest_xml}" "https://c.speedtest.net/speedtest-servers-static.php" -H 'Accept-Encoding: gzip' --compressed
perl -ne '/host="(.+):[0-9]+"/ && print "full:$1\n"' "${speedtest_xml}" | perl -ne 'print if not /^(full:([0-9]{1,3}\.){3}[0-9]{1,3})$/' | perl -ne 'print lc' | sort --ignore-case -u >> "${GOPATH}"/src/${repo_url}/data/ookla-speedtest

# exec
echo "exec  domain-list-community command ....."
"${current_dir}"/domain-list-community

echo "move dlc.dat to v2ray bin dir....."
chmod -x "${root_dir}"/dlc.dat
mv "${root_dir}"/dlc.dat ${root_dir}/publish/geosite.dat

echo "reset files....."
git checkout HEAD -- ${root_dir}/data/ookla-speedtest
rm -f "${speedtest_xml}"
