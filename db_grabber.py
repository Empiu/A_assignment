import mysql.connector as mys
from mysql.connector import Error
from tkinter import *


class dbGrab:  # устанавливает соединение с БД и забирает данные по SQL-запросу
    def connect(self, h, db, usr, pwd):
        try:
            self.con = mys.connect(host=h, database=db, user=usr, password=pwd)
            if self.con.is_connected():
                return True
        except Error as e:
            print(e)

    def do_the_thing(self, date_from, date_to):

        command = """
        SELECT date_opened, date_current_status, full_name, nginfo FROM bank_credit_request_forms 
        INNER JOIN clients ON (bank_credit_request_forms.b_client_id = clients.b_client_id) 
        WHERE bank_credit_request_forms.status = '2'
        """

        if date_from: command += " AND bank_credit_request_forms.date_opened>= %(date_0)s "
        if date_to: command += " AND bank_credit_request_forms.date_opened<= %(date_1)s "
        command += "ORDER BY bank_credit_request_forms.nginfo ASC"
        cursor = self.con.cursor()
        if date_from and not date_to:
            cursor.execute(command, {'date_0': date_from})
        elif date_to and not date_from:
            cursor.execute(command, {'date_1': date_to})
        elif date_from and date_to:
            cursor.execute(command, {'date_0': date_from, 'date_1': date_to})
        else:
            cursor.execute(command)

        lst = (cursor.fetchall())
        self.con.close()
        return lst

dbgrab = dbGrab()

class dataGrab: #графика и цикл запускающий коннект и запрос

    def __init__(self, main):
        self.ent1 = Entry(main, width=15, bd=3)
        self.ent2 = Entry(main, width=15, bd=3)
        self.ent3 = Entry(main, width=15, bd=3)
        self.ent4 = Entry(main, width=15, bd=3)
        self.ent5 = Entry(main, width=15, bd=3)
        self.ent6 = Entry(main, width=15, bd=3)

        self.lab1 = Label(main, text='host')
        self.lab2 = Label(main, text='dbname')
        self.lab3 = Label(main, text='user')
        self.lab4 = Label(main, text='password')
        self.lab5 = Label(main, text='slice from')
        self.lab6 = Label(main, text='to')

        self. lbox = Listbox(main, height=20, width = 50)

        self.but1 = Button(main, text='Do the thing')
        self.but1.bind("<Button-1>", self.gui_parse)

        self.ent1.grid(row=1, column=0, sticky=NE)
        self.ent2.grid(row=1, column=1, sticky=NE)
        self.ent3.grid(row=1, column=2, sticky=N)
        self.ent4.grid(row=1, column=3, sticky=N)
        self.ent5.grid(row=3, column=1, sticky=NE)
        self.ent6.grid(row=3, column=2, sticky=NE)


        self.lab1.grid(row=0, column=0, sticky=NE)
        self.lab2.grid(row=0, column=1, sticky=N)
        self.lab3.grid(row=0, column=2, sticky=N)
        self.lab4.grid(row=0, column=3, sticky=N)
        self.lab5.grid(row=2, column=1, sticky=NE)
        self.lab6.grid(row=2, column=2, sticky=N)

        self.lbox.grid(row=4, column=0, sticky=S)
        self.but1.grid(row=4, column=1, sticky=SW)

    def gui_parse(self, event):
        self.lbox.delete(0, END)
        entry1_host = self.ent1.get()
        entry2_dbname = self.ent2.get()
        entry3_user = self.ent3.get()
        entry4_password = self.ent4.get()
        _from = self.ent5.get()
        _to = self.ent6.get()
        if dbgrab.connect(entry1_host, entry2_dbname, entry3_user, entry4_password):
            table = [(i[0].strftime('%d.%m.%Y'),
                i[1].strftime('%d.%m.%Y'), i[2], i[3]) for i in dbgrab.do_the_thing(_from, _to)]
            for i in table: self.lbox.insert(END, i)
        else:
            try:
                dbgrab.con.close()
            except AttributeError:
                pass
root = Tk()
root.title('Задание 3')
gui = dataGrab(root)
root.mainloop()