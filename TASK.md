# Zendesk Melbourne - Coding Challenge
# OVERVIEW
Using the provided data (tickets.json and users.json and organization.json) write a simple
command line application to search the data and return the results in a human readable format.
- Feel free to use libraries or roll your own code as you see fit. However, please do not
use a database or full text search product as we are interested to see how you write the
solution.
- Where the data exists, values from any related entities should be included in the results,
i.e. searching organization by id should return its tickets and users.
- The user should be able to search on any field, full value matching is fine (e.g. "mar"
won't return "mary").
- The user should also be able to search for empty values, e.g. where description is
empty.
Search can get pretty complicated pretty easily, we just want to see that you can code a basic
but efficient search application. Ideally, search response times should not increase linearly as
the number of documents grows. You can assume all data can fit into memory on a single
machine.


# EVALUATION CRITERIA
We will look at your project and assess it for:
1. Extensibility - separation of concerns.
2. Simplicity - aim for the simplest solution that gets the job done whilst remaining
readable, extensible and testable.
3. Test Coverage - breaking changes should break your tests.
4. Performance - should gracefully handle a significant increase in the amount of data
provided.
5. Robustness - should handle and report errors.
6. Usability - Should provide installation instructions and how easy it is to use the
application
7. General technical skills - Demonstrate proficiency in the chosen language and strong
attention to details

# SPECIFICATIONS
- Use the language in which you are strongest.
- Include a README with (accurate) usage instructions.
- Document the assumptions and tradeoffs you’ve made.

---

Sample OUTPUT layouts from the task

SAMPLE OUTPUT
Note: This output is not prescriptive, in fact we encourage you to do better.

CLI - Display Results

CLI - No Search Result

CLI - List Searchable Fields

