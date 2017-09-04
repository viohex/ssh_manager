# ssh_manager      
description: manager remote host login info   
attention: before use s.sh , you should configure your remote host info into remote_host.cfg file  
platform: it is wirte by shell, so you can run it on any platform which support shell(bash or sh),  
the platform need install expect which is an open source software, too.   

usage:  
   s.sh       to print all remote host info   
   s.sh id    to login remote host which identify is id  
   
at lastly, you can create a symbolic linker /bin/s to path_to_s.sh/s.sh  by shell cmd: sudo  ln -s path_to_s.sh/s.sh /bin/s   
now you can you s.sh by :    
usage:   
   s       to print all remote host info   
   s id    to login remote host which identify is id   

