pub fn get_table(id: &str) -> &str {
    match id {
        "a" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
            "
        }
        "a:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM A to A);
            "
        }
        "a_label:w_year" => {
            "
              CREATE NODE TABLE Artist(id SERIAL PRIMARY KEY, label STRING);
              CREATE REL TABLE WORKED_WITH(FROM Artist to Artist, year INT64);
            "
        }
        "ab" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
            "
        }
        "ab:bf" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE BAR(FROM B to B);
              CREATE REL TABLE FOO(FROM A to B);
            "
        }
        "ab_num:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE KNOWS(FROM A to B);
            "
        }
        "ab_name:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B);
            "
        }
        "ab_num:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE LOOP(FROM A to B);
            "
        }
        "ab:r" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM B to A);
            "
        }
        "ab_num:r" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE REL(FROM A to B, name STRING);
            "
        }
        "ab:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM A to B);
            "
        }
        "ab:t_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM A to B, name STRING);
            "
        }
        "ab_name:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM A to B);
            "
        }
        "ab_name:t_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM A to B, name STRING);
            "
        }
        "ab:t12" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM A to B);
              CREATE REL TABLE T2(FROM B to A);
            "
        }
        "ab:t14" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM A to B);
              CREATE REL TABLE T2(FROM B to A);
              CREATE REL TABLE T3(FROM B to B);
              CREATE REL TABLE T4(FROM A to A);
            "
        }
        "abc_p12" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, p1 INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, p2 INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
            "
        }
        "abc_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
            "
        }
        "abc_a:a" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, a STRING);
              CREATE REL TABLE ADMIN(FROM B to A, FROM B to C);
            "
        }
        "abc_num:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE KNOWS(FROM A to B, FROM A to C);
            "
        }
        "abc_name:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B, FROM B to C);
            "
        }
        "abc_name:k_num" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B, FROM B to C, num INT64);
            "
        }
        "abc_name:kf" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B);
              CREATE REL TABLE FRIEND(FROM B to C);
            "
        }
        "abc:r" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM A to B, FROM B to C, FROM C TO B, FROM B TO A);
            "
        }
        "abc:r12" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R1(FROM B to A);
              CREATE REL TABLE R2(FROM B to C);
            "
        }
        "abc:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM A to B, FROM A to C);
            "
        }
        "abc_name:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM B to A, FROM C TO B);
            "
        }
        "abc:y" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE REL TABLE Y(FROM A to B, FROM B TO C);
            "
        }
        "abc_name:hk" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B);
              CREATE REL TABLE HATES(FROM A to C);
            "
        }
        "abc_name:hkw" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B);
              CREATE REL TABLE HATES(FROM A to C);
              CREATE REL TABLE WONDERS(FROM A to C);
            "
        }
        "abc_num:fk" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE KNOWS(FROM A to B);
              CREATE REL TABLE FRIEND(FROM B to C);
            "
        }
        "abc_num:r_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE REL(FROM A to B, FROM B TO C, name STRING);
            "
        }
        "abl:t12l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Looper(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM A to Looper);
              CREATE REL TABLE T2(FROM Looper to B);
              CREATE REL TABLE LOOP(FROM Looper to Looper);
            "
        }
        "abx:k_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE REL TABLE KNOWS(FROM X to A, FROM X to B, name STRING);
            "
        }
        "abcd:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM A to B, FROM A to C, FROM A to D, FROM B TO C, FROM B TO D, FROM C TO D);
            "
        }
        "abcd_name:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE LIKES(FROM A to B, FROM B TO C, FROM C TO D);
            "
        }
        "abcd_name:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM A to B, FROM A to C, FROM A to D, FROM B to A, FROM C TO B, FROM D TO C);
            "
        }
        "abcd_animal:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, animal STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, animal STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, animal STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, animal STRING);
              CREATE REL TABLE KNOWS(FROM A to B, FROM A TO C, FROM D TO B, FROM D TO C);
            "
        }
        "abce_name:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE E(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE LIKES(FROM A to B, FROM B to A, FROM B TO C, FROM C TO D, FROM D TO E);
            "
        }
        "abcs:lr" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
            "
        }
        "abcs:lrx" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
              CREATE REL TABLE X(FROM A to B);
            "
        }
        "abcns_num:lr" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE NonExistent(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
            "
        }
        "abcns_num:lnr" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE NotThere(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE NOR_THIS(FROM NotThere to NotThere);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
            "
        }
        "abe:r_num" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Endd(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM A to B, FROM B TO Endd, num INT64);
            "
        }
        "an:xy" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE X(FROM A to N);
              CREATE REL TABLE Y(FROM N to N);
            "
        }
        "aptv_name:3" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE P(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE T(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE V(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE ADV_HAS_PRODUCT(FROM A to P);
              CREATE REL TABLE AA_HAS_VALUE(FROM T to V);
              CREATE REL TABLE AP_HAS_VALUE(FROM P to V);
            "
        }
        "bce:r_num" => {
            "
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Start(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM Start to B, FROM B TO C, num INT64);
            "
        }
        "be:t" => {
            "
              CREATE NODE TABLE Begin(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE `End`(id SERIAL PRIMARY KEY);
              CREATE REL TABLE TYPE(FROM Begin TO `End`);
            "
        }
        "bn_name" => {
            "
              CREATE NODE TABLE Bar(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
            "
        }
        "bgry:t" => {
            "
              CREATE NODE TABLE Blue(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Green(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Red(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Yellow(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM Blue TO Red, FROM Red TO Green, FROM Red TO Yellow);
            "
        }
        "ens_name:c" => {
            "
              CREATE NODE TABLE Eend(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Start(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE CONNECTED_TO(FROM N to Start, FROM N to Eend, FROM N to N);
            "
        }
        "bfn:t12" => {
            "
              CREATE NODE TABLE Bar(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Foo(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM Foo TO N, FROM N TO Foo);
              CREATE REL TABLE T2(FROM Bar TO N, FROM N TO Bar);
            "
        }
        "bdf:o" => {
            "
              CREATE NODE TABLE Bar(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Dog(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Foo(id SERIAL PRIMARY KEY);
              CREATE REL TABLE OWNS(FROM Bar TO Dog);
            "
        }
        "d" => {
            "
              CREATE NODE TABLE DoesNotExist(id SERIAL PRIMARY KEY);
            "
        }
        "dssst:bcdsst" => {
            "
              CREATE NODE TABLE Department(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE School(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Student(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Subject(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE StudyBuddy(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Teacher(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE BUDDY(FROM Student to StudyBuddy);
              CREATE REL TABLE CURRICULUM(FROM Department to Subject);
              CREATE REL TABLE DEPARTMENTR(FROM School to Department);
              CREATE REL TABLE STAFF(FROM School to Teacher);
              CREATE REL TABLE STUDENTR(FROM School to Student);
              CREATE REL TABLE TAUGHT_BY(FROM Subject to Teacher);
            "
        }
        "irt_2:t" => {
            "
              CREATE NODE TABLE Root(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE TextNode(id SERIAL PRIMARY KEY, var STRING);
              CREATE NODE TABLE IntNode(id SERIAL PRIMARY KEY, var INT64);
              CREATE REL TABLE T(FROM Root to TextNode, FROM Root to IntNode);
            "
        }
        "l" => {
            "
              CREATE NODE TABLE Label(id SERIAL PRIMARY KEY);
            "
        }
        "l12_name:t" => {
            "
              CREATE NODE TABLE Label1(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Label2(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE TYPE(FROM Label2 to Label1);
            "
        }
        "l13_name:t12" => {
            "
              CREATE NODE TABLE Label1(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Label2(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Label3(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T1(FROM Label2 to Label1);
              CREATE REL TABLE T2(FROM Label2 to Label3);
            "
        }
        "mn_name:t" => {
            "
              CREATE NODE TABLE Movie(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM N to Movie);
            "
        }
        "mp:ad" => {
            "
              CREATE NODE TABLE Movie(id SERIAL PRIMARY KEY, title STRING, released UINT64, tagline STRING);
              CREATE NODE TABLE Person(id SERIAL PRIMARY KEY, name STRING, born UINT64);
              CREATE REL TABLE ACTED_IN(FROM Person to Movie, roles STRING[]);
              CREATE REL TABLE DIRECTED(FROM Person to Movie);
              CREATE REL TABLE PRODUCED(FROM Person to Movie);
              CREATE REL TABLE WROTE(FROM Person to Movie);
              CREATE REL TABLE FOLLOWS(FROM Person to Person);
              CREATE REL TABLE REVIEWED(FROM Person to Movie, summary STRING, rating UINT64);
            "
        }
        "mt:t" => {
            "
              CREATE NODE TABLE MissingLabel(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE TheLabel(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM TheLabel to TheLabel, FROM TheLabel to MissingLabel);
            "
        }
        "n" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
            "
        }
        "n_created" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, created BOOL);
            "
        }
        "n_name" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
            "
        }
        "n_num" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, num INT64);
            "
        }
        "n_num:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n:t_id" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to N, id INT64);
            "
        }
        "n:ab" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE A(FROM N to N);
              CREATE REL TABLE B(FROM N to N);
            "
        }
        "n_name:ab" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE A(FROM N to N);
              CREATE REL TABLE B(FROM N to N);
            "
        }
        "n_name:c" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE CONTAINS(FROM N to N);
            "
        }
        "n_name:cf" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE CONTAINS(FROM N to N);
              CREATE REL TABLE FRIEND(FROM N to N);
            "
        }
        "n:d" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE DoesNotExist(FROM N to N);
            "
        }
        "n:e" => {
            "
              CREATE NODE TABLE Node(id SERIAL PRIMARY KEY);
              CREATE REL TABLE Edge(FROM Node to Node);
            "
        }
        "n:f" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE FOO(FROM N to N);
            "
        }
        "n_name:hkw" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM N to N);
              CREATE REL TABLE HATES(FROM N to N);
              CREATE REL TABLE WONDERS(FROM N to N);
            "
        }
        "n_name:k" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM N to N);
            "
        }
        "n:l" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE LINK(FROM N to N);
            "
        }
        "n:n" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE NOT_EXIST(FROM N to N);
            "
        }
        "n:r" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM N to N);
            "
        }
        "n:r_name" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM N to N, name STRING);
            "
        }
        "n:r_num" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM N to N, num INT64);
            "
        }
        "n:r_2" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM N to N, id INT64, name STRING);
            "
        }
        "n:r13" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R1(FROM N to N);
              CREATE REL TABLE R2(FROM N to N);
              CREATE REL TABLE R3(FROM N to N);
            "
        }
        "n:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n_name:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n_var:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, var STRING);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n_name:x" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE X(FROM N to N);
            "
        }
        "n:x_2" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE X(FROM N to N, id INT64, name STRING);
            "
        }
        "nf:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Foo(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to Foo, FROM N to N);
            "
        }
        "np:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Person(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM Person to N);
            "
        }
        "nt:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE TheLabel(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "nu:f" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE User(id SERIAL PRIMARY KEY);
              CREATE REL TABLE FRIEND(FROM User to N);
            "
        }
        "nx:r" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM X to N, FROM N to N);
            "
        }
        "pf:a" => {
            "
              CREATE NODE TABLE P(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE F(id SERIAL PRIMARY KEY, type STRING);
              CREATE REL TABLE ATE(FROM P to F, times INT64);
            "
        }
        "pt:ps" => {
            "
              CREATE NODE TABLE Player(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Team(id SERIAL PRIMARY KEY);
              CREATE REL TABLE PLAYS_FOR(FROM Player to Team);
              CREATE REL TABLE SUPPORTS(FROM Player to Team);
            "
        }
        "r:l" => {
            "
              CREATE NODE TABLE Root(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LINK(FROM Root to Root);
            "
        }
        "rt:r" => {
            "
              CREATE NODE TABLE R(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE T(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM T to R);
            "
        }
        "t" => {
            "
              CREATE NODE TABLE TheLabel(id SERIAL PRIMARY KEY);
            "
        }
        "u" => {
            "
              CREATE NODE TABLE User(id SERIAL PRIMARY KEY);
            "
        }
        "u:r" => {
            "
              CREATE NODE TABLE User(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM User to User);
            "
        }
        "x:t" => {
            "
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM X to X);
            "
        }
        "xy:r" => {
            "
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Y(id SERIAL PRIMARY KEY);
              CREATE REL TABLE R(FROM X to Y, FROM Y to X);
            "
        }
        "xyy:r" => {
            "
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Y(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE YZ(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM X to Y, FROM X TO YZ);
            "
        }
        "xyz_val:e12" => {
            "
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY, val INT64);
              CREATE NODE TABLE Y(id SERIAL PRIMARY KEY, val INT64);
              CREATE NODE TABLE Z(id SERIAL PRIMARY KEY, val INT64);
              CREATE REL TABLE E1(FROM X to Y);
              CREATE REL TABLE E2(FROM Y to Z);
            "
        }
        _ => panic!("Table not found: {id}"),
    }
}
