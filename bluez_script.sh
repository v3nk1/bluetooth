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
ZLIB=0
LIBFFI=0
GETTEXT=0
GLIB=0
EXPAT=0
DBUS=0
LIBICAL=0
NCURSES=0
READLINE=0
BLUEZ=0
OBEX=0

ROOTDIR=/embedded/mini2440/projects/bluetooth/test
INSTDIR=${ROOTDIR}/Recipe
PKGDIR=${ROOTDIR}/pkg-build
LOG=${PKGDIR}/build.log

${PEXP_MINI}	#exporting cross compile toolchain path

export INSTALL_DIR=${INSTDIR}
export PRE_FIX=/usr
export MY_SYSCONFDIR=/etc
export MY_LOCALSTATEDIR=/var

mkdir -p ${INSTDIR} ${PKGDIR}
date > ${LOG}

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


#pkg_check () {
#
#	 if test -e zlib*.tar*
#        if test -e libffi*.tar*
#        if test -e gettext*.tar*
#        if test -e glib*.tar*
#        if test -e expat*.tar*
#        if test -e dbus*.tar*
#        if test -e libical*.tar*
#        if test -e ncurses*.tar*
#        if test -e readline*.tar*			
#        if test -e bluez*.tar* 
#
#}

download_pkg () {

	#pkg_check

	colored_echo "Downloading packages"
	echo -e "\nChecking/Downloading packages .." >> $LOG    &&
	if test -e ./down	
		then 
		cp ./down ${PKGDIR}     &&
                cd ${PKGDIR}    &&
                ./down          &&
                rm -rf down
		echo "Acomplished Checking/Downloading packages." >> $LOG        &&
		colored_echo "Accomplished downloading"	
	else
		echo "Failed: Download script is not found." >> $LOG
		colored_echo "Failed downloading"	
		exit 0	
	fi

}

zlib () {

colored_echo "Building zlib"	&&
	echo -e "\nStarted building zlib .." >> $LOG	&&
	tar -xvf zlib-1.2.8.tar.gz &&
	cd zlib-1.2.8	&&
	CC=arm-linux-gcc CFLAGS="-O4" ./configure --prefix=${PRE_FIX} --sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} &&
	make DESTDIR=${INSTALL_DIR} -j4	&&
	make DESTDIR=${INSTALL_DIR} install &&
	cd ..	&&
	ZLIB=1	&&
	echo "Acomplished zlib." >> $LOG	&&
colored_echo "Acomplished zlib"	
	
}

libffi () {

colored_echo "Building libffi"	&&
	echo -e "\nStarted building libffi .." >> $LOG &&
	tar -xvf libffi*	&&
	cd libffi*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX} --sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} &&
	make DESTDIR=${INSTALL_DIR} -j4	&&
	make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	LIBFFI=1	&&
	echo "Acomplished libffi." >> $LOG      &&
colored_echo "Acomplished libffi"	

}

gettext () {

colored_echo "Building gettext"	&&
	echo -e "\nStarted building gettext .." >> $LOG &&
	tar -xvf gettext*	&&
	cd gettext*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX} --sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} &&
	make DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	GETTEXT=1	&&
	echo "Acomplished gettext." >> $LOG      &&
colored_echo "Acomplished gettext"	

}

glib () {

sudo apt-get install libglib2.0-dev	&&

colored_echo "Building glib"	&&
	echo -e "\nStarted building glib .." >> $LOG &&
	tar -xvf glib-*	&&
	cd glib-*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX} \
	--sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} \
	PKG_CONFIG_PATH=${INSTDIR}/usr/lib/pkgconfig  \
	CC="arm-linux-gcc -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include" \
	glib_cv_stack_grows=no glib_cv_uscore=yes ac_cv_func_posix_getpwuid_r=yes \
	ac_cv_func_posix_getgrgid_r=yes	&&
	make LIBFFI_CFLAGS=-I${INSTDIR}/usr/lib/libffi-3.1/include DESTDIR=${INSTALL_DIR} -j4	&&
	make DESTDIR=${INSTALL_DIR} install	&&
	cd ..	&&
	GLIB=1	&&
	echo "Acomplished glib." >> $LOG      &&
colored_echo "Acomplished glib"	

}

expat () {

colored_echo "Building expat"	&&
	echo -e "\nStarted building expat .." >> $LOG &&
	tar -xvzf expat-*	&&
	cd expat*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX}	\
	--sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} &&
	make DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install &&
        cd ..	&&
	EXPAT=1	&&
	echo "Acomplished expat." >> $LOG      &&
colored_echo "Acomplished expat"	

}

dbus () {

colored_echo "Building Dbus"	&&
	echo -e "\nStarted building Dbus .." >> $LOG &&
	tar -xzvf dbus-*	&&
	cd dbus*	&&
	export PKG_CONFIG_LIBDIR=${INSTDIR}/usr/lib/pkgconfig	&&
	echo ac_cv_have_abstract_sockets=yes > arm-linux.cache	&&
	./configure --host=arm-linux --prefix=${PRE_FIX} \
	--sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} \
	CC="arm-linux-gcc -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include -lexpat" \
	--cache-file=arm-linux.cache	&&
	make GLIB_CFLAGS="-I${INSTDIR}/usr/lib/glib-2.0/include -I${INSTDIR}/usr/include/glib-2.0"	\
	DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	DBUS=1	&&
	echo "Acomplished Dbus." >> $LOG      &&
