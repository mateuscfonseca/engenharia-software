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

class Order2:
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

class Order3:
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

class Order4:
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


class BankAccount2:
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
        

class Transaction2:
    def __init__(self, type, amount):
        self.type = type
        self.amount = amount

    def calculate_fee(self):
        if self.type == 'withdrawal' and self.amount > 100:
            return self.amount * 0.02
        elif self.type == 'deposit' and self.amount > 1000:
            return self.amount * 0.01
        return 0
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

class Transaction3:
    def __init__(self, transaction_type, amount):
        self.transaction_type = transaction_type
        self.amount = amount

    def calculate_fee(self):
        return self.transaction_type.calculate_fee(self.amount)
if __name__ == '__main__':
    order = Order([{'name': 'Item 1', 'price': 100}, {'name': 'Item 2', 'price': 200}])
    order.print_order()

    order = Order2([{'name': 'Item 1', 'price': 100}, {'name': 'Item 2', 'price': 200}])
    order.print_order()

    transaction = Transaction('withdrawal', 101)
    acc = BankAccount('123456789')
    acc.add_transaction(transaction)
    print(acc.calculate_fees())

    transaction = Transaction2('withdrawal', 301)
    acc = BankAccount2('123456789')
    acc.add_transaction(transaction)
    print(acc.calculate_fees())

    transaction = Transaction3(Withdrawal(), 500)
    acc = BankAccount2('123456789')
    acc.add_transaction(transaction)
    print(acc.calculate_fees())

    order3 = Order3(100, 100)
    print(order3.calculate_total())

    order4 = Order4(100, 100)
    print(order4.calculate_total())