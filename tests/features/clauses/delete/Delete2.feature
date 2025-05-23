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

Feature: Delete2 - Deleting relationships

  @fails @unsupportedUndirDelete
  Scenario: [1] Delete relationships
    Given an empty graph
    And having defined kuzu types: n:r
    And having executed:
      """
      UNWIND range(0, 2) AS i
      CREATE (:N)-[:R]->(:N)
      """
    When executing query:
      """
      MATCH ()-[r]-()
      DELETE r
      """
    Then the result should be empty
    And the side effects should be:
      | -relationships | 3 |

  @fails @unsupportedUndirDelete
  Scenario: [2] Delete optionally matched relationship
    Given an empty graph
    And having defined kuzu types: n
    And having executed:
      """
      CREATE (:N)
      """
    When executing query:
      """
      MATCH (n)
      OPTIONAL MATCH (n)-[r]-()
      DELETE n, r
      """
    Then the result should be empty
    And the side effects should be:
      | -nodes | 1 |

  @fails @unsupportedUndirDelete
  Scenario: [3] Delete relationship with bidirectional matching
    Given an empty graph
    And having defined kuzu types: n:t_id
    And having executed:
      """
      CREATE (:N)-[:T {id: 42}]->(:N)
      """
    When executing query:
      """
      MATCH p = ()-[r:T]-()
      WHERE r.id = 42
      DELETE r
      """
    Then the result should be empty
    And the side effects should be:
      | -relationships | 1 |
      | -properties    | 1 |

  @fails @unsupportedUndirDelete
  Scenario: [4] Ignore null when deleting relationship
    Given an empty graph
    And having defined kuzu types: n:d
    When executing query:
      """
      OPTIONAL MATCH (:N)-[r:DoesNotExist]-(:N)
      DELETE r
      RETURN r
      """
    Then the result should be, in any order:
      | r |
      |   |
    And no side effects

  Scenario: [5] Failing when deleting a relationship type
    Given an empty graph
    And having defined kuzu types: n:t_id
    And having executed:
      """
      CREATE (:N)-[:T {id: 42}]->(:N)
      """
    When executing query:
      """
      MATCH ()-[r:T]-()
      DELETE r:T
      """
    Then a SyntaxError should be raised at compile time: InvalidDelete
