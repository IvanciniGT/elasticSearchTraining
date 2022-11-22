# Elastic

## ElasticSearch

It is a search engine / Index JSON documents

### Index: 

Is a collection of shards (each shard is a lucene process) which index a portion of the documents contained in that index.
In each shard, we may store a copy of the original document indexed.

We have Primary shards and replica shards
- Primary: Scalability
- Replica: High availability

An index can be in different states:
- Open      Allows us to add new documents, update existent documents, delete documents, and search documents
- Frozen    We can only search for documents
- Closed    That index is there only for keep the information alive... But while the index is closed,
            the info included in the index is useless

An Index may have:
- Aliases: Alternative names for that index. We may have a bunch of them. Specially useful for searches
- Mappings: That instructs ElasticSearch on how to index each field:
    - Datatypes....
- Custom Settings: Number of shards, number of replcias, routing algorithm

We want to have a bunch of indexes... even for storing the same kind of info. Maybe one per month, day... hour.
That gaves us the possibility of closing / freezing indexes, so ES (Lucene) could optimize the inverted indexes
inside the Index (file segments)

## About an ES Cluster arquitecture.

ES Is a distributed system.
Different types of nodes (masters, data (hot, cold), ingest, coordinators)

# Kibana

Kibana is just a GUI(web app):
- Analytics 
    - Discover : Search for documents
    - Dashboards
    - Canvas: Kind of dashboards, but they are ment to be printed or proyected in a TV
- Observability
    - Monitor events
    - Machine learning features
- Stack monitoring. Not that powerful... but enough for most scenerios.
- Stack managment
    - Manage indexes, index templates
    - Data view: Is just an index pattern, selecting indexes, that we will use in all kibana


Apache Web Server 1             ES Cluster
    access_log                      Node 1
Apache Web Server 2         =>          apache_access_logs_2022_01              CLOSED          Frozen data node
    access_log                      Node 2
Apache Web Server 3                     apache_access_logs_2022_02              CLOSED          Frozen data node
    access_log                          apache_access_logs_2022_03              CLOSED          Frozen data node
                                        apache_access_logs_2022_04              CLOSED          Frozen data node
                                        apache_access_logs_2022_05              CLOSED          Frozen data node
                                        apache_access_logs_2022_06              CLOSED          Frozen data node
                                        apache_access_logs_2022_07              CLOSED          Frozen data node    HDD 5400
                                        apache_access_logs_2022_08              FRONZED         cold data node. HDD 7200
                                        apache_access_logs_2022_09              FRONZED         warm data node. HDD + SDD(cache)
                                        apache_access_logs_2022_10              FRONZED         warm data node  HDD + SDD(cache)
                                        apache_access_logs_2022_11              OPENED          hot data node   NVME + SSD
                                        ...
Once each moth ends, we are going to freeze that index... By doing that, ES (Lucenes) 
                                                          will improve the internal index structure
We are only going to keep frozen last 3 months indexes
Once an index have been frozen for motre than 3 months, we will close that index

We can easily define those rules in kibana: Index LifeCycle Managment

But then ... Do I need to reconfigure all my dashboards and canvas?
No.. as you are using Data Views... Which work with that INDEX PATTERN CONCEPT: apache_access_logs_*
I'm, going to be able to search just in NON CLOSED indexes

## Beats

They are small programs (daemons) which allow us to extraect information from different sources and ship that to :
- ES
- Logstash

Beats family:
- Filebeat
- Heartbeat
- MetricBeat
- WinlogBeat
- Auditbeat

## Logstash

It allows us to create PIPELINES, which can tranforms the information while sending that to ES

--------------------------------------------------------------------------------
Imagine I have an index with 8Gbs of information

We said that for doing a search, Lucene needs to have the hole index in Memory

Would it be ok to split that index in 2 partitions, or not? To have 2 primary shards

Benefits of having 2 primary shards vs 1 single shard?
- We are probably going to have a better performance in get and write operations : SCALABILITY
    -  By "get",... I mean, to access (recover) 1 single document by its ID.
    -  We are completly sure that those ops are going to be faster!
        As I have 2 different lucenes stores and recovering each document.
