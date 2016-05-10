--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

-- ===============================================================
-- WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
--
-- DO NOT MANUALLY RUN THIS DATABASE MIGRATION. IT WILL BE EXECUTED
-- AUTOMATICALLY (IF NEEDED) BY "FLYWAY" WHEN YOU STARTUP DSPACE.
-- http://flywaydb.org/
-- ===============================================================

------------------------------------------------------
-- 
-- Este script es utilizado para modificar el esquema base de Dspace 5.x
-- Son cambios propios de CIC-DIGITAL
-- 
------------------------------------------------------

ALTER TABLE MetadataValue ALTER COLUMN authority TYPE VARCHAR(255);