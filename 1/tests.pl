:- consult('family.pl').

run_all_tests :-
    write('=== ТЕСТЫ ЛАБОРАТОРНОЙ №1: ПЛАНТАГЕНЕТЫ ==='), nl,
    
    write('\n--- Уровень 1 ---'), nl,
    (father(henry2, richard1) -> write('[OK] Генрих II - отец Ричарда I'); write('[FAIL]')), nl,
    (brother(richard1, john) -> write('[OK] Ричард I - брат Иоанна Безземельного'); write('[FAIL]')), nl,
    (uncle(richard1, henry3) -> write('[OK] Ричард I - дядя Генриха III'); write('[FAIL]')), nl,
    (cousin_brother(arthur1, henry3) -> write('[OK] Артур I - двоюродный брат Генриха III'); write('[FAIL]')), nl,
    
    write('\n--- Уровень 2 ---'), nl,
    (common_ancestor(edward1, arthur1, henry2) -> write('[OK] Общий предок Эдуарда I и Артура I - Генрих II'); write('[FAIL]')), nl,
    (generation(edward3, 7) -> write('[OK] Эдуард III принадлежит к 7-му поколению от корня'); write('[FAIL]')), nl,
    no_cycles, logical_ages, no_conflicts,
    
    write('\n--- Уровень 3 ---'), nl,
    write('[Тест генерации текста]: '), nl,
    describe_relation(eleanor, john),
    describe_relation(richard1, arthur1),
    
    write('\n[Тест поиска путей от Эдуарда III (edward3) к Ричарду Львиное Сердце (richard1)]: '), nl,
    kinship_path(edward3, richard1, Path),
    write(Path), nl,
    
    write('\n[Тест экспорта в GraphViz]: '), nl,
    export_to_dot('plantagenets_tree.dot').
