#!/bin/bash

# Script para mover arquivos para pastas correspondentes com base no ano no nome do arquivo

# Loop através de todos os arquivos no diretório atual
for file in *; do
    # Verifica se é um arquivo regular
    if [[ -f "$file" ]]; then
        # Extrai o ano de 4 dígitos do nome do arquivo usando regex
        if [[ "$file" =~ ([0-9]{4}) ]]; then
            year=${BASH_REMATCH[1]}
            
            # Determina a década correspondente
            decade=$((year / 10 * 10))
            
            # Nome da pasta da década
            folder="$decade"
            
            # Verifica se a pasta existe; se não, cria
            if [[ ! -d "$folder" ]]; then
                echo "Criando pasta: $folder"
                mkdir "$folder"
            fi
            
            # Move o arquivo para a pasta correspondente
            echo "Movendo '$file' para '$folder/'"
            mv "$file" "$folder/"
        else
            echo "Nenhum ano encontrado no arquivo: '$file'. Pulando..."
        fi
    fi
done

echo "Processo concluído."
