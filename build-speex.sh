#!/bin/sh
# source : http://github.com/xiph/speex
# version : 1.2rc1

CONFIGURE_FLAGS="--enable-static --with-pic=yes --disable-shared"

ARCHS="arm64 armv7s x86_64 i386 armv7"

# directories
SOURCE="../speex"
FAT="pili-speex"
OGG=`pwd`/pili-ogg

SCRATCH="speex-scratch"
# must be an absolute path
THIN=`pwd`/"speex-thin"

COMPILE="y"
LIPO="y"

if [ "$*" ]
then
	if [ "$*" = "lipo" ]
	then
		# skip compile
		COMPILE=
	else
		ARCHS="$*"
		if [ $# -eq 1 ]
		then
			# skip lipo
			LIPO=
		fi
	fi
fi

if [ "$COMPILE" ]
then
	CWD=`pwd`
	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		CFLAGS="-arch $ARCH"

		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
		then
		    PLATFORM="iPhoneSimulator"
			CFLAGS="$CFLAGS -mios-simulator-version-min=6.0"
			HOST="--host=i386-apple-darwin"
		else
		    PLATFORM="iPhoneOS"
			CFLAGS="$CFLAGS -mios-version-min=6.0 -fembed-bitcode"
		    if [ $ARCH = arm64 ]
		    then
		        #CFLAGS="$CFLAGS -D__arm__ -D__ARM_ARCH_7EM__" # hack!
		        HOST="--host=aarch64-apple-darwin"
                    else
		        HOST="--host=arm-apple-darwin"
	            fi
		fi

		CFLAGS="$CFLAGS -I$OGG/include"
		LDFLAGS="$LDFLAGS -L$OGG/lib"

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"
		AS="$CWD/$SOURCE/extras/gas-preprocessor.pl $CC"

		echo "** CFLAGS=${CFLAGS}"
		echo "** LDFLAGS=${LDFLAGS}"
		
		$CWD/$SOURCE/configure \
		    $CONFIGURE_FLAGS \
		    $HOST \
		    CC="$CC" \
		    CXX="$CC" \
		    CPP="$CC -E" \
            AS="$AS" \
		    CFLAGS="$CFLAGS" \
		    LDFLAGS="$LDFLAGS" \
		    CPPFLAGS="$CFLAGS" \
			CXXFLAGS="$CFLAGS" \
		    --prefix="$THIN/$ARCH"

		make -j3 install || exit 1
		cd $CWD
	done
fi

if [ "$LIPO" ]
then
	echo "building fat binaries..."
	mkdir -p $FAT/lib
	set - $ARCHS
	CWD=`pwd`
	cd $THIN/$1/lib
	for LIB in *.a
	do
		cd $CWD
		lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB
	done

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi
