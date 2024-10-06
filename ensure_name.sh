#!/bin/bash

# Nome: ensure_name.sh
# Descrição: Renomeia arquivos nas pastas "Artigos" e "Livros" para seguir o padrão [nome do livro - autores].[Tipo(Livro|Artigo)].[Ano].pdf
# Autor: [Seu Nome]
# Data: [Data Atual]

# Habilita a expansão de padrões que não correspondem a nenhum arquivo
shopt -s nullglob

# Diretório raiz onde o script está localizado
ROOT_DIR="$(pwd)"

# Tipos de arquivos a serem processados
TYPES=("Artigos" "Livros")

# Arrays para armazenar os caminhos dos arquivos renomeados
declare -a RENAMED_FILES

# Função para exibir uma mensagem de erro e sair
error_exit() {
    echo -e "\e[31mErro: $1\e[0m" 1>&2
    exit 1
}

# Função para verificar se dependências estão instaladas
check_dependencies() {
    if ! command -v tree &> /dev/null; then
        error_exit "'tree' não está instalado. Por favor, instale-o para continuar."
    fi
}

# Função para sanitizar o nome do arquivo (título ou autores)
sanitize_text() {
    local text="$1"
    # Remove caracteres especiais, exceto hífens e vírgulas
    text=$(echo "$text" | sed 's/[\/:*?"<>|]/_/g')
    # Substitui vírgulas por vírgulas (mantém)
    # Substitui espaços por underscores
    text=$(echo "$text" | tr ' ' '_')
    # Remove múltiplos underscores
    text=$(echo "$text" | sed 's/__*/_/g')
    # Remove leading e trailing underscores
    text=$(echo "$text" | sed 's/^_//' | sed 's/_$//')
    echo "$text"
}

# Função para converter diretório plural para singular
get_type_singular() {
    local type_dir="$1"
    if [[ "$type_dir" == "Artigos" ]]; then
        echo "Artigo"
    elif [[ "$type_dir" == "Livros" ]]; then
        echo "Livro"
    else
        echo "$type_dir"
    fi
}

# Função para analisar e extrair informações do nome do arquivo
parse_filename() {
    local filename="$1"
    # Expressão regular para extrair o título, autores e ano do nome atual do arquivo
    # Padrão esperado: [Título] - [Autor1, Autor2, ...] ([Ano]).pdf
    if [[ "$filename" =~ ^(.+?)[-_][[:space:]]*([^()]+)[[:space:]]*\(([0-9]{4})\)\.pdf$ ]]; then
        TITLE="${BASH_REMATCH[1]}"
        AUTHORS="${BASH_REMATCH[2]}"
        FILE_YEAR="${BASH_REMATCH[3]}"
        return 0
    else
        return 1
    fi
}

# Função para construir o novo nome do arquivo
construct_new_filename() {
    local title="$1"
    local type="$2"
    local year="$3"
    local authors="$4"

    # Sanitiza o título e os autores separadamente
    local sanitized_title
    sanitized_title=$(sanitize_text "$title")
    local sanitized_authors
    sanitized_authors=$(sanitize_text "$authors")

    # Combina título e autores com ' - '
    local name_with_authors="${sanitized_title}-$(echo "$sanitized_authors" | tr '_' ' ')"

    # Define o novo nome do arquivo
    local new_filename="${name_with_authors}.${type}.${year}.pdf"
    echo "$new_filename"
}

# Função para verificar se o arquivo já está no formato correto
is_already_correct_format() {
    local current_filename="$1"
    local new_filename="$2"
    [[ "$current_filename" == "$new_filename" ]]
}

# Função para verificar se o ano no nome do arquivo é igual ou maior que o ano da pasta
is_year_matching() {
    local file_year="$1"
    local dir_year="$2"
    [[ "$file_year" -ge "$dir_year" ]]
}

# Função para verificar se o novo nome do arquivo já existe
does_new_file_exist() {
    local new_filepath="$1"
    [[ -e "$new_filepath" ]]
}

# Função para renomear o arquivo
execute_rename() {
    local old_filepath="$1"
    local new_filepath="$2"
    local old_filename
    old_filename=$(basename -- "$old_filepath")
    local new_filename
    new_filename=$(basename -- "$new_filepath")

    # Renomeia o arquivo
    mv "$old_filepath" "$new_filepath" && {
        RENAMED_FILES+=("$new_filepath")
        echo -e "\e[32mRenomeado: $old_filename -> $new_filename\e[0m"
    } || {
        echo -e "\e[31mFalha ao renomear: $old_filename\e[0m"
    }
}

