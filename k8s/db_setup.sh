#! /bin/sh
psql -tc "SELECT 1 FROM pg_database WHERE datname = 'comments'" |\
    grep -q 1 ||\
    psql -tc "CREATE DATABASE comments"
psql -tc "SELECT 1 from pg_roles WHERE rolname = 'comments'" |\
    grep -q 1 ||\
    {
        psql -tc "CREATE USER comments WITH ENCRYPTED PASSWORD '${COMMENTS_PW}'"
        psql -tc "GRANT ALL on DATABASE comments TO comments"
    }

