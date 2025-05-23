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

Feature: ReturnOrderBy2 - Order by a single expression (order of projection)

  Scenario: [1] ORDER BY should return results in ascending order
    Given an empty graph
    And having defined kuzu types: n_num
    And having executed:
      """
      CREATE (n1:N {num: 1}),
        (n2:N {num: 3}),
        (n3:N {num: -5})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.num AS prop
      ORDER BY n.num
      """
    Then the result should be, in order:
      | prop |
      | -5   |
      | 1    |
      | 3    |
    And no side effects

  Scenario: [2] ORDER BY DESC should return results in descending order
    Given an empty graph
    And having defined kuzu types: n_num
    And having executed:
      """
      CREATE (n1:N {num: 1}),
        (n2:N {num: 3}),
        (n3:N {num: -5})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.num AS prop
      ORDER BY n.num DESC
      """
    Then the result should be, in order:
      | prop |
      | 3    |
      | 1    |
      | -5   |
    And no side effects

  Scenario: [3] Sort on aggregated function
    Given an empty graph
    And having defined kuzu types: n_ad
    And having executed:
      """
      CREATE (:N {division: 'A', age: 22}),
        (:N {division: 'B', age: 33}),
        (:N {division: 'B', age: 44}),
        (:N {division: 'C', age: 55})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.division as div, max(n.age) as max
        ORDER BY max
      """
    Then the result should be, in order:
      | div | max |
      | 'A' | 22  |
      | 'B' | 44  |
      | 'C' | 55  |
    And no side effects


  Scenario: [4] Support sort and distinct
    Given an empty graph
    And having defined kuzu types: n_name
    And having executed:
      """
      CREATE (:N {name: 'A'}),
        (:N {name: 'B'}),
        (:N {name: 'C'})
      """
    When executing query:
      """
      MATCH (a)
      RETURN DISTINCT a
        ORDER BY a.name
      """
    Then the result should be, in order:
      | a                |
      | (:N {name: 'A'}) |
      | (:N {name: 'B'}) |
      | (:N {name: 'C'}) |
    And no side effects

  Scenario: [5] Support ordering by a property after being distinct-ified
    Given an empty graph
    And having defined kuzu types: ab_name:t
    And having executed:
      """
      CREATE (:A)-[:T]->(:B)
      """
    When executing query:
      """
      MATCH (a)-->(b)
      RETURN DISTINCT b
        ORDER BY b.name
      """
    Then the result should be, in order:
      | b    |
      | (:B) |
    And no side effects

  Scenario: [6] Count star should count everything in scope
    Given an empty graph
    And having defined kuzu types: l13
    And having executed:
      """
      CREATE (:L1), (:L2), (:L3)
      """
    When executing query:
      """
      MATCH (a)
      RETURN a, count(*) as count
      ORDER BY count
      """
    Then the result should be, in any order:
      | a     | count |
      | (:L1) | 1     |
      | (:L2) | 1     |
      | (:L3) | 1     |
    And no side effects

  Scenario: [7] Ordering with aggregation
    Given an empty graph
    And having defined kuzu types: n_name
    And having executed:
      """
      CREATE (:N {name: 'nisse'})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.name, count(*) AS foo
        ORDER BY n.name
      """
    Then the result should be, in order:
      | n.name  | foo |
      | 'nisse' | 1   |
    And no side effects

  Scenario: [8] Returning all variables with ordering
    Given an empty graph
    And having defined kuzu types: n_id
    And having executed:
      """
      CREATE (:N {id: 1}), (:N {id: 10})
      """
    When executing query:
      """
      MATCH (n)
      RETURN *
        ORDER BY n.id
      """
    Then the result should be, in order:
      | n             |
      | (:N {id: 1})  |
      | (:N {id: 10}) |
    And no side effects

  Scenario: [9] Using aliased DISTINCT expression in ORDER BY
    Given an empty graph
    And having defined kuzu types: n_id
    And having executed:
      """
      CREATE (:N {id: 1}), (:N {id: 10})
      """
    When executing query:
      """
      MATCH (n)
      RETURN DISTINCT n.id AS id
        ORDER BY id DESC
      """
    Then the result should be, in order:
      | id |
      | 10 |
      | 1  |
    And no side effects

  Scenario: [10] Returned columns do not change from using ORDER BY
    Given an empty graph
    And having defined kuzu types: n_id
    And having executed:
      """
      CREATE (:N {id: 1}), (:N {id: 10})
      """
    When executing query:
      """
      MATCH (n)
      RETURN DISTINCT n
        ORDER BY n.id
      """
    Then the result should be, in order:
      | n             |
      | (:N {id: 1})  |
      | (:N {id: 10}) |
    And no side effects

  Scenario: [11] Aggregates ordered by arithmetics
    Given an empty graph
    And having defined kuzu types: ax
    And having executed:
      """
      CREATE (:A), (:X), (:X)
      """
    When executing query:
      """
      MATCH (a:A), (b:X)
      RETURN count(a) * 10 + count(b) * 5 AS x
      ORDER BY x
      """
    Then the result should be, in order:
      | x  |
      | 30 |
    And no side effects

  Scenario: [12] Aggregation of named paths
    Given an empty graph
    And having defined kuzu types: abcdef:r
    And having executed:
      """
      CREATE (a:A), (b:B), (c:C), (d:D), (e:E), (f:F)
      CREATE (a)-[:R]->(b)
      CREATE (c)-[:R]->(d)
      CREATE (d)-[:R]->(e)
      CREATE (e)-[:R]->(f)
      """
    When executing query:
      """
      MATCH p = (a)-[*]->(b)
      RETURN collect(nodes(p)) AS paths, length(p) AS l
      ORDER BY l
      """
    Then the result should be, in order (ignoring element order for lists):
      | paths                                                    | l |
      | [[(:A), (:B)], [(:C), (:D)], [(:D), (:E)], [(:E), (:F)]] | 1 |
      | [[(:C), (:D), (:E)], [(:D), (:E), (:F)]]                 | 2 |
      | [[(:C), (:D), (:E), (:F)]]                               | 3 |
    And no side effects

  Scenario: [13] Fail when sorting on variable removed by DISTINCT
    Given an empty graph
    And having defined kuzu types: n_agename
    And having executed:
      """
      CREATE (:N {name: 'A', age: 13}), (:N {name: 'B', age: 12}), (:N {name: 'C', age: 11})
      """
    When executing query:
      """
      MATCH (a)
      RETURN DISTINCT a.name
        ORDER BY a.age
      """
    Then a SyntaxError should be raised at compile time: UndefinedVariable

  Scenario: [14] Fail on aggregation in ORDER BY after RETURN
    Given any graph
    And having defined kuzu types: n_num12
    When executing query:
      """
      MATCH (n:N)
      RETURN n.num1
        ORDER BY max(n.num2)
      """
    Then a SyntaxError should be raised at compile time: InvalidAggregation
