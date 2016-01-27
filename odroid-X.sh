#!/bin/bash
## WARNING this is under heavey development
## Odroid XU4 Series
##
##  mk uboot
##  mk kernel
##  mk the img file with dd and the partitions
##  mk the rootfs stage one & two
##  run custom mango releated scripts
##  cleanup
##  mk compression and m5dsum
# set -e
set -x

. common/extraPackages
. common/common.sh
. common/htmlHelper
. common/errorChecker
. config/web.config
. common/mango/makeMango

echo "making all te base directorys that are needed."
mkdir -p ${basedir}
mkdir -p ${basedir}/bootp
mkdir -p ${basedir}/root
mkdir -p ${basedir}/bootp.tmp
mkdir -p ${basedir}/root.tmp

## fixme later crossCompileCheck
export packages="${odroidCRepo} ${arm} ${base} ${services} ${tools} ${wireless} ${mangoPackages}"
export architecture=$buildArch
export mirror=$mainMirror
export security=$securityMirror

## setup bootstrap and index html pages
createLogIndex
setupIndex
setupHtmlPages



for i in ${packages};
do
  echo "<a class=\"list-group-item\" href=\"https://packages.debian.org/testing/$i\">$i</a>"   >> $rootDir/web/logs/index.html
done
echo "</ul>" >> $rootDir/web/logs/index.html

cd ${basedir}
echo "All the webpages have been setup feel free to look at them"
echo "DONEWITHDEPS"


# Build the latest u-boot bootloader, and then use the Hardkernel script to fuse

## export our new path for the eabi compile of u-boot
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=/home/joseph/Work/sandy/odroidBuilder/toolkits/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

## came from html helper
echo "<h3>Compilers PATH</h3>" >> $ubootLogfile
echo $PATH >> $ubootLogfile
echo "<h3>Arch</h3>" >> $ubootLogfile
echo $ARCH >> $ubootLogfile
echo "<h3>CROSS COMPILE</h3>" >> $ubootLogfile
echo $CROSS_COMPILE >> $ubootLogfile
echo "<h3>Arm EABI Specs</h3>" >> $ubootLogfile
echo "<pre>" >> $ubootLogfile
arm-linux-gnueabihf-gcc -v >> $ubootLogfile 2>&1
echo "</pre>" >> $ubootLogfile

echo "Building UBoot Please Be patient"
echo "DONEUBOOT"
echo "<h3>Cloning Uboot from Git</h3>" >> $ubootLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $ubootLogfile
git clone https://github.com/hardkernel/u-boot.git -b odroidxu3-v2012.07 >> $ubootLogfile 2>&1
echo "</textarea>" >> $ubootLogfile

cd ${basedir}/u-boot

echo "<h3>Make odroid_config</h3>" >> $ubootLogfile
echo "<pre>" >> $ubootLogfile
make odroid_config >> $ubootLogfile 2>&1
echo "</pre>" >> $ubootLogfile

echo "<h3>Build config<h3>" >> $ubootLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $ubootLogfile
cat  $basedir/u-boot/.boards.depend >> $ubootLogfile
echo "</textarea>" >> $ubootLogfile

echo "<h3>From make</h3>" >> $ubootLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $ubootLogfile
make -j $cnum >> $ubootLogfile 2>&1
echo "</textarea>" >> $ubootLogfile
echo "UBoot has been Built"


echo "Building the linux Kernel"
cd ${basedir}
## Set up the gcc linaro cross compiler fo the linux kernel
export ARCH=arm
export CROSS_COMPILE=arm-eabi-
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=/home/joseph/Work/sandy/odroidBuilder/toolkits/arm-eabi-4.6/bin:$PATH

