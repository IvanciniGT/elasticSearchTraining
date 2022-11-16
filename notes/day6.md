Each information is stored at least 3 times in a production env.

1 disk of 3 Tb 
For having those 3 Tb, whe need 3 disks x 200 € = 600 €

# Elasticsearch Mapping

A mapping tells an index how to store and process each field (or some of them).
We define mapping in JSON

{
    "mappings": {
        "properties": {
            "population": { type: "long" },
            "coordinates": { type: "geo_point" },
            "accentcity": { type: "text" },
        }
    }    
}

{
     "accentcity" => "Aixàs",
    "coordinates" => [
        [0] 1.4666667,
        [1] 42.4833333
    ],
         "region" => "06",
        "country" => "ad",
           "city" => "aixas"
}