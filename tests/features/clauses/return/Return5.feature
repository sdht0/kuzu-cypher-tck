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

Feature: Return5 - Implicit grouping with distinct

  Scenario: [1] DISTINCT inside aggregation should work with lists in maps
    Given an empty graph
    And having defined kuzu types: n_l
    And having executed:
      """
      CREATE (:N {list: ['A', 'B']}), (:N {list: ['A', 'B']})
      """
    When executing query:
      """
      MATCH (n)
      RETURN count(DISTINCT {name: n.list}) AS count
      """
    Then the result should be, in any order:
      | count |
      | 1     |
    And no side effects

  Scenario: [2] DISTINCT on nullable values
    Given an empty graph
    And having defined kuzu types: n_name
    And having executed:
      """
      CREATE (:N {name: 'Florescu'}), (:N), (:N)
      """
    When executing query:
      """
      MATCH (n)
      RETURN DISTINCT n.name
      """
    Then the result should be, in any order:
      | n.name     |
      | 'Florescu' |
      | null       |
    And no side effects

  Scenario: [3] DISTINCT inside aggregation should work with nested lists in maps
    Given an empty graph
    And having defined kuzu types: n_l
    And having executed:
      """
      CREATE (:N {list: ['A', 'B']}), (:N {list: ['A', 'B']})
      """
    When executing query:
      """
      MATCH (n)
      RETURN count(DISTINCT {name: [[n.list, n.list], [n.list, n.list]]}) AS count
      """
    Then the result should be, in any order:
      | count |
      | 1     |
    And no side effects

  @fails @typeErrorArray
  Scenario: [4] DISTINCT inside aggregation should work with nested lists of maps in maps
    Given an empty graph
    And having defined kuzu types: n_l
    And having executed:
      """
      CREATE (:N {list: ['A', 'B']}), (:N {list: ['A', 'B']})
      """
    When executing query:
      """
      MATCH (n)
      RETURN count(DISTINCT {name: [{name2: n.list}, {baz: {apa: n.list}}]}) AS count
      """
    Then the result should be, in any order:
      | count |
      | 1     |
    And no side effects

  Scenario: [5] Aggregate on list values
    Given an empty graph
    And having defined kuzu types: n_color
    And having executed:
      """
      CREATE (:N {color: ['red']})
      CREATE (:N {color: ['blue']})
      CREATE (:N {color: ['red']})
      """
    When executing query:
      """
      MATCH (a)
      RETURN DISTINCT a.color, count(*) as c
      """
    Then the result should be, in any order:
      | a.color  | c |
      | ['red']  | 2 |
      | ['blue'] | 1 |
    And no side effects
