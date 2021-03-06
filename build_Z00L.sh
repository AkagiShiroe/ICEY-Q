BUILD_START=$(date +"%s");

# Colours
blue='\033[0;34m';
cyan='\033[0;36m';
yellow='\033[0;33m';
red='\033[0;31m';
nocol='\033[0m';

# Kernel details;
KERNEL_NAME="ICEY-Q";
VERSION="1.0a";
DATE=$(date +"%d-%m-%Y-%I-%M");
DEVICE="Z00L";
OUT="msm8916";
FINAL_ZIP=$KERNEL_NAME-$VERSION-$DATE-$DEVICE.zip;

# Dirs
ANYKERNEL_DIR=$TRAVIS_BUILD_DIR/AnyKernel3;
KERNEL_IMG=$TRAVIS_BUILD_DIR/arch/arm64/boot/Image.gz-dtb;
UPLOAD_DIR=$TRAVIS_BUILD_DIR/$OUT;

git clone https://github.com/milouk/gcc-prebuilt-elf-toolchains.git -b master --single-branch --depth=1 -4 aarch64-milouk-elf -j$(nproc --all);
export CROSS_COMPILE="/usr/bin/ccache ./aarch64-milouk-elf/aarch64-milouk-elf/bin/aarch64-milouk-elf-" ;
export ARCH=arm64;
export SUBARCH=arm;
export KBUILD_BUILD_USER="Akanerin";
export KBUILD_BUILD_HOST="Tsurara";
STRIP="aarch64-milouk-elf/aarch64-milouk-elf/bin/aarch64-milouk-elf-strip";
export CCOMPILE=$CROSS_COMPILE;
export PATH=$PATH:./aarch64-milouk-elf/aarch64-milouk-elf/bin/ ;
make Z00L_defconfig;
make -j$(nproc --all);
mkdir -p tmp_mod;
make -j4 modules_install INSTALL_MOD_PATH=tmp_mod INSTALL_MOD_STRIP=1;
find tmp_mod/ -name '*.ko' -type f -exec cp '{}' $ANYKERNEL_DIR/modules/system/lib/modules/ \;
cp $KERNEL_IMG $ANYKERNEL_DIR;
mkdir -p $UPLOAD_DIR;
cd $ANYKERNEL_DIR;
zip -r9 UPDATE-AnyKernel3.zip * -x README UPDATE-AnyKernel2.zip;
mv $ANYKERNEL_DIR/UPDATE-AnyKernel3.zip $UPLOAD_DIR/$FINAL_ZIP;

# Cleanup
rm $ANYKERNEL_DIR/Image.gz-dtb;

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol";
