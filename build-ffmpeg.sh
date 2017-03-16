#!/bin/sh
# source : http://github.com:pili-engineering/pili-ffmpeg.git
# version : n3.1-dev-1420-g6f1dd1f

# directories
SOURCE="../pili-ffmpeg"
FAT="pili-ffmpeg"

SCRATCH="ffmpeg-scratch"
# must be an absolute path
THIN=`pwd`/"ffmpeg-thin"

# absolute path to x264 library
#X264=`pwd`/fat-x264

#FDK_AAC=`pwd`/pili-fdk-aac

#LIB_VPX=`pwd`/pili-libvpx

SPEEX=`pwd`/pili-speex

OPENSSL=`pwd`/pili-openssl

CONFIGURE_FLAGS="--enable-cross-compile \
				 --disable-debug \
				 --disable-programs \
				 --disable-doc \
				 --disable-avdevice \
				 --disable-avfilter \
				 --disable-swscale \
				 --disable-everything \
				 --enable-nonfree \
				 --enable-avformat \
				 --enable-swresample \
				 --enable-decoder=mpeg4 \
				 --enable-decoder=h264 \
				 --enable-decoder=hevc \
				 --enable-decoder=vp8 \
				 --enable-decoder=vp9 \
				 --enable-decoder=aac \
				 --enable-decoder=mp3* \
				 --enable-decoder=opus \
				 --enable-decoder=vorbis \
				 --enable-decoder=nellymoser \
				 --enable-decoder=rv20 \
				 --enable-decoder=rv40 \
				 --enable-decoder=cook \
				 --enable-decoder=srt \
				 --enable-decoder=ass \
				 --enable-demuxer=h264 \
				 --enable-demuxer=matroska \
				 --enable-demuxer=aac \
				 --enable-demuxer=flv \
				 --enable-demuxer=mpegts \
				 --enable-demuxer=hls \
				 --enable-demuxer=mp3 \
				 --enable-demuxer=mov \
				 --enable-demuxer=avi \
				 --enable-demuxer=m4v \
				 --enable-demuxer=rm \
				 --enable-demuxer=asf \
				 --enable-demuxer=ogg \
				 --enable-demuxer=wav \
				 --enable-demuxer=srt \
				 --enable-demuxer=ass \
				 --enable-parser=h264 \
				 --enable-parser=hevc \
				 --enable-parser=vp8 \
				 --enable-parser=vp9 \
				 --enable-parser=rv40 \
				 --enable-parser=aac \
				 --enable-parser=opus \
				 --enable-parser=vorbis \
				 --enable-protocol=http \
				 --enable-protocol=https \
				 --enable-protocol=rtmp \
				 --enable-protocol=hls \
				 --enable-protocol=file \
				 --enable-protocol=cache "

if [ "$X264" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl --enable-libx264"
fi

if [ "$FDK_AAC" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk-aac --enable-decoder=libfdk_aac"
fi

if [ "$LIB_VPX" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libvpx \
					--enable-decoder=libvpx_vp8 \
					--enable-decoder=libvpx_vp9"
fi

if [ "$SPEEX" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libspeex --enable-decoder=libspeex"
	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$SPEEX/lib/pkgconfig/"
fi

if [ "$OPENSSL" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-openssl --enable-protocol=tls_openssl"
	export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$OPENSSL/lib/pkgconfig/"
fi

# avresample
#CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-avresample"

ARCHS="armv7 armv7s arm64 x86_64 i386"

COMPILE="y"
LIPO="y"

DEPLOYMENT_TARGET="6.0"

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
	if [ ! `which yasm` ]
	then
		echo 'Yasm not found'
		if [ ! `which brew` ]
		then
			echo 'Homebrew not found. Trying to install...'
                        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
				|| exit 1
		fi
		echo 'Trying to install Yasm...'
		brew install yasm || exit 1
	fi
	if [ ! `which gas-preprocessor.pl` ]
	then
		echo 'gas-preprocessor.pl not found. Trying to install...'
		(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
			-o /usr/local/bin/gas-preprocessor.pl \
			&& chmod +x /usr/local/bin/gas-preprocessor.pl) \
			|| exit 1
	fi

	if [ ! -r $SOURCE ]
	then
		echo 'FFmpeg source not found. Trying to download...'
		curl http://www.ffmpeg.org/releases/$SOURCE.tar.bz2 | tar xj \
			|| exit 1
	fi

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
		    CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
		else
		    PLATFORM="iPhoneOS"
		    CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
		    if [ "$ARCH" = "arm64" ]
		    then
		        EXPORT="GASPP_FIX_XCODE5=1"
		    fi
		fi

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"
		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"
		if [ "$X264" ]
		then
			CFLAGS="$CFLAGS -I$X264/include"
			LDFLAGS="$LDFLAGS -L$X264/lib"
		fi
		if [ "$FDK_AAC" ]
		then
			CFLAGS="$CFLAGS -I$FDK_AAC/include"
			LDFLAGS="$LDFLAGS -L$FDK_AAC/lib"
		fi
		if [ "$LIB_VPX" ]
		then
			CFLAGS="$CFLAGS -I$LIB_VPX/include"
			LDFLAGS="$LDFLAGS -L$LIB_VPX/lib"
		fi
		if [ "$SPEEX" ]
		then
			CFLAGS="$CFLAGS -I$SPEEX/include"
			LDFLAGS="$LDFLAGS -L$SPEEX/lib"
		fi
		if [ "$OPENSSL" ]
		then
			CFLAGS="$CFLAGS -I$OPENSSL/include"
			LDFLAGS="$LDFLAGS -L$OPENSSL/lib -lssl -lcrypto"
		fi
		
		echo "** CFLAGS=${CFLAGS}"
		echo "** LDFLAGS=${LDFLAGS}"

		TMPDIR=${TMPDIR/%\/} $CWD/$SOURCE/configure \
		    --target-os=darwin \
		    --arch=$ARCH \
		    --cc="$CC" \
		    $CONFIGURE_FLAGS \
		    --extra-cflags="$CFLAGS" \
		    --extra-ldflags="$LDFLAGS" \
		    --prefix="$THIN/$ARCH" \
		|| exit 1

		make -j10 install $EXPORT || exit 1
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
		echo lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB 1>&2
		lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB || exit 1
	done

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

echo Done
