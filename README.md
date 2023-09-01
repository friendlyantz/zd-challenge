# Action Plan / Tracker

- [ ] Clarify func / non-func requirements, brainstorm MVP solution as well as potential future Features
- [ ] Outline Strategy
    - [ ] Design Patterns
    - [ ] Outline basic models / objects, Data Storage and retrieval
    - [ ] Consider O(n) vs O(1) implementations of Search algorythim
    - [ ] Consider Data Indexing algorithms
- [ ] Implement/TDD data models and storage
- [ ] Implement/TDD search engine
- [ ] Implement/TDD cli
- [ ] Improve Search Algorithm, CLI, etc
- [ ] Consider multi-column index
- [ ] OPT: Improve CLI Tool UX - autocomplete, extra commands
- [ ] OPT: Explore Data encoding alternatives: `protobuf`, `avro` (avro_turf / avro gems)
- [ ] OPT: Containerize
- [ ] OPT: Deploy

# Requirements

## Functional requirements

- CLI tool that takes user input and returns search results
- Where the data exists, values from any related entities should be included in the results,
i.e. searching organization by id should return its tickets and users.
- The user should be able to search on any field, full value matching is fine (e.g. "mar" won't return "mary").
- The user should also be able to search for empty values, e.g. where description is empty.

## Non-Functional requirements

1. Extensibility - separation of concerns.
2. Simplicity
3. Test Coverage
4. Performance - should gracefully handle a significant increase in the amount of data
provided.
5. Robustness / Error Handling - should handle and report errors.
6. Usability - Should provide installation instructions and how easy it is to use the
application
7. General technical skills

