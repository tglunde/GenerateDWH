{% import 'macros.sql' as default %}
{% for interface in interfaces.values() -%}
DROP TABLE IF EXISTS TGT_{{ interface.source.name | replace(' ', '_')  }}_{{ interface.name }};
SELECT * INTO TABLE TGT_{{ interface.source.name | replace(' ', '_')  }}_{{ interface.name }} FROM SRC_{{ interface.source.name | replace(' ', '_')  }}_{{ interface.name | lower }};

COMMENT ON TABLE TGT_{{ interface.source.name | replace(' ', '_')  }}_{{ interface.name }} IS '{{interface.remark}}';
{% for column in interface.columns.values() -%}
COMMENT ON COLUMN TGT_{{ interface.source.name | replace(' ', '_')  }}_{{ interface.name }}.{{column.name}} IS '{{column.remark}}';
{% endfor %}

{% endfor -%}

COMMIT;
