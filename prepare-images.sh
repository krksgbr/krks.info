set -euo pipefail
IFS=$'\n\t'

widths=(640 768 1024 1366 1600 1920)

contentDir=${1:-content}
srcDir="$contentDir/raw-images"
targetDir="$contentDir/images"

rm -rf $targetDir
mkdir -p $targetDir

for srcImg in $srcDir/*; do
  for width in ${widths[@]}; do
    basename=`basename $srcImg`
    filename=${basename%.*}
    target="$targetDir/$width-$filename.jpg"
    echo "$srcImg -> $target"
    convert -strip -interlace Plane $srcImg -resize "$width" $target
  done
done
