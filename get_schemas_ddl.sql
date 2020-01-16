SELECT
		QUOTE_IDENT(nspname) AS schemaname,
		'CREATE SCHEMA IF NOT EXISTS '|| QUOTE_IDENT(nspname) || ';' AS ddl
	FROM pg_namespace
	WHERE nspowner > 1;
