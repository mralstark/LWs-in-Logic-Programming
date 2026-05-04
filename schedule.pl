% =================================================================
% ЛАБОРАТОРНАЯ РАБОТА №2: Составление расписания с ограничениями
% Уровни 1, 2 и 3 (CLP(FD))
% =================================================================

:- use_module(library(clpfd)).
:- use_module(library(lists)).

% =================================================================
% БАЗА ЗНАНИЙ (Для Уровней 1 и 2)
% =================================================================

% Домены (5 групп, 10 предметов, 5 преподавателей, 10 аудиторий)
group(X)   :- member(X, [g1, g2, g3, g4, g5]).
subject(X) :- member(X, [math, physics, cs, history, english, db, logic, ai, web, os]).
teacher(X) :- member(X, [ivanov, petrov, sidorov, smirnova, kuznetsov]).
room(X)    :- member(X, [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]).
day(X)     :- member(X, [mon, tue, wed, thu, fri]).
time_slot(X) :- member(X, [1, 2, 3, 4, 5, 6]).

% Факты: lesson(Группа, Предмет, Преподаватель, День, Время, Аудитория).
% Специально заложены окна и небольшие конфликты (для демонстрации валидаторов Уровня 2).

% Группа 1
lesson(g1, math, ivanov, mon, 1, r1).
lesson(g1, cs, sidorov, mon, 3, r2).     % Окно на 2-й паре!
lesson(g1, english, smirnova, tue, 1, r3).
lesson(g1, db, kuznetsov, tue, 2, r4).

% Группа 2
lesson(g2, physics, petrov, mon, 1, r5).
lesson(g2, math, ivanov, mon, 2, r1).
lesson(g2, history, smirnova, wed, 1, r6).
lesson(g2, logic, sidorov, wed, 3, r7).  % Окно на 2-й паре!

% Группа 3
lesson(g3, web, kuznetsov, thu, 1, r8).
lesson(g3, ai, petrov, thu, 2, r9).
lesson(g3, os, ivanov, fri, 1, r10).

% Группа 4
lesson(g4, history, smirnova, tue, 1, r6).
lesson(g4, math, ivanov, tue, 2, r1).

% Группа 5
lesson(g5, english, smirnova, mon, 1, r3). % ВНИМАНИЕ: Конфликт! Смирнова уже ведет у g1 во вторник, но здесь в ПН. Однако тут конфликт аудиторий не предусмотрен явно, оставим его без конфликта, добавим реальный ниже.
lesson(g5, logic, sidorov, fri, 1, r10).   % ВНИМАНИЕ: Конфликт! Аудитория r10 занята группой g3 в это же время (fri, 1).


% =================================================================
% УРОВЕНЬ 1: БАЗОВЫЕ ЗАПРОСЫ И АНАЛИЗ
% =================================================================

% 1. Какие аудитории свободны в заданный день и время?
free_room(Room, Day, Time) :- 
    room(Room), day(Day), time_slot(Time),
    \+ lesson(_, _, _, Day, Time, Room).

% 2. У каких групп ведет занятия преподаватель Z?
teacher_groups(Teacher, Groups) :-
    teacher(Teacher),
    setof(G, Sub^D^T^R^lesson(G, Sub, Teacher, D, T, R), Groups).

% 3. Нагрузка группы (количество пар в неделю)
group_load(Group, Count) :- 
    group(Group),
    findall(1, lesson(Group, _, _, _, _, _), L),
    length(L, Count).

% 4. Какие дни свободны у преподавателя?
teacher_free_days(Teacher, FreeDays) :-
    teacher(Teacher),
    findall(D, (day(D), \+ lesson(_, _, Teacher, D, _, _)), FreeDays).


% =================================================================
% УРОВЕНЬ 2: ВАЛИДАЦИЯ И ОПТИМИЗАЦИЯ
% =================================================================

% Детекторы конфликтов (через отрицание как отказ)
no_group_conflicts :-
    \+ (lesson(G, Sub1, _, D, T, _), lesson(G, Sub2, _, D, T, _), Sub1 \= Sub2),
    write('[OK] Группы не находятся в двух местах одновременно.'), nl.

no_teacher_conflicts :-
    \+ (lesson(G1, _, T, D, Time, _), lesson(G2, _, T, D, Time, _), G1 \= G2),
    write('[OK] Преподаватели не ведут две пары одновременно.'), nl.

no_room_conflicts :-
    (   lesson(G1, Sub1, _, D, T, R), lesson(G2, Sub2, _, D, T, R), G1 \= G2
    ->  format('[ОШИБКА] Конфликт аудиторий: ~w занята ~w (~w) и ~w (~w) в ~w, пара ~w~n', [R, G1, Sub1, G2, Sub2, D, T]), fail
    ;   write('[OK] Конфликтов аудиторий нет.'), nl
    ).

% Подсчет "окон" (пустых слотов между первой и последней парой в день)
windows_in_schedule(Group, TotalWindows) :-
    group(Group),
    findall(W, (day(D), day_windows(Group, D, W)), WindowsList),
    sum_list(WindowsList, TotalWindows).

day_windows(Group, Day, Count) :-
    findall(T, lesson(Group, _, _, Day, T, _), Times),
    sort(Times, SortedTimes),
    (SortedTimes = [] -> Count = 0 ; min_max_diff(SortedTimes, Count)).

