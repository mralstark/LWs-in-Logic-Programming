:- encoding(utf8).
:- consult('schedule.pl').

run_schedule_tests :-
    write('=== ЛАБОРАТОРНАЯ РАБОТА №2: ТЕСТИРОВАНИЕ ==='), nl,

    write('\n--- Уровень 1: Базовые запросы ---'), nl,

    write('1. Аудитории, свободные в ПН на 1-й паре: '),
    findall(R, free_room(R, mon, 1), FreeRooms),
    write(FreeRooms), nl,

    write('2. Нагрузка группы g1: '),
    group_load(g1, LoadG1),
    write(LoadG1),
    write(' пар(ы)'), nl,

    write('3. У каких групп ведет Иванов: '),
    teacher_groups(ivanov, GroupsIvanov),
    write(GroupsIvanov), nl,

    write('4. Свободные дни у преподавателя Петрова: '),
    teacher_free_days(petrov, FreeDaysPetrov),
    write(FreeDaysPetrov), nl,


    write('\n--- Уровень 2: Валидация ---'), nl,

    % Эти проверки должны просто выполниться.
    % Если где-то есть ошибка, тесты не должны полностью останавливаться.
    (no_group_conflicts -> true ; write('[FAIL] Обнаружен конфликт групп.'), nl),
    (no_teacher_conflicts -> true ; write('[FAIL] Обнаружен конфликт преподавателей.'), nl),

    % В базе специально есть конфликт аудитории r10.
    % Поэтому no_room_conflicts напечатает ошибку и вернет false.
    % Оборачиваем в -> ; true, чтобы тестирование продолжилось дальше.
    (no_room_conflicts -> true ; true),

    windows_in_schedule(g1, WG1),
    format('Окон у группы g1: ~w~n', [WG1]),

    windows_in_schedule(g2, WG2),
    format('Окон у группы g2: ~w~n', [WG2]),


    write('\n--- Уровень 3: CLP(FD) Генерация ---'), nl,

    write('Генерация расписания без конфликтов: '), nl,
    generate_schedule(GeneratedLessons),
    write(GeneratedLessons), nl,

    write('\nЭкспорт расписания в schedule.csv...'), nl,
    export_to_csv('schedule.csv'),

    write('\n=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ==='), nl.
