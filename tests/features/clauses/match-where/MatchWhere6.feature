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

Feature: MatchWhere6 - Filter optional matches

  @fails @labelInMatch
  Scenario: [1] Filter node with node label predicate on multi variables with multiple bindings after MATCH and OPTIONAL MATCH
    Given an empty graph
    And having defined kuzu types: abcd_name:t
    And having executed:
      """
      CREATE (a:A {name: 'A'}), (b:B {name: 'B'}), (c:C {name: 'C'}), (d:D {name: 'C'})
      CREATE (a)-[:T]->(b),
             (a)-[:T]->(c),
             (a)-[:T]->(d)
      """
    When executing query:
      """
      MATCH (a)-->(b)
      WHERE b:B
      OPTIONAL MATCH (a)-->(c)
      WHERE c:C
      RETURN a.name
      """
    Then the result should be, in any order:
      | a.name |
      | A      |
    And no side effects

  @fails @labelInMatch
  Scenario: [2] Filter node with false node label predicate after OPTIONAL MATCH
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
      MATCH (n:Singlee)
      OPTIONAL MATCH (n)-[r]-(m)
      WHERE m:NonExistent
      RETURN r
      """
    Then the result should be, in any order:
      | r    |
      | null |
    And no side effects

  Scenario: [3] Filter node with property predicate on multi variables with multiple bindings after OPTIONAL MATCH
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
      MATCH (n:Singlee)
      OPTIONAL MATCH (n)-[r]-(m)
      WHERE m.num = 42
      RETURN m.num as m
      """
    Then the result should be, in any order:
      | m  |
      | 42 |
    And no side effects

  Scenario: [4] Do not fail when predicates on optionally matched and missed nodes are invalid
    Given an empty graph
    And having defined kuzu types: ab_name:t
    And having executed:
      """
      CREATE (a:A), (b:B {name: 'Mark'})
      CREATE (a)-[:T]->(b)
      """
    When executing query:
      """
      MATCH (n)-->(x0)
      OPTIONAL MATCH (x0)-->(x1)
      WHERE x1.name = 'bar'
      RETURN x0.name
      """
    Then the result should be, in any order:
      | x0.name |
      | 'Mark'  |
    And no side effects

  @fails @multipleVarBindings
  Scenario: [5] Matching and optionally matching with unbound nodes and equality predicate in reverse direction
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
      OPTIONAL MATCH (a2)<-[r]-(b2)
      WHERE a1 = a2
      RETURN label(a1) as a1, label(r) as r, label(b2) as b2, label(a2) as a2
      """
    Then the result should be, in any order:
      | a1 | r | b2 | a2 |
      | A  | T |    |    |
    And no side effects

  Scenario: [6] Join nodes on non-equality of properties – OPTIONAL MATCH and WHERE
    Given an empty graph
    And having defined kuzu types: xyz_val:e12
    And having executed:
      """
      CREATE
        (:X {val: 1})-[:E1]->(:Y {val: 2})-[:E2]->(:Z {val: 3}),
        (:X {val: 4})-[:E1]->(:Y {val: 5}),
        (:X {val: 6})
      """
    When executing query:
      """
      MATCH (x:X)
      OPTIONAL MATCH (x)-[:E1]->(y:Y)
      WHERE x.val < y.val
      RETURN x.val as x, y.val as y
      """
    Then the result should be, in any order:
      | x | y    |
      | 1 | 2    |
      | 4 | 5    |
      | 6 | null |
    And no side effects

  Scenario: [7] Join nodes on non-equality of properties – OPTIONAL MATCH on two relationships and WHERE
    Given an empty graph
    And having defined kuzu types: xyz_val:e12
    And having executed:
      """
      CREATE
        (:X {val: 1})-[:E1]->(:Y {val: 2})-[:E2]->(:Z {val: 3}),
        (:X {val: 4})-[:E1]->(:Y {val: 5}),
        (:X {val: 6})
      """
    When executing query:
      """
      MATCH (x:X)
      OPTIONAL MATCH (x)-[:E1]->(y:Y)-[:E2]->(z:Z)
      WHERE x.val < z.val
      RETURN x.val as x, y.val as y, z.val as z
      """
    Then the result should be, in any order:
      | x | y    | z    |
      | 1 | 2    | 3    |
      | 4 | null | null |
      | 6 | null | null |
    And no side effects

  Scenario: [8] Join nodes on non-equality of properties – Two OPTIONAL MATCH clauses and WHERE
    Given an empty graph
    And having defined kuzu types: xyz_val:e12
    And having executed:
      """
      CREATE
        (:X {val: 1})-[:E1]->(:Y {val: 2})-[:E2]->(:Z {val: 3}),
        (:X {val: 4})-[:E1]->(:Y {val: 5}),
        (:X {val: 6})
      """
    When executing query:
      """
      MATCH (x:X)
      OPTIONAL MATCH (x)-[:E1]->(y:Y)
      OPTIONAL MATCH (y)-[:E2]->(z:Z)
      WHERE x.val < z.val
      RETURN x.val as x, y.val as y, z.val as z
      """
    Then the result should be, in any order:
      | x | y    | z    |
      | 1 | 2    | 3    |
      | 4 | 5    | null |
      | 6 | null | null |
    And no side effects