## HTMLHELPER KERNEL
echo "DONELINUXKERNEL"
echo "<h3>Compilers PATH</h3>" >> $kernelCompileLogfile
echo $PATH >> $kernelCompileLogfile
echo "<h3>Arch</h3>" >> $kernelCompileLogfile
echo $ARCH >> $kernelCompileLogfile
echo "<h3>CROSS COMPILE</h3>" >> $kernelCompileLogfile
echo $CROSS_COMPILE >> $kernelCompileLogfile
echo "<h3>Arm EABI Specs</h3>" >> $kernelCompileLogfile
echo "<pre>" >> $kernelCompileLogfile
arm-eabi-gcc -v >> $kernelCompileLogfile 2>&1
echo "</pre>" >> $kernelCompileLogfile

echo "<h3>Cloning the  Linux kernel</h3><hr>" >> $kernelCompileLogfile
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $kernelCompileLogfile
git clone --depth 1 https://github.com/hardkernel/linux.git -b odroidxu3-3.10.y ${basedir}/kernel >> $kernelCompileLogfile 2>&1
echo "</textarea><hr>" >> $kernelCompileLogfile

cd ${basedir}/kernel

echo "<h3>Output of make odroidxu4_defconfig</h3><hr>" >> $kernelCompileLogfile
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $kernelCompileLogfile
make odroidxu3_defconfig >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

echo "<h3>Output of make Z Image</h3><hr>" >> $kernelCompileLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
make -j $cnum >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

#echo "<h3>Output of make Dtbs</h3><hr>" >> $kernelCompileLogfile
#echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
#make -j $cnum dtbs >> $kernelCompileLogfile 2>&1
#echo "</textarea>" >> $kernelCompileLogfile

#echo "<h3>Output of make moduels</h3><hr>" >> $kernelCompileLogfile
#echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
#make -j $cnum modules >> $kernelCompileLogfile 2>&1
#echo "</textarea>" >> $kernelCompileLogfile

echo "<h3>Output of modules_install</h3><hr>" >> $kernelCompileLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
make modules_install ARCH=arm INSTALL_MOD_PATH=${basedir}/root.tmp >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

cp ${basedir}/kernel/arch/arm/boot/zImage ${basedir}/bootp.tmp/
cp ${basedir}/kernel/arch/arm/boot/dts/exynos5422-odroidxu3.dtb ${basedir}/bootp.tmp/


_VER=`make kernelversion`
cp .config ${basedir}/bootp.tmp/config-$_VER



echo "Built the Linux Kernel"
cd ${basedir}

echo "Making the IMG file"
dd if=/dev/zero of=${basedir}/$manufacturer-$version-$distro-$board.img bs=1M count=3000 >> $mkImageMountLog 2>&1
# sync
echo "</pre>" >> $mkImageMountLog ## This is the End of the HTMLHelper IMAGE
echo "made the image File"
echo "DONEIMGFILE"
echo "Setting up the partitions "
# Set the partition variables
## See http://odroid.com/dokuwiki/doku.php?id=en:u3_partition_table#ubuntu_partition_table for details on sectors
parted $manufacturer-$version-$distro-X.img --script -- mklabel msdos
parted $manufacturer-$version-$distro-X.img --script -- mkpart primary fat32 3072s 266239s
parted $manufacturer-$version-$distro-X.img --script -- mkpart primary ext4 266240s 100%
## FIXME lets add a swap in here also
echo "Done Setting up the partitions "

echo "DEBOOTSTRAPSTARTED"
echo "Running debootstrap stage 1"
##HTMLHELPER DeBootsttrap
debootstrap --foreign --arch $architecture $2 $manufacturer-$architecture $mirror  >> $debootstrapLogFile 2>&1
echo "	</textarea>" >> $debootstrapLogFile
echo "Stage One has been Built"

echo "moving qemu-arm-static over to $manufacturer-$architecture So We can chroot in"
cp /usr/bin/qemu-arm-static $manufacturer-$architecture/usr/bin/

echo "Running Stage two of debootstrap "
cat <<EOF>> $debootstrapLogFile
<h3>Stage Two Log</h3>
<hr>
<label for="stageTwo">debootstrap part 2:</label>
<textarea class="form-control" overview="auto" rows="5" id="stageTwo">
EOF


LANG=C chroot $manufacturer-$architecture /debootstrap/debootstrap --second-stage >> $debootstrapLogFile  2>&1
echo "</textarea>" >> $debootstrapLogFile
echo "Done runing stage 2 of debootstrap"


