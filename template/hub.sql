{% for interface in cbc.interfaces.values() -%}
{{ "with" if loop.first }} {{ "src_" + interface.name | lower }} as (

    select {% for column in cbc.mappings[interface.name + "|" + cbc.bk.name].columns %} CONVERT(VARCHAR(255),{{ column.name | lower }}) {{ "||" if not loop.last }} {% endfor %} AS BK, ldts, rsrc from {% autoescape false %}{{ "{{ ref('" + interface.name + "') }}" | lower }}{% endautoescape %} 
    group by {% for column in cbc.mappings[interface.name + "|" + cbc.bk.name].columns %}{{ column.name | lower }}, {% endfor %} ldts, rsrc

),
{% endfor -%}
src_union as (

    {% for interface in cbc.interfaces.values() -%}
    select * from {{ "src_" + interface.name | lower }}
    {{ "union" if not loop.last }}
    {% endfor %}
),

ergebnis as (

    select 
        HASH_MD5(bk) as {{ cbc.name | lower }}_hk,
        min(ldts) as ldts,
        min(rsrc) as rsrc,
        bk as {{ cbc.bk.name }}
    from src_union        
    group by bk

)

select * from ergebnis;