### Exercise!

####  Now

- [ ] Workout POST handler should create reference to "resolved exercise" after parsing the raw exercise string out
- [ ] Create a google/bing spelling correct for things like "benchpress" -> "bench press"

#### Done

- [x] Create an exponential multiplier for "related searches" ranks. Modelled by eyeballing a small amount test data. 
  - [x] If a "related search" is super confident, then lets make it matter. 
  - [x] If a "related search" is semi to not confident at all, then lets not have it matter much at all.
- [x] Write tests for ResolveHelper. 
  - [x] Create test file schema (raw -> expected proper name)
  - [x] Write first level specs 
- [x] Determine some basic utility function for determining highest probability selector
- [x] Sanatize search names by removing stop words
- [x] Get related search terms for all proper exercise names 
- [x] Related Names should be unique on the ts_vector

#### Materials

* [PostgreSQL Text Search](http://shisaa.jp/postset/postgresql-full-text-search-part-3.html)
* [Example workout](https://www.instagram.com/p/BY7EIqvA1_C/)