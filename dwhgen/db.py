from pyexasol import ExaStatement, ExaConnection
import sqlite3
from sqlite3 import Error, Connection


def connect(**kwargs):
    return Connection(**kwargs)


class DB2Connection(ExaConnection):
    def cursor(self):
        return ExasolCursor(self)


class ExasolCursor(object):
    arraysize = 1

    def __init__(self, connection):
        self.connection = connection
        self.stmt = None

    def execute(self, query):
        self.stmt = self.connection.execute(query)
        return self

    def executemany(self, query):
        raise RuntimeError

    def fetchone(self):
        return self.stmt.fetchone()

    def fetchmany(self, size=None):
        if size is None:
            size = self.arraysize

        return self.stmt.fetchmany(size)

    def fetchall(self):
        return self.stmt.fetchall()

    def nextset(self):
        raise RuntimeError

    def setinputsizes(self):
        pass

    def setoutputsize(self):
        pass

    @property
    def description(self):
        cols = []
        if 'resultSet' != self.stmt.result_type:
            return None

        for k, v in self.stmt.columns().items():
            cols.append((
                k,
                v.get('type', None),
                v.get('size', None),
                v.get('size', None),
                v.get('precision', None),
                v.get('scale', None),
                True
            ))

        return cols

    @property
    def rowcount(self):
        return self.stmt.rowcount()

    def close(self):
        self.stmt.close()
