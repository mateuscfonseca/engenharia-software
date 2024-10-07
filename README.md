# IDEIA 

um reposotório de informações inteligente

Criar um sistema que automatiza a gestão de conhecimento. Unindo LLMs open source pequenas, banco de vector para os embbeddings dos textos, fazer uma aplicação de console que gere uma diversidade de informações a partir de uma base de conhecimento.

# Objetivo
- Automatizar a estração de informações de metados de uma base de conhecimento em .pdf
    - embeddings
    - extração de categorias/agrupamentos
    - extração de mapas conceituais
          - teia de conceitos
          - ideias geradoras (centroide)
    - linha do tempo de desenvolvimento de conceitos
    - geração de modelos de dominio

# Funcionalidades pretendidas
- Organizar a base de diferentes formas (hierarquizar e agrupar por caracteristicas descritas em um arquivo de metadados)
- RAG com os documentos da base
    - trazer referencias e localizações de termos pesquisados a partir da base de conhecimento
    - trazer o abstract dos artigos, e resumo por capitulos de livros.
    - trazer lista de bibliografias para determinado tema
    - trazer rank de autores mais citados em bibliografias
- NLP com LLM
    - conceitos contrapostos
    - estrutura dos argumentos contra e a favor
    - conceitos vistos como positivos/negativos
- gerar indices automaticos em arquivos .md
- categorizar os recursos por tema vindos dos metadados e/ou dos conteudos
    - usar llms como ferramentas de NLP
# Fazer
- Criar script para buscar informações sobre os itens do indice, jusando o gepeto, pegando o api key por variavel de ambiente. 
- colocar no script logica de validação com nota de confiança 
- script que move o livro para o lugar certo, a partir do nome do arquivo, e depois renomeia para o nome do livro
- arrumar nomes
- novo script para gerar indices nas pastas 
- criar scripts python para gerar um sistema de rag com os livros. 
    - faz embed de cada livro, com alguns metadados. 
    - o sistema vai receber perguntas e vai retornar onde achar aquela informação nos livros.
    - criar linha do tempo para conceitos
    - criar mapas de conceitos
    - gerar mapas de referencias
    - sugerir novas referencias a partir das bibliografias
 - script que organiza de diferentes formas
    - forma padrao por ano, mas pode escolher, por autor, por topico
        - criar arquivo com metadados      
  
