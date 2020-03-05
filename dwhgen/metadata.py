import pandas as pd 
from jinja2 import Environment, FileSystemLoader, select_autoescape
from dwhgen.model import *
from dwhgen.db import * 
from sqlalchemy import create_engine


def metadata(templatepath=None):

    env = Environment(
        loader=FileSystemLoader(templatepath),
        autoescape=select_autoescape(['sql'])
    )

    engine = create_engine('sqlite:///metadata/metadata.db')
    with open('metadata/metadata.csv', 'r') as file:
        data_df = pd.read_csv(file)
    data_df.to_sql('source', con=engine, index=True, index_label='id', if_exists='replace')

    C = connect(database='metadata/metadata.db')
    cursor = C.cursor().execute('select source_system,source_conn,tabschema,tabname,colno,colname,typename,length,scale,remarks,tab_remarks, tab_catalog,limitierung from source order by 1,3,4,5')

    interfaces = {} 

    for row in cursor.fetchall():
        interface_bk = row[2] + '.' + row[3]
        if interface_bk in interfaces:
            interface = interfaces[interface_bk]
        else:
            interface = Interface(row[3], row[11], row[2], row[10], row[12], Source(row[0], row[1]), {})
            interfaces[interface_bk] = interface

        column = Column(row[5], row[4], row[6], row[7], row[8], row[9])
        interface.columns[column.no] = column

    lz_src_view = env.get_template('lz_src_view.sql')
    lz_src_view = lz_src_view.render(interfaces=interfaces)
    with open('target/lz_src_view.sql', 'w') as f:
        f.write(lz_src_view)

    lz_src_tbl = env.get_template('lz_src_tbl.sql')
    lz_src_tbl = lz_src_tbl.render(interfaces=interfaces)
    with open('target/lz_src_tbl.sql', 'w') as f:
        f.write(lz_src_tbl)
