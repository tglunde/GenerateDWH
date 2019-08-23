drop view if exists mapping_v;
CREATE VIEW mapping_v AS
WITH mappings AS (
	SELECT * FROM mapping
), attributes AS (
	SELECT
	    name, typ, REPLACE(pfad, 'BI Modell::Geschäftsobjektmodell::Geschäftsobjekte::', '') AS entity
	FROM
    	mappings
	WHERE
    	typ IN ('Entitätsattribut','Business Key')
), cbc AS (
	SELECT name FROM mappings WHERE typ = 'Geschäftsobjekt'
), nbr AS (
	SELECT name FROM mappings WHERE typ = 'Ereignis'
), maps AS (
	SELECT
    	to_entity,
    	attributes.name AS to_attr,
    	attributes.typ AS to_typ,
    	from_if,
    	from_col
	FROM
    (
		SELECT
		    SUBSTR(mapof, 1, INSTR(mapof, '::')-1) AS from_if,
		    SUBSTR(mapof, INSTR(mapof, '::')+ 2) AS from_col,
		    SUBSTR(mapto, 1, INSTR(mapto, '::')-1) AS to_entity,
		    SUBSTR(mapto, INSTR(mapto, '::')+ 2) AS to_attr
		FROM
		(
			SELECT
			    SUBSTR(mapfrom, 1, INSTR(mapfrom, '@')-1) AS mapof,
			    mapto
			FROM
			(
				SELECT
				    REPLACE(name, 'conceptionalCopy@', '') AS mapfrom,
				    REPLACE(pfad, 'BI Modell::Geschäftsobjektmodell::Geschäftsobjekte::', '') AS mapto
				FROM
				    mappings
				WHERE
				    typ = '<<conceptionalCopy>> Abhängigkeit'
			)
		)
	)
	JOIN ATTRIBUTES ON
    	attributes.entity = to_entity AND attributes.name = to_attr
)
SELECT
    'cbc' AS entity_typ, maps.*
FROM
    cbc JOIN maps ON cbc.name = maps.to_entity
UNION
SELECT
    'nbr' AS entity_typ, maps.*
FROM
    nbr JOIN maps ON nbr.name = maps.to_entity
;

CREATE VIEW nbr_cbc_map_v AS
WITH mappings AS (

	SELECT * FROM mapping

), rels AS (
	SELECT
	    SUBSTR(name, INSTR(name, '_')+ 1) AS nbr,
	    SUBSTR(name, 1, INSTR(name, '_')-1) AS cbc
	FROM
	    mappings
	WHERE
	    typ = 'Entitätsbeziehung'
)

SELECT * FROM rels;

CREATE VIEW SRC AS
WITH tbl AS (
SELECT
    VIEW_SCHEMA AS TBL_SCHEMA,
    VIEW_NAME AS TBL_NAME,
    VIEW_COMMENT AS TBL_COMMENT
FROM
    sys.EXA_ALL_VIEWS
WHERE
    VIEW_SCHEMA = 'DWH_PUBLIC'
UNION
SELECT
TABLE_SCHEMA AS TBL_SCHEMA,
TABLE_NAME AS TBL_NAME,
TABLE_COMMENT AS TBL_COMMENT
FROM
sys.EXA_ALL_TABLES
WHERE
TABLE_SCHEMA = 'DWH_PUBLIC'

),

col AS (
SELECT
    COLUMN_SCHEMA AS COL_SCHEMA,
    COLUMN_TABLE AS COL_TABLE,
    COLUMN_NAME AS COL_NAME,
    COLUMN_TYPE AS COL_TYPE,
    COLUMN_ORDINAL_POSITION AS COL_POS,
    COLUMN_COMMENT AS COL_COMMENT
FROM
sys.EXA_ALL_COLUMNS
WHERE
column_schema = 'DWH_PUBLIC' ),

src AS (
SELECT
    col.*,
    tbl.tbl_comment
FROM
    col
JOIN tbl ON
    col.col_table = tbl.tbl_name
    AND col.col_schema = tbl.tbl_schema
ORDER BY
tbl.tbl_schema,
tbl.tbl_name,
col.col_pos

)

SELECT * FROM src;

CREATE VIEW VAULT AS
WITH vault AS (
SELECT
    *
FROM
    sys.exa_user_views
WHERE
    view_schema LIKE '%CORE'
    AND SUBSTR(view_name, len(view_name), 1) IN ('L',
    'H',
    'S')

),

objects AS (
SELECT
    SUBSTR(view_name, 1, INSTR(view_name, '_')-1) AS cbc,
    SUBSTR(view_name,-1) AS Vault_Type ,
    view_schema,
    view_name
FROM
    vault
WHERE
SUBSTR(view_name, 1, INSTR(view_name, '_') -1) IN (
    SELECT DISTINCT UPPER(cbc) AS cbc
FROM
    NBR_CBC_MAP_V)

),

object_bk AS (
SELECT
    cbc,
    vault_type,
    view_schema,
    view_name,
    col.column_name AS bk
FROM
    objects
LEFT JOIN sys.exa_user_columns col ON
    col.column_table = view_name
    AND col.column_name NOT IN ('LDTS',
    'RSRC')
    AND col.column_schema LIKE '%CORE'

)

SELECT
    *
FROM
    object_bk
ORDER BY
    cbc,
    vault_type
;