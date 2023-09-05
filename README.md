* [ℹ️GitHub Pages WEB view of this readme](https://friendlyantz.github.io/zendesk-challenge/)
{:toc}

# Installation and Usage

Refer `Makefile` for installation and usage instructions => in terminal just run `make` to see all available commands

```sh
$ make
_____________________________________________
Hi friendlyantz! Welcome to zendesk-challenge

Getting started

make install                  install dependencies
make test                     run tests
make run                      launch app
make lint                     lint app
make lint-unsafe              lint app(UNSAFE)
```

# Action Plan / Tracker

- [x] Clarify functional / non-functional requirements, brainstorm MVP solution as well as potential future Features
- [x] Outline Strategy
    - [x] Design Patterns
    - [x] Outline basic models / objects, Data Storage and retrieval
    - [x] Consider O(n) vs O(logn) vs O(1) implementations of Search algorithm
    - [x] Consider Data Indexing algorithms
- [x] Spike
- [x] Implement/TDD data models and storage
- [x] Implement/TDD search engine
- [x] Implement/TDD cli
- [x] Improve Search Algorithm, CLI, etc

Future work:
- [ ] Consider multi-column index
- [ ] OPT: Improve CLI Tool UX - autocomplete, extra commands
- [ ] OPT: Explore Data encoding alternatives: `protobuf`, `avro` (avro_turf / avro gems)
- [ ] OPT: Containerize
- [ ] OPT: Deploy

# Requirements

## Functional requirements

- [x] CLI tool that takes user input and returns search results
- [x] Where the data exists, values from any related entities should be included in the results,
i.e. searching organization by id should return its tickets and users.
- [x] The user should be able to search on any field, full value matching is fine (e.g. "mar" won't return "mary").
- [x] The user should also be able to search for empty values, e.g. where description is empty.

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

UNIX style approach to CLI tool design to enable leveraging `GNU Parallel` / etc if required:

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

### Assumptions

- `_id` is unique and can be used as a primary key
- `json` data is valid and can be parsed, it is not corrupted and is matching `db/schema.rb`
- UX allows to search for case insensitive values
## Schema

![image](https://github.com/friendlyantz/zendesk-challenge/assets/70934030/c680cce2-0155-465c-94f6-328de52b01e4)
https://dbdiagram.io/d/64f2c16402bd1c4a5ed6532a

## SearchEngine performance: O(n) vs O(logn) vs O(1) considerations

- O(n) - simple Ruby `filter`, `select` would work, but challange requires non linear performance
- O(logn) - consider implementing binary search / tree data structures for data. might be too convoluted to implement
- O(1) - create indexes for constant time access at the cost of storage. seems like the best approach if we create a HashMap index, which will be the fastest / O(1)

## Index using [`HashMap` algorithm](https://en.wikipedia.org/wiki/Hash_table)

Adobted to archieve O(1) performance for search engine
## Index using [`Trie` algorithm](https://en.wikipedia.org/wiki/Trie)

Some data can be also indexd as `tries`, which is more space efficient than `HashMap`
i.e. `Time` (implemented):
- 2023y -> 09m -> 01d -> 15h -> 43m -> 12s

or `URL` (not yet implemented):
- `https` -> `domain_2nd_lvl` -> `.com_domain_1st_level` -> `/sub_pages` -> `ref`

## Design and Strategy discussion

Since we handle data pipelines/queries, functional flavoured approach might work well.
Haskel / Rust Monads might be the best fit Haskel / Rust Monads might be the best fit.

### Design patterns to consider

https://refactoring.guru/design-patterns

- Command Pattern? (Behaviour)
    - https://refactoring.guru/design-patterns/command
    - Dry Transaction is a command pattern
- Decorator Pattern? (Structural Pattern)
    - https://refactoring.guru/design-patterns/decorator
- Factory Pattern for generating Models?
    - https://refactoring.guru/design-patterns/factory-method
- Repository Pattern to act as a middleware between DB Data and search engine?


## App Components:

- `App` - main entry point
- `SearchEngine` - search engine with index lookup
- `Repo` - data access layer used by Search Engine and abstarcting low level logic. (Ideally I wanted to have a Repo per user, org, ticket, etc, but that seemed convoluted, too dry and required extra time)

- `Models` - main models used as an [ORM](https://en.wikipedia.org/wiki/Object%E2%80%93relational_mapping) interface
    - `User`
    - `Ticket`
    - `Organization`
    - `DataBase` - data storage with lookup by `_id` and recursive `Trie` traversal

- `Parsers` - Data Parsers used by SearchEngine to parse various Data types incl a separate parser for `Time`. Return `Some(type)` or `None`
- `Services` - Services for Fetching Schema and DB generation

- `Validators` - data validator used by Search Engine to check if search term input is part of searchable params and is correct type (i.e. Time string for `Time`, Integers for `_id`, etc)
- `Errors` - custom errors

- `Loaders` - data loaders for CLI, SearchEngine and Error wrapper
    - `CLI`
    - `SearchEngine`
    - `UI Errors wrapper / interface`
- `Decorators` - data decorators for models that can be used to display data in a user friendly way, rewrtiting default Ruby `to_s` method used in `puts`
- `Renderer` - STDOUT Printer used by App

![image](https://github.com/friendlyantz/zendesk-challenge/assets/70934030/3ba4e04f-27bc-40a4-8467-8fbd1796cd0b)

## Misc

### RSpec - testing framework
### Zeitwerk

- Zeitwerk autoloader - works well with normal Ruby and supports dry-rb [since late 2022](https://dry-rb.org/news/2022/10/17/dry-rb-adopts-zeitwerk-for-code-loading/)

### Monads / Dry-rb

Monads heavily used in func languages like Rust && Haskell, but Ruby `dry` library can archive similar performance with much simpler Ruby syntax.

Insbired by [RailsConf 2021 Denver - Dry Monads](https://www.youtube.com/watch?app=desktop&v=YXiqzHMmv_o)

### Transactions

Tried `Dry Transactions` / [Railway oriented programming: Error handling in functional languages by Scott Wlaschin](https://vimeo.com/113707214) considered but was not widely adobted. Ideally stick to DryMonads only