# Função para processar um único arquivo
process_file() {
    local file="$1"
    local type="$2"
    local year_dir="$3"

    local filename
    filename=$(basename -- "$file")

    if parse_filename "$filename"; then
        # Verifica se o ano no nome do arquivo é igual ou maior que o ano da pasta
        if ! is_year_matching "$FILE_YEAR" "$year_dir"; then
            echo -e "\e[33mAno no nome do arquivo ($FILE_YEAR) é menor que o diretório ($year_dir) para o arquivo: $filename. Pulando...\e[0m"
            return
        fi

        # Constrói o novo nome do arquivo usando o ano do arquivo, não do diretório
        local new_filename
        new_filename=$(construct_new_filename "$TITLE" "$type" "$FILE_YEAR" "$AUTHORS")

        # Define o novo caminho completo do arquivo
        local new_filepath="${file%/*}/$new_filename"

        # Verifica se o nome atual já está no formato correto
        if ! is_already_correct_format "$filename" "$new_filename"; then
            # Verifica se o arquivo com o novo nome já existe para evitar sobrescrita
            if does_new_file_exist "$new_filepath"; then
                echo -e "\e[31mArquivo com o nome $new_filename já existe. Não foi possível renomear $filename.\e[0m"
                return
            fi

            # Renomeia o arquivo
            execute_rename "$file" "$new_filepath"
        else
            echo -e "\e[34mArquivo já está no formato correto: $filename\e[0m"
        fi
    else
        echo -e "\e[34mNome do arquivo não corresponde ao padrão esperado: $filename\e[0m"
    fi
}

# Função para processar todos arquivos em um diretório de ano
process_year_directory() {
    local year_dir="$1"
    local type_singular="$2"

    local year
    year=$(basename "$year_dir")

    # Verifica se o ano é um número de 4 dígitos
    if ! [[ "$year" =~ ^[0-9]{4}$ ]]; then
        echo -e "\e[34mDiretório de ano inválido: $year. Pulando...\e[0m"
        return
    fi

    # Percorre cada arquivo PDF no diretório de ano
    for file in "$year_dir"/*.pdf; do
        # Verifica se é um arquivo regular
        if [[ -f "$file" ]]; then
            process_file "$file" "$type_singular" "$year"
        fi
    done
}

# Função para processar um diretório de tipo (Artigos ou Livros)
process_type_directory() {
    local type_dir="$1"
    local type_singular
    type_singular=$(get_type_singular "$(basename "$type_dir")")

    # Verifica se o diretório do tipo existe
    if [[ ! -d "$type_dir" ]]; then
        echo -e "\e[33mDiretório $(basename "$type_dir") não encontrado. Pulando...\e[0m"
        return
    fi

    # Percorre cada diretório de ano dentro do tipo
    for year_dir in "$type_dir"/*/; do
        # Verifica se é um diretório
        if [[ -d "$year_dir" ]]; then
            process_year_directory "$year_dir" "$type_singular"
        fi
    done
}

# Função para processar todos tipos
process_all_types() {
    for type_dir in "${TYPES[@]}"; do
        process_type_directory "$ROOT_DIR/$type_dir"
    done
}

# Função para exibir a estrutura de pastas com arquivos renomeados em verde
display_structure() {
    echo ""
    echo -e "\e[1mRenomeação Concluída. Estrutura de Pastas Atualizada:\e[0m"
    echo ""

    if [[ ${#RENAMED_FILES[@]} -eq 0 ]]; then
        # Se tudo estiver correto, exibe "OK" em ASCII art verde
        echo -e "\e[32m"
        echo "  ___   ____    _    _  __    ___  "
        echo " / _ \ |  _ \  | |  | | \ \  / / | "
        echo "| | | || | | | | |  | |  \ \/ /| | "
        echo "| |_| || |_| | | |__| |   \  / | |___ "
        echo " \___/ |____/   \____/     \/  |_____|"
        echo -e "\e[0m"
    else
        # Usa tree para exibir a estrutura, colorindo os arquivos renomeados
        tree -C | while IFS= read -r line; do
            local colored_line="$line"
            for renamed_file in "${RENAMED_FILES[@]}"; do
                # Extrai o nome do arquivo
                relativo_nome=$(basename "$renamed_file")
                # Verifica se a linha contém o nome do arquivo
                if [[ "$line" == *"$relativo_nome"* ]]; then
                    # Substitui o nome do arquivo na linha com a versão colorida
                    colored_line=$(echo "$line" | sed "s/$relativo_nome/\x1b[32m$relativo_nome\x1b[0m/")
                fi
            done
            echo -e "$colored_line"
        done
    fi
}

# Função principal
main() {
    check_dependencies
    process_all_types
    display_structure
}

# Executa a função principal
main

# Desabilita a expansão de padrões
shopt -u nullglob
