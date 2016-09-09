#!/bin/bash
# simple bash script for generating dtb image

# root directory of Samsung msm8996 kernel git repo (default is this script's location)
RDIR=$(pwd)

# directory containing cross-compile arm64 toolchain
TOOLCHAIN=$HOME/build/toolchain/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu

# device dependant variables
PAGE_SIZE=4096
DTB_PADDING=0

export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-linux-gnu-

BDIR=$RDIR/build
OUTDIR=$BDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts/samsung
DTBDIR=$OUTDIR/dtb
DTCTOOL=$BDIR/scripts/dtc/dtc

ABORT()
{
	[ "$1" ] && echo "Error: $*"
	exit 1
}

[ -x "$DTCTOOL" ] || ABORT "You need to run ./build.sh first!"

[ -x "${CROSS_COMPILE}gcc" ] ||
ABORT "Unable to find gcc cross-compiler at location: ${CROSS_COMPILE}gcc"

[ "$1" ] && DEVICE=$1
[ "$2" ] && VARIANT=$2

case $DEVICE in
graceqlte)
	case $VARIANT in
	chn|chnzc|zc)
		DTSFILES="msm8996-sec-graceqlte-chn-r02 msm8996-sec-graceqlte-chn-r03
				msm8996-sec-graceqlte-chn-r06 msm8996-sec-graceqlte-chn-r09"
		;;
	chnzh|zh)
		DTSFILES="msm8996-sec-graceqlte-chn-r02 msm8996-sec-graceqlte-chn-r03
				msm8996-sec-graceqlte-chn-r06 msm8996-sec-graceqlte-chnzh-r09"
		;;
	jpn|kdi|dcm)
		DTSFILES="msm8996-sec-graceqlte-jpn-r02 msm8996-sec-graceqlte-jpn-r03
				msm8996-sec-graceqlte-jpn-r06	msm8996-sec-graceqlte-jpn-r09"
		;;
	usa|can|bmc|acg|att|mtr|spr|tmo|usc|vzw)
		DTSFILES="msm8996-sec-graceqlte-r00 msm8996-sec-graceqlte-r01
				msm8996-sec-graceqlte-r02 msm8996-sec-graceqlte-r03
				msm8996-sec-graceqlte-r05 msm8996-sec-graceqlte-r06
				msm8996-sec-graceqlte-r08 msm8996-sec-graceqlte-r09"
	;;
	*) ABORT "Unknown variant of $DEVICE: $VARIANT" ;;
	esac
	;;
heroqlte)
	case $VARIANT in
	chn|chnzc|chnzh|zc|zh)
		DTSFILES="msm8996-sec-heroqlte-r00 msm8996-sec-heroqlte-r01
				msm8996-sec-heroqlte-r02 msm8996-sec-heroqlte-r03
				msm8996-sec-heroqlte-chn-r05 msm8996-sec-heroqlte-chn-r06
				msm8996-sec-heroqlte-chn-r07 msm8996-sec-heroqlte-chn-r08
				msm8996-sec-heroq-r09 msm8996-sec-heroq-r09-v3
				msm8996-sec-heroqlte-chn-r10 msm8996-sec-heroqlte-chn-r11
				msm8996-sec-heroqlte-chn-r13 msm8996-sec-heroqlte-chn-r15"
		;;
	jpn|kdi|dcm)
		DTSFILES="msm8996-sec-heroqlte-jpn-r00 msm8996-sec-heroqlte-jpn-r01
				msm8996-sec-heroqlte-jpn-r05 msm8996-sec-heroqlte-jpn-r06
				msm8996-sec-heroqlte-jpn-r07 msm8996-sec-heroqlte-jpn-r08
				msm8996-sec-heroqlte-jpn-r10 msm8996-sec-heroqlte-jpn-r11
				msm8996-sec-heroqlte-jpn-r13 msm8996-sec-heroqlte-jpn-r15"
		;;
	usa|acg|att|mtr|spr|tmo|usc|vzw)
		DTSFILES="msm8996-sec-heroqlte-r00 msm8996-sec-heroqlte-r01
				msm8996-sec-heroqlte-r02 msm8996-sec-heroqlte-r03
				msm8996-sec-heroqlte-r05 msm8996-sec-heroqlte-r06
				msm8996-sec-heroqlte-r07 msm8996-sec-heroqlte-r08
				msm8996-sec-heroq-r09 msm8996-sec-heroq-r09-v3
				msm8996-sec-heroqlte-r10 msm8996-sec-heroqlte-r11
				msm8996-sec-heroqlte-r13 msm8996-sec-heroqlte-r15"
	;;
	*) ABORT "Unknown variant of $DEVICE: $VARIANT" ;;
	esac
	;;
