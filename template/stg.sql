with src as (

    select * from {% autoescape false %}{{ "{{ source('" + interface.source.rsrc + "', '"+ interface.relation_name + "') }}" | lower }}{% endautoescape %} 

),

stg as (

    select distinct
        {{ interface.ldts_name }} AS LDTS,
        '{{ interface.source.short }}' AS RSRC,
        versicherter.VORNAME
    FROM stg

)

select * from stg;