#!/bin/bash

bold=`tput bold`
unline="\033[0m"
#bold yellow underline
BYU="\033[3;33m\033[4m${bold}"
#return to normal font {deselect all}
NORM="\033[0m"
#bold yellow
BY="\033[3;33m${bold}"

#Local env:

ROOTDIR=/embedded/mini2440/projects/bluetooth/test
INSTDIR=${ROOTDIR}/Recipe
PKGDIR=${ROOTDIR}/pkg-build
LOG=${PKGDIR}/build.log

export INSTALL_DIR=${INSTDIR}
export PRE_FIX=/usr
export MY_SYSCONFDIR=/etc
export MY_LOCALSTATEDIR=/var

mkdir -p ${INSTDIR} ${PKGDIR}

${PEXP_MINI}      #exporting cross compile toolchain path

date >> ${LOG}

colored_echo () {
# 1. The arguments what you've passed to function can accessed form $1, $2, $3 so-on..
# 2. The arguments what you've passed while running the script form terminal are different if you want to access
#  them in side the funtion then only you shud pass them aslo to your function as an arguments.
echo -e ${BYU}"\n$1"${unline}${BY}" .."${NORM}

}

check_pkgsuccess () {

        if [ $1 -ne 1 ];
        then
                colored_echo $2": Package build failed";
        else
                colored_echo $2": Package build Sucess"
        fi
}

download_pkg () {

colored_echo "Downloading packages"
        echo -e "\nChecking/Downloading packages .." >> $LOG    &&
        if test -e ./down_obex
                then
                cp ./down_obex ${PKGDIR}     &&
                cd ${PKGDIR}    &&
                ./down_obex          &&
                rm -rf down_obex
                echo "Acomplished Checking/Downloading packages." >> $LOG
                colored_echo "Accomplished downloading"
        else
                echo "Failed: Download script is not found." >> $LOG
                colored_echo "Failed downloading"
                exit 0
        fi

}

build_libusb () {

colored_echo "Building libusb"
	echo -e "\nStarted building libusb .." >> $LOG    &&
	cd libusb* &&
	./configure --host=arm-linux --sysconfdir=${MY_SYSCONFDIR} --prefix=${PRE_FIX}	\
			--localstatedir=${MY_LOCALSTATEDIR}				\
			OPENOBEX_LIBS=-L${INSTDIR}/usr/lib 				\
			BLUETOOTH_LIBS=-L${INSTDIR}/usr/lib 				\
			OPENOBEX_CFLAGS=-I${INSTDIR}/usr/include 			\
			BLUETOOTH_CFLAGS=-I${INSTDIR}/usr/include
	make DESTDIR=${INSTALL_DIR} -j4 &&
        make DESTDIR=${INSTALL_DIR} install &&
	cd ..   &&
        echo "Acomplished libusb." >> $LOG        &&
colored_echo "Acomplished libusb"


}

build_libopenobex () {

colored_echo "Building libopenobex"
	echo -e "\nStarted building openobex .." >> $LOG    &&
	cd libopenobex* &&
	sed 's/test "$cross_compiling" = yes \&\&/test "$cross_compiling" = * \&\&/' -i configure
	./configure --host=arm-linux --sysconfdir=${MY_SYSCONFDIR} --prefix=${PRE_FIX}	\
		--localstatedir=${MY_LOCALSTATEDIR} 	\
		PKG_CONFIG_PATH=${INSTDIR}/usr/lib/pkgconfig	\
		 CC="arm-linux-gcc -I${INSTDIR}/usr/include/ -L${INSTDIR}/usr/lib"
	make DESTDIR=${INSTALL_DIR} -j4 &&
        make DESTDIR=${INSTALL_DIR} install &&
	cd ..   &&
        echo "Acomplished libopenobex." >> $LOG        &&
colored_echo "Acomplished libopenobex"

}

build_obexftp () {

colored_echo "Building obexftp"    &&
        echo -e "\nStarted building obexftp .." >> $LOG    &&
	build_libusb
	build_libopenobex
        cd obexftp* &&
	./configure --host=arm-linux --sysconfdir=${MY_SYSCONFDIR} --prefix=${PRE_FIX} \
	--localstatedir=${MY_LOCALSTATEDIR} \
	CC="arm-linux-gcc -L${INSTDIR}/usr/lib -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include/ -I${INSTDIR}/usr/include/ -lusb" 			\
	OPENOBEX_LIBS="-L${INSTDIR}/usr/lib -lopenobex" 			\
	--disable-perl --disable-python --disable-ruby --disable-tcl CFLAGS="-L${INSTDIR}/usr/lib" &&	
	mv /usr/lib/libopenobex.so /	&&
	cp ${INSTDIR}/usr/lib/libusb.la -Rfp /usr/lib/ &&
	
	make DESTDIR=${INSTALL_DIR} PKG_CONFIG_PATH=${INSTDIR}/usr/lib/pkgconfig -j4 &&
	
	cp obexftp/.libs/libobexftp.a obexftp/.libs/libobexftp.lai	&&
	cp multicobex/.libs/libmulticobex.a multicobex/.libs/libmulticobex.lai	&&

	make DESTDIR=${INSTALL_DIR} install	&&
	
	mv /libopenobex.so /usr/lib		&&
	rm -rf /usr/lib/libusb.la		&&
	
        cd ..   &&
        echo "Acomplished obexftp." >> $LOG        &&
colored_echo "Acomplished obexftp"

}

build_libfuse () {

colored_echo "Building libfuse"
	echo -e "\nStarted building libfuse .." >> $LOG    &&
	tar -xvf fuse-2.9.3*
	cd fuse* &&
	./configure --host=arm-linux --sysconfdir=${MY_SYSCONFDIR} --prefix=${PRE_FIX} \
	--localstatedir=${MY_LOCALSTATEDIR} \
	CC="arm-linux-gcc -L${INSTDIR}/usr/lib -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include/ -I${INSTDIR}/usr/include"        &&
	make DESTDIR=${INSTALL_DIR} -j4 &&
        make DESTDIR=${INSTALL_DIR} install &&
	cd ..   &&
        echo "Acomplished libfuse." >> $LOG        &&
colored_echo "Acomplished libfuse"

}

build_obexfs () {

colored_echo "Building obexfs"
	echo -e "\nStarted building obexfs .." >> $LOG    &&
	build_libfuse
	tar -xvf obexfs*
	cd obexfs* &&
	./configure --host=arm-linux --sysconfdir=${MY_SYSCONFDIR} --prefix=${PRE_FIX} \
        --localstatedir=${MY_LOCALSTATEDIR} \
	CC="arm-linux-gcc -L${INSTDIR}/usr/lib -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include/ -I${INSTDIR}/usr/include"        &&
	make DESTDIR=${INSTALL_DIR} -j4 &&
        make DESTDIR=${INSTALL_DIR} install &&
        cd ..   &&
        echo "Acomplished obexfs." >> $LOG        &&
colored_echo "Acomplished obexfs"

}

################################################################################

case "$1" in
    make-install)
        download_pkg    &&
	build_obexftp	&&
	build_obexfs	&&
        date >> $LOG
        ;;
    clean-build)
        cd ${PKGDIR}
        rm -rf *
        cd ..
        ;;
    *)
        echo "Usage: $0 {make-install|clean-build}"
        exit 1
        ;;
esac


#################################################################################
