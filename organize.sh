#!/bin/bash

# Nome: organize
# Descrição: Organiza arquivos na estrutura de pastas baseada no nome do arquivo.
# Formato do nome do arquivo: [nome_arquivo].[Tipo(Livro|Artigo)].[Ano]
# Autor: [Seu Nome]
# Data: [Data Atual]

# Habilita a expansão de padrão para evitar problemas com nomes de arquivos que contêm espaços
shopt -s nullglob

# Diretório raiz onde o script está localizado
ROOT_DIR="$(pwd)"

# Arrays para armazenar os caminhos dos arquivos movidos
declare -a MOVED_FILES

# Função para exibir uma mensagem de erro e sair
function error_exit {
    echo -e "\e[31mErro: $1\e[0m" 1>&2
    exit 1
}

# Verifica se o comando 'tree' está instalado
if ! command -v tree &> /dev/null
then
    error_exit "'tree' não está instalado. Por favor, instale-o para continuar."
fi

# Percorre todos os arquivos no diretório raiz (exclui diretórios)
for file in "$ROOT_DIR"/*; do
    # Verifica se é um arquivo regular
    if [[ -f "$file" ]]; then
        filename=$(basename -- "$file")
        
        # Extrai partes do nome do arquivo usando expressão regular
        # Formato esperado: [nome_arquivo].[Tipo].[Ano]
        if [[ "$filename" =~ ^(.+)\.(Livro|Artigo)\.([0-9]{4})$ ]]; then
            nome_arquivo="${BASH_REMATCH[1]}"
            tipo="${BASH_REMATCH[2]}"
            ano="${BASH_REMATCH[3]}"
            
            # Define o diretório de destino baseado no tipo e ano
            destino="$ROOT_DIR/$tipo/$ano/"
            
            # Verifica se o diretório de destino existe
            if [[ ! -d "$destino" ]]; then
                echo -e "\e[33mDiretório $destino não existe. Criando...\e[0m"
                mkdir -p "$destino" || { echo -e "\e[31mFalha ao criar o diretório $destino.\e[0m"; continue; }
            fi
            
            # Move o arquivo para o destino
            mv "$file" "$destino" && {
                MOVED_FILES+=("$destino$filename")
                echo -e "\e[32mMovido: $filename para $destino\e[0m"
            } || {
                echo -e "\e[31mFalha ao mover: $filename\e[0m"
            }
        else
            echo -e "\e[34mIgnorando arquivo com nome inválido: $filename\e[0m"
        fi
    fi
done

echo ""
echo -e "\e[1mEstrutura de Pastas Atualizada:\e[0m"
echo ""

# Função para colorir os arquivos movidos em verde na saída do tree
function color_tree {
    tree -C | while IFS= read -r line; do
        for moved_file in "${MOVED_FILES[@]}"; do
            # Extrai o caminho relativo do arquivo movido
            relativo="${moved_file#$ROOT_DIR/}"
            # Verifica se a linha contém o caminho relativo
            if [[ "$line" == *"$relativo"* ]]; then
                # Substitui a linha com a versão colorida
                line=$(echo "$line" | sed "s/$relativo/\x1b[32m$relativo\x1b[0m/")
            fi
        done
        echo -e "$line"
    done
}

# Exibe a estrutura de pastas com os arquivos movidos em verde
color_tree

# Desabilita a expansão de padrão
shopt -u nullglob
