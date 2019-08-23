from jinja2 import Environment, FileSystemLoader, select_autoescape
from dwhgen.model import *
from dwhgen.db import *


def supernova(dsn=None, user=None, password=None, outputpath=None, templatepath=None):
    env = Environment(
        loader=FileSystemLoader(templatepath),
        autoescape=select_autoescape(['sql'])
    )

    C = connect(database='metadata/metadata.db')
    cursor = C.cursor().execute('select * from VAULT')

    hubs = {}
    links = {}
    sats = {}

    for row in cursor.fetchall():
        hub_name = row[0]
        v_type = row[1]
        tab_name = row[3]
        col = Column(row[4], None)
        if hub_name not in hubs:
            hubs[hub_name] = Hub(hub_name, None, None, None, list(), list())
        hub = hubs[hub_name]

        if v_type == 'H':
            hub.tabname = tab_name
            if col.name.endswith('HK'):
                hub.hk = col
            else:
                hub.bk = col
        if v_type == 'L':
            if tab_name not in links:
                links[tab_name] = Link(tab_name, list())
            links[tab_name].hks.append(col)
            hub.links.append(links[tab_name])
        if v_type == 'S':
            if tab_name not in sats:
                sats[tab_name] = Satellit(tab_name, None, list())
                hub.sats.append(sats[tab_name])
            if col.name.endswith('HK'):
                sats[tab_name].hk = col
                hub.hk = col
            else:
                sats[tab_name].cols.append(col)

    hubVersionTemplate = env.get_template('hub_version.sql')
    for hub in list(hubs.values()):
        hubVersion = hubVersionTemplate.render(hub=hub)
        with open(outputpath + '/' + hub.name.upper() + '_VERSION.sql', 'w') as f:
            f.write(hubVersion)

    hubSNTemplate = env.get_template('hub_sn.sql')
    for hub in list(hubs.values()):
        hubSN = hubSNTemplate.render(hub=hub)
        with open(outputpath + '/' + hub.name.upper() + '.sql', 'w') as f:
            f.write(hubSN)
