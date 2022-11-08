
# Indexes in ElasticSearch

An Index is a collection of inverted indexes. In addition, within that collection of inverted indexes, ElasticSearch can also store a copy of the indexed document.

ElasticSearch splits indexes in SHARDs. 

A shard is a portion of that collection of inverted indexes.
An index is split in Shards... But we have 2 different types of shards:
- Primary shards
- Replica Shards: Is just a copy of the information stored inside a primary shard

                                            SERVERS in our ES Cluster
                                Server 1        Server 2             Server 3         Server 4
Index: ApacheLogs (5 shards x 3 copies)
    ApacheLogs S0                 (*)              (1)                                  (2)         ALE1
    ApacheLogs S1                 (1)              (*)                  (2)
    ApacheLogs S2                                  (1)                  (*)             (2)
    ApacheLogs S3                                  (1)                  (2)             (*)         ALE2 ALE4
    ApacheLogs S4                 (*)                                   (1)             (2)         ALE3


    Query every single ALE:  S0 + S1 + S2 + S3 + S4. Once I get the information from everybody... what should I do?
        Can I just group all that information all together and return that to whoever queries me? NO
        S0: 1000 sorted entries: server1: 100, server2: 200, server 8, 900
        S1: 2000 sorted entries: server3: 150, server4: 200, server 5, 300
        S2: 1500 sorted entries
        S3: 1200 sorted entries
        S4: 2200 sorted entries
    --------------------------------------------------
        server1: 100, server3: 150, server2: 200, server4: 200, server5: 300, server 8, 900 

How many shards do we have in this index? 5 primary shards and 10 replica shards = 15 shards
Do you know what a shard actually is ? An Apache LUCENE !

ApacheLog Entry comes 

( ) Means a SHARD
(*) Means PRIMARY SHARD
(#) Means REPLICA SHARD

Why do we want PRIMARY shards?      SCALABILITY
Why do we want REPLICA shards?      HIGH AVAILABILITY


# Production Environment: 2 characteristics 
- High Availability
    We will TRY to accomplish with a preset agreement regarding TIME OF SERVICE of our system.  | 
        The system is going to be fully up and running 90% of the time it supposed to be up.    |
                                                           36,5 days a year : System offline    | €
        The system is going to be fully up and running 99% of the time it supposed to be up.    | €€
                                                           3,65 days a year : System offline... | €€€€
        The system is going to be fully up and running 99,9% of the time it supposed to be up.  | €€€€€€€€€
                                                           8 hours a year : System offline...   | €€€€€€€€€€€€€€€
        The system is going to be fully up and running 99,99% of the time it supposed to be up. | €€€€€€€€€€€€€€€€€€€€€€€€€€€€
                                                           20 minutes a year : System offline...V
    We try to avoid Information lost!
        I'm going to store information in multiple devices. At least 3 times
    Replication


- Scalability
    To adjust the infrastructure to each moment need.

        App: INTERNET                                                   Website Dominos Pizza
            day n           100 users
            day n+1         1.000.000 users         Black friday
            day n+2         1000 users
            day n+2         20.000.000 users        Cybermonday


In an ElasticSearch cluster we will have a bunch of servers.

But ElasticSearch is a Distributed System => That means that each server is going to be doing a different thing.
Each ElasticSearch instance that we may have running in a server is called a Node
We have a number of node types in ElasticSearch.
                                                                        MIN Number of Data nodes in a production env?
- Data nodes: They store shards                                     At least 2 (min HA)... In the practice, at least 3
                                                                        2, 3, 4, 5, 6.....
- Master nodes: They orquestrate the workload.                          3, 5, 7, 9 (To avoid what we called a BRAIN SPLIT)
                They decide where each shard is going to be placed 
- Coordinator nodes: A node which is going to receive queries, and to process queries' results before answering to the client
- Machine learning nodes
- Ingest nodes

# Distributed System?

It is a system with different parts running in different places

A cluster of 5 Apaches is a Distributed system? NO










ES Cluster
    Data 1              Master 1
    Data 2              Master 3
    Data 3              Master 2
                            Master election is done by quorum (2)

At any point of time, we could only have 1 ACTIVE MASTER