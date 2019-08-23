from dataclasses import dataclass
from typing import Optional, Set, List, Dict


@dataclass(unsafe_hash=True, eq=True)
class Interface:
    name: str


@dataclass(unsafe_hash=True, eq=True)
class Column:
    name: str
    type: Optional[str]


@dataclass(unsafe_hash=True, eq=True)
class Attribute:
    name: str
    iskey: bool
    type: Optional[str]


@dataclass(unsafe_hash=True, eq=True)
class AttributeMap:
    attribute: Attribute
    columns: Optional[Set[Column]]


@dataclass(unsafe_hash=True, eq=True)
class CBC(object):
    """ Core Business Concept - business objects for the target model as defined by the business"""
    name: str
    bk: Attribute
    attributes: Optional[Dict[str, Attribute]]
    interfaces: Optional[Dict[str, Interface]]
    mappings: Optional[Dict[str, AttributeMap]]
    attrInterfaces: Optional[Set[Interface]]


@dataclass(unsafe_hash=True, eq=True)
class NBR(object):
    name: str
    cbcs: Optional[List[CBC]]
    attributes: Optional[Dict[str, Attribute]]
    interfaces: Optional[Dict[str, Interface]]
    mappings: Optional[Dict[str, AttributeMap]]


@dataclass
class Satellit:
    name: str
    hk: Column
    cols: List[Column]


@dataclass
class Link:
    name: str
    hks: List[Column]


@dataclass
class Hub:
    name: str
    tabname: str
    hk: Column
    bk: Column
    sats: List[Satellit]
    links: List[Link]
