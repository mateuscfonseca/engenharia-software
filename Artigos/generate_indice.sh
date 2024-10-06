#!/bin/bash

# Nome do arquivo README
README="README.md"

# Iniciar o arquivo README
echo "# Índice de Artigos por Década" > $README
echo "" >> $README
echo "Este índice lista os artigos organizados por década. Clique nos links para acessar os arquivos correspondentes." >> $README
echo "" >> $README

# Loop através das pastas de décadas
for dir in */ ; do
    # Remover a barra no final do nome da pasta
    dir=${dir%/}
    
    echo "## $dir" >> $README
    echo "" >> $README
    
    # Loop através dos arquivos na pasta
    for file in "$dir"/* ; do
        # Verificar se é um arquivo
        if [[ -f "$file" ]]; then
            # Extrair o nome do arquivo sem o caminho
            filename=$(basename "$file")
            # Codificar espaços e caracteres especiais para URLs
            url=$(echo "$dir/$filename" | sed 's/ /%20/g')
            # Adicionar o link ao README
            echo "- [${filename}](./${url})" >> $README
        fi
    done
    echo "" >> $README
done

# Adicionar seção para arquivos que não foram movidos
echo "## Outros" >> $README
echo "" >> $README

# Loop através dos arquivos no diretório atual que não estão em pastas
for file in * ; do
    # Ignorar pastas
    if [[ -f "$file" ]]; then
        # Verificar se o arquivo já está listado nas pastas
        listed=false
        for dir in */ ; do
            if [[ -f "${dir}${file}" ]]; then
                listed=true
                break
            fi
        done
        # Se não estiver listado, adiciona na seção "Outros"
        if [[ "$listed" = false ]]; then
            # Codificar espaços e caracteres especiais para URLs
            url=$(echo "$file" | sed 's/ /%20/g')
            echo "- [${file}](./${url})" >> $README
        fi
    fi
done

echo "" >> $README
echo "---" >> $README
echo "" >> $README
echo "Gerado automaticamente em $(date)." >> $README

echo "O arquivo README.md foi gerado com sucesso."