#!/bin/sh
#
# Script Name   :burn-d.sh
# Description   :Configure script as a daemon on systems managed by systemd or sysrc.
# Args          :script file on first argument.
# Script repo   :https://github.com/usrbinbrain/burn-d
# Author        :G.A.Gama

# Function deploy sysrc service.
sysrc_() {
  local script=$1
  # Sysrc daemon name.
  local dname=${script%%.*}_d
  # Write daemon file on /usr/local/etc/rc.d/ with ".sh" ext.
  local rcd='/usr/local/etc/rc.d/'
  local dfile=${rcd}${script%%.*}.sh

  # Write config file service on "/usr/local/etc/rc.d/".
  cat > ${dfile} <<EOF
#!/bin/sh
. /etc/rc.subr
name=${dname}
rcvar=${dname}_enable
pidfile="/var/run/\${name}.pid"
logfile="/tmp/\${name}.log"
script_command="${PWD}/${script}"
command="/usr/sbin/daemon"
command_args="-P \${pidfile} -o \${logfile} -r -f \${script_command}"
load_rc_config \$name
run_rc_command "\$1"
EOF

  # Add execution mode and create daemon shortcut.
  chmod +x "${dfile}" && ln -s "${dfile}" "${rcd}${dname}"

  # Enable service on rc.
  sysrc -e "${dname}_enable=YES"

  # Show service name.
  printf "[+] Sysrc service ( ${dname} ) created on ${dfile} !\n"

  exit
}


# Function deploy systemd service.
systemd_() {
  script=$1
  # Write daemon file on '/etc/systemd/system/' with ".service" ext.
  dfile='/etc/systemd/system/'${script%%.*}'.service'

  cat > ${dfile} <<EOF
[Unit]
Description=${script%%.*} service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=${PWD}/${script}

[Install]
WantedBy=multi-user.target
EOF

  # Add execution mode.
  chmod +x "${dfile}"

  # Show service name.
  printf "[+] Systemd service ( ${script%%.*} ) created on ${dfile} !\n"
  exit
}


# Function run deploys.
run_() {
  #Check OS
  os=$(uname)
  [ "${os}" == 'FreeBSD' ] && sysrc_ "$1" || [ "${os}" == 'Linux' ] && systemd_ "$1" ||
  # Cant execution info.
  printf "[-] Cant locate sysrc or systemd.\n" && exit
}

# Start execution if first arg is a file.
[ -f "$1" ] && run_ "$1" || printf "[-] Require a script as argument.\n[-] Run: $0 script.py\n"
