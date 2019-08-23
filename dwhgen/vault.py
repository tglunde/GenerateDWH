from jinja2 import Environment, FileSystemLoader, select_autoescape
from pprint import pprint
import pyexasol
import os
import shutil
from typing import Optional, Set, List, Dict
from dwhgen.model import *
from dwhgen.db import *


def vault(dsn=None, user=None, password=None, outputpath=None, templatepath=None):

    env = Environment(
        loader=FileSystemLoader(templatepath),
        autoescape=select_autoescape(['sql'])
    )

    C = connect(database='metadata/metadata.db')
    cursor = C.cursor().execute('select * from mapping_v order by 1,2,4,5,6')

    cbcs = {}
    nbrs = {}
    ifcs = {}
    cbc = None
    nbr = None
    ifc = None

    for row in cursor.fetchall():
        entity_typ = row[0]
        to_entity = row[1]
        to_attr = row[2]
        to_typ = row[3]
        from_if = row[4]
        from_col = row[5]
        if from_if in ifcs.keys():
            ifc = ifcs[from_if]
        else:
            ifc = Interface(from_if)
            ifcs[from_if] = ifc

        col = Column(from_col, None)
        col.interface = ifc
        attribute = Attribute(to_attr, False, None)
        mapKey = ifc.name + "|" + attribute.name
        if entity_typ == 'cbc':
            if to_entity in cbcs:
                cbc = cbcs[to_entity]
            else:
                cbc = CBC(to_entity, dict(), dict(), dict(), dict(), set())
                cbcs[to_entity] = cbc
            if 'Business Key' == to_typ:
                attribute.iskey = True
                cbc.bk = attribute
            else:
                cbc.attributes[attribute.name] = attribute
                cbc.attrInterfaces.add(ifc)

            cbc.interfaces[ifc.name] = ifc

            if mapKey in cbc.mappings:
                cbc.mappings[mapKey].columns.add(col)
            else:
                mapping = AttributeMap(attribute, set())
                mapping.columns.add(col)
                cbc.mappings[mapKey] = mapping

        elif entity_typ == 'nbr':
            if to_entity in nbrs:
                nbr = nbrs[to_entity]
            else:
                nbr = NBR(to_entity, list(), dict(), dict(), dict())
                nbrs[to_entity] = nbr
            nbr.attributes[attribute.name] = attribute
            if mapKey in nbr.mappings:
                cbc.mappings[mapKey].columns.add(col)
            else:
                mapping = AttributeMap(attribute, set())
                mapping.columns.add(col)
                nbr.mappings[mapKey] = mapping
            nbr.interfaces[ifc.name] = ifc

        else:
            raise

    cursor = C.cursor().execute('select * from nbr_cbc_map_v order by 1,2')
    for row in cursor.fetchall():
        if row[0] in nbrs:
            nbr = nbrs[row[0]]
        else:
            nbr = NBR(row[0], list(), set(), set(), dict())
            nbrs[row[0]] = nbr
        cbc = cbcs[row[1]]
        nbr.cbcs.append(cbc)

    hubTemplate = env.get_template('hub.sql')
    satTemplate = env.get_template('sat.sql')
    linkTemplate = env.get_template('link.sql')
    for cbc in list(cbcs.values()):
        hub = hubTemplate.render(cbc=cbc)
        with open(outputpath + cbc.name.lower() + '_h.sql', 'w') as f:
            f.write(hub)

        for interface in cbc.attrInterfaces:
            sat = satTemplate.render(cbc=cbc, interface=interface)
            with open(outputpath + cbc.name.lower() + "_" + interface.name.lower() + '_s.sql', 'w') as f:
                f.write(sat)

    for nbr in list(nbrs.values()):
        names = nbr.name.split("_")
        first_name = names[0]
        ki = None
        for cbc in nbr.cbcs:
            if cbc.name not in names:
                ki = cbc.name
        if ki == None:
            ki = first_name
        cbc = CBC(ki, dict(), dict(), dict(), dict(), set())
        cbcKI = cbcs[ki]
        cbc.bk = cbcKI.bk
        interface = list(nbr.interfaces.values())[0]
        attributeMap = cbcKI.mappings[interface.name + "|" + cbc.bk.name]

        cbc.mappings[interface.name + "|" + cbc.bk.name] = attributeMap
        for attrMap in list(nbr.mappings.values()):
            cbc.mappings[interface.name + "|" +
                         attrMap.attribute.name] = attrMap
        cbc.attributes = nbr.attributes
        sat = satTemplate.render(cbc=cbc, interface=interface)
        with open(outputpath + '/' + cbc.name.lower() + "_" + interface.name.lower() + '_s.sql', 'w') as f:
            f.write(sat)

        link = linkTemplate.render(nbr=nbr)
        with open(outputpath + '/' + nbr.name.lower() + '_l.sql', 'w') as f:
            f.write(link)
