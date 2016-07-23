# spark-on-windows_dxc
spark on windows
####spark在windows上进一步支持。
在windows环境下，原本开源只支持通过bin目录下的spark-class脚本，去起master，worker等等。
和在linux下启动集群的方式很不一样。

这里基本支持了使用sbin目录下的脚本，去启动集群的功能

    start-master.cmd          启动master节点
    start-local-slave.cmd     启动本地worker节点 不需要指定master的url
    start-slave.cmd           启动本地worker节点   需要指定master的url
    start-slaves.cmd          启动远程的worker节点
    
    start-history-server.cmd   启动history-server
    start-shuffle-service.cmd  启动shuffle-service
    start-thriftserver.cmd     启动thriftserver
    
    spark-daemon.cmd          其他start/stop脚本都是通过调用spark-daemon.cmd来完成功能的
    
    remote-slaves-getCredential.ps1   在进行远程机器登录的时候，需要远程机器的凭证，所以必须
                                      先在远程机器上运行这个脚本，将凭证传到master点上                                           
                                      
                                      
    remote-slaves-daemon.ps1         在登录远程slave节点，启动worker进程的时候，会调用这个脚本，登到远程机器，去起进程。
                                     认证方面是通过各个slave节点传过来的凭证进行认证的

