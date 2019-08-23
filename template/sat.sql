with sat as (

    select 
        {% for column in cbc.mappings[interface.name + "|" + cbc.bk.name].columns -%}
        CONVERT(VARCHAR(255),{{ column.name | lower }}) {{ "||" if not loop.last }} {% endfor %} AS BK_CONCAT, 
        {% for column in cbc.mappings[interface.name + "|" + cbc.bk.name].columns -%}
        {{ column.name | lower }} AS {{ cbc.bk.name | lower }}_{{ column.name | lower }}, {% endfor %}
        ldts, rsrc ,
        {% for attribute in cbc.attributes.values() -%}
        {%- if interface.name + "|" + attribute.name in cbc.mappings -%}
            {% for column in cbc.mappings[interface.name + "|" + attribute.name].columns -%}
                {{column.name}} {{ "||" if not loop.last }} {% endfor -%} AS {{attribute.name}}{%endif-%}{{ "," if not loop.last }}
        {% endfor %}
    from {% autoescape false %}{{ "{{ ref('" + interface.name + "') }}" | lower }}{% endautoescape %}

), ergebnis as (

    select hash_md5(bk_concat) as {{ cbc.name | lower }}_hk, sat.* from sat

)

select * from ergebnis;