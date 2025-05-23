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

Feature: Delete3 - Deleting named paths

  @fails @deletePath
  Scenario: [1] Detach deleting paths
    Given an empty graph
    And having defined kuzu types: nx:r
    And having executed:
      """
      CREATE (x:X), (n1:N), (n2:N), (n3:N)
      CREATE (x)-[:R]->(n1)
      CREATE (n1)-[:R]->(n2)
      CREATE (n2)-[:R]->(n3)
      """
    When executing query:
      """
      MATCH p = (:X)-->()-->()-->()
      DETACH DELETE p
      """
    Then the result should be empty
    And the side effects should be:
      | -nodes         | 4 |
      | -relationships | 3 |
      | -labels        | 1 |

  @fails @deletePath
  Scenario: [2] Delete on null path
    Given an empty graph
    When executing query:
      """
      OPTIONAL MATCH p = ()-->()
      DETACH DELETE p
      """
    Then the result should be empty
    And no side effects
