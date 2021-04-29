## Movie API Test

#### Getting started:
  - Clone repo
  - Make sure in correct directory
  - On command line run `ruby api_test.rb`
  - Any failing test results from search will appear in terminal window

#### Tests:
1. Tests that connection to omdbapi is working and that response is "True".


2. Tests that missing API key will result in a "False" response and an error message stating "No API key provided".


3. Test that search results for a keyword...
```
  - Include all relevant matches.
  - Include expected keys (Title, Year, imdbID, Type, and Poster url)
  - All key values are strings.
  - All years are in correct format for movies (yyyy) and series (yyyy-yyyy)
```

4. Test that search results by keyword have valid Imdb Id's.

5. Test that verifies none on the post links on the first page results are broken.

6. Test to ensure none of the results have duplicate records across the first 5 pages.


7. Test that "type" param will return only "movies" results across first 5 pages.
