import mysql.connector as mys
from mysql.connector import Error
import tkinter as tk
from collections import OrderedDict as odict
import datetime

# устанавливает соединение с БД и забирает данные по SQL-запросу
class dbGrab:
    # соединение с базой данных
    def connect(self, h, db, usr, pwd):
        try:
            self.con = mys.connect(host=h, database=db, user=usr, password=pwd)
            if self.con.is_connected():
                return True
        except Error as e:
            print(e)

    # формирование SQL запроса и выдача таблицы в виде списка где элемент списка == запись таблицы
    def do_the_thing(self, date_from, date_to):

        command = """
        SELECT date_opened, date_current_status, full_name, nginfo FROM bank_credit_request_forms 
        INNER JOIN clients ON (bank_credit_request_forms.b_client_id = clients.b_client_id) 
        WHERE bank_credit_request_forms.status = '2'
        """

        if date_from: command += " AND bank_credit_request_forms.date_opened>= %(date_0)s "
        if date_to: command += " AND bank_credit_request_forms.date_current_status<= %(date_1)s "
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

# графика
class dataGrab(tk.Tk):

    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        # заготовка для деления энтрисов на два ряда
        self.lst1 = ['Host', 'DbName', 'User', 'Password']
        self.lst2 = ['Slice from', 'Slice to']

        # стандартные параметры для полей коннекта к моей бд, что бы не вводить каждый раз при запуске формы
        self.lst11 = ['localhost', 'credit_scoring', 'root', '101101']

        # элементы формы
        self.button = tk.Button(self, text='Провести выборку',
                                command=lambda: self.gui_parse()).grid(row=1, column=2, sticky='nswe')

        self.label = tk.LabelFrame(self, text='Дата подачи, Дата закрытия, Клиент, Код отказа')
        self.label.grid(row=3, columnspan=4, column=0, sticky='nsw')
        self.lbox = tk.Listbox(self.label, height=20, width=50)
        self.lbox.grid(row=4, columnspan=4, column=0)

        # расставляем ряды энтрисов
        self.entries = self.entries_compile(self.lst1)
        self.entries2 = self.entries_compile(self.lst2)
        self.grid_entries(0, self.entries.values())
        self.grid_entries(1, self.entries2.values())

        # заполняем энтрисы дефолтными параметрами
        for val in enumerate(self.entries.values()):
            val[1].insert('end', self.lst11[val[0]])

    # собирает пару лэйбл_фрэйм: энтри и добавляет в упорядоченный словарь что бы можно было обращаться к ним за .гет()
    def entries_compile(self, lst):
        entries = odict()
        for i in lst:
            label_frame = tk.LabelFrame(self, text=i)
            entry = tk.Entry(label_frame)
            entry.pack(expand=True, fill='both')
            entries.update({i: entry})
        return entries

    # присваевает номера сетки энтрисам
    @staticmethod
    def grid_entries(row, _set):
        for column, entry in enumerate(_set):
            #print(entry.master['text']) это для тестов
            entry.master.grid(row=row, column=column, sticky='nswe')

    # меняет формат даты с дд.мм.гггг на гггг-мм-дд, который принимает mysql
    @staticmethod
    def convert_date(date):
        result = datetime.datetime.strptime(date, "%d.%m.%Y").date().strftime("%Y-%m-%d")
        return result

    def gui_parse(self):

        self.lbox.delete(0, 'end')
        entry1_host = self.entries['Host'].get()
        entry2_dbname = self.entries['DbName'].get()
        entry3_user = self.entries['User'].get()
        entry4_password = self.entries['Password'].get()
        _from = self.entries2['Slice from'].get()
        _to = self.entries2['Slice to'].get()
        if _from: _from = self.convert_date(_from)
        if _to: _to = self.convert_date(_to)
        if dbgrab.connect(entry1_host, entry2_dbname, entry3_user, entry4_password):
            table = [(i[0].strftime('%d.%m.%Y'),
                i[1].strftime('%d.%m.%Y'), i[2], i[3]) for i in dbgrab.do_the_thing(_from, _to)]
            for i in table: self.lbox.insert('end', i)
        else:
            try:
                dbgrab.con.close()
            except AttributeError:
                pass


gui = dataGrab()
gui.title('Задание 3')
gui.mainloop()
