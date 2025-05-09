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

Feature: Quantifier6 - Single quantifier interop

  Scenario Outline: [1] Single quantifier can nest itself and other quantifiers on nested lists
    Given any graph
    When executing query:
      """
      RETURN single(x IN [['abc'], ['abc', 'def']] WHERE <condition>) AS result
      """
    Then the result should be, in any order:
      | result   |
      | <result> |
    And no side effects

    Examples:
      | condition                      | result |
      | none(y IN x WHERE y = 'def')   | true   |
      | none(y IN x WHERE y = 'ghi')   | false  |
      | single(y IN x WHERE y = 'def') | true   |
      | single(y IN x WHERE y = 'abc') | false  |
      | any(y IN x WHERE y = 'def')    | true   |
      | any(y IN x WHERE y = 'abc')    | false  |
      | all(y IN x WHERE y = 'abc')    | true   |
      | all(y IN x WHERE y = 'def')    | false  |

  Scenario Outline: [2] Single quantifier can nest itself and other quantifiers on the same list
    Given any graph
    When executing query:
      """
      WITH [1, 2, 3, 4, 5, 6, 7, 8, 9] AS list
      RETURN single(x IN list WHERE <condition>) AS result
      """
    Then the result should be, in any order:
      | result   |
      | <result> |
    And no side effects

    Examples:
      | condition                           | result |
      | none(y IN list WHERE x < y)         | true   |
      | none(y IN list WHERE x % y = 0)     | false  |
      | single(y IN list WHERE x + y < 5)   | true   |
      | single(y IN list WHERE x % y = 1)   | false  |
      | any(y IN list WHERE 2 * x + y > 25) | true   |
      | any(y IN list WHERE x < y)          | false  |
      | all(y IN list WHERE x <= y)         | true   |
      | all(y IN list WHERE x <= y + 1)     | false  |

  Scenario Outline: [3] Single quantifier is equal whether the size of the list filtered with same the predicate is one
    Given any graph
    When executing query:
      """
      RETURN single(x IN [1, 2, 3, 4, 5, 6, 7, 8, 9] WHERE <predicate>) = (size([x IN [1, 2, 3, 4, 5, 6, 7, 8, 9] WHERE <predicate> | x]) = 1) AS result
      """
    Then the result should be, in any order:
      | result |
      | true   |
    And no side effects

    Examples:
      | predicate |
      | x = 2     |
      | x % 2 = 0 |
      | x % 3 = 0 |
      | x < 7     |
      | x >= 3    |
