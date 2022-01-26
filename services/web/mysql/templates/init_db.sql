CREATE DATABASE IF NOT EXISTS `analytics-micro-marker`;
CREATE USER IF NOT EXISTS 'analytics-micro-util'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.UTILITY_USER_PASSWORD }}';
GRANT ALL ON `analytics-micro-marker`.* TO 'analytics-micro-util'@'%';

CREATE USER IF NOT EXISTS '{{ .Env.READ_ONLY_USER }}'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.READ_ONLY_PASSWORD }}';
GRANT SELECT ON *.* TO '{{ .Env.READ_ONLY_USER }}'@'%';

CREATE USER IF NOT EXISTS '{{ .Env.DB_MIGRATION_USER }}'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.DB_MIGRATION_PASS }}';
GRANT ALL ON `analytics-api`.* TO '{{ .Env.DB_MIGRATION_USER }}'@'%';
GRANT ALL ON `reports`.* TO '{{ .Env.DB_MIGRATION_USER }}'@'%';
GRANT ALL ON `dashboard`.* TO '{{ .Env.DB_MIGRATION_USER }}'@'%';

CREATE USER IF NOT EXISTS 'api001'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.MYSQL_API001_PASSWORD }}';
GRANT ALL ON `analytics-api`.* TO 'api001'@'%';
GRANT SELECT ON `reports`.* TO 'api001'@'%';

CREATE USER IF NOT EXISTS 'reports001'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.MYSQL_REPORTS001_PASSWORD }}';
GRANT SELECT ON `reports`.* TO 'reports001'@'%';

CREATE USER IF NOT EXISTS 'dashboard001'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.MYSQL_DASHBOARD001_PASSWORD }}';
GRANT ALL ON `dashboard`.* TO 'dashboard001'@'%';

CREATE DATABASE IF NOT EXISTS `edx_hive_metastore`;
CREATE USER IF NOT EXISTS '{{ .Env.HIVE_METASTORE_DATABASE_USER }}'@'%' IDENTIFIED WITH mysql_native_password BY '{{ .Env.HIVE_MATASTORE_DATABASE_PASSWORD }}';
GRANT ALL ON `edx_hive_metastore`.* TO '{{ .Env.HIVE_METASTORE_DATABASE_USER }}'@'%';

USE `analytics-micro-marker`;
CREATE TABLE IF NOT EXISTS marker(
    `id` VARCHAR(20) NOT NULL,
    `done` BOOLEAN NOT NULL,
    PRIMARY KEY ( `id` )
);
