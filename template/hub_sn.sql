with hub_version as (

    select hk, ldts, ledts, active_flag from {% autoescape false %}{{ "{{ ref('" + hub.name | upper + "_VERSION') }}" }}{% endautoescape %}

),

ergebnis as (

    select hub_version.hk, hub_version.ldts, hub_version.ledts, hub_version.active_flag, 
    {% for sat in hub.sats -%}
    {% for col in sat.cols -%}
        {% autoescape false %}{{ "{{ ref('" + sat.name | lower + "') }}" }}{% endautoescape %}.{{ col.name }}{{ "," if not loop.last }}
    {% endfor -%}
    {{ "," if not loop.last }}
    {% endfor -%}
    from 
        hub_version
        {% for sat in hub.sats -%}
        left join {% autoescape false %}{{ "{{ ref('" + sat.name | lower + "') }}" }}{% endautoescape %} on hub_version.hk={{hub.name}}_hk
            AND hub_version.ledts >= {% autoescape false %}{{ "{{ ref('" + sat.name | lower + "') }}" }}{% endautoescape %}.ldts
        {% endfor %}

)

select * from ergebnis;