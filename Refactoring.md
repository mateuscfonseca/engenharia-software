Esse é o primeiro artigo de uma série. Estou escrevendo essa série com o intuíto de me ajudar a absorver melhor o conteúdo do livro [Refactoring - 1ª](https://www.amazon.com.br/Refactoring-Improving-Design-Existing-Code/dp/0134757599).Entendo que ao tentar comunicar o meu entendimento para outras pessoas, sou capaz de refletir de maneira mais rica o conteúdo do livro e meu entendimento dele. Dito isso, será um prazer imenso ler comentários e sugestões de quem ler esse artigo. 


**Considerações importantes**

Eu sou adepto do SOLID, por isso você vai ver eu argumentando que respeitar seus princípios é sempre benefico. Isso não quer dizer que acho que devemos seguir esses princípios de forma automática, sem a devida reflexão dos seus beneficios e maleficios (geralmente aumentar o número de abstrações,aumentando a complexidade do código).

Os exemplos são feitos para ajudar a entender melhor o conceito. Por isso devem ser simples. Isso pode fazer com que pareça desnecessário algumas refatorações, como se elas apenas aumentassem a complexidade do código. Mas imagine que estamos em um contexto de um sistema que está em constante evolução, como  novas funcionalidades e regras de negócio. 

Outra coisa importante notar é que algumas técnicas de refatoração parecem não levar em consideração a performance, especialmente se o código for chamado muitas vezes em um loop.E de certa forma é isso mesmo. Mas isso não é desconsiderar a perfomance, é apenas entender que são momentos diferentes do estágio de mantutenção do código.

Um código bem estruturado vai ser sempre mais fácil de tornar performatico do que um codigo altamente acoplado (faz com que mudanças em uma funcionalidade acabem afetando outras), dificil de entender (aumentando a chance de adição de código adicionar bugs). Além disso, tem a questão que nosso instito sobre a performance de uma aplicação pode estar completamente errado, apesar de fazer sentido lógico. 

Por isso é sempre preciso MEDIR a performance para saber o que de fato é um gargalo ou não. Então, durante a refatoração, não vamos nos preocupar com a performance e tudo bem. Quando formos trabalhar a performance, ai sim podemos abrir mão de um alto nível legibilidade e maior segração de interfaces.

**Todas essas considerações são feitas pelo Martin no livro. (menos a parte do SOLID)**

# Chapter 1. Rafactoring, a First Example

O Martin tem uma maneira de escrever seus livros, começando sempre por um exemplo prático. Nesse exemplo ele já mobiliza os diversos conceitos que ele vai posteriormente detalhar.

Antes de começar, ele estressa bastante o ponto de que é preciso ter testes unitários para poder realizar o refactor com segurança
	- primeiro testes
	- depois /refactor

Outro ponto importante é: executar o refactor em pequenos passos, tornando mais fácil corrigir se algo der errado. 

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand."

Abaixo listo as técnicas comentadas nesse capitulo, com exemplos diferentes, que fiz para poder absorver melhor o conteúdo. Para criar a implementação em Python dos novos exemplos, usei a ajuda do Gepeto (me tornei um programador muito preguiçoso, quero só pensar, deixo a escrita pra LLM 😂). Tirando isso, o restante foi escrito por mim. 

## Extract Method

A técnica de refatoração Extract Method é usada quando você tem um trecho de código que pode ser extraído para um novo método, dando-lhe um nome descritivo e reduzindo a complexidade do método original. Isso melhora a legibilidade e facilita a manutenção do código.

### Exemplo
```py
class Order:
    def __init__(self, items):
        self.items = items

    def print_order(self):
        print("Order Details:")
        total_price = 0
        for item in self.items:
            total_price += item['price']
            print(f"Item: {item['name']}, Price: {item['price']}")

        print(f"Total Price: {total_price}")

```

### Problema
Neste exemplo, o método print_order faz várias coisas: imprime os detalhes de cada item e calcula o preço total.

### Aplicando o Move Method

```py
class Order:
    def __init__(self, items):
        self.items = items

    def print_order(self):
        print("Order Details:")
        total_price = self._calculate_total_price()
        self._print_items()
        print(f"Total Price: {total_price}")

    def _calculate_total_price(self):
        total_price = 0
        for item in self.items:
            total_price += item['price']
        return total_price

    def _print_items(self):
        for item in self.items:
            print(f"Item: {item['name']}, Price: {item['price']}")

```

*Agora, o método print_order é mais simples e legível. Ele delega as responsabilidades de calcular o preço total e imprimir os itens para métodos específicos (_calculate_total_price e _print_items). Isso segue o princípio de responsabilidade única, facilitando a manutenção e possíveis futuras alterações.*

### Benefícios da Refatoração

- A legibilida melhorada: Cada parte do cálculo agora tem um nome descritivo, tornando o código mais fácil de entender.
- Reusabilidade: Se precisarmos do preço base ou do desconto em outro lugar, podemos simplesmente chamar o método correspondente.
- Facilidade de Manutenção: Se a lógica de cálculo mudar (por exemplo, a regra de desconto), só precisamos modificar o método específico.
- Testabilidade: Cada método pode ser testado independentemente, facilitando a criação de testes unitários.

## Move Method
A técnica de refatoração Move Method é usada quando você percebe que um método em uma classe está mais relacionado ou tem maior dependência de outra classe. A ideia é mover o método para a classe onde ele faz mais sentido, melhorando o encapsulamento e a coesão.

### Exemplo 

Considere um sistema que gerencia contas bancárias e transações. Temos as classes BankAccount e Transaction, onde o método de cálculo de taxas de transação está atualmente na classe BankAccount. No entanto, faz mais sentido que essa lógica resida na classe Transaction.

```py
class BankAccount:
    def __init__(self, account_number, balance=0):
        self.account_number = account_number
        self.balance = balance
        self.transactions = []

    def add_transaction(self, transaction):
        self.transactions.append(transaction)

    def calculate_fees(self):
        total_fees = 0
        for transaction in self.transactions:
            if transaction.type == 'withdrawal' and transaction.amount > 100:
                total_fees += transaction.amount * 0.02
            elif transaction.type == 'deposit' and transaction.amount > 1000:
                total_fees += transaction.amount * 0.01
        return total_fees
      

class Transaction:
    def __init__(self, type, amount):
        self.type = type
        self.amount = amount

```

*Repare como no método que calcula o total de taxas. Ele basicamente usa informações que não pertencem a classe BankAccount.Isso é um forte sinal de que o método deveria estar na classe Transaction.*

#### Problema

Aqui, o método calculate_fees na classe BankAccount depende fortemente dos detalhes de cada transação, como o tipo e o valor. Como essa lógica é mais relacionada à transação em si, podemos movê-la para a classe Transaction.

#### Aplicando Move Method

Primeiro, movemos a lógica de cálculo de taxas para a classe Transaction. Vamos criar um novo método calculate_fee na classe Transaction.

```python
class BankAccount:
    def __init__(self, account_number, balance=0):
        self.account_number = account_number
        self.balance = balance
        self.transactions = []

    def add_transaction(self, transaction):
        self.transactions.append(transaction)

    def calculate_fees(self):
        total_fees = 0
        for transaction in self.transactions:
            total_fees += transaction.calculate_fee()
        return total_fees
        

class Transaction:
    def __init__(self, type, amount):
        self.type = type
        self.amount = amount

    def calculate_fee(self):
        if self.type == 'withdrawal' and self.amount > 100:
            return self.amount * 0.02
        elif self.type == 'deposit' and self.amount > 1000:
            return self.amount * 0.01
        return 0
```

*Repare que o método que calcula as taxas não recebe nenhum parâmetro. Isso é um sinal de que ele não precisa estar na classe BankAccount, e sim na classe Transaction. Não que isso seja uma regra, não tem para metros, move a classe, mas é um bom indicativo. Em orientação a objetos, um dos objetivos é que a lógica de um método dependa de dados que são da sua classe. Por isso a importância do conceito de encapsulamento.*

### Benefícios da Refatoração

- Legibilidade melhorada: a melhor segmentação do código torna a carga cognitiva mais leve, tornando o código mais fácil de entender.
- Encapsulamento Melhorado: A lógica específica de cada transação está agora encapsulada dentro da classe Transaction, que é **responsável pelos detalhes** das transações.
- Maior Coesão: A classe BankAccount é agora mais coesa, focando em gerenciar a conta e delegando a lógica de cada transação para a classe apropriada.
- Facilidade de Manutenção: Se as regras de cálculo de taxas mudarem, isso pode ser tratado diretamente na classe Transaction, sem afetar a lógica geral da classe BankAccount.


## Replace Type Code with State/Strategy

Essa técnica é usada quando você tem um código que utiliza tipos ou valores específicos para determinar o comportamento (como os tipos de transação no exemplo) e deseja substituir isso por uma estrutura mais orientada a objetos, utilizando padrões como [State](https://refactoring.guru/design-patterns/state) ou [Strategy](https://refactoring.guru/design-patterns/strategy).

### Exemplo

No exemplo atual, a classe Transaction usa uma string ('withdrawal' ou 'deposit') para determinar o tipo de transação e, com isso, calcula a taxa correspondente:

```py
class Transaction:
    def __init__(self, type, amount):
        self.type = type
        self.amount = amount

    def calculate_fee(self):
        if self.type == 'withdrawal' and self.amount > 100:
            return self.amount * 0.02
        elif self.type == 'deposit' and self.amount > 1000:
            return self.amount * 0.01
        return 0

```

*Repare como a forma de calcular muda a depender do tipo da transação. Isso é um sinal de que podemos aplicar o padrão [Strategy](https://refactoring.guru/design-patterns/strategy), que vai tornar o código mais orientado a objetos e extensível, respeitando o príncipio de Open/Closed, uma vez que adicionar mais formas de calcular taxas não afetará o código de Transaction.*

### Problema

Usar strings para representar tipos de transações pode tornar o código menos robusto e mais difícil de manter. Além disso, se o cálculo da taxa de transação se tornar mais complexo, essa abordagem pode levar a um código com muitos condicionais. A técnica Replace Type Code with State/Strategy pode ser aplicada aqui para melhorar a organização do código.

### Aplicando Replace Type Code with State/Strategy

Vamos substituir o uso de strings para representar tipos de transação por uma hierarquia de classes, onde cada classe representa um tipo específico de transação e encapsula o comportamento correspondente.

#### Passo 1: Criar a Hierarquia de Classes

Primeiro, criamos uma classe base TransactionType e subclasses específicas para cada tipo de transação (Withdrawal e Deposit), que implementam o método calculate_fee de maneira diferente.

```py
from abc import ABC, abstractmethod

class TransactionType(ABC):
    @abstractmethod
    def calculate_fee(self, amount):
        pass

class Withdrawal(TransactionType):
    def calculate_fee(self, amount):
        if amount > 100:
            return amount * 0.02
        return 0

class Deposit(TransactionType):
    def calculate_fee(self, amount):
        if amount > 1000:
            return amount * 0.01
        return 0
```

#### Passo 2: Refatorar a Classe Transaction
Agora, modificamos a classe Transaction para utilizar uma instância de TransactionType em vez de uma string:

```py
class Transaction:
    def __init__(self, transaction_type, amount):
        self.transaction_type = transaction_type
        self.amount = amount

    def calculate_fee(self):
        return self.transaction_type.calculate_fee(self.amount)
```

Agora, ao invés de verificar o tipo de transação usando strings, Transaction delega o cálculo da taxa à instância da estratégia apropriada.  

### Benefícios da Refatoração

- Eliminação de Condicionais: O código que antes usava condicionais para determinar o comportamento agora usa polimorfismo, onde cada classe de transação encapsula seu próprio comportamento.
- Maior Flexibilidade: Novos tipos de transação podem ser adicionados simplesmente criando novas subclasses de TransactionType, sem precisar modificar a classe Transaction ou adicionar mais condicionais.
- Código Mais Limpo e Manutenível: O uso de objetos em vez de códigos de tipo torna o código mais organizado e facilita futuras expansões ou modificações.

## Replace Conditional with Polymorphism
Replace Conditional with Polymorphism é uma técnica de refatoração que substitui condicionais complexas (como if-else ou switch-case) por polimorfismo. Isso é feito criando uma hierarquia de classes onde cada classe concreta implementa um comportamento específico. Essa abordagem melhora a legibilidade, facilita a manutenção e reduz a complexidade do código.

Como estamos fazendo baseado em uma estrutura de classes, podemos usar o conceito de polimorfismo, que é uma técnica de refatoração que substitui condicionais complexas (como if-else ou switch-case) por polimorfismo. 

Isso é possível pois a classe que chama o método depende apenas da classe abstrata TransactionType, e não da sua implementação concreta. 

Isso faz com que não seja necessario condicionais, uma vez que ao receber um objeto TransactionType, o método calculate_fee pode ser chamado de forma independente da classe concreta que implementa o método. 

Ao instanciar uma Transcation, informamos qual a classe TransactionType que vai ser usada para calcular a taxa, e o método Transaction chama o método calculate_fee da instância da classe TransactionType.

No exemplo anterior, tinhamos:

- Condicionais Existentes: 

   O código original usava condicionais para verificar o tipo de transação ('withdrawal' ou 'deposit') e, com base nisso, aplicava uma lógica diferente no cálculo da taxa.

- Refatoração com Polimorfismo:

   Em vez de manter esses condicionais, criamos uma hierarquia de classes (TransactionType, Withdrawal, e Deposit), onde cada classe implementa o método calculate_fee de forma distinta, de acordo com o tipo de transação.

   Esse é o princípio central do Replace Conditional with Polymorphism: o comportamento variável é tratado por meio de classes distintas e polimorfismo, em vez de condicionais.

- Respeita o princípio de Open/Closed:
    Adicionar novos comportamentos é uma questao de implmentar novas subclasses de TransactionType, e não de modificar a classe Transaction. Isso é um sinal de que o código deve ser aberto para extensão, mas fechado para modificação.
Entendi. Vou criar um exemplo semelhante para a técnica "Replace Temp With Query" que acabamos de discutir. Aqui está:

## Replace Temp With Query

A técnica de refatoração "Replace Temp With Query" é utilizada quando você tem uma variável temporária que armazena o resultado de uma expressão. A ideia é substituir essa variável por uma chamada de método, melhorando a legibilidade e a manutenibilidade do código.

### Exemplo

Considere um sistema de gerenciamento de pedidos em uma loja online. Temos uma classe `Order` que calcula o preço total de um pedido, incluindo descontos.

```python
class Order:
    def __init__(self, quantity, item_price):
        self.quantity = quantity
        self.item_price = item_price

    def calculate_total(self):
        base_price = self.quantity * self.item_price
        quantity_discount = 0
        if self.quantity > 100:
            quantity_discount = base_price * 0.1
        shipping = base_price * 0.1
        return base_price - quantity_discount + shipping
```

**Obs:** 
Repare como temos várias variáveis temporárias (`base_price`, `quantity_discount`, `shipping`) que armazenam resultados intermediários. Isso pode tornar o código mais difícil de entender e manter, especialmente se esses cálculos forem necessários em outros lugares.

#### Problema

O método `calculate_total` usa várias variáveis temporárias para cálculos intermediários. Isso pode dificultar a compreensão do código e levar a duplicações se esses cálculos forem necessários em outros lugares.

#### Aplicando Replace Temp With Query

Vamos refatorar o código substituindo cada variável temporária por uma chamada de método:

```python
class Order:
    def __init__(self, quantity, item_price):
        self.quantity = quantity
        self.item_price = item_price

    def calculate_total(self):
        return self.base_price() - self.quantity_discount() + self.shipping()

    def base_price(self):
        return self.quantity * self.item_price

    def quantity_discount(self):
        return self.base_price() * 0.1 if self.quantity > 100 else 0

    def shipping(self):
        return self.base_price() * 0.1
```

**Obs:**
Repare que agora não temos mais variáveis temporárias. Cada cálculo intermediário foi transformado em um método. Isso torna o código mais legível e cada parte do cálculo pode ser facilmente reutilizada ou testada individualmente.

### Benefícios da Refatoração

- **Legibilidade Melhorada**: Cada parte do cálculo agora tem um nome descritivo, tornando o código mais fácil de entender.
- **Reusabilidade**: Se precisarmos do preço base ou do desconto em outro lugar, podemos simplesmente chamar o método correspondente.
- **Facilidade de Manutenção**: Se a lógica de cálculo mudar (por exemplo, a regra de desconto), só precisamos modificar o método específico.
- **Testabilidade**: Cada método pode ser testado independentemente, facilitando a criação de testes unitários.

### Considerações

- **Performance**: Em alguns casos, substituir variáveis por chamadas de método pode ter um pequeno impacto na performance, especialmente se o método for chamado muitas vezes em um loop.
- **Complexidade**: Para cálculos muito simples, criar um método separado pode parecer excessivo. Use seu julgamento para decidir quando a refatoração vale a pena.

Ao aplicar "Replace Temp With Query", você está essencialmente transformando dados (variáveis) em comportamento (métodos), o que geralmente leva a um design mais orientado a objetos e mais flexível.

# Chapter 2. Principles in Refactoring

> Refatorar é mudar a estrutura interna de um programa, mas não mudar seu comportamento. (Substantivo)

> Alterar um software aplicando uma série de refatorações sem alterar o seu comportamento observavel.

> O objetivo da refatoração é tornar o código mais legível, mais fácil de manter e mais flexível. É bastante diferente de otimizar o software, pois nesse caso o desempenho é mais importante que a legibilidade e facilidade de manutenção.

## Os dois chapéis
Ken Beck, um dos maiores desenvolvedores de software da história, fala sobre a ideia de dois chapéis. Tem o chapéu de adição de funcionalidade e o chapéu de refatoração. Quando você está adicionando funcionalidade, seu objetivo é adicionar um novo comportamente ao sistema. Quando você está refatorando, seu objetivo é tornar o código mais legível, mais fácil de manter e mais flexível, sem adicionar novos comportamentos.

## Por que refatorar?

> Sem refatoração, o design do sistema vai degradar ao longo do tempo, tornando-o mais difícil de manter e menos flexível. A atuação de diferentes pessoas e equipes também pode fazer o sistema perder sua arquitetura. Isso vai tornar entender o design do sistema mais dificil. 

> Quanto mais dificil de pereber um design, mais difícil é manter e refatorar.

> Isso faz com que para mudar um pedaço de código acabe sendo necessário escrever mais linhas. O que em si contribui para piorar o problema.

> Uma das causas de se tornar mais díficil é por que um sistema mal estruturado tende a ter muita repetição de código. Entao, para mudar o código é necessário verificar se existe alguma repetição, e vc acaba tendo que fazer a mesma alteração em vários lugares.

> Quanto mais código, mais difícil é modificar corretamente. Ou seja, sem a introdução de bugs.

> A remoção de duplicação vc garante que o código diga tudo que tem que dizer e apenas uma vez, o que é a essencia de um bom design.

## Refatoração torna o código mais fácil de entender

Para sermos capazes de trabalhar de forma efetiva em um sistema, é necessário entender seu código e design. A refatoração, ao garantir a preservação da estrutura do código e sua legibilidade, a refatoração garante que a proxima pessoa a trabalhar no seu código, tenha a possibilidade de entender rapidamente e ser capaz de alterar com maior segurança, visto que um dos resultaedos da refatoração é deixar o código aberto para extensao e fechado para modificação.

Refatorar também é um alinhado ao processo de entendimento de um sistema. Isso pq ao modificar o codigo, sem modificar seu comportamento, vc acaba expressando o mesmo comportamento mas agora dentro de um arcabouço de ideias que vc esta propondo ao refatorar, te tornando mais dono do código e entendedor da sua motivação e forma correta de funcionamento.

## Refatorar te ajuda a achar bugs

Ao facilitar o entendimento de um sistema, refatorar também ajuda a achar bugs. Quando vc refatora, vc acaba entendendo o código e sua estrutura, e ao encontrar um bug, vc acaba entendendo o que está errado e como corrigir. 

## Refatorar ajuda a programar mais rápido

Uma boa estrutura de código torna ele mais facil de extender, isso pq a extensibilidade  é uma das caracterísitcas que a refatoração vai trazer. Como a uplicação é minima, siguinifica que vai ter que alterar em menos lugares, diminuindo o espaço para erros. Também torna testar mais fácil, uma vez que outra consequencia da refatoração é a melhor seguimentação do código, melhor organização das abstrações do negócio, e isso tora o teste unitario mais rapido de fazer. 

