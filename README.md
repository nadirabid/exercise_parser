### Exercise!

####  Now

- [ ] WorkoutEditor: fix the hide button
- [ ] Create icon for app - annoying wokr
- [ ] Get/save profile picture from server
- [ ] Workout date should not be optional
- [ ] Time elapsed should not be optional
- [ ] WorkoutEditor: add on text change - re resolve the exercise w/ some debounce
- [ ] Exercise search???? BIG IFF

#### Reminder (*important*)

- [ ] Create a google/bing spelling correct for things like "benchpress" -> "bench press"

#### Done

- [x] Pick a new app color - annoying work
- [x] WorkoutEditor: Create a view/input to allow naming the working (also pick a default name)
- [x] WorkoutEditor: timer looks ugly - annoying work
- [x] FeedView: if could not parse - show raw string - needed fosho
- [x] FeedView: show total time of workout
- [x] Add header in FeedView - currently it scrolls past the notch
- [x] EditorView
  - [x] Fix side padding
  - [x] Save amount of time the workout took
  - [x] Add view indicator when exercise fails to resolve
- [x] List view of past workouts
  - [x] Should be cards based
  - [x] Should have a "create"/"add button"
- [x] "add"/"create" view
  - [x] Simple text editor to create a list
  - [x] Button (top or bottom?) which allows user to insert new line item
    - [x] Orrrrrr just automatically inserts empty line item at the bottom (might look "unsymetrical")
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

#### Examples

* [0](https://www.instagram.com/dailylifts365/)
* [1](https://www.instagram.com/p/BY7EIqvA1_C/)
* [2](https://www.instagram.com/p/B9ctyA0n4As/)
* [3](https://www.instagram.com/p/B9csO4Eh6Ez/)
* [4](https://www.instagram.com/p/B9clg8ulDe_/)
* [5](https://www.instagram.com/p/B9aIOuDj90c/)
* [6](https://www.instagram.com/p/B9c77IagavC/)
* [7](https://www.instagram.com/p/B9cz1s2jBsS/)
* [8](https://www.instagram.com/p/B9cgZZyFtSV/)
* [9](https://www.instagram.com/p/B9cdp77nLZr/)

