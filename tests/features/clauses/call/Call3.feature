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

Feature: Call3 - Assignable-type arguments

  @skip @unsupportedCustomProc
  Scenario: [1] Standalone call to procedure with argument of type NUMBER accepts value of type INTEGER
    Given an empty graph
    And there exists a procedure test.my.proc(in :: NUMBER?) :: (out :: STRING?):
      | in   | out           |
      | 42   | 'wisdom'      |
      | 42.3 | 'about right' |
    When executing query:
      """
      CALL test.my.proc(42)
      """
    Then the result should be, in order:
      | out      |
      | 'wisdom' |
    And no side effects

  @skip @unsupportedCustomProc
  Scenario: [2] In-query call to procedure with argument of type NUMBER accepts value of type INTEGER
    Given an empty graph
    And there exists a procedure test.my.proc(in :: NUMBER?) :: (out :: STRING?):
      | in   | out           |
      | 42   | 'wisdom'      |
      | 42.3 | 'about right' |
    When executing query:
      """
      CALL test.my.proc(42) YIELD out
      RETURN out
      """
    Then the result should be, in order:
      | out      |
      | 'wisdom' |
    And no side effects

  @skip @unsupportedCustomProc
  Scenario: [3] Standalone call to procedure with argument of type NUMBER accepts value of type FLOAT
    Given an empty graph
    And there exists a procedure test.my.proc(in :: NUMBER?) :: (out :: STRING?):
      | in   | out           |
      | 42   | 'wisdom'      |
      | 42.3 | 'about right' |
    When executing query:
      """
      CALL test.my.proc(42.3)
      """
    Then the result should be, in order:
      | out           |
      | 'about right' |
    And no side effects

  @skip @unsupportedCustomProc
  Scenario: [4] In-query call to procedure with argument of type NUMBER accepts value of type FLOAT
    Given an empty graph
    And there exists a procedure test.my.proc(in :: NUMBER?) :: (out :: STRING?):
      | in   | out           |
      | 42   | 'wisdom'      |
      | 42.3 | 'about right' |
    When executing query:
      """
      CALL test.my.proc(42.3) YIELD out
      RETURN out
      """
    Then the result should be, in order:
      | out           |
      | 'about right' |
    And no side effects

  @skip @unsupportedCustomProc
  Scenario: [5] Standalone call to procedure with argument of type FLOAT accepts value of type INTEGER
    Given an empty graph
    And there exists a procedure test.my.proc(in :: FLOAT?) :: (out :: STRING?):
      | in   | out            |
      | 42.0 | 'close enough' |
    When executing query:
      """
      CALL test.my.proc(42)
      """
    Then the result should be, in order:
      | out            |
      | 'close enough' |
    And no side effects

  @skip @unsupportedCustomProc
  Scenario: [6] In-query call to procedure with argument of type FLOAT accepts value of type INTEGER
    Given an empty graph
    And there exists a procedure test.my.proc(in :: FLOAT?) :: (out :: STRING?):
      | in   | out            |
      | 42.0 | 'close enough' |
    When executing query:
      """
      CALL test.my.proc(42) YIELD out
      RETURN out
      """
    Then the result should be, in order:
      | out            |
      | 'close enough' |
    And no side effects
