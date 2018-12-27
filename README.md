### Exercise!

####  Now

- [ ] Create an exponential multiplier for "related searches" ranks. if a "related search" is super confident, then lets make it matter. 
- [ ] Workout POST handler should create reference to "resolved exercise" after parsing the raw exercise string out

#### Done

- [x] Write tests for ResolveHelper. 
  - [x] Create test file schema (raw -> expected proper name)
  - [x] Write first level specs 
- [x] Determine some basic utility function for determining highest probability selector
- [x] Sanatize search names by removing stop words
- [x] Get related search terms for all proper exercise names 
- [x] Related Names should be unique on the ts_vector