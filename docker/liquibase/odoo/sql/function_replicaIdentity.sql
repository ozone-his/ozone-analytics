DROP FUNCTION IF EXISTS replicaIdentity;

GO

CREATE FUNCTION replicaIdentity(tables text []) RETURNS void AS $$
    DECLARE m   text;
    BEGIN
        FOREACH m IN ARRAY tables
        LOOP
                EXECUTE format($fmt$
                    ALTER TABLE %I REPLICA IDENTITY FULL;
                $fmt$, m);
        END LOOP;
    END;
$$ LANGUAGE plpgsql;

GO