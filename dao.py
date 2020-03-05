from sqlalchemy import Table, MetaData, Column, Integer, String, MetaData, Numeric
from sqlalchemy.orm import mapper
from dwhgen.model import Source, Interface

metadata = MetaData()

interface = Table('interface', metadata, 
        Column('id'),
        Column('name')
    )

mapper(Interface, interface)
