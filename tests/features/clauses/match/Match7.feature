#
# Copyright (c) "Neo4j"
# Neo4j Sweden AB [https://neo4j.com]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Attribution Notice under the terms of the Apache License 2.0
#
# This work was created by the collective efforts of the openCypher community.
# Without limiting the terms of Section 6, any Derivative Work that is not
# approved by the public consensus process of the openCypher Implementers Group
# should not be described as “Cypher” (and Cypher® is a registered trademark of
# Neo4j Inc.) or as "openCypher". Extensions by implementers or prototypes or
# proposals for change that have been documented or implemented should only be
# described as "implementation extensions to Cypher" or as "proposed changes to
# Cypher that are not yet approved by the openCypher community".
#

#encoding: utf-8

#consider splitting into separate category optional-match
Feature: Match7 - Optional match

  @outputModified
  Scenario: [1] Simple OPTIONAL MATCH on empty graph
    Given an empty graph
    When executing query:
      """
      OPTIONAL MATCH (n)
      RETURN n
      """
    Then the result should be, in any order:
      | n |
      |   |
    And no side effects

  @modified @outputModified
  Scenario: [2] OPTIONAL MATCH with previously bound nodes
    Given an empty graph
    And having defined kuzu types: n:n
    And having executed:
      """
      CREATE (:N)
      """
    When executing query:
      """
      MATCH (n)
      OPTIONAL MATCH (n)-[:NOT_EXIST]->(x)
      RETURN label(n) as n, x
      """
    Then the result should be, in any order:
      | n | x |
      | N |   |
    And no side effects

  @modified @keywordClash
  # Cannot create table Single in Kuzu.
  Scenario: [3] OPTIONAL MATCH and bound nodes
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:A), (b:C)
      OPTIONAL MATCH (x)-->(b)
      RETURN concat('(:', label(x), ' {num: ', x.num, '})') as x
      """
    Then the result should be, in any order:
      | x              |
      | (:A {num: 42}) |
    And no side effects

  @modified @fails @bugFailedVarBinding
  # Binder exception: Bind relationship r to relationship with same name is not supported.
  Scenario: [4] Optionally matching relationship with bound nodes in reverse direction
    Given an empty graph
    And having defined kuzu types: ab:t
    And having executed:
      """
      CREATE (:A)-[:T]->(:B)
      """
    When executing query:
      """
      MATCH (a1)-[r]->()
      WITH r, a1
        LIMIT 1
      OPTIONAL MATCH (a1)<-[r]-(b2)
      RETURN a1, r, b2
      """
    Then the result should be, in any order:
      | a1   | r    | b2   |
      | (:A) | [:T] | null |
    And no side effects

  @modified @fails @bugFailedVarBinding
  # Binder exception: Bind relationship r to relationship with same name is not supported.
  Scenario: [5] Optionally matching relationship with a relationship that is already bound
    Given an empty graph
    And having defined kuzu types: ab:t
    And having executed:
      """
      CREATE (:A)-[:T]->(:B)
      """
    When executing query:
      """
      MATCH ()-[r]->()
      WITH r
        LIMIT 1
      OPTIONAL MATCH (a2)-[r]->(b2)
      RETURN a2, r, b2
      """
    Then the result should be, in any order:
      | a2   | r    | b2   |
      | (:A) | [:T] | (:B) |
    And no side effects

  @modified @fails @bugFailedVarBinding
  # Binder exception: Bind relationship r to relationship with same name is not supported.
  Scenario: [6] Optionally matching relationship with a relationship and node that are both already bound
    Given an empty graph
    And having defined kuzu types: ab:t
    And having executed:
      """
      CREATE (:A)-[:T]->(:B)
      """
    When executing query:
      """
      MATCH (a1)-[r]->()
      WITH r, a1
        LIMIT 1
      OPTIONAL MATCH (a1)-[r]->(b2)
      RETURN a1, r, b2
      """
    Then the result should be, in any order:
      | a1   | r    | b2   |
      | (:A) | [:T] | (:B) |
    And no side effects

  @modified
  Scenario: [7] MATCH with OPTIONAL MATCH in longer pattern
    Given an empty graph
    And having defined kuzu types: n_name:k
    And having executed:
      """
      CREATE (a:N {name: 'A'}), (b:N {name: 'B'}), (c:N {name: 'C'})
      CREATE (a)-[:KNOWS]->(b),
             (b)-[:KNOWS]->(c)
      """
    When executing query:
      """
      MATCH (a {name: 'A'})
      OPTIONAL MATCH (a)-[:KNOWS]->()-[:KNOWS]->(foo)
      RETURN concat('({name: \'', foo.name, '\'})') as foo
      """
    Then the result should be, in any order:
      | foo           |
      | ({name: 'C'}) |
    And no side effects

  @modified @keywordClash @outputModified
  # Cannot create table Single in Kuzu.
  Scenario: [8] Longer pattern with bound nodes without matches
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:A), (c:C)
      OPTIONAL MATCH (a)-->(b)-->(c)
      RETURN b
      """
    Then the result should be, in any order:
      | b |
      |   |
    And no side effects

  @modified @keywordClash
  # Cannot create table Single in Kuzu.
  Scenario: [9] Longer pattern with bound nodes
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:Singlee), (c:C)
      OPTIONAL MATCH (a)-->(b)-->(c)
      RETURN concat('(:', label(b), ' {num: ', b.num, '})') as b
      """
    Then the result should be, in any order:
      | b              |
      | (:A {num: 42}) |
    And no side effects

  Scenario: [10] Optionally matching from null nodes should return null
    Given an empty graph
    When executing query:
      """
      OPTIONAL MATCH (a)
      WITH a
      OPTIONAL MATCH (a)-->(b)
      RETURN b
      """
    Then the result should be, in any order:
      | b |
      |   |
    And no side effects

  @modified @fails @bugUnexpectedOutput @kuzubug
  # Kuzu should not produce B A C
  Scenario: [11] Return two subgraphs with bound undirected relationship and optional relationship
    Given an empty graph
    And having defined kuzu types: abc_num:r_name
    And having executed:
      """
      CREATE (a:A {num: 1})-[:REL {name: 'r1'}]->(b:B {num: 2})-[:REL {name: 'r2'}]->(c:C {num: 3})
      """
    When executing query:
      """
      MATCH (a)-[r {name: 'r1'}]-(b)
      OPTIONAL MATCH (b)-[r2]-(c)
      WHERE r <> r2
      RETURN concat('(:', label(a), ' {num: ', a.num, '})') as a,
             concat('(:', label(b), ' {num: ', b.num, '})') as b,
             concat('(:', label(c), ' {num: ', c.num, '})') as c
      """
    Then the result should be, in any order:
      | a             | b             | c             |
      | (:A {num: 1}) | (:B {num: 2}) | (:C {num: 3}) |
      | (:B {num: 2}) | (:A {num: 1}) | null          |
    And no side effects

  @modified @keywordClash @fails @bugUnexpectedOutput @kuzubug
  # Should not produce (:C {num: 46}) when C does not have property. Glob over self loop is unspecified?
  Scenario: [12] Variable length optional relationships
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:Singlee)
      OPTIONAL MATCH (a)-[*]->(b)
      RETURN concat('(:', label(b), ' {num: ', b.num, '})') as b
      """
    Then the result should be, in any order:
      | b              |
      | (:A {num: 42}) |
      | (:B {num: 46}) |
      | (:B {num: 46}) |
      | (:C)           |
    And no side effects

  @mmodified
  Scenario: [13] Variable length optional relationships with bound nodes
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:Singlee), (x:C)
      OPTIONAL MATCH (a)-[*]->(x)
      RETURN concat('(:', label(x), CASE x.num WHEN null THEN '' ELSE concat(' {num: ', x.num, '}') END, ')') as x
      """
    Then the result should be, in any order:
      | x    |
      | (:C) |
    And no side effects

  @modified @keywordClash @fails @bugOptionalGlob @kuzubug
  # Glob over self loop is unspecified?
  Scenario: [14] Variable length optional relationships with length predicates
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:Singlee)
      OPTIONAL MATCH (a)-[*3..]-(b)
      RETURN b
      """
    Then the result should be, in any order:
      | b    |
      | null |
    And no side effects

  @modified @fails @bugUnexpectedOutput @kuzubug
  # Produces (:A) | (:B) | (:B)
  Scenario: [15] Variable length patterns and nulls
    Given an empty graph
    And having defined kuzu types: ab:bf
    And having executed:
      """
      CREATE (a:A), (b:B)
      """
    When executing query:
      """
      MATCH (a:A)
      OPTIONAL MATCH (a)-[:FOO]->(b:B)
      OPTIONAL MATCH (b)<-[:BAR*]-(c:B)
      RETURN concat('(:', LABEL(a), ')') as a,
             concat('(:', LABEL(b), ')') as b,
             concat('(:', LABEL(c), ')') as c
      """
    Then the result should be, in any order:
      | a    | b    | c    |
      | (:A) | null | null |
    And no side effects

  @modified @keywordClash @fails @bugInternalError @kuzubug
  # Internal error: entered unreachable code (cannot reproduce in CLI)
  Scenario: [16] Optionally matching named paths - null result
    Given an empty graph
    And having defined kuzu types: abcs:lrx
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:A)
      OPTIONAL MATCH p = (a)-[:X]->(b)
      RETURN p
      """
    Then the result should be, in any order:
      | p    |
      | null |
    And no side effects

  @modified @fails @bugUnexpectedOutput @kuzubug
  # empty path still fills in lambda (from prev row?)
  Scenario: [17] Optionally matching named paths - existing result
    Given an empty graph
    And having defined kuzu types: n_name:x
    And having executed:
      """
      CREATE (a:N {name: 'A'}), (b:N {name: 'B'}), (c:N {name: 'C'})
      CREATE (a)-[:X]->(b)
      """
    When executing query:
      """
      MATCH (a {name: 'A'}), (x)
      WHERE x.name IN ['B', 'C']
      OPTIONAL MATCH p = (a)-->(x)
      RETURN concat('({name: \'', x.name, '\'})') as x,
             list_transform(rels(p), i->concat('[:', label(i), ']')) as p
      """
    Then the result should be, in any order:
      | x             | p                                   |
      | ({name: 'B'}) | <({name: 'A'})-[:X]->({name: 'B'})> |
      | ({name: 'C'}) | null                                |
    And no side effects

  @modified @keywordClash @fails @bugUnexpectedOutput @kuzubug
  # Running in CLI produces empty results, in cucumber produces an output.
  Scenario: [18] Named paths inside optional matches with node predicates
    Given an empty graph
    And having defined kuzu types: abcs:lrx
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:A), (b:B)
      OPTIONAL MATCH p = (a)-[:X]->(b)
      RETURN p
      """
    Then the result should be, in any order:
      | p    |
      | null |
    And no side effects

  @modified @fails @bugInternalError @kuzubug
  # Internal error: entered unreachable code (cannot reproduce in CLI)
  Scenario: [19] Optionally matching named paths with single and variable length patterns
    Given an empty graph
    And having defined kuzu types: n_name:x
    And having executed:
      """
      CREATE (a:N {name: 'A'}), (b:N {name: 'B'})
      CREATE (a)-[:X]->(b)
      """
    When executing query:
      """
      MATCH (a {name: 'A'})
      OPTIONAL MATCH p = (a)-->(b)-[*]->(c)
      RETURN p
      """
    Then the result should be, in any order:
      | p    |
      | null |
    And no side effects

  @modified @outputModified
  Scenario: [20] Variable length optional relationships with bound nodes, no matches
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:A), (b:B)
      OPTIONAL MATCH p = (a)-[*]->(b)
      RETURN list_transform(rels(p), i->concat('[:', label(i), ']')) as p
      """
    Then the result should be, in any order:
      | p  |
      | [] |
    And no side effects

  @modified @outputModified
  Scenario: [21] Handling optional matches between nulls
    Given an empty graph
    And having defined kuzu types: abcns_num:lnr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      OPTIONAL MATCH (a:NotThere)
      OPTIONAL MATCH (b:NotThere)
      WITH a, b
      OPTIONAL MATCH (b)-[r:NOR_THIS]->(a)
      RETURN a, b, r
      """
    Then the result should be, in any order:
      | a | b | r |
      |   |   |   |
    And no side effects

  @modified @fails @bugFailedVarBinding
  # Query execution failed: Binder exception: Cannot bind x as node pattern.
  Scenario: [22] MATCH after OPTIONAL MATCH
    Given an empty graph
    And having defined kuzu types: abcns_num:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:Singlee)
      OPTIONAL MATCH (a)-->(b:NonExistent)
      OPTIONAL MATCH (a)-->(c:NonExistent)
      WITH coalesce(b, c) AS x
      MATCH (x)-->(d)
      RETURN d
      """
    Then the result should be, in any order:
      | d |
    And no side effects

  @modified @fails @bugUnexpectedOutput @kuzubug
  # Does not produce (:YZ) or null, produces (:Y)x2.
  Scenario: [23] OPTIONAL MATCH with labels on the optional end node
    Given an empty graph
    And having defined kuzu types: xyy:r
    And having executed:
      """
      CREATE (:X), (x:X), (y1:Y), (y2:YZ)
      CREATE (x)-[:REL]->(y1),
             (x)-[:REL]->(y2)
      """
    When executing query:
      """
      MATCH (a:X)
      OPTIONAL MATCH (a)-->(b:Y)
      RETURN concat('(:', label(b), ')') as b
      """
    Then the result should be, in any order:
      | b      |
      | null   |
      | (:Y)   |
      | (:Y:Z) |
    And no side effects

  @modified @testbug @fails @extraOutputUndirected
  Scenario: [24] Optionally matching self-loops
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:B)
      OPTIONAL MATCH (a)-[r]-(a)
      RETURN concat('[:', label(r), ']') as r
      """
    Then the result should be, in any order:
      | r       |
      | [:LOOP] |
    And no side effects

  @modified @keywordClash @fails @parserErrorOptionalMatch
  # Query execution failed: Parser exception: Invalid input <MATCH (a) WHERE NOT (a:B) OPTIONAL>: expected rule oC_SingleQuery (line: 3, offset: 0)
  Scenario: [25] Optionally matching self-loops without matches
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a)
      WHERE NOT (a:B)
      OPTIONAL MATCH (a)-[r]->(a)
      RETURN r
      """
    Then the result should be, in any order:
      | r    |
      | null |
      | null |
      | null |
    And no side effects

  @modified
  Scenario: [26] Handling correlated optional matches; first does not match implies second does not match
    Given an empty graph
    And having defined kuzu types: abcs:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (a:A), (b:B)
      OPTIONAL MATCH (a)-->(x)
      OPTIONAL MATCH (x)-[r]->(b)
      RETURN concat('(:', LABEL(x), ')') as x,
             CASE r WHEN null THEN 'null' ELSE concat('(:', LABEL(r), ')') END as r
      """
    Then the result should be, in any order:
      | x    | r    |
      | (:C) | null |
    And no side effects

  @modified @fails @bugUnexpectedOutput @kuzubug
  # Produces all nulls.
  Scenario: [27] Handling optional matches between optionally matched entities
    Given an empty graph
    And having defined kuzu types: abcns_num:lnr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      OPTIONAL MATCH (a:NotThere)
      WITH a
      MATCH (b:B)
      WITH a, b
      OPTIONAL MATCH (b)-[r:NOR_THIS]->(a)
      RETURN CASE a WHEN null THEN 'null' ELSE concat('(:', label(a), ' {num: ', a.num, '})') END as a,
             CASE b WHEN null THEN 'null' ELSE concat('(:', label(b), ' {num: ', b.num, '})') END as b,
             CASE r WHEN null THEN 'null' ELSE concat('[:', label(r), ']') END as r
      """
    Then the result should be, in any order:
      | a    | b              | r    |
      | null | (:B {num: 46}) | null |
    And no side effects

  @modified
  Scenario: [28] Handling optional matches with inline label predicate
    Given an empty graph
    And having defined kuzu types: abcns_num:lr
    And having executed:
      """
      CREATE (s:Singlee), (a:A {num: 42}),
             (b:B {num: 46}), (c:C)
      CREATE (s)-[:REL]->(a),
             (s)-[:REL]->(b),
             (a)-[:REL]->(c),
             (b)-[:LOOP]->(b)
      """
    When executing query:
      """
      MATCH (n:Singlee)
      OPTIONAL MATCH (n)-[r]-(m:NonExistent)
      RETURN CASE r WHEN null THEN 'null' ELSE concat('(:', LABEL(r), ')') END as r
      """
    Then the result should be, in any order:
      | r    |
      | null |
    And no side effects

  @modified @outputModified
  Scenario: [29] Satisfies the open world assumption, relationships between same nodes
    Given an empty graph
    And having defined kuzu types: pt:ps
    And having executed:
      """
      CREATE (a:Player), (b:Team)
      CREATE (a)-[:PLAYS_FOR]->(b),
             (a)-[:SUPPORTS]->(b)
      """
    When executing query:
      """
      MATCH (p:Player)-[:PLAYS_FOR]->(team:Team)
      OPTIONAL MATCH (p)-[s:SUPPORTS]->(team)
      RETURN count(*) AS matches, s IS NULL AS optMatch
      """
    Then the result should be, in any order:
      | matches | optMatch |
      | 1       | False    |
    And no side effects

  @modified @outputModified
  Scenario: [30] Satisfies the open world assumption, single relationship
    Given an empty graph
    And having defined kuzu types: pt:ps
    And having executed:
      """
      CREATE (a:Player), (b:Team)
      CREATE (a)-[:PLAYS_FOR]->(b)
      """
    When executing query:
      """
      MATCH (p:Player)-[:PLAYS_FOR]->(team:Team)
      OPTIONAL MATCH (p)-[s:SUPPORTS]->(team)
      RETURN count(*) AS matches, s IS NULL AS optMatch
      """
    Then the result should be, in any order:
      | matches | optMatch |
      | 1       | True     |
    And no side effects

  @modified @outputModified
  Scenario: [31] Satisfies the open world assumption, relationships between different nodes
    Given an empty graph
    And having defined kuzu types: pt:ps
    And having executed:
      """
      CREATE (a:Player), (b:Team), (c:Team)
      CREATE (a)-[:PLAYS_FOR]->(b),
             (a)-[:SUPPORTS]->(c)
      """
    When executing query:
      """
      MATCH (p:Player)-[:PLAYS_FOR]->(team:Team)
      OPTIONAL MATCH (p)-[s:SUPPORTS]->(team)
      RETURN count(*) AS matches, s IS NULL AS optMatch
      """
    Then the result should be, in any order:
      | matches | optMatch |
      | 1       | True     |
    And no side effects
