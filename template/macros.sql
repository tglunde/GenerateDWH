{% macro dbtype(typename, length, scale) %}
{%- if typename in ['VARCHAR','CHAR','VARCHAR2'] -%}
    {{typename}}({{length|int}})
{%- elif typename in ['DATETIME2','DATETIME'] -%}
    TIMESTAMP
{%- elif typename in ['UNIQUEIDENTIFIER'] -%}
    CHAR(255)
{%- elif typename in ['TIME'] -%}
    VARCHAR(50)
{%- elif typename in ['BIT'] -%}
    BOOLEAN
{%- elif typename in ['DECIMAL'] -%}
    {{typename}}({{length|int}},{{scale|int}})
{%- else -%}
    {{typename}}
{%- endif -%}
{% endmacro %}

{% macro catalog(catalog) %}
{%- if catalog -%}{{catalog}}.{%- else -%}{%- endif -%}
{% endmacro %}

{% macro colname(colname) %}
{%- if colname in ['ORDER','SYSTEM'] -%}
    [{{colname}}]
{%- else -%}
    {{colname}}
{%- endif -%}
{% endmacro %}

{% macro nvl(checkvalue,altvalue) %}
{%- if checkvalue -%}
    {% autoescape false %}{{checkvalue}}{% endautoescape %}
{%- else -%}
    {{altvalue}}
{%- endif -%}
{% endmacro %}