echo "Setting up Apt sources"

if [[ $board == "ubuntu" ]];
then
echo "<h3>Adding ubuntu to the sources list </h3>" >> $debootstrapLogFile

cat << EOF > $manufacturer-$architecture/etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports $codeName main restriced universe multiverse
deb-src http://ports.ubuntu.com/ubuntu-ports $codeName main restriced universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports $codeName-updates main restriced universe multiverse
deb-src http://ports.ubuntu.com/ubuntu-ports $codeName-updates main restriced universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports $codeName-security main restriced universe multiverse
deb-src http://ports.ubuntu.com/ubuntu-ports $codeName-security main restriced universe multiverse
EOF

else

echo "<h3>Adding debian to the sources list </h3>" >> $debootstrapLogFile

cat << EOF > $manufacturer-$architecture/etc/apt/sources.list
deb http://ftp.debian.org/debian $codeName main contrib non-free
deb-src http://ftp.debian.org/debian $codeName main contrib non-free

deb http://security.debian.org/debian-security $codeName/updates main contrib non-free
deb-src http://security.debian.org/debian-security $codeName/updates main contrib non-free
EOF

fi


echo "changing the hostname and settings for the networking"
echo "<h3>changing the host name and setting up the networking</h3>" >> $debootstrapLogFile; 

echo "mangoES" > $manufacturer-$architecture/etc/hostname
cat << EOF > $manufacturer-$architecture/etc/hosts
127.0.0.1       mangoES    localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

cat << EOF > $manufacturer-$architecture/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

cat << EOF > $manufacturer-$architecture/etc/resolv.conf
nameserver 8.8.8.8
EOF

echo "Done setting up simple networking"

echo "Setting up keymaps proc dev pts and console keymaps and time stamps "
export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
mount -t proc proc $manufacturer-$architecture/proc
mount -o bind /dev/ $manufacturer-$architecture/dev/
mount -o bind /dev/pts $manufacturer-$architecture/dev/pts
cat << EOF > $manufacturer-$architecture/debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select us
EOF


echo "Setting up 3rd party repositorys"
cat <<EOF>> $stage3Logfile
<h3>Adding Xu4 odroid Repo and Mango repos</h3>
<pre>
EOF

cat << EOF > $manufacturer-$architecture/addOdroidRepo
#!/bin/bash
echo "deb http://deb.odroid.in/c1/ trusty main" >> /etc/apt/sources.list
echo "deb http://deb.odroid.in/ trusty main" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AB19BAC9
echo "deb http://mangoautomation.net:9902/Applications/apt/debian/ jessie main contrib non-free" >> /etc/apt/sources.list
wget -O - http://mangoautomation.net:9902/Applications/apt/debian/.repokeys.gpg.key|apt-key add -
apt-get update
rm -f addOdroidRepo
EOF

chmod +x $manufacturer-$architecture/addOdroidRepo
LANG=C chroot $manufacturer-$architecture /addOdroidRepo >> $stage3Logfile 2>&1
echo "</pre>" >> $stage3Logfile


echo "Done Adding odroid repos"


echo "Done setting up the keyboard and other misc things "
echo "Running Stage 3 (Custom Scripts)"
##HTMLHelper Stage3
echo "STAGETHREESTARTED"
cd $basedir
cp ../common/customizeBuild $manufacturer-$architecture/third-stage
## Run the 3rd stage,
chmod +x $manufacturer-$architecture/third-stage
LANG=C chroot $manufacturer-$architecture /third-stage >> $stage3Logfile 2>&1
echo "</textarea>" >> $stage3Logfile


echo "Done running stage 3 "

echo "Running clean up for the OS "


