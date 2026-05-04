% ==========================================
% ЛАБОРАТОРНАЯ РАБОТА №1 (УРОВНИ 1, 2, 3)
% Предметная область: Династия Плантагенетов
% ==========================================

:- dynamic person/7.
:- dynamic parent/2.

% --- БАЗА ЗНАНИЙ (ФАКТЫ) ---
% Структура: person(ID, Name, Gender, BirthYear, DeathYear, Title, Status).

% Поколение 1 (Основатели)
person(geoffrey5, 'Жоффруа V Плантагенет', m, 1113, 1151, 'Анжу', 'Граф Анжуйский').
person(matilda, 'Императрица Матильда', f, 1102, 1167, 'Винчестер', 'Королева Англии (спорно)').

% Поколение 2
person(henry2, 'Генрих II Плантагенет', m, 1133, 1189, 'Ле-Ман', 'Король Англии').
person(eleanor, 'Алеонора Аквитанская', f, 1122, 1204, 'Пуатье', 'Королева Англии').

% Поколение 3
person(richard1, 'Ричард I Львиное Сердце', m, 1157, 1199, 'Оксфорд', 'Король Англии').
person(geoffrey2, 'Жоффруа II', m, 1158, 1186, 'Париж', 'Герцог Бретани').
person(john, 'Иоанн Безземельный', m, 1166, 1216, 'Оксфорд', 'Король Англии').
person(joan, 'Иоанна Английская', f, 1165, 1199, 'Анже', 'Королева Сицилии').
person(isabella, 'Изабелла Ангулемская', f, 1188, 1246, 'Ангулем', 'Королева-консорт').

% Поколение 4
person(arthur1, 'Артур I', m, 1187, 1203, 'Нант', 'Герцог Бретани').
person(henry3, 'Генрих III', m, 1207, 1272, 'Винчестер', 'Король Англии').
person(richard_c, 'Ричард Корнуоллский', m, 1209, 1272, 'Винчестер', 'Римский король').
person(joan_scot, 'Иоанна Английская', f, 1210, 1238, 'Йорк', 'Королева Шотландии').

% Поколение 5
person(edward1, 'Эдуард I Длинноногий', m, 1239, 1307, 'Вестминстер', 'Король Англии').
person(edmund, 'Эдмунд Горбатый', m, 1245, 1296, 'Лондон', 'Граф Ланкастер').

% Поколение 6
person(edward2, 'Эдуард II', m, 1284, 1327, 'Карнарвон', 'Король Англии').

% Поколение 7
person(edward3, 'Эдуард III', m, 1312, 1377, 'Виндзор', 'Король Англии').

% --- СВЯЗИ (ГРАФ РОДСТВА) ---
% parent(ParentID, ChildID).
parent(geoffrey5, henry2). parent(matilda, henry2).

parent(henry2, richard1). parent(eleanor, richard1).
parent(henry2, geoffrey2). parent(eleanor, geoffrey2).
parent(henry2, john). parent(eleanor, john).
parent(henry2, joan). parent(eleanor, joan).

parent(geoffrey2, arthur1).

parent(john, henry3). parent(isabella, henry3).
parent(john, richard_c). parent(isabella, richard_c).
parent(john, joan_scot). parent(isabella, joan_scot).

parent(henry3, edward1). parent(henry3, edmund).

parent(edward1, edward2).
parent(edward2, edward3).

% --- УРОВЕНЬ 1: БАЗОВЫЕ И ПРОИЗВОДНЫЕ ОТНОШЕНИЯ ---
male(X) :- person(X, _, m, _, _, _, _).
female(X) :- person(X, _, f, _, _, _, _).

mother(M, C) :- parent(M, C), female(M).
father(F, C) :- parent(F, C), male(F).

sibling(A, B) :- parent(P, A), parent(P, B), A \= B.
brother(B, P) :- sibling(B, P), male(B).
sister(S, P) :- sibling(S, P), female(S).

grandfather(GF, GC) :- father(GF, P), parent(P, GC).
grandmother(GM, GC) :- mother(GM, P), parent(P, GC).

uncle(U, N) :- brother(U, P), parent(P, N).
aunt(A, N) :- sister(A, P), parent(P, N).

