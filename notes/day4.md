
An index in Elastic is just a collection of Lucenes (shards)

We want a bunch of lucenes for having scalability

Each lucene stores its information (innverted indexes) inside files that we call SEGMENTS

ES -> Index 20 docs -> 1 or more Lucenes

Maybe 1 lucene is going to get 5 docs.
For those 5 documents, lucene is going to create inverted indexes

SEGMENT FILE / this file structure improves writes performance!
             / The counterpart is that when Lucene needs to read that file... 
                                It takes a lot of time to consolidate the information in Memory
ball            500 (2)
red             100 (1)
-----------
ball            5 (2)
color           2 (3)
football        5 (1)
lamp            1 (2) 3 (2)
little          3 (1) 4 (1)
notebook        2 (1) 4 (2)
red             1 (1) 2 (2)
-----------------------------> that inforation is just append to the end of the current segment file.
-----------------------------> At the same time, that information is aggregated with all the current SHARD 
                               information in MEMORY
MEMORY
ball            500 (2) 5 (2)
color           2 (3)
football        5 (1)
lamp            1 (2) 3 (2)
little          3 (1) 4 (1)
notebook        2 (1) 4 (2)
red             1 (1) 2 (2) 100 (1)

Is it worthy for lucene to rewrite segments files with the information consolidated?
I would only be worthy if the file contents (shard documents) are not going to change anymore!

Documents are products that people buy



Imagine we want to index Our App1 Apache logs (5 serves).

How many indexes do I want?
Do I want everything in just 1 single index or not? FOR SURE NO !

How many indexes then? 1 per day | 1 per week | 1 per month | 1 per hour
Why?
Because when a day ends... I know that no more logs are going to be added to that day... ---> Rewrite segment files
    CLOSE a INDEX

App3-nginx-logs-2022-01 - Multiple aliases < Webserver101-2022-01

App1-apache-logs-2022-01 - Multiple aliases < Webserver1-2022-01
App1-apache-logs-2022-02
App1-apache-logs-2022-03
App1-apache-logs-2022-04
App1-apache-logs-2022-05
App1-apache-logs-2023-01

App2-apache-logs-2022-01
App2-apache-logs-2022-02
App2-apache-logs-2022-03
App2-apache-logs-2022-04
App2-apache-logs-2022-05

What is gonna happen if I want to do a search?
# of errors in App1

Data view in Kibana: 
    Index-pattern-1: App1-apache-*
    Index-pattern-2: App2-apache-*
    Index-pattern-3: *-apache-*
    Index-pattern-3: Webserver*


Apache
    -> Logs     < - Filebeat -> Logstash -> ES < - Kibana
                                Index template
                                    settings
                                    mappings