cat <<EOF>> $stage3Logfile
<h3>Stage Three Clean Up</h3>
<pre>
EOF
cat << EOF > $manufacturer-$architecture/cleanup
#!/bin/bash
rm -rf /root/.bash_history
apt-get update
apt-get clean
rm -f /0
rm -f /hs_err*
rm -f cleanup
## FIXME hardCode
rm -f /usr/bin/qemu*
echo "all cleaned up"
EOF
chmod +x $manufacturer-$architecture/cleanup
LANG=C chroot $manufacturer-$architecture /cleanup >> $stage3Logfile 2>&1
echo "</pre>" >> $stage3Logfile
echo "Done Cleaning up the OS System"


## satarting a race are we
sleep 4;

echo "Unmounting the some of the loop devices"
## FIXME run checks /proc/sys/fs/binfmt_misc WHY YOU NO MOUNTED ?
#umount $manufacturer-$architecture/proc/sys/fs/binfmt_misc
umount -l $manufacturer-$architecture/dev/pts
umount -l $manufacturer-$architecture/dev/
umount -l $manufacturer-$architecture/proc
echo "Done unmounting the dev and proc "



echo "Setting up the loop device "
# Put the patrtitions on a loop device so we can alter them
modprobe loop
loopdevice=$(losetup -f)
losetup $loopdevice ${basedir}/$manufacturer-$version-$distro-X.img
partprobe $loopdevice
bootp=${loopdevice}p1
rootp=${loopdevice}p2

echo "Done setting up the loop device to make the true img "


echo "<h3>Partitions that where mounted<h3>" >> $mkImageMountLog
echo "<div class='row'> <div class='col-md-6'>" >> $mkImageMountLog
echo "<h3>ROOT FS </h3>" >> $mkImageMountLog
echo  $rootp >> $mkImageMountLog
echo "</div> <div class='col-md-6'><h3> BOOT FS </h3>" >> $mkImageMountLog
echo  $bootp >> $mkImageMountLog
echo "</div></div>" >> $mkImageMountLog
# Create file systems on the looped partitions


echo "Setting up the vfat and ext4 filesystems "

echo "<h3>mkfs.vfat and mkfs.ext4</h3>" >> $mkImageMountLog
echo "<pre>" >> $mkImageMountLog

mkfs.vfat -F 32 -n BOOT $bootp >> $mkImageMountLog 2>&1
fatuuid=$(blkid -s UUID -o value $bootp);

mkfs.ext4 -F -L MangoES $rootp >> $mkImageMountLog 2>&1
ext4uuid=$(blkid -s UUID -o value $rootp)

echo "Done Setting up the fat32 and ext4 filesystems "


echo "</pre>" >> $mkImageMountLog

echo "Mounting the boot partition and also the root file system"

mount $bootp ${basedir}/bootp
mount $rootp ${basedir}/root

echo "Done mounting the boot and rootfs partitions"



echo "Moving the Linux kernel"
cp ${basedir}/bootp.tmp/zImage ${basedir}/bootp/
cp ${basedir}/bootp.tmp/exynos5422-odroidxu3.dtb ${basedir}/bootp/
echo "Adding all the uboot scripts to the boot partition"

echo "Moving over the boot scripts"
cp ../boards/odroid/X/files/boot.ini ${basedir}/bootp/boot.ini
cp ../boards/odroid/X/files/boot.txt ${basedir}/bootp/boot.txt
chmod +x ${basedir}/bootp/boot.ini
chmod +x ${basedir}/bootp/boot.txt


## sed -i "s/\${BOOT_UUID}/$fatuuid/g"  ${basedir}/bootp/boot.ini
## sed -i "s/\${ROOT_UUID}/$ext4uuid/g" ${basedir}/bootp/boot.ini
## sed -i "s/\${ROOT_UUID}/$ext4uuid/g" ${basedir}/bootp/boot.txt

## Use rsync to copy the root file system to the 2nd partition
echo "Rsyncing $rootFS aka Root File system into the image file"

echo "<h2>Rsyncing $rootp aka Root File system into the image file</h2>" >> $mkImageMountLog
rsync -HPavz -q ${basedir}/$manufacturer-$architecture/ ${basedir}/root/
mkdir -p ${basedir}/root/boot
cp ${basedir}/bootp.tmp/config-$_VER  ${basedir}/root/boot/config-$_VER
mkdir -p ${basedir}/root/media
mkdir -p ${basedir}/root/root
mkdir -p ${basedir}/root/tmp

