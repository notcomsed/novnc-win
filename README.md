# novnc-win
This is noVNC version which can run at win cmd natural without mingw32(git-bash) or Cygwin

start cmd

cd noVNC\utils

novnc_proxy --listen 8080 --vnc 127.0.0.1:5900

need install python <br />
recommand conda

[original docs](https://github.com/notcomsed/novnc-win/blob/master/README_bk.md)

windows下可以直接使用<br />
直接下载解压在一个目录就行，集成了websockify-0.10.0，novnc原始版本为1.3.0<br />
可以配合TightVNC实现windows下web云桌面<br />
可以使用nginx下开启ssl

玩的开心