hero2qlte)
	case $VARIANT in
	chn|chnzc|chnzh|zc|zh)
		DTSFILES="msm8996-sec-hero2qlte-r00 msm8996-sec-hero2qlte-r01
				msm8996-sec-hero2qlte-r02 msm8996-sec-hero2qlte-r03
				msm8996-sec-hero2qlte-chn-r05 msm8996-sec-hero2qlte-chn-r06
				msm8996-sec-hero2qlte-chn-r07 msm8996-sec-hero2qlte-chn-r08
				msm8996-sec-heroq-r09 msm8996-sec-heroq-r09-v3
				msm8996-sec-hero2qlte-chn-r10 msm8996-sec-hero2qlte-chn-r11
				msm8996-sec-hero2qlte-chn-r13 msm8996-sec-hero2qlte-chn-r15"
		;;
	jpn|kdi|dcm)
		DTSFILES="msm8996-sec-hero2qlte-jpn-r00 msm8996-sec-hero2qlte-jpn-r01
				msm8996-sec-hero2qlte-jpn-r05 msm8996-sec-hero2qlte-jpn-r06
				msm8996-sec-hero2qlte-jpn-r07 msm8996-sec-hero2qlte-jpn-r08
				msm8996-sec-hero2qlte-jpn-r10 msm8996-sec-hero2qlte-jpn-r11
				msm8996-sec-hero2qlte-jpn-r13 msm8996-sec-hero2qlte-jpn-r15"
		;;
	usa|acg|att|mtr|spr|tmo|usc|vzw)
		DTSFILES="msm8996-sec-hero2qlte-r00 msm8996-sec-hero2qlte-r01
				msm8996-sec-hero2qlte-r02 msm8996-sec-hero2qlte-r03
				msm8996-sec-hero2qlte-r05 msm8996-sec-hero2qlte-r06
				msm8996-sec-hero2qlte-r07 msm8996-sec-hero2qlte-r08
				msm8996-sec-heroq-r09 msm8996-sec-heroq-r09-v3
				msm8996-sec-hero2qlte-r10 msm8996-sec-hero2qlte-r11
				msm8996-sec-hero2qlte-r13 msm8996-sec-hero2qlte-r15"
	;;
	*) ABORT "Unknown variant of $DEVICE: $VARIANT" ;;
	esac
	;;
*) ABORT "Unknown device: $DEVICE" ;;
esac

mkdir -p "$OUTDIR" "$DTBDIR"

cd "$DTBDIR" || ABORT "Unable to cd to $DTBDIR!"

rm -f ./*

echo "Processing dts files..."

for dts in $DTSFILES; do
	echo "=> Processing: ${dts}.dts"
	"${CROSS_COMPILE}cpp" -nostdinc -undef -x assembler-with-cpp -I"$RDIR/include" -I"$DTSDIR/../" "$DTSDIR/${dts}.dts" > "${dts}.dts" || ABORT
	echo "=> Generating: ${dts}.dtb"
	$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
done

echo "Generating dtb.img..."
"$RDIR/scripts/dtbTool/dtbTool" -o "$OUTDIR/dtb.img" -s $PAGE_SIZE "$DTBDIR/" || ABORT

echo "Done."