echo "Setting up all the uinitram and moving the kernel modules over "
## the kernel mods


cp -rp ${basedir}/root.tmp/lib ${basedir}/root/


## FIXME not sure why the kernel is saving the mods as version+
cp /usr/bin/qemu-arm-static ${basedir}/root/usr/bin/
cat << EOF > ${basedir}/root/uinitram
#!/bin/bash
plus="+"
mods=$_VER$plus
apt-get install -y --force-yes initramfs-tools
cd /boot
/usr/sbin/update-initramfs -c -t -k $mods
## rm -f /uinitram
EOF


echo "<h3>Updating Initramfs </h3><hr><pre>" >> $kernelCompileLogfile
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $kernelCompileLogfile
chmod +x ${basedir}/root/uinitram
LANG=C chroot ${basedir}/root ./uinitram >> $kernelCompileLogfile 2>&1
echo "</pre></textarea>" >> $kernelCompileLogfile

rm ${basedir}/root/usr/bin/qemu-arm-static


## Make the uInitrd
echo "<h3>uInitrd</h3><hr><pre>" >> $mkImageMountLog
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $mkImageMountLog 
mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d ${basedir}/root/boot/initrd.img-$_VER ${basedir}/root/boot/uInitrd-$_VER >> $mkImageMountLog 2>&1
cp ${basedir}/root/boot/uInitrd-$_VER ${basedir}/bootp/uInitrd
echo "</pre></textarea>" >> $mkImageMountLog


echo "Setting up the fstab so that the file systems can boot"
touch ${basedir}/root/etc/fstab
echo "# Odroid fstab" > ${basedir}/root/etc/fstab
echo "" >> ${basedir}/root/etc/fstab
echo "/dev/mmcblk0p2  /  ext4  errors=remount-ro,noatime,nodiratime  0 1" >> ${basedir}/root/etc/fstab
echo "/dev/mmcblk0p1  /media/boot  vfat  defaults,rw,owner,flush,umask=000  0 0" >> ${basedir}/root/etc/fstab
echo "tmpfs /tmp  tmpfs nodev,nosuid,mode=1777  0 0" >> ${basedir}/root/etc/fstab


echo "Done setting up the fstab"

echo "Setting up odroid specific configureations "

## FILES AREA FROM BOARD DIR HERE
cd ${basedir};
mkdir -p ${basedir}/root/etc/X11/
touch ${basedir}/root/etc/securetty
touch ${basedir}/root/etc/X11/xorg.conf
touch ${basedir}/root/etc/udev/rules.d/10.odroid.rules
touch ${basedir}/root/etc/modprobe.d/blacklist-odroid.conf
touch ${basedir}/root/etc/asound.conf

cp ${rootDir}/common/securetty  ${basedir}/root/etc/securetty
cp ${rootDir}/boards/odroid/X/files/xorg.conf  ${basedir}/root/etc/X11/xorg.conf
cp ${rootDir}/boards/odroid/X/files/10.odroid.rules  ${basedir}/root/etc/udev/rules.d/10-odroid.rules
cp ${rootDir}/boards/odroid/X/files/asound.conf  ${basedir}/root/etc/asound.conf


## the custom mango things that need to be installed
echo "Setting up custom init scripts"

## other custom mango things 
makeInits

echo "Setting up the Permissions for all the service files "
chmod u+x ${basedir}/root/etc/init.d/mango
chmod u+x ${basedir}/root/etc/init.d/usbmount-start
chmod u+x ${basedir}/root/etc/init.d/framebuffer-start




echo "Making the Boot SCR file"
echo "<h3>Boot Scr</h3><hr></pre>" >> $mkImageMountLog
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $mkImageMountLog
mkimage -A arm -T script -C none -d ${basedir}/bootp/boot.txt ${basedir}/bootp/boot.scr  >> $mkImageMountLog 2>&1
echo "</pre></textarea>" >> $mkImageMountLog

