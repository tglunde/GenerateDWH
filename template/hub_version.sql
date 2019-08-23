with hub as (
	
	select {{hub.hk.name}} as hk, ldts, {{hub.bk.name}} as bk from {% autoescape false %}{{ "{{ ref('" + hub.tabname | lower + "') }}" }}{% endautoescape %}
{% for sat in hub.sats %}
), {{ sat.name | lower }} as (

	select {{ sat.hk.name }} as HK,ldts from {% autoescape false %}{{ "{{ ref('" + sat.name | lower + "') }}" }}{% endautoescape %}

), 
{% endfor -%}

satellites as (

{% for sat in hub.sats %}
	select * from {{ sat.name | lower }} 
	{{ "union" if not loop.last }}
{% endfor -%}

), startdates (hk, ldts, bk) as (

	select distinct
		hub.hk,
		CASE WHEN s.ldts IS NULL THEN CAST('0001-01-01' as TIMESTAMP) ELSE s.ldts END AS LDTS, 
		hub.bk
	from hub left join (
		select *
		from satellites
	) s on hub.hk=s.hk

), results (hk, bk, ldts, ledts, active_flag) as (

	select 
		hk,
		bk,
		ldts,
		case when lead(ldts) over(partition by bk order by ldts) is null 
			then CAST('9999-12-31' as TIMESTAMP) 
			else lead(ldts) over(partition by bk order by ldts) END AS ledts,
		case when lead(ldts) over(partition by bk order by ldts) is null 
			then 'Y' 
			else 'N' END AS active_flag
	from startdates
)
select * from results;