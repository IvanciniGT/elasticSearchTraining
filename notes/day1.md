
# Elastic Inc?

Is just company producing Software:
- ELK Stack:
  - ElasticSearch
  - Kibana
  - Logstash
  - Beats family

# ElasticSearch?

ElasticSearch is a Search engine. It allows us to Index documents.
Is similar to Google search engine.

## Doesn't databases already search information?

Databases... they store information... and they allow us to retrieve that information afterwards.
- SQL Databases             Oracle, MySQL, SQL Server, MariaDB, PostgreSQL
- NoSQL Databases           MongoDB (Not Only SQL)
  - Hierarchical databases              Adabas, Tamino
  - Document oriented databases         MongoDB
  - Graph databases                     Neo4J

I've heard that database engines are extremely efficient in order to retrieve information... It depends... on the type of information... and the queries.

    > SQL Engine(oracle): Table

        People
        First name      Last name           Age     Email           Married
        Ivan            Osuna               44      ivan@ivan.com       x       
        Marco           Pellino             29      marco@marco.com     x
        ...
        ....
        Luca            Conforti            28      luca@luca.com       √           1 million  rows

    I want to query for information. I want to get all the people from this table who are older than 28.
        - DB needs to go thru all the rows.. to check wether the age is bigger than 28. --->             TABLE FULL SCAN
    In order to solve this situation (try to avoid a FULL SCAN of the people table)... what can we do?
        - Create an Index... 

# Imagine we have the age ORDERED !

In that case we can do a Improved Binary Search. Since you were 10 years old... probably before that...
How do you search in a dictionary?

    x 10
    x 10
    x 10
    x 12
    x 13
    x 20
    x 27 <<<<<
    x 28 <<<<<
    √ 30
    √ 39 <<<<<
    √ 39
    √ 40
    √ 45

  1.000.000       In 21 split we found the relevant information
    500.000
    250.000
    125.000
     65.000
     33.000
     17.000
      9.000
      4.500
      2 500
      1.300
        700
        350
        180
         90
         45
         23
         12
          6
          3
          2
          1

    cheese 20% - 80%        Because You know how words are distributed <- Table Statistics
    yellow 90% - 10%

# Problems related to sorting

1- Computers are really bad at it.
2- I can only pre-sort(store) the information sorted by 1 single column
3- Imagine I store the information ordered.

    12
    13
    14
    15
    18
    20
        >>> tomorrow ... I have a new person: 15 years old

## What is an Index?

Have you ever used an index? Yes... Each time you open a book !

    Recipes book
        Index by:
            Recipe name
            Main ingredient
            Kind of dish
Each index is just a copy of the information that I want to use in order to perform my search... with a locator attached

    Term                    Location
    ----------------------------------
    Pizza carbonara         Page 78
    Pizza margarita         Page 25

    Term                    Location
    ----------------------------------
    Pasta                   Pages 101-200
    Pizzas                  Page    1-100

Databases are really good creating indexes for structured information.
Databases are really bad creating indexes for non structured information. <- Here is when I need a Search Engine, 
                                                                             such as ElasticSearch

-------------

    Recipe book.... This is an Index right here! Is that index ok for the kind of search that I want to do?
        Pizza carbonara         Page 78
        Pizza margarita         Page 25
        Pasta Carbonara         Page 33
        Pasta pesto             Page 79
        Scalope!                Page 100
        Pizza with tuna         Page 200

    Query: CARBONARA        ---> I need to do an INDEX FULL SCAN !

-------------
To solve this situations we need an "Inverted Index" <- ElasticSearch 

1º. Normalize the information. 2º Remove extra tokens. 3º Remove stop word (words that means nothing at all)
4º. Sort terms

THIS IS AN INVERTED INDEX. This is the kind of indexes that a tool such as Elastic creates....
    (this is a lie... I will let u know about that in a little bit)

    carbonara         Page 33 (2), Page 78 (2)
    margarita         Page 25 (2)
    pasta             Page 33 (1), Page 79 (1)
    pesto             Page 79 (2)
    pizza             Page 78 (1), Page 25 (1), Page 100 (1)
    scalope           Page 100 (1)
    tuna              Page 200 (3)
    
Apache Lucene: Is a search engine... And it creates powerful inverted indexes.
What is ElasticSearch? ElasticSearch is just a Lucenes Orquestrator

