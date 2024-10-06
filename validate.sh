#!/bin/bash

# Nome: validate.sh
# Descrição: Valida se todos os arquivos estão nomeados e localizados corretamente na estrutura de pastas.
# Autor: [Seu Nome]
# Data: [Data Atual]

# Habilita a expansão de padrões que não correspondem a nenhum arquivo
shopt -s nullglob

# Diretório raiz onde o script está localizado
ROOT_DIR="$(pwd)"

# Tipos de arquivos a serem processados
TYPES=("Artigos" "Livros")

# Arrays para armazenar os caminhos dos arquivos incorretos
declare -a INCORRECT_FILES

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

# Função para validar o nome do arquivo
validate_filename() {
    local filename="$1"
    # Expressão regular para validar o padrão [nome_arquivo].[Tipo(Livro|Artigo)].[Ano].pdf
    if [[ "$filename" =~ ^(.+)\.(Livro|Artigo)\.([0-9]{4})\.pdf$ ]]; then
        # Extrai as partes do nome do arquivo
        FILE_NAME="${BASH_REMATCH[1]}"
        FILE_TYPE="${BASH_REMATCH[2]}"
        FILE_YEAR="${BASH_REMATCH[3]}"
        return 0
    else
        return 1
    fi
}

# Função para verificar se o arquivo está na pasta correta
validate_location() {
    local file_path="$1"
    local filename="$2"
    
    # Extrai o tipo e ano do caminho
    local type_dir
    type_dir=$(basename "$(dirname "$(dirname "$file_path")")")  # Extrai "Artigos" ou "Livros"
    local year_dir
    year_dir=$(basename "$(dirname "$file_path")")             # Extrai "1970", "1980", etc.


    # Verifica se o tipo do arquivo corresponde ao diretório
    local expected_type
    expected_type=$(get_type_singular "$type_dir")
    
    if [[ "$FILE_TYPE" != "$expected_type" ]]; then
        return 1
    fi

    # Verifica se o ano do arquivo é igual ou maior que o ano da pasta
    if (( FILE_YEAR < year_dir )); then
        return 1
    fi

    return 0
}

# Função para processar um único arquivo
process_file() {
    local file="$1"
    local filename
    filename=$(basename -- "$file")

    if validate_filename "$filename"; then
        if ! validate_location "$file" "$filename"; then
            INCORRECT_FILES+=("$file")
        fi
    else
        INCORRECT_FILES+=("$file")
    fi
}

# Função para processar todos arquivos em um diretório de tipo
process_type_directory() {
    local type_dir="$1"
    
    # Verifica se o diretório do tipo existe
    if [[ ! -d "$type_dir" ]]; then
        echo -e "\e[33mDiretório $(basename "$type_dir") não encontrado. Pulando...\e[0m"
        return
    fi

    # Percorre cada diretório de ano dentro do tipo
    for year_dir in "$type_dir"/*/; do
        # Verifica se é um diretório
        if [[ -d "$year_dir" ]]; then
            # Percorre cada arquivo PDF no diretório de ano
            for file in "$year_dir"/*.pdf; do
                # Verifica se é um arquivo regular
                if [[ -f "$file" ]]; then
                    process_file "$file"
                fi
            done
        fi
    done
}

# Função para processar todos tipos
process_all_types() {
    for type_dir in "${TYPES[@]}"; do
        process_type_directory "$ROOT_DIR/$type_dir"
    done
}

# Função para exibir a estrutura de pastas com arquivos incorretos em vermelho
display_results() {
    if [[ ${#INCORRECT_FILES[@]} -eq 0 ]]; then
        # Se tudo estiver correto, exibe "OK" em ASCII art verde
        echo -e "\e[32m"
        echo "  ___   ____    _    _  __    ___  "
        echo " / _ \ |  _ \  | |  | | \ \  / / | "
        echo "| | | || | | | | |  | |  \ \/ /| | "
        echo "| |_| || |_| | | |__| |   \  / | |___ "
        echo " \___/ |____/   \____/     \/  |_____|"
        echo -e "\e[0m"
    else
        # Se houver arquivos incorretos, exibe a estrutura com eles em vermelho
        echo -e "\e[31m"
        echo "Arquivos incorretos encontrados:"
        echo -e "\e[0m"

        # Usa tree para exibir a estrutura, colorindo os arquivos incorretos
        tree -C | while IFS= read -r line; do
            local colored_line="$line"
            for incorrect_file in "${INCORRECT_FILES[@]}"; do
                local relative_path="${incorrect_file#$ROOT_DIR/}"
                local filename=$(basename "$relative_path")
                if [[ "$line" == *"$filename"* ]]; then
                    # Colore apenas o nome do arquivo em vermelho
                    colored_line=$(echo "$line" | sed "s/$filename/\x1b[31m$filename\x1b[0m/")
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
    display_results
}

# Executa a função principal
main

# Desabilita a expansão de padrões
shopt -u nullglob