ancestor(A, D) :- parent(A, D).
ancestor(A, D) :- parent(A, X), ancestor(X, D).
descendant(D, A) :- ancestor(A, D).

cousin_brother(CB, P) :- parent(P1, CB), parent(P2, P), sibling(P1, P2), male(CB).
second_cousin_sister(SCS, P) :- 
    parent(P1, SCS), parent(P2, P), parent(GP1, P1), parent(GP2, P2), 
    sibling(GP1, GP2), female(SCS).

% --- УРОВЕНЬ 2: АНАЛИЗ И ВАЛИДАЦИЯ ---
root(X) :- person(X, _, _, _, _, _, _), \+ parent(_, X).

generation(X, 1) :- root(X).
generation(X, N) :- parent(P, X), generation(P, N1), N is N1 + 1.

common_ancestor(A, B, CA) :- ancestor(CA, A), ancestor(CA, B), A \= B.

distance(A, A, 0).
distance(A, D, Dist) :- parent(A, X), distance(X, D, D1), Dist is D1 + 1.

degree_of_kinship(A, B, Degree) :-
    setof(D, CA^(common_ancestor(A, B, CA), distance(CA, A, D1), distance(CA, B, D2), D is D1 + D2), Distances),
    min_list(Distances, Degree).

no_cycles :- \+ (ancestor(X, Y), ancestor(Y, X)), write('Циклов не обнаружено.'), nl.
logical_ages :- \+ (parent(P, C), person(P, _, _, YP, _, _, _), person(C, _, _, YC, _, _, _), YP >= YC - 10), write('Аномалий возрастов нет.'), nl.
no_conflicts :- \+ ancestor(X, X), write('Конфликтов самопорождения нет.'), nl.

% --- УРОВЕНЬ 3: ЭКСПЕРТНЫЙ (Генерация, Визуализация, Поиск путей) ---
describe_relation(A, B) :-
    person(A, NameA, _, _, _, _, _), person(B, NameB, _, _, _, _, _),
    (   father(A, B) -> Rel = 'отец'
    ;   mother(A, B) -> Rel = 'мать'
    ;   brother(A, B) -> Rel = 'брат'
    ;   sister(A, B) -> Rel = 'сестра'
    ;   grandfather(A, B) -> Rel = 'дедушка'
    ;   grandmother(A, B) -> Rel = 'бабушка'
    ;   uncle(A, B) -> Rel = 'дядя'
    ;   aunt(A, B) -> Rel = 'тетя'
    ;   cousin_brother(A, B) -> Rel = 'двоюродный брат'
    ;   ancestor(A, B) -> Rel = 'прямой предок'
    ;   descendant(A, B) -> Rel = 'прямой потомок'
    ;   Rel = 'родственник'
    ),
    format('~w — ~w для ~w.~n', [NameA, Rel, NameB]).

export_to_dot(Filename) :-
    open(Filename, write, Stream),
    write(Stream, 'digraph Plantagenets {\n'),
    write(Stream, '  node [shape=box, fontname="Arial", style=filled, rounded=true];\n'),
    write(Stream, '  edge [color="#555555", penwidth=1.5];\n'),
    forall(person(ID, Name, Gender, YB, YD, _, Title),
           (Gender == m -> Color = '"#A2C4C9"' ; Color = '"#D5A6BD"',
            format(Stream, '  ~w [label="~w\\n~w\\n(~w - ~w)", fillcolor=~w];~n', [ID, Name, Title, YB, YD, Color]))),
    forall(parent(P, C),
           format(Stream, '  ~w -> ~w;~n', [P, C])),
    write(Stream, '}\n'),
    close(Stream),
    format('Дерево Плантагенетов экспортировано в: ~w~n', [Filename]).

connected(A, B) :- parent(A, B).
connected(A, B) :- parent(B, A).

kinship_path(A, B, Path) :-
    travel(A, B, [A], ReversedPath),
    reverse(ReversedPath, Path).

travel(A, B, Visited, [B|Visited]) :- connected(A, B).
travel(A, B, Visited, Path) :-
    connected(A, X),
    X \= B,
    \+ member(X, Visited),
    travel(X, B, [X|Visited], Path).
