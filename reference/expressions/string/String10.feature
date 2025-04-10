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

Feature: String10 - Exact Substring Search

  Scenario: [1] Finding exact matches with non-proper substring
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      MATCH (a)
      WHERE a.name CONTAINS 'ABCDEF'
      RETURN a
      """
    Then the result should be, in any order:
      | a                            |
      | (:TheLabel {name: 'ABCDEF'}) |
    And no side effects

  Scenario: [2] Finding substring of string
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      MATCH (a)
      WHERE a.name CONTAINS 'CD'
      RETURN a
      """
    Then the result should be, in any order:
      | a                            |
      | (:TheLabel {name: 'ABCDEF'}) |
    And no side effects

  Scenario: [3] Finding the empty substring
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      MATCH (a)
      WHERE a.name CONTAINS ''
      RETURN a
      """
    Then the result should be, in any order:
      | a                            |
      | (:TheLabel {name: 'ABCDEF'}) |
      | (:TheLabel {name: 'AB'})     |
      | (:TheLabel {name: 'abcdef'}) |
      | (:TheLabel {name: 'ab'})     |
      | (:TheLabel {name: ''})       |
    And no side effects

  Scenario: [4] Finding strings containing whitespace
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel),
             (:TheLabel {name: 'Foo Foo'}),
             (:TheLabel {name: 'Foo\nFoo'}),
             (:TheLabel {name: 'Foo\tFoo'})
      """
    When executing query:
      """
      MATCH (a)
      WHERE a.name CONTAINS ' '
      RETURN a.name AS name
      """
    Then the result should be, in any order:
      | name    |
      | 'Foo Foo' |
    And no side effects

  Scenario: [5] Finding strings containing newline
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel),
             (:TheLabel {name: 'Foo Foo'}),
             (:TheLabel {name: 'Foo\nFoo'}),
             (:TheLabel {name: 'Foo\tFoo'})
      """
    When executing query:
      """
      MATCH (a)
      WHERE a.name CONTAINS '\n'
      RETURN a.name AS name
      """
    Then the result should be, in any order:
      | name      |
      | 'Foo\nFoo' |
    And no side effects

  Scenario: [6] No string contains null
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      MATCH (a)
      WHERE a.name CONTAINS null
      RETURN a
      """
    Then the result should be, in any order:
      | a |
    And no side effects

  Scenario: [7] No string does not contain null
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      MATCH (a)
      WHERE NOT a.name CONTAINS null
      RETURN a
      """
    Then the result should be, in any order:
      | a |
    And no side effects

  Scenario: [8] Handling non-string operands for CONTAINS
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      WITH [1, 3.14, true, [], {}, null] AS operands
      UNWIND operands AS op1
      UNWIND operands AS op2
      WITH op1 CONTAINS op2 AS v
      RETURN v, count(*)
      """
    Then the result should be, in any order:
      | v    | count(*) |
      | null | 36       |
    And no side effects

  Scenario: [9] NOT with CONTAINS
    Given an empty graph
    And having executed:
      """
      CREATE (:TheLabel {name: 'ABCDEF'}), (:TheLabel {name: 'AB'}),
             (:TheLabel {name: 'abcdef'}), (:TheLabel {name: 'ab'}),
             (:TheLabel {name: ''}), (:TheLabel)
      """
    When executing query:
      """
      MATCH (a)
      WHERE NOT a.name CONTAINS 'b'
      RETURN a
      """
    Then the result should be, in any order:
      | a                            |
      | (:TheLabel {name: 'ABCDEF'}) |
      | (:TheLabel {name: 'AB'})     |
      | (:TheLabel {name: ''})       |
    And no side effects
