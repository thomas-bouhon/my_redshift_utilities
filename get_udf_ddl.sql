WITH arguments AS (
	SELECT
			oid,
			i,
			arg_name[i] AS argument_name,
			arg_types[i - 1] AS argument_type
		FROM (
			SELECT
					GENERATE_SERIES(1, arg_count) AS i,
					arg_name,
					arg_types,
					oid
				FROM (
					SELECT
							oid,
							proargnames AS arg_name,
							proargtypes AS arg_types,
							pronargs AS arg_count
						FROM pg_proc
						WHERE proowner != 1)))
SELECT
		schemaname,
		udfname,
		seq,
		TRIM(ddl) AS ddl
	FROM (
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				1000 AS seq,
				('CREATE OR REPLACE FUNCTION ' || QUOTE_IDENT(n.nspname) ||'.'|| QUOTE_IDENT(p.proname) || ' \(')::varchar(max) AS ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				2000 + NVL(i, 0) as seq,
				CASE
						WHEN i = 1
							THEN NVL(argument_name, '') || ' ' || FORMAT_TYPE(argument_type, NULL)
						ELSE ',' || NVL(argument_name,'') || ' ' || FORMAT_TYPE(argument_type, NULL)
					END AS ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			LEFT JOIN arguments AS a
				ON a.oid = p.oid
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				3000 AS seq,
				'\)' AS ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				4000 AS seq,
				'  RETURNS ' || pg_catalog.FORMAT_TYPE(p.prorettype, NULL) AS ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				5000 AS seq,
				CASE 
						WHEN p.provolatile = 'v'
							THEN 'VOLATILE'
						WHEN p.provolatile = 's'
							THEN 'STABLE' 
						WHEN p.provolatile = 'i'
							THEN 'IMMUTABLE' 
						ELSE '' 
					END AS ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				6000 AS seq,
				'AS $$' as ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n 
				ON n.oid = p.pronamespace
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				7000 AS seq,
				p.prosrc AS DDL
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			WHERE p.proowner != 1
		UNION ALL
		SELECT
				n.nspname AS schemaname,
				p.proname AS udfname,
				p.oid AS udfoid,
				8000 as seq,
				'$$ LANGUAGE ' + lang.lanname + ';' AS ddl
			FROM pg_proc AS p
			LEFT JOIN pg_namespace AS n
				ON n.oid = p.pronamespace
			LEFT JOIN (
				select 
						oid,
						lanname 
					FROM pg_language) AS lang 
				ON p.prolang = lang.oid
			WHERE p.proowner != 1)
	ORDER BY udfoid,seq;