colored_echo "Acomplished Dbus"	

}


libical () {

sudo apt-get install cmake	&&

colored_echo "Building libical"	&&
	echo -e "\nStarted building libical .." >> $LOG &&
	tar -xzvf libical* &&
	cd libical*	&&
	export CC=arm-linux-gcc	&&
	export CXX=arm-linux-g++	&&
	cmake -DCMAKE_INSTALL_PREFIX=/usr	&&
	make DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	LIBICAL=1	&&
	echo "Acomplished libical." >> $LOG      &&
colored_echo "Acomplished libical"	

}

ncurses () {

colored_echo "Building ncurses"	&&
	echo -e "\nStarted building ncurses .." >> $LOG &&
	tar -xvf ncurses*	&&
	cd ncurses*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX} CXX="arm-linux-g++"	\
	--sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} &&
	make DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	NCURSES=1	&&
	echo "Acomplished ncurses." >> $LOG      &&
colored_echo "Acomplished ncurses"

}

readline () {

colored_echo "Building readline"	&&
	echo -e "\nStarted building readline .." >> $LOG &&
	tar -xvzf readline*	&&
	cd readline*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX} \
	--sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} \
	bash_cv_wcwidth_broken=yes	&&
	make CC="arm-linux-gcc -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include -lc" \
	SHLIB_LIBS=-lncurses DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	READLINE=1	&&
	echo "Acomplished readline." >> $LOG      &&
colored_echo "Acomplished readline"	

}

bluez () {

colored_echo "Building Bluez"		&&
	echo -e "\nStarted building Bluez .." >> $LOG &&
	tar -xvf bluez-*	&&
	cd bluez-*	&&
	./configure --host=arm-linux --prefix=${PRE_FIX}	\
	--sysconfdir=${MY_SYSCONFDIR} --localstatedir=${MY_LOCALSTATEDIR} \
	LIBS="-lncurses" PKG_CONFIG_PATH=${INSTDIR}/usr/lib/pkgconfig        \
	--disable-systemd --disable-udev --disable-cups  --enable-library         \
	GLIB_CFLAGS="-I${INSTDIR}/usr/lib/glib-2.0/include -I${INSTDIR}/usr/include/glib-2.0"             \
	CC="arm-linux-gcc -L${INSTDIR}/usr/lib -I${INSTDIR}/usr/include -lc" \
	DBUS_CFLAGS="-I${INSTDIR}/usr/lib/dbus-1.0/include -I${INSTDIR}/usr/include/dbus-1.0"	&&

	make DESTDIR=${INSTALL_DIR} -j4	&&
        make DESTDIR=${INSTALL_DIR} install	&&
        cd ..	&&
	BLUEZ=1	&&
	echo "Acomplished Bluez." >> $LOG      &&
colored_echo "Acomplished Bluez"
	cd $ROOTDIR

}

check_build_success () {

	colored_echo "BUILDING LOG:"
	check_pkgsuccess $ZLIB zlib
	check_pkgsuccess $LIBFFI libffi
	check_pkgsuccess $GETTEXT gettext
	check_pkgsuccess $GLIB glib
	check_pkgsuccess $EXPAT expat
	check_pkgsuccess $DBUS dbus
	check_pkgsuccess $LIBICAL libical
	check_pkgsuccess $NCURSES "ncurses"
	check_pkgsuccess $READLINE "readline"
	check_pkgsuccess $BLUEZ bluez
	check_pkgsuccess $OBEX obex


}


################################################################################

case "$1" in
    make-bluez)
	$0 clean-build    &&
	download_pkg	&&
	zlib		&&
	libffi		&&
	gettext    &&
	glib    &&
	expat    &&
	dbus    &&
	libical    &&
	ncurses    &&
	readline    &&
	bluez
	check_build_success
	date >> $LOG	
        ;;
    make-bluez-obex)
#	$0 clean-build    &&
	download_pkg    &&
        zlib    &&
        libffi    &&
        gettext    &&
        glib    &&
        expat    &&
        dbus    &&
        libical    &&
        ncurses    &&
        readline    &&
        bluez	&&
	./obex.sh make-install &&
	OBEX=1
	check_build_success
	date >> $LOG	
        ;;
    clean-build)
	rm -rf bluez-5.20 dbus-1.8.0 gettext-0.19.1 expat-2.1.0 glib-2.40.0 libffi-3.1 \
		libical-1.0 ncurses-5.9 readline-6.3 zlib-1.2.8
        ;;
    *)
        echo "Usage: $0 {make-bluez|make-bluez-obex|clean-build}"
        exit 1
        ;;
esac


#################################################################################
