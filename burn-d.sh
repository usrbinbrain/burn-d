#!/bin/sh
#
# Script Name   :burn-d.sh
# Description   :Configure script as a daemon on systems managed by systemd or sysrc.
# Args          :script file on first argument.
# Script repo   :https://github.com/tr4kthebox/burn-d
# Author        :G.A.Gama
#

# Function deploy sysrc service.
sysrc_() {

  script=$1
  # Sysrc daemon name.
  dname=${script%%.*}_d
  # Sysrc deamon file content.
  rc_f='#!/bin/sh\n. /etc/rc.subr\nname='${dname}'\nrcvar='${dname}'_enable\npidfile="/var/run/${name}.pid"\nlogfile="/tmp/${name}.log"\nscript_command="'${PWD}'/'${script}'"\ncommand="/usr/sbin/daemon"\ncommand_args="-P ${pidfile} -o ${logfile} -r -f ${script_command}"\nload_rc_config $name\nrun_rc_command "$1"'

  # Write daemon file on /usr/local/etc/rc.d/ with ".sh" ext.
  rcd='/usr/local/etc/rc.d/'
  dfile=${rcd}${script%%.*}.sh
  printf "${rc_f}" > "${dfile}" && chmod +x "${dfile}" && ln -s "${dfile}" "${rcd}${dname}"

  # Enable service on rc.
  sysrc -e "${dname}_enable=YES"

  # Show service name.
  printf "[+] Sysrc service ( ${dname} ) created on ${dfile} !\n"
  exit
}


# Function deploy systemd service.
systemd_() {

  script=$1
  # Systemd deamon file content.
  ctl_f='[Unit]\nDescription='${script%%.*}' service\nAfter=network.target\nStartLimitIntervalSec=0\n\n[Service]\nType=simple\nRestart=always\nRestartSec=1\nUser=root\nExecStart='${PWD}'/'${script}'\n\n[Install]\nWantedBy=multi-user.target'

  # Write daemon file on '/etc/systemd/system/' with ".service" ext.
  dfile='/etc/systemd/system/'${script%%.*}'.service'
  printf "${ctl_f}" > "${dfile}" && chmod +x "${dfile}"

  # Show service name.
  printf "[+] Systemd service ( ${script%%.*} ) created on ${dfile} !\n"
  exit
}


# Function run deploys.
run_() {

  # Check system and run.
  [ -f '/usr/sbin/sysrc' ] && sysrc_ "$1" || [ -f '/usr/bin/systemd' ] && systemd_ "$1" ||
  # Cant execution info.
  printf "[-] Cant locate sysrc or systemd.\n" && exit
}

# Start execution if first arg is a file.
[ -f "$1" ] && run_ "$1" || printf "[-] Require a script as argument.\n[-] Run: $0 script.py\n"
