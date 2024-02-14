#!/bin/bash
# Di buat oleh helmiarimbawa(sshade.shop)

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

clear

SERVICE_NAME="modemhp"

ganti_ip() {
    ipsekarang=$(adb shell ip -f inet addr show rmnet0 | awk '/inet / {print $2}' | cut -d'/' -f1)
    echo "IP Address HP dulur sedurunge ${ipsekarang}"
    adb shell settings put global airplane_mode_on 1
    adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true > /dev/null
    echo "Mode Kapal Mabur Aktif"
    sleep 3
    adb shell settings put global airplane_mode_on 0
    adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false > /dev/null
    echo "Mode Kapal Nyungsep"
    sleep 8
    ipbaru=$(adb shell ip -f inet addr show rmnet0 | awk '/inet / {print $2}' | cut -d'/' -f1)
    echo "IP Address HP dulur ${ipbaru}"
}

cek_ip() {
    ipsekarang=$(adb shell ip -f inet addr show rmnet0 | awk '/inet / {print $2}' | cut -d'/' -f1)
    echo "IP Address HP dulur ${ipsekarang}"
}

cek_sms() {
    if adb shell su -c "content query --uri content://sms --projection _id,address,body,date" | head -n 1 2>&1 | grep -q "No result found."; then
        echo "Kotak amal kosong"
    else
        convert_timestamp() {
        local timestamp=$1
        converted_wib_date=$(date -d "@$((timestamp / 1000))" +"%Y-%m-%d %H:%M:%S" 2>/dev/null)
        if [ -z "$converted_wib_date" ]; then
          echo "Gagal mengonversi tanggal."
        else
          epoch_time=$(date -d "$converted_wib_date" +"%s")
          adjusted_epoch_time=$((epoch_time - 3600))
          adjusted_wib_date=$(date -d "@$adjusted_epoch_time" +"%Y-%m-%d %H:%M:%S")
          echo "$adjusted_wib_date WIB"
        fi
      }
      adb_output=$(adb shell su -c "content query --uri content://sms --projection address,body,date" | head -n 4)
      IFS=$'\n'
      rows=($adb_output)
      for row in "${rows[@]}"; do
        waktu=$(echo "$row" | grep -o 'date=[0-9]\+' | cut -d'=' -f2)
        dari=$(echo "$row" | grep -o 'address=[^,]\+' | cut -d'=' -f2)
        isi=$(echo "$row" | awk -F 'body=' '{print $2}' | awk -F ', date=' '{print $1}' | sed 's/^ //' | awk 'BEGIN { RS=""; FS="\n" } { for(i=1; i<=length($0); i+=110) print substr($0, i, 110) }')
        echo "Tgl&Jam : $(convert_timestamp $waktu)"
        echo "Dari    : $dari"
        echo "Isi SMS : $isi"
        echo "--------------------------------------"
      done
    fi
}

hapus_sms() {
    if adb shell su -c "content query --uri content://sms --projection _id,address,body,date" | head -n 1 2>&1 | grep -q "No result found."; then
        echo "Kotak amal kosong"
    else
        adb shell su -c "pm clear com.android.providers.telephony"
        echo "Kabeh isi kotak amal di gondol sawise reboot"
    fi
}

reboot() {
    adb reboot devices
    echo "HP ne modar mending tuku anyar"
}

function usage() {
    cat <<EOF
Perintah yang anda masukan salah.
Masukan perintah sesuai keterangan berikut:
   modemhp reboot    untuk restart atau reboot
EOF
}

case $1 in
"ganti_ip")
ganti_ip;exit
;;
esac

case $1 in
"cek_ip")
cek_ip;exit
;;
esac

case $1 in
"cek_sms")
cek_sms;exit
;;
esac

case $1 in
"hapus_sms")
hapus_sms;exit
;;
esac

case $1 in
"reboot")
reboot;exit
;;
esac

#-- colors --#
#R='\e[1;31m' #RED
#G='\e[1;32m' #GREEN
#B='\e[1;34m' #BLUE
#Y='\e[1;33m' #YELLOW
#C='\e[1;36m' #CYAN
W='\e[1;37m' #WHITE
##############

#-- colors v2 --#
R='\e[31;1m' #RED
G='\e[32;1m' #GREEN
Y='\e[33;1m' #YELLOW
DB='\e[34;1m' #DARKBLUE
P='\e[35;1m' #PURPLE
LB='\e[36;1m' #LIGHTBLUE

#-- colors v3 --#
BR='\e[3;31m' #RED
BG='\e[3;32m' #GREEN
BY='\e[3;33m' #YELLOW
BDB='\e[3;34m' #DARKBLUE
BP='\e[3;35m' #PURPLE
BLB='\e[3;36m' #LIGHTBLUE


echo -e "$DB **************************************************"
echo -e " **                                              **"
echo -e "$DB **$R          SELAMAT DATANG DULUR DULUR          $DB**"
echo -e " **                                              **"
echo -e "$DB **************************************************"
echo -e "$DB **$Y           PILIH OPSI YANG TERSEDIA           $DB**"
echo -e "$DB **************************************************"
echo -e "$DB **$G DAFTAR :                  * PERINTAH :       $DB**"
echo -e "$DB **$G Ganti IP Address          * modemhp ganti_ip   $DB**"
echo -e "$DB **$G Cek IP Address            * modemhp cek_ip     $DB**"
echo -e "$DB **$G Lihat 4 SMS terbaru       * modemhp cek_sms    $DB**"
echo -e "$DB **$G Hapus semua SMS           * modemhp hapus_sms  $DB**"
echo -e "$DB **$G Restart/reboot            * modemhp reboot     $DB**"
echo -e "$DB **$G KELUAR DARI MENU          * exit             $DB**"
echo -e "$DB **************************************************"
echo -e "$W"
