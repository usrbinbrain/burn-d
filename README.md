# Burn-d

**Burn-d configures your script as a daemon on operating systems managed by systemd and sysrc.**


### _Features._
- Automatically identifies the operating system management system, [systemd](https://wiki.archlinux.org/index.php/Systemd_) (Linux) or [sysrc](https://www.freebsd.org/cgi/man.cgi?query=sysrc) (FreeBSD).
- Allows you to deploy any type of script.
- After executing the deploy of the daemon, just start the created service.


---
### _Install._
Clone repo and modify `burn-d.sh` execution permissions.

```bash
git clone https://github.com/usrbinbrain/burn-d.git && cd burn-d && chmod +x burn-d.sh
```
For a better experience create and add `burn-d` alias in your bashrc.
```bash
alias burn-d=$PWD/burn-d.sh && echo "alias burn-d=$PWD/burn-d.sh" >> $HOME/.bashrc
```

---
### _Execution._
After installation, just access the script directory that will be configured as a daemon.

Run `burn-d` passing your script as the first argument for the management system to be identified and the daemon file created.

Let's assume that the directory is `/home/user/script` and the script has the name `target_script.py`

```bash
# Access path script.
$ cd /home/user/script
# Run burd-d with script.
$ burn-d script_target.py
```
##### Expected output in systemd environments.
```
[+] Systemd service ( script_target ) created on /etc/systemd/system/script_target.service !
```
To start your new daemons configured in systemd reload the systemctl then enable the daemon and start

```bash
systemctl daemon-reload && systemctl enable script_target && systemct start script_target
```

---
##### Expected output in sysrc environments.
```
script_target_d_enable="YES" # -> "YES"
[+] Sysrc service ( script_target_d ) created on /usr/local/etc/rc.d/script_target.sh !
```
When deploying the deamon in the sysrc managed environment, the deamon is already enabled by default at the boot of the operating system, so just start deamon with the following command.
```bash
service script_target_d start
```
---
