### Exercise!

####  Now

- [ ] List view of past workouts
  - [ ] Should be cards based
  - [ ] Should have a "create"/"add button"
- [ ] "add"/"create" view
  - [ ] Simple text editor to create a list
  - [ ] Button (top or bottom?) which allows user to insert new line item
    - [ ] Orrrrrr just automatically inserts empty line item at the bottom (might look "unsymetrical")

#### Reminder (*important*)

- [ ] Create a google/bing spelling correct for things like "benchpress" -> "bench press"

#### Done

- [x] Start iOS project: basic element it should have:
- [x] Workout POST handler should create reference to "resolved exercise" after parsing the raw exercise string out
  - [x] Filter out ExerciseDictionary results with too low results 
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