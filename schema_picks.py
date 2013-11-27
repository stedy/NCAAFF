import csv
import sqlite3

connection = sqlite3.connect('site/ncaaff.db')
connection.text_factory = str
cursor = connection.cursor()
connection.text_factory = lambda x: unicode(x, "utf-8", "ignore")

cursor.execute('drop table if exists picks')
cursor.execute('CREATE TABLE picks (Conf text, Team text, \
				Picker text)')
connection.commit()
csvk = csv.reader(open("all_teamsclean.txt", 'rb'), delimiter = ",",
					quotechar = '"')

k = (csvk,)

for k in csvk:
    cursor.execute('INSERT INTO picks VALUES (?,?,?)', k)
connection.commit()
