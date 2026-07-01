# Corrupt input patterns

Use corrupt-input tests for parsers, importers, decoders, protocol handlers, and any boundary that accepts external structured data.

## Corruption methods

- truncate input
- flip selected bytes or tokens
- corrupt length/count fields
- change version marker
- remove required section
- duplicate unique section
- reorder sections
- insert invalid encoding
- create inconsistent references
- combine valid pieces from incompatible examples

## Expected outcomes

Specify:

- controlled rejection
- stable error category
- no unsafe behavior
- no durable side effect unless explicitly allowed
- no resource leak
- no excessive runtime or memory growth

## Positive control

Start from at least one valid example so the test proves the corruption, not the fixture, causes rejection.

## Regression path

When a corrupt input reveals a bug:

- save original input
- minimize it
- document corruption method
- add deterministic regression case