## FIXME when flashing the loop0 with the samsung binary it does not work here.
## Need to plug in eemc and flash then add samsung binary then unplug eemc and plug back in.
# echo -e "\x55\xaa" | dd bs=1 count=2 seek=510 of=${basedir}/$manufacturer-$version-$distro-odroid-$board.img conv=notrunc >> $mkImageMountLog 2>&1
# dd if=${basedir}/u-boot/sd_fuse/bl1.bin.hardkernel of=${basedir}/$manufacturer-$version-$distro-odroid-$board.img bs=1 count=442 conv=notrunc >> $mkImageMountLog 2>&1
# dd if=${basedir}/u-boot/sd_fuse/bl1.bin.hardkernel of=${basedir}/$manufacturer-$version-$distro-odroid-$board.img bs=512 skip=1 seek=1 conv=notrunc >> $mkImageMountLog 2>$
# dd if=${basedir}/u-boot/sd_fuse/u-boot.bin of=${basedir}/$manufacturer-$version-$distro-odroid-$board.img bs=512 seek=64 conv=notrunc >> $mkImageMountLog 2>&1

echo "Done setting up the boot.scr file"

cd ${basedir}
umount -l $bootp
umount -l $rootp
losetup -d $loopdevice

echo "Image has been succfully made"


echo " Clean up all the temporary build stuff and remove the directories."
# Comment this out to keep things around if you need to debug
rm -rf ${basedir}/kernel ${basedir}/bootp ${basedir}/root ${basedir}/$manufacturer-$architecture ${basedir}/bootp.tmp $manufacturer-armhf ${basedir}/root.tmp
#
## ${basedir}/web
## ${basedir}/u-boot

## FIXME Cut up the image, use the UUID and blkid
#cd ${basedir}
#num=$(fdisk -l $manufacturer-$version-$distro-odroid-C.img |awk '/img2/ {print $3}')
#truncate --size=$[($num+1)*512] $manufacturer-$version-$distro-odroid-C.img

#
echo "Comperssing all the images and getting ready for a upload "
#
## HTMLHELPER COMPRESSION
echo "COMPRESSIONSTARTED"
sha1sum $manufacturer-$version-$distro-X.img > ${basedir}/$manufacturer-$version-$distro-X.img.sha1sum >> $compressLogFile 2>&1
echo "</pre>" >> $compressLogFile;
#
machineType=$(uname -m)
 if [ ${machineType} == 'x86_64' ];
 then
   echo "<h3>Compressing $manufacturer-$version-$distro-$board.img</h3>" >> $compressLogFile;
     pixz ${basedir}/$manufacturer-$version-$distro-$board.img ${basedir}/$manufacturer-$version-$distro-$board.img.xz >> $compressLogFile 2>&1
   echo "<h3>Generating sha1sum for $manufacturer-$version-$distro-$board.img</h3><pre>" >> $compressLogFile;
     sha1sum $manufacturer-$version-$distro-$board.img.xz > ${basedir}/$manufacturer-$version-$distro-$board.img.xz.sha1sum >> $compressLogFile 2>&1
   echo "</pre>" >> $compressLogFile

     echo "Moving $manufacturer-$version-$distro-$board.img to /home/joseph/Work/MangoES/X/mangoes-daily-$2-$board.img"
     #mkdir -p /home/joseph/Work/MangoES/X/
     #cp ${basedir}/$manufacturer-$version-$distro-$board.img /home/joseph/Work/MangoES/X/$manufacturer-daily-$distro-odroid-$board.img
   else
   echo "Please Don't pixz on non 64bit, there isn't enough memory to compress the images."
   fi


echo "Done Compressing all the Images "

echo "Adding the footer to the HTML5 log files "
addFooter;

echo "DONE !!!!!!!"
echo "Comming soon  Uploading the images and logs to the server."
##    $scpCMD $basedir/web
echo "IMPORTANT make sure that you flash the dang sd_fuse crap to the image after your burn it."


echo "ALLDONE"