min_max_diff(List, Count) :-
    min_list(List, Min), max_list(List, Max), length(List, Len),
    Count is (Max - Min + 1) - Len.

% Предикат: можно ли поменять две пары местами без конфликтов?
can_swap(L1, L2) :-
    L1 = lesson(G1, S1, T1, D1, Time1, R1),
    L2 = lesson(G2, S2, T2, D2, Time2, R2),
    call(L1), call(L2), L1 \= L2,
    % Проверяем, что преподаватель T1 свободен в слот 2, а T2 в слот 1
    \+ (lesson(_, _, T1, D2, Time2, _), T1 \= T2),
    \+ (lesson(_, _, T2, D1, Time1, _), T1 \= T2),
    % Проверяем аудитории (если они разные)
    \+ (lesson(_, _, _, D2, Time2, R1), R1 \= R2),
    \+ (lesson(_, _, _, D1, Time1, R2), R1 \= R2).


% =================================================================
% УРОВЕНЬ 3: CLP(FD) АВТОГЕНЕРАЦИЯ РАСПИСАНИЯ
% =================================================================

% Учебный план (что нужно поставить в расписание).
% req(ID, Group, Subject, Teacher).
req(1, g1, math, ivanov).
req(2, g1, physics, petrov).
req(3, g1, cs, sidorov).
req(4, g2, math, ivanov).
req(5, g2, history, smirnova).
req(6, g3, web, kuznetsov).
req(7, g3, ai, petrov).
req(8, g4, english, smirnova).
req(9, g5, os, ivanov).
req(10, g5, db, kuznetsov).

% Генерация валидного расписания
generate_schedule(GeneratedLessons) :-
    findall(req(ID, G, S, T), req(ID, G, S, T), Tasks),
    length(Tasks, N),
    
    % Переменные: Временные слоты (1..30) и Аудитории (1..10)
    % Слот 1..6 = ПН, 7..12 = ВТ, и т.д.
    length(Slots, N), Slots ins 1..30,
    length(Rooms, N), Rooms ins 1..10,

    % 1. Ограничения для Групп: у одной группы не может быть двух пар в один слот
    maplist(constrain_group_slots(Tasks, Slots), [g1, g2, g3, g4, g5]),

    % 2. Ограничения для Преподавателей: один препод - один слот
    maplist(constrain_teacher_slots(Tasks, Slots), [ivanov, petrov, sidorov, smirnova, kuznetsov]),

    % 3. Ограничения для Аудиторий: в одном (Слоте + Аудитории) не может быть двух занятий.
    % Создаем уникальный идентификатор SpaceTime = Slot * 100 + Room
    length(SpaceTimes, N),
    create_spacetime(Slots, Rooms, SpaceTimes),
    all_distinct(SpaceTimes),

    % Дополнительная оптимизация: минимизируем разброс слотов (чтобы пары были кучнее)
    % В clpfd можно использовать labeling для поиска
    labeling([ff], Slots),
    labeling([ff], Rooms),
    
    % Формирование результата
    build_result(Tasks, Slots, Rooms, GeneratedLessons).

% Вспомогательные предикаты для CLP
constrain_group_slots(Tasks, Slots, TargetGroup) :-
    extract_slots_by_param(Tasks, Slots, TargetGroup, group, GroupSlots),
    all_distinct(GroupSlots).

constrain_teacher_slots(Tasks, Slots, TargetTeacher) :-
    extract_slots_by_param(Tasks, Slots, TargetTeacher, teacher, TeacherSlots),
    all_distinct(TeacherSlots).

extract_slots_by_param([], [], _, _, []).
extract_slots_by_param([req(_, G, _, _)|Ts], [S|Ss], Target, group, [S|Result]) :- G == Target, !, extract_slots_by_param(Ts, Ss, Target, group, Result).
extract_slots_by_param([req(_, _, _, T)|Ts], [S|Ss], Target, teacher, [S|Result]) :- T == Target, !, extract_slots_by_param(Ts, Ss, Target, teacher, Result).
extract_slots_by_param([_|Ts], [_|Ss], Target, Param, Result) :- extract_slots_by_param(Ts, Ss, Target, Param, Result).

create_spacetime([], [], []).
create_spacetime([S|Ss], [R|Rs], [ST|STs]) :- ST #= S * 100 + R, create_spacetime(Ss, Rs, STs).

build_result([], [], [], []).
build_result([req(_, G, Sub, T)|Tasks], [S|Slots], [R|Rooms], [gen_lesson(G, Sub, T, Day, Time, RoomName)|Rest]) :-
    DayIdx is (S - 1) div 6,
    nth0(DayIdx, [mon, tue, wed, thu, fri], Day),
    Time is (S - 1) mod 6 + 1,
    nth1(R, [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10], RoomName),
    build_result(Tasks, Slots, Rooms, Rest).

% Экспорт сгенерированного расписания в CSV
export_to_csv(Filename) :-
    generate_schedule(Lessons),
    open(Filename, write, Stream),
    write(Stream, 'Группа,Предмет,Преподаватель,День,Время,Аудитория\n'),
    forall(member(gen_lesson(G, S, T, D, Tm, R), Lessons),
           format(Stream, '~w,~w,~w,~w,~w,~w~n', [G, S, T, D, Tm, R])),
    close(Stream),
    format('Расписание успешно сгенерировано и сохранено в файл: ~w~n', [Filename]).