Query: "a Carbonara PIZZA"
What should I do to that text (query) before actually looking for that in my index? The same process than above
    carbonara         Page 33 (2), Page 78 (2)
    pizza             Page 78 (1), Page 25 (1), Page 100 (1)

    Results of the query:
        Page 78         *** Higher score! Pizza carbonara
        Page 33         *** Lower score   Pasta carbonara
        Page 25         *** Lower score   Pizza ...
        Page 100        *** Lower score   Pizza ...

Whenever ElasticSearch index a document... We could tell ES to store a copy of that document!
Imagine that we are storing logs!
- A log is associated always with a TIMESTAMP
- A log can not be modified after it was produced

... So If I have a copy of a data that is not going to be modified... Is like I have the original data.... 

------------------------------------------------------------------------------
- Monitoring system                         NO
- A non relational database                 NO
- An engine for querying information        Kind of....

---

# ElasticSearch

Is a software application.
How are we going to communicate with ES? ES only has an HTTP API. Nothing else... No fancy screens... nothing at all!


PDF Document ->   
Logs       --->  JSON  ---->  ElasticSearch  <<<<  Kibana
Metrics    --->
                            Stores documents       Query information
                            Creates indexes        Creates powerful dashboards & canvas
                                                    Has an amazing set of windows (utilities) to monitor apps


We said that ES is going to create inverted indexes of documents. In addition (if I want), It is going to store a copy of the document.
But... what kind of documents?
     PDF? Word? HTML? NOP
     Just JSON !

Logstash
    A data aggregator / transformer

Beats
    FileBeat... Reads lines of text from a file (log file), converts them into JSON and push them away



Website

    Apache 1                                                    SCHEMA!
        access log1
        FileBeat ----->                                                   XMEN
        MetricBeat                                                       cerebro (brain) (Management Tool)
    Apache 2                                                                |
        access log2                       Its own containers                v
        FileBeat ----->     5 containers  ONLINE                         10 containers
    Apache 3               Kafka  <----  Logstash1 --->  Logstash2 ---> ElasticSearch 1         <<<<    Kibana
        access log3         queue        router          transform      Store logs here
    ... FileBeat ----->                                                 Index those logs
    Apache N
        access logN
        FileBeat ----->                                                  7 containers
                                                ---->   Logstash3 ----> ElasticSearch 2         <<<<<   Kibana 2
                                                        transform 

Kubernetes Cluster
    Machine 1
        crio
            Pod 1
                Apache container
                    VOLUME ^    100kb    40Kb access_log1
                     RAM   v             40Kb access_log2
                Filebeat container
    Machine 2
        crio
            Pod 2
                Apache container
                Filebeat container
    Machine 3
        crio
    ...
    Machine n
        crio
            Pod 3
                Apache container
                Filebeat container
    
Hey Kubernetes, I want to have 3 Apaches running in the cluster as PODs
Each apache has to go with a filebeat 
A POD is a set of containers, that:
- they are all installed in the same machine
- they share network configuration
- they can share volumes... so files


Kafka is not an Elastic Product. It is an Apache project. Kafka is a messaging broker.

    Each entry(line) in those log files is going to be a JSON DOCUMENT 

We want to monitor those apaches. How could we do it?
- For sure we could just opening every single file right there... Would this be ok? NO
  - Crazy... Too many files
  - Those files could pack my servers...

I could configure FileBeat to send each line (JSON document) to ElasticSearch... Would that be a good idea? It is not!
Why?
- 1 Do I want the data only in 1 ES ? Maybe not... Maybe I'm going to have 1 ES for monitoring(IT)
                                                        Is the system online
                                                        Do the clients use a mobile or a PC in order to access my website
                                                   In addition I could have another ES for Business Monitoring
                                                        How many clients do I have connected...
                                                        From where they are?
 ** Actually... I have no idea right now the usage that i WILL do of that information in the future.
- 2. Maybe I don't want all the information stored in my ES... Just some (filter information)
                                                                At least not the same information in every ES installation that I could have 
     Maybe I want to add information to those logs: 
        In those log files... Im gonna have the IP of each client.
                                Maybe It could be great to look for that IP inside a GPS Database 
                                    -> So I could get the location of each client
