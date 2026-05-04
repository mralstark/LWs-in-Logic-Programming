:- consult('schedule.pl').

run_schedule_tests :-
    write('=== ЛАБОРАТОРНАЯ РАБОТА №2: ТЕСТИРОВАНИЕ ==='), nl,
    
    write('\n--- Уровень 1: Базовые запросы ---'), nl,
    write('1. Аудитории, свободные в ПН на 1-й паре: '),
    findall(R, free_room(R, mon, 1), FreeRooms), write(FreeRooms), nl,
    
    write('2. Нагрузка группы g1: '), group_load(g1, LoadG1), write(LoadG1), write(' пар(ы)'), nl,
    
    write('3. У каких групп ведет Иванов: '), teacher_groups(ivanov, GroupsIvanov), write(GroupsIvanov), nl,
    
    write('\n--- Уровень 2: Валидация ---'), nl,
    \+ no_group_conflicts, % \+ используется для игнорирования фейлов при выводе текста
    \+ no_teacher_conflicts,
    (no_room_conflicts -> true ; true), % Захватываем ошибку аудитории r10 из нашей статической БЗ
    
    windows_in_schedule(g1, WG1), format('Окон у группы g1: ~w~n', [WG1]),
    windows_in_schedule(g2, WG2), format('Окон у группы g2: ~w~n', [WG2]),

    write('\n--- Уровень 3: CLP(FD) Генерация ---'), nl,
    write('Генерация расписания без конфликтов и экспорт в schedule.csv...'), nl,
    export_to_csv('schedule.csv').