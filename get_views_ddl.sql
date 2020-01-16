SELECT
		n.nspname || '.' || c.relname AS viewname,
		'CREATE OR REPLACE VIEW ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' AS ' + COALESCE(pg_get_viewdef(c.oid), '') AS ddl
	FROM pg_catalog.pg_class AS c
	INNER JOIN pg_catalog.pg_namespace AS n
		ON c.relnamespace = n.oid
	WHERE relkind = 'v'
		AND relowner > 1;
