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

Feature: Aggregation8 - DISTINCT

  Scenario: [1] Distinct on unbound node
    Given an empty graph
    When executing query:
      """
      OPTIONAL MATCH (a)
      RETURN count(DISTINCT a)
      """
    Then the result should be, in any order:
      | count(DISTINCT a) |
      | 0                 |
    And no side effects

  Scenario: [2] Distinct on null
    Given an empty graph
    And having executed:
      """
      CREATE ()
      """
    When executing query:
      """
      MATCH (a)
      RETURN count(DISTINCT a.name)
      """
    Then the result should be, in any order:
      | count(DISTINCT a.name) |
      | 0                      |
    And no side effects

  Scenario: [3] Collect distinct nulls
    Given any graph
    When executing query:
      """
      UNWIND [null, null] AS x
      RETURN collect(DISTINCT x) AS c
      """
    Then the result should be, in any order:
      | c  |
      | [] |
    And no side effects

  Scenario: [4] Collect distinct values mixed with nulls
    Given any graph
    When executing query:
      """
      UNWIND [null, 1, null] AS x
      RETURN collect(DISTINCT x) AS c
      """
    Then the result should be, in any order:
      | c   |
      | [1] |
    And no side effects
