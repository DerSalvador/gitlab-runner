#!/bin/bash
shopt -u extglob; set +H
[ -z "$1" ] && echo "Usage: $(basename $0) namespace serviceaccount" && oc get projects && exit 1
NS=$1
[ -z "$2" ] && echo "Usage: $(basename $0) namespace serviceaccount" && oc get sa -n $NS && exit 1

for s in `oc get sa $2 -n $1 -o jsonpath='{range .secrets[*]} {.name} {end}'`; do 
	echo $s >&2; 
	echo oc get secret $s -n $NS -o json >&2
	RET=`oc get secret $s -n $NS -o json`
        echo RET=$? >&2
	if [ $? == 0 ]; then
		echo oc get secret $s -n $NS -o jsonpath='{.data.token}' >&2
		TOK=`oc get secret $s -n $NS -o jsonpath='{.data.token}'` 
		if [ ! -z "$TOK" ]; then
		   echo $TO >&2K
		   echo "------ Base64 decoded for use as secret token $s, for example in oc login" >&2
		   echo $TOK|base64 -D >&1
		fi
	fi
done

