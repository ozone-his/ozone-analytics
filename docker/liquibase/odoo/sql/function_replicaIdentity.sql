DROP FUNCTION IF EXISTS replicaIdentity(text[]);

CREATE OR REPLACE FUNCTION replicaIdentity(tables text[]) RETURNS void AS $$
DECLARE
    m text;
BEGIN
    FOREACH m IN ARRAY tables
    LOOP
        EXECUTE format($fmt$
            ALTER TABLE %I REPLICA IDENTITY FULL;
        $fmt$, m);
    END LOOP;
END;
$$ LANGUAGE plpgsql;