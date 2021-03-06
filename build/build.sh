#!/bin/bash
BARR="==================================================================================================="
Barr="---------------------------------------------------------------------------------------------------"
pstr="[==========================================]"

	## Recognize the Buil dir
	if [[ ! -d ./src ]] || [[ ! -d ./conf ]] || [[ ! -f main ]];then
		echo " - Build process needed the 'src','conf' dir with 'main' file"
		exit 1
	fi

Build ()
{
build_dir="$PWD"
src_org="$build_dir/main"
target_file="$build_dir/../zinst"

## All source scan
all_src=(`egrep 'source \.\/src' ./main | awk '{print $2}'`)
all_conf=(`egrep 'source \.\/conf' ./main | awk '{print $2}'`)

## Define Last line number
endline=`wc -l $src_org| awk '{print $1}'`

## Purge the old artifact
rm -f $target_file;touch $target_file

## Stamp a time for start
#beginTime=$(date +%s%N)
	## Start loop
	echo "$BARR"
	echo " Source code build..."
	echo "$Barr"
	count=1
	Cnt=0
	while [[ $count -le $endline ]];do	
		if [[ `(echo $(awk "NR == $count" $src_org |egrep 'source \.\/src'))` != "" ]] || [[ `(echo $(awk "NR == $count" $src_org |egrep 'source \.\/conf'))` != "" ]] ;then
			Exec=`echo $(awk "NR == $count" $src_org | sed -e 's/source /cat /g')`
			$Exec |sed '/\#\!\//d'  >> $target_file
			## Part of Progress bar
			All_count="$(( ${#all_src[@]} + ${#all_conf[@]} ))"
			pd=$(( $Cnt * 46 / $All_count ))
				if [[ $Cnt = ${#all_src[@]} ]];then
					Pkg_picklist=" - Source code Build has been finished -"
				else
					Pkg_picklist="${all_src[$Cnt]}"
				fi
			printf "\r%-2s %-40s %3s %3d.%1d%% %.${pd}s" '|' "$Pkg_picklist" '|' $(( $Cnt * 100 / ${#all_src[@]} )) $(( ($Cnt * 1000 / ${#all_src[@]}) % 10 )) $pstr
			let Cnt=$Cnt+1
		else
			awk "NR == $count" $src_org >> $target_file
		fi
	
	let count=$count+1
	done
## Line braker for Progress bar
echo ""
echo "$BARR"

## Permission change
chmod 755 $target_file
}

time Build 

echo "Artifact is here \"$target_file\""
## Print time for result
#endTime=$(date +%s%N)
#elapsed=`echo "($endTime - $beginTime) / 1000000" | bc`
#elapsedSec=`echo "scale=6;$elapsed / 1000" | bc | awk '{printf "%.6f", $1}'`
#echo TOTAL: $elapsedSec sec
