extends Control

onready var money_label = $MoneyAmount/Label

func update_money(money, goal):
	money_label.text = "Money: $" + str(money) + "/ $" + str(goal)
