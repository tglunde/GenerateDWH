{% import 'macros.sql' as default %}
{% for interface in interfaces.values() -%}
CREATE OR REPLACE VIEW SRC_{{ interface.source.name | replace(' ', '_')  }}_{{ interface.name | lower }} AS
select
    {% for column in interface.columns.values() -%}
	cast([{{column.name}}] AS {{ default.dbtype(column.typename, column.length, column.scale) -}}) AS {{ default.colname(column.name) }}{{"," if not loop.last}}
    {% endfor -%}
from (
    import from jdbc at {{interface.source.connection}} statement '
        SELECT * FROM {{default.catalog(interface.catalog)}}{{ interface.schema}}.{{ interface.name}} 
        {{default.nvl(interface.limit,'')}}
    ');

{% endfor -%}

COMMIT;
