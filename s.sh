#!/bin/sh

#get this script real directory
SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    this_script_dir="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    # if $SOURCE was a relative symlink, 
    #we need to resolve it relative to the path 
    #where the symlink file was located
    [[ $SOURCE != /*  ]] && SOURCE="$this_script_dir/$SOURCE"
done
this_script_dir="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"


config_file_name="$this_script_dir/remote_host.cfg"
expect_ssh_path="$this_script_dir/vlogin.sh"
show_fmt="%24s%14s%8s %s\n";

#param:
#   1,username 2,ip 3,passwd 4,id 5,description
print_one_host_info()
{
    pass=$3;
    if [ 16 -lt ${#pass} ];then
        show_passwd="???";
        show_description="???"
    else
        show_passwd=$3;
        show_description=$5;
    fi
    uip=$1"@"$2;

    printf "$show_fmt" \
        "$uip" \
        "$show_passwd"  \
        "$4" \
        "[$show_description]"; 
}

print_line()
{
    for((print_line_i=0;print_line_i<${1:-80};++print_line_i))
        {
            printf "-";
        }
        printf "\n";
}


###############################script entry##################

if [ ! -f "$config_file_name" ];then
    echo "file [$config_file_name],dose not exist!"
    exit
fi

if [ ! -f "$expect_ssh_path" ];then
    echo "file [$expect_ssh_path],dose not exist!"
    exit
fi

#temp_cfg=`mktemp`
#set variable in this shell
#read my private machine information
config_file_name_private="$HOME/Documents/private/remote_host_private.cfg"
if [  -f "$config_file_name_private" ];then
    eval `sed '/^[ ]*#/d' "$config_file_name_private" | \
        awk 'BEGIN{ FS="!!" ; 
    i=0 }
    {
        printf("user_name[%d]=\"%s\"\n\
            host_ip[%d]=\"%s\"\n\
            user_passwd[%d]=\"%s\"\n\
            id_of_ip[%d]=\"%s\"\n\
            ssh_port[%d]=\"%s\"\n\
            description[%d]=\"%s\"\n",
        i,$1,
        i,$2,
        i,$3,
        i,$4,
        i,$5,
        i,$6);

        ++i;
    }  
    END{printf("index_of_item=%d",i)}'` 
else
    index_of_item=0;
fi

eval `sed '/^[ ]*#/d' "$config_file_name" | \
    awk 'BEGIN{ FS="!!" ; i='$index_of_item'}
{
    printf("user_name[%d]=\"%s\"\n\
    host_ip[%d]=\"%s\"\n\
    user_passwd[%d]=\"%s\"\n\
    id_of_ip[%d]=\"%s\"\n\
    ssh_port[%d]=\"%s\"\n\
    description[%d]=\"%s\"\n",
    i,$1,
    i,$2,
    i,$3,
    i,$4,
    i,$5,
    i,$6);

    ++i;
}  
END{ }'` 



if [ "help" == "$1" ]||[ "h" == "$1" ]||[ ! -n "$1" ];then
num_of_host=${#user_name[*]}

printf "$show_fmt" "user@ip" "passwd" "id" "description" ;
print_line
    for((i=0;i<num_of_host;++i));do
        #   1,username 2,ip 3,passwd 4,id 5,description
        print_one_host_info "${user_name[i]}" \
            "${host_ip[i]}" \
            "${user_passwd[i]}" \
            "${id_of_ip[i]}" \
            "${description[i]}";
done
exit 0;
fi

#try to login the remote computer by ssh
for (( i=0; i<${#id_of_ip[*]}; ++i )); do
    if [ "${id_of_ip[i]}" = "$1" ] ; then
        this_mac_ip=`/sbin/ifconfig -a`
        if [ "`whoami`" != "${user_name[i]}" ] \
            || ! echo "$this_mac_ip" | grep -i -E "${host_ip[i]}" \
            > /dev/null ; then
        printf "$show_fmt" "user@ip" "passwd" "id" "description" ;
        print_line #this function take variable namespace populate
        #   1,username 2,ip 3,passwd 4,id 5,description
        print_one_host_info "${user_name[i]}" \
            "${host_ip[i]}" \
            "${user_passwd[i]}" \
            "${id_of_ip[i]}" \
            "${description[i]}";

        eval "$expect_ssh_path ${user_name[i]} ${host_ip[i]} \
            ${user_passwd[i]} ${ssh_port[i]}" 
        exit 0;
    else
        printf "%s current machine's ip is already [ %s ],\
            which you want to login.\n" "--" "${host_ip[i]}"
        exit 0;
    fi
fi
done

#if do not find id in configure file
printf "id [%s] donot found in configure file,please check!\n" "$1"


exit 0;
#######################################################################
##eval `grep -E -i -n "1_ip"  "$temp_cfg" | \
##    awk 'BEGIN {i=0;} {host_ip[i]=$NF; i++} \
##    END {for(i=0;i<NR;i++) \
##    printf( "host_ip[%d]=%s\n", i, host_ip[i])}'`
##
###for ip in ${host_ip[*]}; do
###echo $ip
###done
##
##
##
##eval `grep -E -i -n "2_user_name"  "$temp_cfg" | \
##    awk 'BEGIN {i=0;} {user_names[i]=$NF; i++} \
##    END {for(i=0;i<NR;i++) \
##    printf( "user_names[%d]=%s\n", i, user_names[i])}'`
##
###for user in ${user_names[*]}; do
###echo $user
###done
##
##
##eval `grep -E -i -n "3_passwd"  "$temp_cfg" | \
##    awk 'BEGIN {i=0;} {user_passwd[i]=$NF; i++} \
##    END {for(i=0;i<NR;i++) \
##    printf( "user_passwd[%d]=%s\n", i, user_passwd[i])}'`
##
###for pd in ${user_passwd[*]}; do
###echo $pd
###done
##
##eval `grep -E -i -n "4_description"  "$temp_cfg" | \
##    awk -F '"' 'BEGIN {i=0;} {description[i]=$2; i++} \
##    END {for(i=0;i<NR;i++) \
##    printf( "description[%d]=\"%s\"\n", i, description[i])}'`
##    #printf( "description[%d]=%s\n", i, description[i])}'`
##
###for desc in ${description[*]}; do
###echo $pd
###done
##
##eval `grep -E -i -n "5_id"  "$temp_cfg" | \
##    awk 'BEGIN {i=0;} {ids[i]=$NF; i++} \
##    END {for(i=0;i<NR;i++) \
##    printf( "ids[%d]=%s\n", i, ids[i])}'`
##
###for ids_ in ${ids[*]}; do
###echo $pd
###done
##
##if test -f "$temp_cfg"; then
##    rm "$temp_cfg"
##fi
##
##printf "##%s||%s||%s||%s||%s||%s\n"  \
##    "user" "ip" "password" "id" "ssh_port" "description" > remote_host.cfg;
##
##    for (( i=0; i<${#ids[*]}; ++i )); do
##        printf "%s||%s||%s||%s||22||%s\n" \
##            "${user_names[i]}" \
##            "${host_ip[i]}" \
##            "${user_passwd[i]}" \
##            "${ids[i]}" \
##        "${description[i]}"  >> remote_host.cfg
##done
##
##################################
##exit 0;
##
##if [ "help" == "$1" ]||[ "h" == "$1" ]||[ ! -n "$1" ];then
##    printf "%24s %12s %8s  %s\n" \
##            "user&ip" "password" "id" "description" 
##        echo "-----------------------------------------------------------------------------"
##    for (( i=0; i<${#ids[*]}; ++i )); do
##        printf "%24s %12s %8s  [%s]\n" \
##            "${user_names[i]}@${host_ip[i]}" "${user_passwd[i]}" "${ids[i]}" "${description[i]}" 
##    done
##    exit 0
##fi
##
###try to login the remote computer by ssh
##for (( i=0; i<${#ids[*]}; ++i )); do
##    if [ "${ids[i]}" = "$1" ] ; then
##        #echo ${ids[i]} 
##        this_mac_ip=`/sbin/ifconfig -a`
##        if [ "`whoami`" != "${user_names[i]}" ] \
##           || ! echo "$this_mac_ip" | grep -i -E "${host_ip[i]}" > /dev/null ; then
##            printf "%12s@%-18s %9s %8s    [%s]\n" \
##                "${user_names[i]}" "${host_ip[i]}" "${user_passwd[i]}" \
##                "${ids[i]}" "${description[i]}" 
##
##            eval $expect_ssh_path "${user_names[i]}" ${host_ip[i]} ${user_passwd[i]} 
##            exit 0;
##        else
##            printf "%s current machine's ip is already [ %s ],which you want to login.\n" "--" "${host_ip[i]}"
##            exit 0;
##        fi
##    fi
##done
##
###if do not find id in configure file
##printf "id [%s] donot found in configure file,please check!\n" "$1"
##
##
