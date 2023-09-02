# Action Plan / Tracker

- [x] Clarify func / non-func requirements, brainstorm MVP solution as well as potential future Features
- [x] Outline Strategy
    - [x] Design Patterns
    - [ ] Outline basic models / objects, Data Storage and retrieval
    - [x] Consider O(n) vs O(logn) vs O(1) implementations of Search algorithm
    - [x] Consider Data Indexing algorithms
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

# Dev Notes

![image](https://github.com/friendlyantz/zendesk-challenge/assets/70934030/5153b245-210c-4829-a5ee-57d04bbbe4f8)
Inspired by [what makes a good CLI tool](https://friendlyantz.me/learning/2023-08-25-what-makes-a-good-cli-tool/)

## Existing Data

- all models have these fields:
    - `_id`
    - `url`
    - `external_id`
- users can submit a ticket 
- users can be assigned to a ticket
- users belongs to organization
- users HAS ONLY organization foreign key. no ticket key
- tickets belongs to organization
- tickets HAS ALL foreign keys to USERS and ORGS: `submitter_id`, `assignee_id`, `organization_id`
- organizations HAS NO foreign keys to its tickets and users

## Schema

![image](https://github.com/friendlyantz/zendesk-challenge/assets/70934030/c680cce2-0155-465c-94f6-328de52b01e4)
https://dbdiagram.io/d/64f2c16402bd1c4a5ed6532a


## Design and Strategy discussion

Since we handle data pipelines/queries, functional flavoured approach might work well. Haskel / Rust Monads might be the best fit Haskel / Rust Monads might be the best fit.

### Monads

Monads heavily used in func languages like Rust && Haskell, but Ruby `dry` library can archive similar performance with much simpler Ruby syntax.

Insbired by [RailsConf 2021 Denver - Dry Monads](https://www.youtube.com/watch?app=desktop&v=YXiqzHMmv_o)

### Transactions

Consider txt / [Railway oriented programming: Error handling in functional languages by Scott Wlaschin](https://vimeo.com/113707214)


## Design patterns to consider

https://refactoring.guru/design-patterns

- Command Pattern? (Behaviour)
    - https://refactoring.guru/design-patterns/command
    - Dry Transaction is a command pattern
- Decorator Pattern? (Structural Pattern)
    - https://refactoring.guru/design-patterns/decorator
- Factory Pattern for generating Models?
    - https://refactoring.guru/design-patterns/factory-method

# SearchEngine performance: O(n) vs O(logn) vs O(1)

- O(n) - simple Ruby `filter`, `select` would work, but challange requires non linear performance
- O(logn) - consider implementing binary search / tree data structures for data. requires indexing
- O(1) - seems like an best approach is we create a HashMap index which will be the fastest at the cost of some memory

Some data can be also indexd as `tries`
i.e. `Time`:
- 2023y -> 09m -> 01d -> 15h -> 43m -> 12s

or `URL`
- `https` -> `domain_2nd_lvl` -> `.com_domain_1st_level` -> `/sub_pages` -> `ref`

## Misc

- Zeitwerk autoloader - works well with normal Ruby and supports dry-rb [since late 2022](https://dry-rb.org/news/2022/10/17/dry-rb-adopts-zeitwerk-for-code-loading/)

