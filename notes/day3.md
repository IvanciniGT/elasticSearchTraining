# Index in ElastiSearch is

It is a collection of Shards.
What is a shard? It is an Apache Lucene process... in charge of: indexing documents and searching for them

Each shard has a PRIMARY copy... and a bunch of replicas

Primary shards provide SCALABILITY
Replicas provides HIGH AVAILABILITY

In ES, nodes perform different tasks:
                        HOW MANY DO WE NEED
- Data nodes                At least 2 
                                One of them, we will configure it as a master node.... just for voting
- Master nodes              At least 3 (5...7..9). The truth is that we are going to have just 2
                            
- ----------
- Coordinators
- Ingest nodes
- Machine learning

How many active master nodes are we going to have ? JUST 1
Do we really need 3, just in case????


3 real master nodes
+ 2 voting nodes (master... but without the possibility of acting as masters)



Whenever we create a container, we always use a container image.

What is a container image?
Is just a compressed file (tar) containing:
- An installation of a software
- Additional commands, libraries and tool which may be interesting to have installed...

I decide to install MSOffice in my computer
1 - Download an Installer
2 - Execute the installer
c:\Program Files\Office ---> compress -> zip ---> email

What a container is?
An isolated environment inside a Linux OS where we can run processes.
Isolated:
- Each container is gonna have iots own network configuration ... and its own IP address
- Each container has its own env vars
- Each container has its own filesystem
- Each container can have limits in order to access the HW resources of the host

nginx is a Reverse proxy ----> Web servers: 80 (http) or 443 (https)

In every container image we have a set of useful commands, such as:
        ls                      alpine
        mkdir
        cat
        rm
        sh
        
                                ubuntu
        bash
        apt
        apt-get
                                fedora
        bash
        yum
        
        
        
Each container has its own FileSystem

HOST:           
        /
                bin/
                opt/
                var/
                        lib/
                                docker/
                                        volumes/
                                                        elasticVolume1/
                                                                        files
                                        containers/
                                                ....
                                                        elasticsearch/
                                                                var/lib/elasticsearch/
                                                                                        ES is going to store all the inverted indexes
                                                        mynginx/ This folder is overlapped onto the image folder
                                                                bin/
                                                                        file.txt
                                        images/
                                                ....    # THIS IS THE BASE LAYER OF A CONTAINER FileSystem
                                                        nginx/ ****     This is available in UNIX since 1990... chroot
                                                                bin/
                                                                        ls
                                                                        chmod
                                                                opt/
                                                                var/
                                                                home/
                                                                root/
                                                                tmp/
                                                                sbin/
                home/
                root/
                tmp/
                sbin/
                
                We cheat process running inside a container to make them think that THIS FOLDER **** is the root folder
                
    
  ------------------------------------------------------------------------ Amazon network
  |                                                                     |
  172.31.3.117                                                          Your computers 
  |     NAT   :8080
 HOST             |  
  |               v
  |---172.17.0.2:80----nginx Container
  |
  docker virtual network