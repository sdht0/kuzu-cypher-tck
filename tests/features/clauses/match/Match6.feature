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

Feature: Match6 - Match named paths scenarios

  @note @tckDifferentPathOutputFormat
  Scenario: [1] Zero-length named path
    Given an empty graph
    And having defined kuzu types: n_name
    And having executed:
      """
      CREATE (:N {name: 'N'})
      """
    When executing query:
      """
      MATCH p = (a)
      RETURN p
      """
    Then the result should be, in any order:
      | p  |
      | [] |
    And no side effects

  Scenario: [2] Return a simple path
    Given an empty graph
    And having defined kuzu types: ab_name:k
    And having executed:
      """
      CREATE (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})
      """
    When executing query:
      """
      MATCH p = (a {name: 'A'})-->(b)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p          |
      | ['A', 'B'] |
    And no side effects

  Scenario: [3] Return a three node path
    Given an empty graph
    And having defined kuzu types: abc_name:k
    And having executed:
      """
      CREATE (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:KNOWS]->(c:C {name: 'C'})
      """
    When executing query:
      """
      MATCH p = (a {name: 'A'})-[rel1]->(b)-[rel2]->(c)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A', 'B', 'C'] |
    And no side effects

  Scenario: [4] Respecting direction when matching non-existent path
    Given an empty graph
    And having defined kuzu types: n_name:t
    And having executed:
      """
      CREATE (a:N {name: 'a'}), (b:N {name: 'b'})
      CREATE (a)-[:T]->(b)
      """
    When executing query:
      """
      MATCH p = ({name: 'a'})<--({name: 'b'})
      RETURN p
      """
    Then the result should be, in any order:
      | p |
    And no side effects

  Scenario: [5] Path query should return results in written order
    Given an empty graph
    And having defined kuzu types: l12_name:t
    And having executed:
      """
      CREATE (:Label1 {name: 'Label1'})<-[:TYPE]-(:Label2 {name: 'Label2'})
      """
    When executing query:
      """
      MATCH p = (a:Label1)<--(:Label2)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p                    |
      | ['Label1', 'Label2'] |
    And no side effects

  Scenario: [6] Handling direction of named paths
    Given an empty graph
    And having defined kuzu types: ab_name:t
    And having executed:
      """
      CREATE (a:A {name: 'A'})-[:T]->(b:B {name: 'B'})
      """
    When executing query:
      """
      MATCH p = (b)<--(a)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p          |
      | ['B', 'A'] |
    And no side effects

  Scenario: [7] Respecting direction when matching existing path
    Given an empty graph
    And having defined kuzu types: n_name:t
    And having executed:
      """
      CREATE (a:N {name: 'a'}), (b:N {name: 'b'})
      CREATE (a)-[:T]->(b)
      """
    When executing query:
      """
      MATCH p = ({name: 'a'})-->({name: 'b'})
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p          |
      | ['a', 'b'] |
    And no side effects

  @fails @semanticsBackTraversal
  Scenario: [8] Respecting direction when matching non-existent path with multiple directions
    Given an empty graph
    And having defined kuzu types: n_name:t
    And having executed:
      """
      CREATE (a:N {name: 'a'}), (b:N {name: 'b'})
      CREATE (a)-[:T]->(b),
             (b)-[:T]->(a)
      """
    When executing query:
      """
      MATCH p = (n)-->(k)<--(n)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p |
    And no side effects

  @fails @semanticsUndirTraversal
  Scenario: [9] Longer path query should return results in written order
    Given an empty graph
    And having defined kuzu types: l13_name:t12
    And having executed:
      """
      CREATE (:Label1 {name: 'Label1'})<-[:T1]-(:Label2 {name: 'Label2'})-[:T2]->(:Label3 {name: 'Label3'})
      """
    When executing query:
      """
      MATCH p = (a:Label1)<--(:Label2)--()
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p                              |
      | ['Label1', 'Label2', 'Label3'] |
    And no side effects

  @fails @semanticsUndirTraversal
  Scenario: [10] Named path with alternating directed/undirected relationships
    Given an empty graph
    And having defined kuzu types: abc_name:t
    And having executed:
      """
      CREATE (a:A {name: "A"}), (b:B {name: "B"}), (c:C {name: "C"})
      CREATE (b)-[:T]->(a),
             (c)-[:T]->(b)
      """
    When executing query:
      """
      MATCH p = (n)-->(m)--(o)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['C', 'B', 'A'] |
    And no side effects

  @fails @semanticsUndirTraversal
  Scenario: [11] Named path with multiple alternating directed/undirected relationships
    Given an empty graph
    And having defined kuzu types: abcd_name:t
    And having executed:
      """
      CREATE (a:A {name: "A"}), (b:B {name: "B"}), (c:C {name: "C"}), (d:D {name: "D"})
      CREATE (b)-[:T]->(a),
             (c)-[:T]->(b),
             (d)-[:T]->(c)
      """
    When executing query:
      """
      MATCH path = (n)-->(m)--(o)--(p)
      RETURN properties(nodes(path), 'name') as path
      """
    Then the result should be, in any order:
      | path                 |
      | ['D', 'C', 'B', 'A'] |
    And no side effects

  @note @cypherUndirectedDoubleArrow
  @fails @semanticsUndirTraversal
  Scenario: [12] Matching path with multiple bidirectional relationships
    Given an empty graph
    And having defined kuzu types: ab_name:t14
    And having executed:
      """
      CREATE (a:A {name: "A"}), (b:B {name: "B"})
      CREATE (a)-[:T1]->(b),
             (b)-[:T2]->(a)
      """
    When executing query:
      """
      MATCH p=(n)--(k)--(n)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A', 'B', 'A'] |
      | ['A', 'B', 'A'] |
      | ['B', 'A', 'B'] |
      | ['B', 'A', 'B'] |
    And no side effects

  @fails @semanticsUndirTraversal
  Scenario: [13] Matching path with both directions should respect other directions
    Given an empty graph
    And having defined kuzu types: ab_name:t14
    And having executed:
      """
      CREATE (a:A {name: "A"}), (b:B {name: "B"})
      CREATE (a)-[:T1]->(b),
             (b)-[:T2]->(a)
      """
    When executing query:
      """
      MATCH p = (n)--(k)<--(n)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A', 'B', 'A'] |
      | ['B', 'A', 'B'] |
    And no side effects

  @fails @semanticsUndirTraversal
  Scenario: [14] Named path with undirected fixed variable length pattern
    Given an empty graph
    And having defined kuzu types: ens_name:c
    And having executed:
      """
      CREATE (db1:Start {name: "Start"}), (db2:`End` {name: "End"}),
             (mid:N {name: "Mid"}), (other:N {name: "Other"})
      CREATE (mid)-[:CONNECTED_TO]->(db1),
             (mid)-[:CONNECTED_TO]->(db2),
             (mid)-[:CONNECTED_TO]->(db2),
             (mid)-[:CONNECTED_TO]->(other),
             (mid)-[:CONNECTED_TO]->(other)
      """
    When executing query:
      """
      MATCH topRoute = (:Start)<-[:CONNECTED_TO]-()-[:CONNECTED_TO*3..3]-(:`End`)
      RETURN properties(nodes(topRoute), 'name') as topRoute
      """
    Then the result should be, in any order:
      | topRoute                                |
      | ['Start', 'Mid', 'Other', 'Mid', 'End'] |
      | ['Start', 'Mid', 'End', 'Mid', 'End']   |
      | ['Start', 'Mid', 'Start', 'Mid', 'End'] |
      | ['Start', 'Mid', 'Start', 'Mid', 'End'] |
    And no side effects

  Scenario: [15] Variable-length named path
    Given an empty graph
    And having defined kuzu types: n_name
    And having executed:
      """
      CREATE (:N {name: 'N'})
      """
    When executing query:
      """
      MATCH p = ()-[*0..]->()
      RETURN p
      """
    Then the result should be, in any order:
      | p |
    And no side effects

  Scenario: [16] Return a var length path
    Given an empty graph
    And having defined kuzu types: abc_name:k_num
    And having executed:
      """
      CREATE (a:A {name: 'A'})-[:KNOWS {num: 1}]->(b:B {name: 'B'})-[:KNOWS {num: 2}]->(c:C {name: 'C'})
      """
    When executing query:
      """
      MATCH p = (n {name: 'A'})-[:KNOWS*1..2]->(x)
      RETURN properties(nodes(p), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A', 'B']      |
      | ['A', 'B', 'C'] |
    And no side effects

  @fails @bugZeroLengthPaths #https://github.com/kuzudb/kuzu/issues/5841
  Scenario: [17] Return a named var length path of length zero
    Given an empty graph
    And having defined kuzu types: abc_name:kf
    And having executed:
      """
      CREATE (a:A {name: 'A'})-[:KNOWS]->(b:B {name: 'B'})-[:FRIEND]->(c:C {name: 'C'})
      """
    When executing query:
      """
      MATCH p = (a {name: 'A'})-[:KNOWS*0..1]->(b)-[:FRIEND*0..1]->(c)
      RETURN properties(list_distinct(nodes(p)), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A']           |
      | ['A', 'B']      |
      | ['A', 'B', 'C'] |
    And no side effects

  Scenario: [18] Undirected named path
    Given an empty graph
    And having defined kuzu types: mn_name:t
    And having executed:
      """
      CREATE (a:Movie {name: 'a'}), (b:N {name: 'b'})
      CREATE (b)-[:T]->(a)
      """
    When executing query:
      """
      MATCH p = (n:Movie)--(m)
      RETURN properties(list_distinct(nodes(p)), 'name') as p
        LIMIT 1
      """
    Then the result should be, in any order:
      | p          |
      | ['a', 'b'] |
    And no side effects

  Scenario: [19] Variable length relationship without lower bound
    Given an empty graph
    And having defined kuzu types: n_name:k
    And having executed:
      """
      CREATE (a:N {name: 'A'}), (b:N {name: 'B'}),
             (c:N {name: 'C'})
      CREATE (a)-[:KNOWS]->(b),
             (b)-[:KNOWS]->(c)
      """
    When executing query:
      """
      MATCH p = ({name: 'A'})-[:KNOWS*..2]->()
      RETURN properties(list_distinct(nodes(p)), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A', 'B']      |
      | ['A', 'B', 'C'] |
    And no side effects

  Scenario: [20] Variable length relationship without bounds
    Given an empty graph
    And having defined kuzu types: n_name:k
    And having executed:
      """
      CREATE (a:N {name: 'A'}), (b:N {name: 'B'}),
             (c:N {name: 'C'})
      CREATE (a)-[:KNOWS]->(b),
             (b)-[:KNOWS]->(c)
      """
    When executing query:
      """
      MATCH p = ({name: 'A'})-[:KNOWS*..]->()
      RETURN properties(list_distinct(nodes(p)), 'name') as p
      """
    Then the result should be, in any order:
      | p               |
      | ['A', 'B']      |
      | ['A', 'B', 'C'] |
    And no side effects

  @fails @bugVariableBinding #https://github.com/kuzudb/kuzu/issues/5963
  Scenario Outline: [21] Fail when a node has the same variable in a preceding MATCH
    Given any graph
    When executing query:
      """
      MATCH <pattern>
      MATCH p = ()-[]-()
      RETURN p
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

    Examples:
      | pattern                               |
      | (p)-[]-()                             |
      | (p)-[]->()                            |
      | (p)<-[]-()                            |
      | ()-[]-(p)                             |
      | ()-[]->(p)                            |
      | ()<-[]-(p)                            |
      | (p)-[]-(), ()                         |
      | ()-[]-(p), ()                         |
      | (p)-[]-()-[]-()                       |
      | ()-[]-(p)-[]-()                       |
      | ()-[]-()-[]-(p)                       |
      | (a)-[r]-(p)-[]->(b), (t), (t)-[*]-(b) |
      | (a)-[r*]-(s)-[]-(b), (p), (t)-[]-(b)  |
      | (a)-[r]-(p)<-[*]-(b), (t), (t)-[]-(b) |

  @fails @bugVariableBinding #https://github.com/kuzudb/kuzu/issues/5963
  Scenario Outline: [22] Fail when a relationship has the same variable in a preceding MATCH
    Given any graph
    When executing query:
      """
      MATCH <pattern>
      MATCH p = ()-[]-()
      RETURN p
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

    Examples:
      | pattern                               |
      | ()-[p]-()                             |
      | ()-[p]->()                            |
      | ()<-[p]-()                            |
      | ()-[p*]-()                            |
      | ()-[p*]->()                           |
      | ()<-[p*]-()                           |
      | ()-[p]-(), ()                         |
      | ()-[p*]-(), ()                        |
      | ()-[p]-()-[]-()                       |
      | ()-[p*]-()-[]-()                      |
      | ()-[]-()-[p]-()                       |
      | ()-[]-()-[p*]-()                      |
      | (a)-[r]-()-[]->(b), (t), (t)-[p*]-(b) |
      | (a)-[r*]-(s)-[p]-(b), (t), (t)-[]-(b) |
      | (a)-[r]-(s)<-[p]-(b), (t), (t)-[]-(b) |

  @fails @bugVariableBinding #https://github.com/kuzudb/kuzu/issues/5963
  Scenario Outline: [23] Fail when a node has the same variable in the same pattern
    Given any graph
    When executing query:
      """
      MATCH <pattern>
      RETURN p
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

    Examples:
      | pattern                                               |
      | p = (p)-[]-()                                         |
      | p = (p)-[]->()                                        |
      | p = (p)<-[]-()                                        |
      | p = ()-[]-(p)                                         |
      | p = ()-[]->(p)                                        |
      | p = ()<-[]-(p)                                        |
      | (p)-[]-(), p = ()-[]-()                               |
      | (p)-[]->(), p = ()-[]-()                              |
      | (p)<-[]-(), p = ()-[]-()                              |
      | ()-[]-(p), p = ()-[]-()                               |
      | ()-[]->(p), p = ()-[]-()                              |
      | ()<-[]-(p), p = ()-[]-()                              |
      | (p)-[]-(), (), p = ()-[]-()                           |
      | ()-[p]-(), (), p = ()-[]-()                           |
      | ()-[]-(p), (), p = ()-[]-()                           |
      | (p)-[]-()-[]-(), p = ()-[]-()                         |
      | ()-[]-(p)-[]-(), p = ()-[]-()                         |
      | ()-[]-()-[]-(p), p = ()-[]-()                         |
      | (a)-[r]-(p)-[]-(b), p = (s)-[]-(t), (t), (t)-[]-(b)   |
      | (a)-[r]-(p)<-[*]-(b), p = (s)-[]-(t), (t), (t)-[]-(b) |

  @fails @bugVariableBinding #https://github.com/kuzudb/kuzu/issues/5963
  Scenario Outline: [24] Fail when a relationship has the same variable in the same pattern
    Given any graph
    When executing query:
      """
      MATCH <pattern>
      RETURN p
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

    Examples:
      | pattern                                                |
      | p = ()-[p]-()                                          |
      | p = ()-[p]->()                                         |
      | p = ()<-[p]-()                                         |
      | p = ()-[p*]-()                                         |
      | p = ()-[p*]->()                                        |
      | p = ()<-[p*]-()                                        |
      | ()-[p]-(), p = ()-[]-()                                |
      | ()-[p]->(), p = ()-[]-()                               |
      | ()<-[p]-(), p = ()-[]-()                               |
      | ()-[p*]-(), p = ()-[]-()                               |
      | ()-[p*]->(), p = ()-[]-()                              |
      | ()<-[p*]-(), p = ()-[]-()                              |
      | ()-[p]-(), (), p = ()-[]-()                            |
      | ()-[p*]-(), (), p = ()-[]-()                           |
      | ()-[p]-()-[]-(), p = ()-[]-()                          |
      | ()-[p*]-()-[]-(), p = ()-[]-()                         |
      | ()-[]-()-[p]-(), p = ()-[]-()                          |
      | ()-[]-()-[p*]-(), p = ()-[]-()                         |
      | (a)-[r]-(s)-[p]-(b), p = (s)-[]-(t), (t), (t)-[]-(b)   |
      | (a)-[r]-(s)<-[p*]-(b), p = (s)-[]-(t), (t), (t)-[]-(b) |

  @fails @bugVariableBinding #https://github.com/kuzudb/kuzu/issues/5963
  Scenario Outline: [25] Fail when matching a path variable bound to a value
    Given any graph
    When executing query:
      """
      WITH <invalid> AS p
      MATCH p = ()-[]-()
      RETURN p
      """
    Then a SyntaxError should be raised at compile time: VariableAlreadyBound

    Examples:
      | invalid |
      | true    |
      | 123     |
      | 123.4   |
      | 'foo'   |
      | []      |
      | [10]    |
      | {x: 1}  |
      | {x: []} |