- What about searches? Are they going to be faster? Not sure sure !
    - By "search"... I mean to look for 500 documents, and to recover them all.
    - If I have to look for the info in 2 different places... Then I won't be able to perform 2 searches at a time.
        - If this is all the problem... Performance is not going to be worst... just the same as if we have just 1 primary shard
            And... I can solve this situation just by having more replicas.
        THIS IS NOT THE ACTUAL PROBLEM. We have a problem that could make out searches even slower that before (1 single primary shard)
    - Remember that eachlucene is going to return its won information (documents) and those are gonna be sorted.
        But I I receive documents from 2 different lucenes, I need to join those sets.... 
        And It will be required to re-sort the whole resultset

        First Lucene: 1 4 6 8 9
        Second lucene: 2 7 11
        Mix them: 1 4 6 8 9 2 7 11 -> 1 2 4 6 7 8 9 11. ... This operation is time consuming
        
        That's we reason in ES we have a special Node type for dealing with this kind of problems: COORDINATOR NODE TYPE
    *** SOLUTIONS... in a little bit
    
 - There is something else here !
    
    Imagine I have that index: 8 Gbs of Space
    If I have 2 primary shards. How much are they going to require (Gbs of space)?
        Whole Index was 8 Gbs when it was stored in just 1 primary shard
                            2 primary shards                                    |       4 primary shards
                        What we expect          What we are going to see        |   Each: 4-5 Gbs
        IndexA_P1       4Gbs    5Gbs            5-7 Gbs - drive A (nodeA)       |
        IndexA_P2       4Gbs    3Gbs            5-7 Gbs - drive B (nodeB)       |
                        -------------           --------                        | -----------------
                        8 Gbs.  8 Gbs           10 - 14 Gbs                     |   Up to 20 Gbs of memory and space in my drives.
                        
        If I have 1 single primary shard... I need 8 Gbs in the drive... but in addition in the server's RAM MEMORY
        If I have 2 primary shard...        I need 10-14 Gbs in the drives... but in addition in the servers' RAM MEMORY
        
        I'm going to have a waste of resources.


            Document 1:                             Document 2:
            {                                       {
                name: Ivan Osuna.                       name: Gianmarco Osuna
                age:  44                                age: 44
                married: false                          married: false
            }                                       }
        
        SCENERIO WITH 2 PRIMARY shards
        
            PrimaryShard 1                          PrimaryShard 2
            
            FIELD   TERM    OCCURENCY               FIELD   TERM            OCCURENCY
            name    Ivan    Document1(position 1)   name    Gianmarco       Document2(position 1)
                    Osuna   Document1(position 2)           Osuna           Document2(position 2)
            age     44      Document1               age     44              Document2
            married false   Document1               married false           Document2
            
            Can you see that terms are repeted... Same terms appear in both shards?
                "Osuna"
                "44"
                
        SCENERIO WITH 1 PRIMARY SHARD:
        
            FIELD   TERM            OCCURENCY               
            name    Ivan            Document1(position 1)   
                    Gianmarco       Document2(position 1)
                    Osuna           Document1(position 2), Document2(position 2)   
            age     44              Document1, Document2               
            married false           Document1               
                
            The term 44 only appears once in the index (In 2 difefrent documents)... 
                but the term is stores only once in the drive.. and in Memory
            Same thing happens with term "Osuna"
                
Probably when an index is closed... what is the best option? Just 1 primary shard
If the index is frozen... its shards are going to be used in gets and searchs... So... I need to decide what to do here
If the index is open....  its shards are going to be used also for writes (index)

On of the things that are gonna impact the number of primary shards I'm gonna define is how often terms appear in the documents
Probably it can be a better idea, to create 1 index for each web server of our example... with just 1 shard.
And each index (server1, server2, server3) can be stored in its own index (es node)

How much space do I use for terms inside an Index:
Kibana gives that infromation for each index.
    Index A:                8 Gbs
        terms:              3 Gbs
        data
            occurrencies:   5 Gbs
    
    If I split that index in 2 shards: 
    Index A                 Shard 1             Shard 2
        terms                 almost 3 Gbs        almost 3 Gbs          -> 6 Gbs
        data
            occurrencies:     2.5 Gbs             2.5 Gbs               -> 5 Gbs
                                                                        --------
                                                                          11 Gbs
    
    We will have at least "3 copies" of those shards
        1 Primary shard: 8 Gbs x 3   = 24 Gbs
        2 Primary Shards: 11 Gbs x 3 = 33 Gbs
                                     ---------> 9 extra Gbs of HDD and RAM memory
    
    If I have 1 index per week: 52 indexes a year: 52 x 9 = 500 Gb.. almost 0.5 Tbs
    
How to really improve performance when we split an index in more Shards:
We need to analyze the kind of searches that are expected

We said we will have for our apache example, 1 index per month.
But... how are people going to search inside those indexes.
Maybe I have clients from Spain, Italy, Germany, France, Greece
    I'm going to have a buch of searchs just looking for 1 single country.
    I may have any search looking for the info of all the countries
    
    In this scenerio... what do you think that could be a good Idea? To split the index in how many shards?
    Probably 1 per country: Spain, Italy, Germany, France, Greece: 5 shards
    
    So that each shard contains information about 1 single country. => I would need to configure a custom Routing algorithm 
        By default ES routes each document randomly.
        ES generates a HASH of the ID of each document. The HASH is just a number... And is going to divide that number
            between the number of primary shards. And ES is going to get the remainder of that operation:
            
            ABC123 -> 1287189718937189713 / 2 primary shards = Result... But ES doesn't care about that result...
                                                                         It cares about the remainder -> Is going to be the 
                                                                            shard where the document is going to be stored
                      7 / 2 
                        ------
                     -6   3
                      1 <<<< REMAINDER (which would be between 0 and the number of shards less 1)
            
    
    I cannot change the number of shards afterwards. And even if I could... The routing algorithm is going to route 
        documents in a different way.. So Spain is never going to be stored in teh same shard as before.
        
        We can... just a Bit:
            I can split each shard in 2 shards.
            Or I can join shard 
            
        3 shards -> 6 shards... never to 5 or 7 
                       |
                       V 
                       3 shards back 
                       

Tomorrow, we will install heartbeat and metric beat...
    We will send that information to ES thru logstash
We will se how to configure a routing algorithm.
We will activate monitoring in our cluster thru Kibana
And we will do all that with a whole new cluster (big one) that I will provide to you all.

Container
Apache < --- Filebeat ----> Logstash -----> ES  < ---- Kibana
       < --- Heartbeat ---> Logstash -----> 
       < --- Metricbeat
            Monitor containers metrics
            
            
HOST
    Docker
        Container heartbeat