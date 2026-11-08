-- Runs once, on the first boot of an empty data directory, via the image entrypoint.
-- Values come from the container environment (set in compose.yml from the root .env).
\getenv gitea_db   GITEA_DB_NAME
\getenv gitea_user GITEA_DB_USER
\getenv gitea_pw   GITEA_DB_PASSWORD
\getenv sonar_db   SONAR_DB_NAME
\getenv sonar_user SONAR_DB_USER
\getenv sonar_pw   SONAR_DB_PASSWORD

-- Gitea database and user
CREATE USER :"gitea_user" WITH PASSWORD :'gitea_pw';
CREATE DATABASE :"gitea_db" OWNER :"gitea_user";

-- SonarQube database and user
CREATE USER :"sonar_user" WITH PASSWORD :'sonar_pw';
CREATE DATABASE :"sonar_db" OWNER :"sonar_user";

-- Recommended PostgreSQL settings for SonarQube
ALTER ROLE :"sonar_user" SET client_encoding TO 'utf8';
ALTER ROLE :"sonar_user" SET default_transaction_isolation TO 'read committed';
ALTER ROLE :"sonar_user" SET timezone TO 'UTC';
