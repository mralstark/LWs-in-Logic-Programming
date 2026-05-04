import graphviz
import os

def render_family_tree(dot_file_path):
    if not os.path.exists(dot_file_path):
        print(f"Ошибка: Файл {dot_file_path} не найден. Сначала выполните export_to_dot/1 в Prolog.")
        return
    
    print(f"Чтение файла {dot_file_path}...")
    with open(dot_file_path, 'r', encoding='utf-8') as f:
        dot_source = f.read()

    graph = graphviz.Source(dot_source)
    output_path = 'plantagenets_tree_render'
    
    try:
        graph.render(output_path, format='png', cleanup=True)
        print(f"Успех! Дерево Плантагенетов сохранено как: {output_path}.png")
    except graphviz.ExecutableNotFound:
        print("Ошибка: Graphviz не установлен в системе или не добавлен в PATH.")

if __name__ == "__main__":
    render_family_tree('plantagenets_tree.dot')
