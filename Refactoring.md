# Refactoring

## 03/08 

### Chapter 1.

É preciso ter testes unitários para poder realizar o refactor com segurançã
	- primeiro testes
	- depois refactor

É preciso executar o refactor em pequenos passos, tornando mais facil corrigir se algo der errado. 

"Any fool can write code that a computer can understand. Good programmers write
code that humans can understand."

Extract Method
-

Transformar um seguimento de um algoritimo em um método em seperado

```py
class A {
	def a():
		_x = 10
		_y = 20 

		_multiples = Set()
		 
}
```