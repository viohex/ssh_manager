#!/usr/bin/expect
set v_passwd "*assword*"
set timeout 8
set user_name   [lindex $argv 0 ]
set host_ip     [lindex $argv 1 ]
set user_passwd [lindex $argv 2 ]
set ssh_port    [lindex $argv 3 ]
spawn ssh -l $user_name $host_ip  -p $ssh_port
expect {
    "$v_passwd"    
    {
        send "$user_passwd\r"
    }
    "*yes/no*"    
    {
        send "yes\r"
        exp_continue
    }
    "Last login*" 
    {

    }
}
interact

