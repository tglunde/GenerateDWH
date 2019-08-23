{% for interface in nbr.interfaces.values() -%}
{{ "with" if loop.first }} {{ "src_" + interface.name | lower }} as (

    select 
    {%for cbc in nbr.cbcs -%}
    {% for column in cbc.mappings[interface.name + "|" + cbc.bk.name].columns %} 
        CONVERT(VARCHAR(255),{{ column.name | lower }}) {{ "||" if not loop.last }} {% endfor %} AS BK_{{cbc.name}}{{ "," if not loop.last }}
    {% endfor -%}
    from {% autoescape false %}{{ "{{ ref('" + interface.name + "') }}" | lower }}{% endautoescape %} 

),
{% endfor -%}
src_union as (

    {% for interface in nbr.interfaces.values() -%}
    select * from {{ "src_" + interface.name | lower }}
    {{ "union" if not loop.last }}
    {% endfor %}
),

ergebnis as (

    select
    {%for cbc in nbr.cbcs -%}
        HASH_MD5(BK_{{cbc.name}}) AS {{ cbc.name | lower }}_hk{{ "," if not loop.last }}
    {% endfor %}
    from src_union        

)

select * from ergebnis;