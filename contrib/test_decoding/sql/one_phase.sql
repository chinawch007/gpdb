-- We added special flags to the commit log of one-phase transactions 
-- so we can detect such transactions during logical decoding.
-- First execute an one-phase transaction, 
-- then get the decoded content of the transaction log on the segment, 
-- and check the flag of the one-phase.
CREATE TABLE test_table(id int PRIMARY KEY);
-- Use the 'pg_logical_slot_get_changes' command to get the decoded log content on one segment.
-- Normally pg_logical_slot_get_changes will return 'BEGIN xid'.
-- For one-phase transactions, a flag is added, returning 'ONE-PHASE,BEGIN xid'.
-- The specific implementation code is in the 'pg_output_begin' function of test_decoding.c.
CREATE OR REPLACE FUNCTION get_change() RETURNS text AS $$
DECLARE
  buf text;
  get_change_result text;
BEGIN
  SELECT data FROM pg_logical_slot_get_changes('regression_slot_p', NULL, NULL) INTO buf;
  IF buf <> '' THEN -- Only one segment will generate logs.
    SELECT * FROM SPLIT_PART(buf, ',', 1) INTO get_change_result;
  END IF;
  RETURN get_change_result;
END;
$$ language plpgsql;

-- Start test
-- start_ignore
SELECT pg_create_logical_replication_slot('regression_slot_p', 'test_decoding') UNION ALL
SELECT pg_create_logical_replication_slot('regression_slot_p', 'test_decoding') from gp_dist_random('gp_id');
-- end_ignore
INSERT INTO test_table VALUES(700);
SELECT get_change() FROM gp_dist_random('gp_id');

-- Clean
-- start_ignore
SELECT pg_drop_replication_slot('regression_slot_p') UNION ALL 
SELECT pg_drop_replication_slot('regression_slot_p') FROM gp_dist_random('gp_id');
DROP TABLE test_table;
-- end_ignore