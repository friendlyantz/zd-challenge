* [ℹ️GitHub Pages WEB view of this readme](https://friendlyantz.github.io/zendesk-challenge/)
{:toc}

# Installation and Usage

`ruby 3.2.2` is required as per `Gemfile` spec

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

## Code review

Code was written using TDD (Test Driven Development) and can be reviewed commit-by-commit. Ideally I would use BDD (Behaviour Driven Development) to write e2e /top-level tests first, but due to time constaint this was not possible.

RSpec tests act as a documentation and can be used to review the code too.

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
- [ ] OPT: Explore Data encoding alternatives: `protobuf`, `avro` (avro_turf / avro gems) -> I recently contributed to an OSS project `avro_turf` for data encoding managed by a `ZenDeski` engineer -> https://github.com/dasch/avro_turf/pull/194#event-10218602164
- [ ] Add GitHub Actions CI/CD - not implemeted due to limited support for Ruby 3.2.2 at the time
- [ ] Consider multi-column index
- [ ] OPT: Containerize
- [ ] OPT: Deploy
- [ ] OPT: Improve CLI Tool UX - autocomplete, extra commands
- [ ] OPT: Linting - return to default Rubocop settings

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
    - `_id` -> assuming this can be used as primary id / key
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
```sh
2023y -> 09m -> 01d -> 15h -> 43m -> 12s
                           -> 48m -> 12s
      -> 15m -> 01d -> 19h -> 43m -> 12s
             -> 02d -> 18h -> 43m -> 12s
                    -> 19h -> 43m -> 12s
             -> 03d -> 15h -> 43m -> 12s
                           -> 51m -> 12s
2022y -> 12m -> 01d -> 15h -> 43m -> 12s
```

or `URL` (not yet implemented):
```sh
`https` -> `domain_2nd_lvl` -> `.com_domain_1st_level` -> `/sub_pages` -> `ref`
        -> `another_2ndlvl` -> `.far_domain_1st_level` -> `/sub_pages` -> `ref`
                                                       -> `/about_bus` -> `ref`
                                                       -> `/send_some` -> `bus`
                                                       -> `/send_some` -> `abs`
`http`  -> `domain_2nd_lvl` -> `.com_domain_1st_level` -> `/sub_pages` -> `ref`
```

## Design and Strategy discussion

Since we handle data pipelines/queries, functional flavoured approach might work well.
Haskel / Rust Monads might be the best fit Haskel / Rust Monads might be the best fit.

### Design patterns considered

https://refactoring.guru/design-patterns

- Command Pattern (Behaviour)
    - https://refactoring.guru/design-patterns/command
    - Dry Transaction is a command pattern
- Decorator Pattern (Structural Pattern)
    - https://refactoring.guru/design-patterns/decorator
- Factory Pattern for generating Models
    - https://refactoring.guru/design-patterns/factory-method
- Repository Pattern to act as a middleware between DB Data and search engine

## App Components:

- `App` - main entry point
- `Loaders` - data loaders for CLI, SearchEngine and Error wrapper. IO Interface
    - `CLI`
    - `SearchEngine`
    - `UI Errors wrapper / interface`
- `Errors` - custom errors

- `SearchEngine` - search engine with index lookup
- `Services` - Services for Fetching Schema and DB generation
- `Parsers` - Data Parsers used by SearchEngine to parse various Data types incl a separate parser for `Time`. Return `Some(type)` or `None`
- `Validators` - data validator used by Search Engine to check if search term input is part of searchable params and is correct type (i.e. Time string for `Time`, Integers for `_id`, etc)

- `Models` - main models used as an [ORM](https://en.wikipedia.org/wiki/Object%E2%80%93relational_mapping) interface
    - `User`, `Ticket`, `Organization`
    - `DataBase` - data storage with lookup by `_id` and recursive `Trie` traversal
- `Repo` - data access layer used by Search Engine and abstarcting low level logic. (Ideally I wanted to have a Repo per user, org, ticket, etc, but that seemed convoluted, too dry and required extra time)

- `Decorators` - data decorators for models that can be used to display data in a user friendly way, rewrtiting default Ruby `to_s` method used in `puts`
- `Renderer` - STDOUT Printer used by App

![image](https://github.com/friendlyantz/zendesk-challenge/assets/70934030/3ba4e04f-27bc-40a4-8467-8fbd1796cd0b)

## Misc / Libraries and Gems used

### RSpec - testing framework

### ReadLine gem vs standard `.gets` method

I tried to implement autocomplete functionality using `ReadLine` gem.

https://rubyapi.org/3.2/o/readline#method-c-completion_proc-3D

But using standard `STDOUT.gets('result')` seems to be more reliable and easier to implement and test, but lack auto-completion proc 
### Zeitwerk

- Zeitwerk autoloader - works well with normal Ruby and supports dry-rb [since late 2022](https://dry-rb.org/news/2022/10/17/dry-rb-adopts-zeitwerk-for-code-loading/)

### Monads / Dry-rb

Monads heavily used in func languages like Rust && Haskell, but Ruby `dry` library can archive similar performance with much simpler Ruby syntax.

Insbired by [RailsConf 2021 Denver - Dry Monads](https://www.youtube.com/watch?app=desktop&v=YXiqzHMmv_o)

### Transactions

Tried `Dry Transactions` / [Railway oriented programming: Error handling in functional languages by Scott Wlaschin](https://vimeo.com/113707214) considered but was not widely adobted. Ideally stick to DryMonads only

# Demo

## Main Menu and Search Options

```sh
❯ make run
bundle exec run bin/run
Loading data...
Finished loading data!
Initializing application...
Finished initializing application!
==================================
Welcome to Zendesk Search
Press '1' to search for users
Press '2' to search for organizations
Press '3' to search for tickets
Type 'exit' to exit anytime
1
Search users with:
_______________________
_id
url
external_id
name
alias
created_at
active
verified
shared
locale
timezone
last_login_at
email
phone
signature
organization_id
tags
suspended
role
_______________________
Enter search term:

```

## Search Results - Users

```sh
Enter search term:
_id
Enter search value:
1
Found 1 search results.
* User with _id 1
_id                            1
url                            http://initech.zendesk.com/api/v2/users/1.json
external_id                    74341f74-9c79-49d5-9611-87ef9b6eb75f
name                           Francisca Rasmussen
alias                          Miss Coffey
created_at                     2016-04-15T05:19:46 -10:00
active                         true
verified                       true
shared                         false
locale                         en-AU
timezone                       Sri Lanka
last_login_at                  2013-08-04T01:03:27 -10:00
email                          coffeyrasmussen@flotonic.com
phone                          8335-422-718
signature                      Dont Worry Be Happy!
organization_id                119
tags                           ["Springville", "Sutton", "Hartsville/Hartley", "Diaperville"]
suspended                      true
role                           admin
--- Submitted Tickets:
 1. subject:  A Nuisance in Kiribati
    priority: high
    status:   open
 2. subject:  A Nuisance in Saint Lucia
    priority: urgent
    status:   pending
--- Assigned Tickets:
 1. subject:  A Problem in Russian Federation
    priority: low
    status:   solved
 2. subject:  A Problem in Malawi
    priority: urgent
    status:   solved
--- Organization:
    name:     Multron
Search again?: y/n
```

## Search Results - Organisations
```sh
Enter search value:
101
Found 1 search results.
* Organization with _id 101
_id                            101
url                            http://initech.zendesk.com/api/v2/organizations/101.json
external_id                    9270ed79-35eb-4a38-a46f-35725197ea8d
name                           Enthaze
domain_names                   ["kage.com", "ecratic.com", "endipin.com", "zentix.com"]
created_at                     2016-05-21T11:10:28 -10:00
details                        MegaCorp
shared_tickets                 false
tags                           ["Fulton", "West", "Rodriguez", "Farley"]
--- Users:
 1. name:     Loraine Pittman
    alias:    Mr Ola
    role:     admin
 2. name:     Francis Bailey
    alias:    Miss Singleton
    role:     agent
 3. name:     Haley Farmer
    alias:    Miss Lizzie
    role:     agent
 4. name:     Herrera Norman
    alias:    Mr Vance
    role:     end-user
--- Tickets:
 1. subject:  A Drama in Portugal
    priority: low
    status:   hold
 2. subject:  A Problem in Ethiopia
    priority: low
    status:   hold
 3. subject:  A Problem in Turks and Caicos Islands
    priority: low
    status:   pending
 4. subject:  A Problem in Guyana
    priority: normal
    status:   closed
Search again?: y/n
```

## Search Results - Tickets
```sh
Enter search value:
436bf9b0-1147-4c0a-8439-6f79833bff5b
Found 1 search results.
* Ticket with _id 436bf9b0-1147-4c0a-8439-6f79833bff5b
_id                            436bf9b0-1147-4c0a-8439-6f79833bff5b
url                            http://initech.zendesk.com/api/v2/tickets/436bf9b0-1147-4c0a-8439-6f79833bff5b.json
external_id                    9210cdc9-4bee-485f-a078-35396cd74063
created_at                     2016-04-28T11:19:34 -10:00
type                           incident
subject                        A Catastrophe in Korea (North)
description                    Nostrud ad sit velit cupidatat laboris ipsum nisi amet laboris ex exercitation amet et proident. Ipsum fugiat aute dolore tempor nostrud velit ipsum.
priority                       high
status                         pending
submitter_id                   38
assignee_id                    24
organization_id                116
tags                           ["Ohio", "Pennsylvania", "American Samoa", "Northern Mariana Islands"]
has_incidents                  false
due_at                         2016-07-31T02:37:50 -10:00
via                            web
--- Submitter:
    name:     Elma Castro
    alias:    Mr Georgette
    role:     agent
--- Assignee:
    name:     Harris Côpeland
    alias:    Miss Gates
    role:     agent
--- Organization:
    name:     Zentry
```