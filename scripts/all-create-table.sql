-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/fhir_etl_schema.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fhir_etl; Type: SCHEMA; Schema: -; Owner: sec
--

DROP SCHEMA IF EXISTS fhir_etl CASCADE;
CREATE SCHEMA fhir_etl;


ALTER SCHEMA fhir_etl OWNER TO sec;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: condition; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.condition (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    name text NOT NULL,
    condition_date timestamp without time zone,
    code character varying(256),
    code_scheme character varying(256),
    clinical_status text,
    cancer_related boolean
);


ALTER TABLE fhir_etl.condition OWNER TO sec;

--
-- Name: condition_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.condition_id_seq ;
create sequence fhir_etl.condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.condition_id_seq OWNER TO sec;

--
-- Name: condition_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.condition_id_seq OWNED BY fhir_etl.condition.id;


--
-- Name: observation; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.observation (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    observation_date timestamp without time zone,
    category character varying(256),
    code character varying(256),
    code_scheme character varying(256),
    display text,
    value character varying(256),
    unit character varying(64),
    cancer_related boolean
);


ALTER TABLE fhir_etl.observation OWNER TO sec;

--
-- Name: observation_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.observation_id_seq ;
create sequence fhir_etl.observation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.observation_id_seq OWNER TO sec;

--
-- Name: observation_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.observation_id_seq OWNED BY fhir_etl.observation.id;


--
-- Name: patient; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.patient (
    id integer NOT NULL,
    fhir_id character varying(64) NOT NULL,
    name character varying(256) NOT NULL,
    gender character(1),
    dob timestamp without time zone,
    marital_status character(1),
    race character varying(256),
    ethnicity character varying(256)
);


ALTER TABLE fhir_etl.patient OWNER TO sec;

--
-- Name: patient_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.patient_id_seq ;
create sequence fhir_etl.patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.patient_id_seq OWNER TO sec;

--
-- Name: patient_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.patient_id_seq OWNED BY fhir_etl.patient.id;


--
-- Name: procedure; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.procedure (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    procedure_date timestamp without time zone,
    code character varying(256),
    code_scheme character varying(256),
    display text,
    cancer_related boolean
);


ALTER TABLE fhir_etl.procedure OWNER TO sec;

--
-- Name: procedure_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.procedure_id_seq ;
create sequence fhir_etl.procedure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.procedure_id_seq OWNER TO sec;

--
-- Name: procedure_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.procedure_id_seq OWNED BY fhir_etl.procedure.id;


--
-- Name: condition id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.condition ALTER COLUMN id SET DEFAULT nextval('fhir_etl.condition_id_seq'::regclass);


--
-- Name: observation id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.observation ALTER COLUMN id SET DEFAULT nextval('fhir_etl.observation_id_seq'::regclass);


--
-- Name: patient id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.patient ALTER COLUMN id SET DEFAULT nextval('fhir_etl.patient_id_seq'::regclass);


--
-- Name: procedure id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.procedure ALTER COLUMN id SET DEFAULT nextval('fhir_etl.procedure_id_seq'::regclass);


--
-- Name: condition condition_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.condition
    ADD CONSTRAINT condition_pkey PRIMARY KEY (id);


--
-- Name: observation observation_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.observation
    ADD CONSTRAINT observation_pkey PRIMARY KEY (id);


--
-- Name: patient patient_fhir_id_key; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.patient
    ADD CONSTRAINT patient_fhir_id_key UNIQUE (fhir_id);


--
-- Name: patient patient_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.patient
    ADD CONSTRAINT patient_pkey PRIMARY KEY (id);


--
-- Name: procedure procedure_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.procedure
    ADD CONSTRAINT procedure_pkey PRIMARY KEY (id);


--
-- Name: condition_date_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX condition_date_idx ON fhir_etl.condition USING btree (condition_date);


--
-- Name: condition_patient_id_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX condition_patient_id_idx ON fhir_etl.condition USING btree (patient_id);


--
-- Name: observation_date_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX observation_date_idx ON fhir_etl.observation USING btree (observation_date);


--
-- Name: observation_patient_id_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX observation_patient_id_idx ON fhir_etl.observation USING btree (patient_id);


--
-- Name: procedure_date_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX procedure_date_idx ON fhir_etl.procedure USING btree (procedure_date);


--
-- Name: procedure_patient_id_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX procedure_patient_id_idx ON fhir_etl.procedure USING btree (patient_id);


--
-- Name: condition condition_patient_fk; Type: FK CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.condition
    ADD CONSTRAINT condition_patient_fk FOREIGN KEY (patient_id) REFERENCES fhir_etl.patient(id) ON DELETE CASCADE;


--
-- Name: observation observation_patient_fk; Type: FK CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.observation
    ADD CONSTRAINT observation_patient_fk FOREIGN KEY (patient_id) REFERENCES fhir_etl.patient(id) ON DELETE CASCADE;


--
-- Name: procedure procedure_patient_fk; Type: FK CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.procedure
    ADD CONSTRAINT procedure_patient_fk FOREIGN KEY (patient_id) REFERENCES fhir_etl.patient(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/umls_schema.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: umls; Type: SCHEMA; Schema: -; Owner: sec
--

DROP SCHEMA IF EXISTS umls CASCADE;
CREATE SCHEMA umls;


ALTER SCHEMA umls OWNER TO sec;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comp_parents; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.comp_parents (
    parent text,
    concept text,
    level integer,
    path text
);


ALTER TABLE umls.comp_parents OWNER TO sec;

--
-- Name: curated_crosswalk; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.curated_crosswalk (
    index bigint,
    identifier bigint,
    code_system text,
    disease_code text,
    preferred_name text,
    evs_nci_code text,
    corrected_preferred_name_for_icd9 text,
    date_last_created text,
    date_last_updated text,
    site_code text,
    site_name text,
    disease_code_site_code text,
    evs_preferred_name text,
    comments text
);


ALTER TABLE umls.curated_crosswalk OWNER TO sec;

--
-- Name: mrcols; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrcols (
    col text,
    des text,
    ref double precision,
    min bigint,
    av double precision,
    max bigint,
    fil text,
    dty text
);


ALTER TABLE umls.mrcols OWNER TO sec;

--
-- Name: mrconso; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrconso (
    cui character(8),
    lat character(3),
    ts character(1),
    lui character varying(10),
    stt character varying(3),
    sui character varying(10),
    ispref character(1),
    aui character varying(9),
    saui character varying(100),
    scui character varying(100),
    sdui character varying(100),
    sab character varying(40),
    tty character varying(20),
    code character varying(100),
    str character varying(3000),
    srl integer,
    suppress character(1),
    cvf character varying(50)
);


ALTER TABLE umls.mrconso OWNER TO sec;

--
-- Name: mrdef; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrdef (
    cui character(8),
    aui character varying(9),
    atui character varying(11),
    satui character varying(50),
    sab character varying(40),
    def character varying(16000),
    suppress character(1),
    cvf character varying(50)
);


ALTER TABLE umls.mrdef OWNER TO sec;

--
-- Name: mrdoc; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrdoc (
    dockey text,
    value text,
    type text,
    expl text
);


ALTER TABLE umls.mrdoc OWNER TO sec;

--
-- Name: mrfiles; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrfiles (
    fil text,
    des text,
    fmt text,
    cls bigint,
    rws bigint,
    bts bigint
);


ALTER TABLE umls.mrfiles OWNER TO sec;

--
-- Name: mrhier; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrhier (
    cui character(8),
    aui character varying(9),
    cxn integer,
    paui character varying(9),
    sab character varying(40),
    rela character varying(100),
    ptr character varying(1000),
    hcd character varying(100),
    cvf character varying(50)
);


ALTER TABLE umls.mrhier OWNER TO sec;

--
-- Name: mrrel; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrrel (
    cui1 character(8),
    aui1 character varying(9),
    stype1 character varying(50),
    rel character varying(4),
    cui2 character(8),
    aui2 character varying(9),
    stype2 character varying(50),
    rela character varying(100),
    rui character varying(10),
    srui character varying(50),
    sab character varying(40),
    sl character varying(40),
    rg character varying(10),
    dir character varying(1),
    suppress character(1),
    cvf character varying(50)
);


ALTER TABLE umls.mrrel OWNER TO sec;

--
-- Name: ncit; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit (
    index bigint,
    code text,
    url text,
    parents text,
    synonyms text,
    definition text,
    display_name text,
    concept_status text,
    semantic_type text,
    pref_name text
);


ALTER TABLE umls.ncit OWNER TO sec;

--
-- Name: ncit_tc_all; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_all (
    parent text,
    descendant text
);


ALTER TABLE umls.ncit_tc_all OWNER TO sec;

--
-- Name: ncit_tc_with_path_all; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_all (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_all OWNER TO sec;

--
-- Name: ncit_tc_with_path_comp; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_comp (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_comp OWNER TO sec;

--
-- Name: ncit_tc_with_path_icd10cm; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_icd10cm (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_icd10cm OWNER TO sec;

--
-- Name: ncit_tc_with_path_loinc; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_loinc (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_loinc OWNER TO sec;

--
-- Name: ncit_tc_with_path_ncit; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_ncit (
    parent text,
    descendant text,
    level integer,
    path text
);-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/fhir_etl_schema.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fhir_etl; Type: SCHEMA; Schema: -; Owner: sec
--

DROP SCHEMA IF EXISTS fhir_etl CASCADE;
CREATE SCHEMA fhir_etl;


ALTER SCHEMA fhir_etl OWNER TO sec;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: condition; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.condition (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    name text NOT NULL,
    condition_date timestamp without time zone,
    code character varying(256),
    code_scheme character varying(256),
    clinical_status text,
    cancer_related boolean
);


ALTER TABLE fhir_etl.condition OWNER TO sec;

--
-- Name: condition_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.condition_id_seq ;
create sequence fhir_etl.condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.condition_id_seq OWNER TO sec;

--
-- Name: condition_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.condition_id_seq OWNED BY fhir_etl.condition.id;


--
-- Name: observation; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.observation (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    observation_date timestamp without time zone,
    category character varying(256),
    code character varying(256),
    code_scheme character varying(256),
    display text,
    value character varying(256),
    unit character varying(64),
    cancer_related boolean
);


ALTER TABLE fhir_etl.observation OWNER TO sec;

--
-- Name: observation_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.observation_id_seq ;
create sequence fhir_etl.observation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.observation_id_seq OWNER TO sec;

--
-- Name: observation_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.observation_id_seq OWNED BY fhir_etl.observation.id;


--
-- Name: patient; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.patient (
    id integer NOT NULL,
    fhir_id character varying(64) NOT NULL,
    name character varying(256) NOT NULL,
    gender character(1),
    dob timestamp without time zone,
    marital_status character(1),
    race character varying(256),
    ethnicity character varying(256)
);


ALTER TABLE fhir_etl.patient OWNER TO sec;

--
-- Name: patient_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.patient_id_seq ;
create sequence fhir_etl.patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.patient_id_seq OWNER TO sec;

--
-- Name: patient_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.patient_id_seq OWNED BY fhir_etl.patient.id;


--
-- Name: procedure; Type: TABLE; Schema: fhir_etl; Owner: sec
--

CREATE TABLE fhir_etl.procedure (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    procedure_date timestamp without time zone,
    code character varying(256),
    code_scheme character varying(256),
    display text,
    cancer_related boolean
);


ALTER TABLE fhir_etl.procedure OWNER TO sec;

--
-- Name: procedure_id_seq; Type: SEQUENCE; Schema: fhir_etl; Owner: sec
--

drop sequence if exists fhir_etl.procedure_id_seq ;
create sequence fhir_etl.procedure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhir_etl.procedure_id_seq OWNER TO sec;

--
-- Name: procedure_id_seq; Type: SEQUENCE OWNED BY; Schema: fhir_etl; Owner: sec
--

ALTER SEQUENCE fhir_etl.procedure_id_seq OWNED BY fhir_etl.procedure.id;


--
-- Name: condition id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.condition ALTER COLUMN id SET DEFAULT nextval('fhir_etl.condition_id_seq'::regclass);


--
-- Name: observation id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.observation ALTER COLUMN id SET DEFAULT nextval('fhir_etl.observation_id_seq'::regclass);


--
-- Name: patient id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.patient ALTER COLUMN id SET DEFAULT nextval('fhir_etl.patient_id_seq'::regclass);


--
-- Name: procedure id; Type: DEFAULT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.procedure ALTER COLUMN id SET DEFAULT nextval('fhir_etl.procedure_id_seq'::regclass);


--
-- Name: condition condition_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.condition
    ADD CONSTRAINT condition_pkey PRIMARY KEY (id);


--
-- Name: observation observation_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.observation
    ADD CONSTRAINT observation_pkey PRIMARY KEY (id);


--
-- Name: patient patient_fhir_id_key; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.patient
    ADD CONSTRAINT patient_fhir_id_key UNIQUE (fhir_id);


--
-- Name: patient patient_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.patient
    ADD CONSTRAINT patient_pkey PRIMARY KEY (id);


--
-- Name: procedure procedure_pkey; Type: CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.procedure
    ADD CONSTRAINT procedure_pkey PRIMARY KEY (id);


--
-- Name: condition_date_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX condition_date_idx ON fhir_etl.condition USING btree (condition_date);


--
-- Name: condition_patient_id_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX condition_patient_id_idx ON fhir_etl.condition USING btree (patient_id);


--
-- Name: observation_date_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX observation_date_idx ON fhir_etl.observation USING btree (observation_date);


--
-- Name: observation_patient_id_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX observation_patient_id_idx ON fhir_etl.observation USING btree (patient_id);


--
-- Name: procedure_date_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX procedure_date_idx ON fhir_etl.procedure USING btree (procedure_date);


--
-- Name: procedure_patient_id_idx; Type: INDEX; Schema: fhir_etl; Owner: sec
--

CREATE INDEX procedure_patient_id_idx ON fhir_etl.procedure USING btree (patient_id);


--
-- Name: condition condition_patient_fk; Type: FK CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.condition
    ADD CONSTRAINT condition_patient_fk FOREIGN KEY (patient_id) REFERENCES fhir_etl.patient(id) ON DELETE CASCADE;


--
-- Name: observation observation_patient_fk; Type: FK CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.observation
    ADD CONSTRAINT observation_patient_fk FOREIGN KEY (patient_id) REFERENCES fhir_etl.patient(id) ON DELETE CASCADE;


--
-- Name: procedure procedure_patient_fk; Type: FK CONSTRAINT; Schema: fhir_etl; Owner: sec
--

ALTER TABLE ONLY fhir_etl.procedure
    ADD CONSTRAINT procedure_patient_fk FOREIGN KEY (patient_id) REFERENCES fhir_etl.patient(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/umls_schema.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: umls; Type: SCHEMA; Schema: -; Owner: sec
--

DROP SCHEMA IF EXISTS umls CASCADE;
CREATE SCHEMA umls;


ALTER SCHEMA umls OWNER TO sec;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comp_parents; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.comp_parents (
    parent text,
    concept text,
    level integer,
    path text
);


ALTER TABLE umls.comp_parents OWNER TO sec;

--
-- Name: curated_crosswalk; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.curated_crosswalk (
    index bigint,
    identifier bigint,
    code_system text,
    disease_code text,
    preferred_name text,
    evs_nci_code text,
    corrected_preferred_name_for_icd9 text,
    date_last_created text,
    date_last_updated text,
    site_code text,
    site_name text,
    disease_code_site_code text,
    evs_preferred_name text,
    comments text
);


ALTER TABLE umls.curated_crosswalk OWNER TO sec;

--
-- Name: mrcols; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrcols (
    col text,
    des text,
    ref double precision,
    min bigint,
    av double precision,
    max bigint,
    fil text,
    dty text
);


ALTER TABLE umls.mrcols OWNER TO sec;

--
-- Name: mrconso; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrconso (
    cui character(8),
    lat character(3),
    ts character(1),
    lui character varying(10),
    stt character varying(3),
    sui character varying(10),
    ispref character(1),
    aui character varying(9),
    saui character varying(100),
    scui character varying(100),
    sdui character varying(100),
    sab character varying(40),
    tty character varying(20),
    code character varying(100),
    str character varying(3000),
    srl integer,
    suppress character(1),
    cvf character varying(50)
);


ALTER TABLE umls.mrconso OWNER TO sec;

--
-- Name: mrdef; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrdef (
    cui character(8),
    aui character varying(9),
    atui character varying(11),
    satui character varying(50),
    sab character varying(40),
    def character varying(16000),
    suppress character(1),
    cvf character varying(50)
);


ALTER TABLE umls.mrdef OWNER TO sec;

--
-- Name: mrdoc; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrdoc (
    dockey text,
    value text,
    type text,
    expl text
);


ALTER TABLE umls.mrdoc OWNER TO sec;

--
-- Name: mrfiles; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrfiles (
    fil text,
    des text,
    fmt text,
    cls bigint,
    rws bigint,
    bts bigint
);


ALTER TABLE umls.mrfiles OWNER TO sec;

--
-- Name: mrhier; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrhier (
    cui character(8),
    aui character varying(9),
    cxn integer,
    paui character varying(9),
    sab character varying(40),
    rela character varying(100),
    ptr character varying(1000),
    hcd character varying(100),
    cvf character varying(50)
);


ALTER TABLE umls.mrhier OWNER TO sec;

--
-- Name: mrrel; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.mrrel (
    cui1 character(8),
    aui1 character varying(9),
    stype1 character varying(50),
    rel character varying(4),
    cui2 character(8),
    aui2 character varying(9),
    stype2 character varying(50),
    rela character varying(100),
    rui character varying(10),
    srui character varying(50),
    sab character varying(40),
    sl character varying(40),
    rg character varying(10),
    dir character varying(1),
    suppress character(1),
    cvf character varying(50)
);


ALTER TABLE umls.mrrel OWNER TO sec;

--
-- Name: ncit; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit (
    index bigint,
    code text,
    url text,
    parents text,
    synonyms text,
    definition text,
    display_name text,
    concept_status text,
    semantic_type text,
    pref_name text
);


ALTER TABLE umls.ncit OWNER TO sec;

--
-- Name: ncit_tc_all; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_all (
    parent text,
    descendant text
);


ALTER TABLE umls.ncit_tc_all OWNER TO sec;

--
-- Name: ncit_tc_with_path_all; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_all (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_all OWNER TO sec;

--
-- Name: ncit_tc_with_path_comp; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_comp (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_comp OWNER TO sec;

--
-- Name: ncit_tc_with_path_icd10cm; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_icd10cm (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_icd10cm OWNER TO sec;

--
-- Name: ncit_tc_with_path_loinc; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_loinc (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_loinc OWNER TO sec;

--
-- Name: ncit_tc_with_path_ncit; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_ncit (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_ncit OWNER TO sec;

--
-- Name: ncit_tc_with_path_snomedct; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_tc_with_path_snomedct (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE umls.ncit_tc_with_path_snomedct OWNER TO sec;

--
-- Name: ncit_version_composite; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.ncit_version_composite (
    version_id character varying(32),
    downloaded_url text,
    active_version character varying(1),
    composite_ontology_generation_date text
);


ALTER TABLE umls.ncit_version_composite OWNER TO sec;

--
-- Name: parents; Type: TABLE; Schema: umls; Owner: sec
--

CREATE TABLE umls.parents (
    concept text,
    parent text,
    path text,
    level integer
);


ALTER TABLE umls.parents OWNER TO sec;

--
-- Name: cc_code_system_idx; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX cc_code_system_idx ON umls.curated_crosswalk USING btree (code_system);


--
-- Name: conso_aui; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX conso_aui ON umls.mrconso USING btree (aui);


--
-- Name: hier_aui; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX hier_aui ON umls.mrhier USING btree (aui);


--
-- Name: hier_paui; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX hier_paui ON umls.mrhier USING btree (paui);


--
-- Name: hier_sab; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX hier_sab ON umls.mrhier USING btree (sab);


--
-- Name: ix_curated_crosswalk_index; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX ix_curated_crosswalk_index ON umls.curated_crosswalk USING btree (index);


--
-- Name: ix_ncit_index; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX ix_ncit_index ON umls.ncit USING btree (index);


--
-- Name: lower_pref_name_idx; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX lower_pref_name_idx ON umls.ncit USING btree (lower(pref_name));


--
-- Name: mrconso_cui; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX mrconso_cui ON umls.mrconso USING btree (cui);


--
-- Name: ncit_code_index; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX ncit_code_index ON umls.ncit USING btree (code);


--
-- Name: ncit_tc_parent_all; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX ncit_tc_parent_all ON umls.ncit_tc_all USING btree (parent);


--
-- Name: ncit_tc_path_descendant; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX ncit_tc_path_descendant ON umls.ncit_tc_with_path_all USING btree (descendant);


--
-- Name: ncit_tc_path_parent; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX ncit_tc_path_parent ON umls.ncit_tc_with_path_all USING btree (parent);


--
-- Name: par_concept_idx; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX par_concept_idx ON umls.parents USING btree (concept);


--
-- Name: par_par_idx; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX par_par_idx ON umls.parents USING btree (parent);


--
-- Name: rel_cui1; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX rel_cui1 ON umls.mrrel USING btree (cui1);


--
-- Name: rel_cui2; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX rel_cui2 ON umls.mrrel USING btree (cui2);


--
-- Name: tc_desc_all_index; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX tc_desc_all_index ON umls.ncit_tc_all USING btree (descendant);


--
-- Name: tc_parent_all_index; Type: INDEX; Schema: umls; Owner: sec
--

CREATE INDEX tc_parent_all_index ON umls.ncit_tc_all USING btree (parent);


--
-- PostgreSQL database dump complete
--

-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/nci_api_db.sql
SET search_path TO public;
drop table if exists trials cascade;

create table trials (
  nct_id varchar(100) primary key,
  brief_title text,
  official_title text,
  brief_summary text,
  detail_description text,
  max_age_in_years int,
  min_age_in_years int,
  age_expression varchar(200),
  gender varchar(10),
  gender_expression varchar(200),
  diseases text,
  disease_names text,
  diseases_lead text,
  disease_names_lead text,
  phase text,
  primary_purpose_code text,
  study_source text,
  record_verification_date date,
  amendment_date date,
  biomarker_exc_codes text,
  biomarker_exc_names text,
  biomarker_inc_codes text,
  biomarker_inc_names text
);

drop index if exists trials_nct_idx;

create index trials_nct_idx on trials(nct_id);

drop table if exists trial_diseases cascade;

create table trial_diseases (
  idx serial primary key,
  nct_id varchar(100),
  nci_thesaurus_concept_id varchar(100),
  lead_disease_indicator boolean,
  preferred_name text,
  disease_type text,
  inclusion_indicator text,
  display_name text,
  --constraint trial_diseases_pk primary key (nct_id, nci_thesaurus_concept_id)
  constraint trial_diseases_trial_fk foreign key (nct_id) references trials(nct_id)
);

create index trial_diseases_nct_id_idx on trial_diseases(nct_id);

create index trial_diseases_concept_idx on trial_diseases(nci_thesaurus_concept_id);

create index trial_diseases_concept_lead on trial_diseases(nci_thesaurus_concept_id, lead_disease_indicator);

create index trial_diseases_lead_disease on trial_diseases(lead_disease_indicator);

create index trial_diseases_inc_ind on trial_diseases(inclusion_indicator);

drop table if exists distinct_trial_diseases cascade;

create table distinct_trial_diseases(
  nci_thesaurus_concept_id text,
  preferred_name text,
  disease_type text,
  display_name text
);

create index dtd_index on distinct_trial_diseases(nci_thesaurus_concept_id);

drop table if exists maintypes cascade;

create table maintypes(nci_thesaurus_concept_id varchar(100));

create index maintype_idx on maintypes(nci_thesaurus_concept_id);

drop table if exists trial_maintypes cascade;

create table trial_maintypes(
  nct_id varchar(100),
  nci_thesaurus_concept_id text,
  constraint trial_maintypes_pk primary key (nct_id, nci_thesaurus_concept_id)
);

drop table if exists trial_sites cascade;

create table trial_sites(
  nct_id varchar(100),
  org_name text,
  org_family text,
  org_status text,
  org_to_family_relationship text
);

create index trial_sites_nct_idx on trial_sites(nct_id);

create index trial_sites_nct_name_idx on trial_sites(nct_id, org_name);

create index trial_sites_nct_fam_idx on trial_sites(nct_id, org_family);

drop table if exists trial_unstructured_criteria cascade;

create table trial_unstructured_criteria (
  nct_id varchar(100),
  display_order int,
  inclusion_indicator text,
  description text
);

create index tuc_nct_index on trial_unstructured_criteria(nct_id);
drop sequence if exists trial_diseases_sequence;
drop sequence if exists trial_diseases_sequence ;
create sequence trial_diseases_sequence start with 250;

-- Leave room for imported criteria
drop table if exists criteria_types cascade;

create table criteria_types(
  criteria_type_id INTEGER PRIMARY KEY,
  criteria_type_code text not null,
  criteria_type_title text not null,
  criteria_type_desc text not null,
  criteria_type_active varchar(1) check (
    criteria_type_active = 'Y'
    or criteria_type_active = 'N'
  ),
  criteria_type_sense text check (
    criteria_type_sense = 'Inclusion'
    or criteria_type_sense = 'Exclusion'
  ),
  criteria_column_index int
);

drop table if exists trial_criteria cascade;

create table trial_criteria (
  nct_id varchar(100),
  criteria_type_id integer,
    pexp                        text,
    codes                       text,
    codes_and_descendants       text,
  trial_criteria_orig_text text,
  trial_criteria_refined_text text not null,
  trial_criteria_expression text not null,
  update_date timestamp,
  update_by text,
  primary key(nct_id, criteria_type_id),
  foreign key(criteria_type_id) references criteria_types(criteria_type_id)
);


drop table if exists ncit_version cascade;

create table ncit_version (
  version_id varchar(32),
  downloaded_url text,
  transitive_closure_generation_date timestamp,
  active_version char(1) check (
    active_version = 'Y'
    or active_version is NULL
  ),
  ncit_tokenizer_generation_date timestamp,
  ncit_tokenizer bytea
);

--
--
--
drop table if exists ncit cascade;
create unlogged table ncit(code varchar(25) primary key,
                       url text,
                       parents text,
                       synonyms text,
                       definition text,
                       display_name text,
                       concept_status text,
                       semantic_type text,
                       concept_in_subset text,
                       pref_name text
);

drop index if exists ncit_code_index;
create index ncit_code_index on ncit(code);


drop table if exists parents cascade;
create unlogged table parents(
    concept text,
    parent text,
    path text,
    level int);

--

drop index if exists par_concept_idx;
create index par_concept_idx on parents(concept);
drop index if exists par_par_idx;
create index par_par_idx on parents(parent);

drop table if exists relevant_codes cascade;
create unlogged table relevant_codes(
    codes text
);
--
-- This table is the table that enumerates all of the paths within
-- the NCIT digraph.  The level column is the graph distance
-- between parent and descendant
--
drop table if exists ncit_compiled cascade;
create unlogged table ncit_compiled(
  relevant smallint,
  parent text,
  descendants text
);
drop index if exists ncit_compiled_index;
create index ncit_compiled_index on ncit_compiled(relevant);

drop table if exists ncit_tc_with_path cascade;
create unlogged table ncit_tc_with_path (
parent varchar(32),
descendant varchar(32),
level int,
path text
);
drop index if exists ncit_tc_path_parent;
drop index if exists ncit_tc_path_descendant;
create index ncit_tc_path_parent on ncit_tc_with_path(parent);
CREATE INDEX ncit_tc_path_descendant on ncit_tc_with_path(descendant);

drop table if exists ncit_tc cascade;
create unlogged table ncit_tc (
    parent varchar(32),
    descendant varchar(32)
) ;



--
--
--

drop table if exists disease_tree cascade;

create table disease_tree (
  code text,
  parent text,
  child text,
  levels int,
  collapsed int,
  "nodeSize" int,
  "tooltipHtml" text,
  original_child text
);

create index disease_tree_index_1 on disease_tree(code);

create index disease_tree_index_2 on disease_tree(code, levels, parent, child);

drop table if exists disease_tree_nostage cascade;

create table disease_tree_nostage(
  code text,
  parent text,
  child text,
  levels int,
  collapsed int,
  "nodeSize" int,
  "tooltipHtml" text,
  original_child text
);

create index disease_tree_index_1_ns on disease_tree_nostage(code);

create index disease_tree_index_2_ns on disease_tree_nostage(code, levels, parent, child);

drop table if exists curated_crosswalk cascade;

CREATE TABLE curated_crosswalk (
  id serial primary key,
  code_system TEXT,
  disease_code TEXT,
  preferred_name TEXT,
  evs_c_code TEXT,
  evs_preferred_name TEXT
);

create index crosswalk_ind1 on curated_crosswalk(code_system, disease_code);

create index crosswalk_ind2 on curated_crosswalk(evs_c_code);





drop table if exists trial_prior_therapies cascade;

CREATE TABLE trial_prior_therapies(
  idx SERIAL PRIMARY KEY,
  nct_id VARCHAR(100),
  nci_thesaurus_concept_id VARCHAR(25),
  eligibility_criterion TEXT,
  inclusion_indicator TEXT,
  name TEXT,
  CONSTRAINT trial_prior_therapies_trial_fk FOREIGN KEY (nct_id) REFERENCES trials(nct_id) --  TODO (callaway: uncomment this foreign key constraint if/when we can be sure that
  --  all thesaurus entries will exist in our DB.  Currently, it's possible for abstractors
  --  to have access to NCIT concept codes that have not been released by EVS.
  --  CONSTRAINT trial_prior_therapies_ncit_fk FOREIGN KEY (nci_thesaurus_concept_id) REFERENCES ncit(code)
);

CREATE INDEX trial_prior_therapies_nct_id_idx ON trial_prior_therapies(nct_id);

CREATE INDEX trial_prior_therapies_nci_thesaurus_concept_id_idx ON trial_prior_therapies(nci_thesaurus_concept_id);

create view ncit_version_view as
select
  version_id,
  downloaded_url,
  transitive_closure_generation_date,
  ncit_tokenizer_generation_date,
  active_version
from
  ncit_version;
drop table if exists bad_ncit_syns cascade;
create table bad_ncit_syns (code varchar(100), syn_name text);

insert into
  bad_ncit_syns(code, syn_name)
values
  ('C116664', 'ECoG');

insert into
  bad_ncit_syns(code, syn_name)
values
  ('C161964', 'ECOG');

insert into
  criteria_types(
    criteria_type_id,
    criteria_type_code,
    criteria_type_title,
    criteria_type_desc,
    criteria_type_active,
    criteria_type_sense,
    criteria_column_index
  )
values
(1,'biomarker_exc','Biomarker Exclusion','Biomarker Exclusion','N','Exclusion',20),
(2,'biomarker_inc','Biomarker Inclusion','Biomarker Inclusion','N','Inclusion',30),
(3,'immunotherapy_exc','Immunotherapy Exclusion','Immunotherapy Exclusion','N','Exclusion',10),
(4,'chemotherapy_exc','Chemotherapy Exclusion','Chemotherapy Exclusion','N','Exclusion',40),
(5,'hiv_exc','HIV Exclusion','HIV Exclusion','Y','Exclusion',50),
(6,'plt','PLT','Platelets','Y','Inclusion',2010),
(7,'wbc','WBC','White Blood Count','Y','Inclusion',2020),
(8,'perf','Performance Status','Performance Status','Y','Inclusion',2030),
(11,'bmets','Brain Mets','brain mets','Y','Exclusion',60),
(12,'pt_inc','PT Inclusion','Prior therapy inclusion criteria (includes chemotherapy & immunotherapy)','Y','Inclusion',70),
(17,'surg','Prior Surgery','Prior therapy: surgery exclusion','N','Exclusion',50),
(18,'pt_exc','PT Exclusion','chemotherapy, immunotherapy','Y','Exclusion',80),
(19,'diseases_inc','Diseases Inclusion (NLP)','NLP derived diseases facts and expressions.','N','Inclusion',3),
(254,'BMI','BMI','BMI inclusion','N','Inclusion',1910),
(256,'hcv','Hepatitis C infection','Understood to be active Hepatitis C infection (C3098)','N','Exclusion',1930),
(255,'hbv','Hepatitis B infection','Understood as active HBV infection (C3097)','N','Exclusion',1920),
(257,'so_transplant','Solid Organ Transplant','Solid organ transplant (C15289)','N','Exclusion',1940),
(253,'swallow','Able to swallow','Trials where participants are ineligible due to inability to swallow (and not having NG or G tube)','N','Exclusion',1900),
(258,'seizures','Seizures','Coding for uncontrolled seizures, but using NCIt code for just "seizure" (C2962) -- search&match interface needs to specify that search criteria of seizure=yes means UNCONTROLLED seizures only','N','Exclusion',1950);
-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/fhirops_schema.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fhirops; Type: SCHEMA; Schema: -; Owner: sec
--

DROP SCHEMA IF EXISTS fhirops CASCADE;
CREATE SCHEMA fhirops;


ALTER SCHEMA fhirops OWNER TO sec;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE fhirops.ar_internal_metadata OWNER TO sec;

--
-- Name: authentications; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.authentications (
    id bigint NOT NULL,
    access_token character varying,
    token_type character varying,
    expires_at timestamp without time zone,
    scope character varying,
    id_token character varying,
    state character varying,
    patient character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    oauth_callback_id bigint
);


ALTER TABLE fhirops.authentications OWNER TO sec;

--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: fhirops; Owner: sec
--

drop sequence if exists fhirops.authentications_id_seq ;
create sequence fhirops.authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhirops.authentications_id_seq OWNER TO sec;

--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: fhirops; Owner: sec
--

ALTER SEQUENCE fhirops.authentications_id_seq OWNED BY fhirops.authentications.id;


--
-- Name: foobar; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.foobar (
    v1 integer
);


ALTER TABLE fhirops.foobar OWNER TO sec;

--
-- Name: jobs; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.jobs (
    id character varying NOT NULL,
    search_session_id character varying,
    username character varying,
    percent_done double precision,
    total_steps integer,
    current_step integer,
    current_step_name character varying,
    job_type character varying,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE fhirops.jobs OWNER TO sec;

--
-- Name: ncit_tc_all; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.ncit_tc_all (
    parent text,
    descendant text
);


ALTER TABLE fhirops.ncit_tc_all OWNER TO sec;

--
-- Name: ncit_tc_with_path_all; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.ncit_tc_with_path_all (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE fhirops.ncit_tc_with_path_all OWNER TO sec;

--
-- Name: oauth_callbacks; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.oauth_callbacks (
    id bigint NOT NULL,
    verified_state boolean,
    code character varying,
    state character varying,
    oauth_url character varying,
    response_body_raw character varying,
    response_code integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE fhirops.oauth_callbacks OWNER TO sec;

--
-- Name: oauth_callbacks_id_seq; Type: SEQUENCE; Schema: fhirops; Owner: sec
--

drop sequence if exists fhirops.oauth_callbacks_id_seq ;
create sequence fhirops.oauth_callbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhirops.oauth_callbacks_id_seq OWNER TO sec;

--
-- Name: oauth_callbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: fhirops; Owner: sec
--

ALTER SEQUENCE fhirops.oauth_callbacks_id_seq OWNED BY fhirops.oauth_callbacks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE fhirops.schema_migrations OWNER TO sec;

--
-- Name: search_session; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.search_session (
    session_uuid character varying NOT NULL,
    submit_date character varying,
    nodename character varying DEFAULT 'VA Lighthouse'::character varying,
    username character varying
);


ALTER TABLE fhirops.search_session OWNER TO sec;

--
-- Name: search_session_data; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.search_session_data (
    id bigint NOT NULL,
    search_session_id character varying,
    session_uuid character varying,
    concept_cd character varying,
    original_concept_cd character varying,
    valtype_cd character varying,
    tval_char character varying,
    nval_num double precision,
    units_cd character varying,
    comment character varying
);


ALTER TABLE fhirops.search_session_data OWNER TO sec;

--
-- Name: search_session_data_id_seq; Type: SEQUENCE; Schema: fhirops; Owner: sec
--

drop sequence if exists fhirops.search_session_data_id_seq ;
create sequence fhirops.search_session_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhirops.search_session_data_id_seq OWNER TO sec;

--
-- Name: search_session_data_id_seq; Type: SEQUENCE OWNED BY; Schema: fhirops; Owner: sec
--

ALTER SEQUENCE fhirops.search_session_data_id_seq OWNED BY fhirops.search_session_data.id;


--
-- Name: authentications id; Type: DEFAULT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.authentications ALTER COLUMN id SET DEFAULT nextval('fhirops.authentications_id_seq'::regclass);


--
-- Name: oauth_callbacks id; Type: DEFAULT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.oauth_callbacks ALTER COLUMN id SET DEFAULT nextval('fhirops.oauth_callbacks_id_seq'::regclass);


--
-- Name: search_session_data id; Type: DEFAULT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.search_session_data ALTER COLUMN id SET DEFAULT nextval('fhirops.search_session_data_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: oauth_callbacks oauth_callbacks_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.oauth_callbacks
    ADD CONSTRAINT oauth_callbacks_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: search_session_data search_session_data_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.search_session_data
    ADD CONSTRAINT search_session_data_pkey PRIMARY KEY (id);


--
-- Name: search_session search_session_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.search_session
    ADD CONSTRAINT search_session_pkey PRIMARY KEY (session_uuid);


--
-- Name: fhirops_tc_all_descendant; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX fhirops_tc_all_descendant ON fhirops.ncit_tc_all USING btree (descendant);


--
-- Name: fhirops_tc_all_parent; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX fhirops_tc_all_parent ON fhirops.ncit_tc_all USING btree (parent);


--
-- Name: index_authentications_on_oauth_callback_id; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX index_authentications_on_oauth_callback_id ON fhirops.authentications USING btree (oauth_callback_id);


--
-- Name: index_jobs_on_search_session_id; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX index_jobs_on_search_session_id ON fhirops.jobs USING btree (search_session_id);


--
-- Name: index_search_session_data_on_search_session_id; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX index_search_session_data_on_search_session_id ON fhirops.search_session_data USING btree (search_session_id);


--
-- Name: ncit_tc_path_all_descendant; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX ncit_tc_path_all_descendant ON fhirops.ncit_tc_with_path_all USING btree (descendant);


--
-- Name: ncit_tc_path_all_parent; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX ncit_tc_path_all_parent ON fhirops.ncit_tc_with_path_all USING btree (parent);


--
-- Name: authentications fk_rails_41fdce0738; Type: FK CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.authentications
    ADD CONSTRAINT fk_rails_41fdce0738 FOREIGN KEY (oauth_callback_id) REFERENCES fhirops.oauth_callbacks(id);

-- -----------------------------------------------------------------------------------------
-- sec_nlp/nlp_schema.sql
set search_path to public;
drop table if exists trial_nlp_dates cascade;

create table trial_nlp_dates(
    nct_id varchar(100) primary key,
    tokenized_date date,
    classification_date date
);

drop table if exists ncit_nlp_concepts cascade;

create table ncit_nlp_concepts (
    nct_id varchar(100),
    display_order int,
    ncit_code text,
    span_text text,
    start_index int,
    end_index int
);

create index nlp_nct_id_idx on ncit_nlp_concepts(nct_id);

create index nlp_nct_id_ncit_code_idx on ncit_nlp_concepts(nct_id, ncit_code);

create index nlp_ncit_code_idx on ncit_nlp_concepts(ncit_code);

drop view if exists nlp_data_view;

create view nlp_data_view as
select
    nlp.nct_id,
    nlp.ncit_code,
    nlp.display_order,
    n.pref_name,
    nlp.span_text,
    nlp.start_index,
    nlp.end_index,
    tuc.inclusion_indicator,
    tuc.description
from
    ncit_nlp_concepts nlp
    join ncit n on nlp.ncit_code = n.code
    join trial_unstructured_criteria tuc on nlp.nct_id = tuc.nct_id
    and nlp.display_order = tuc.display_order;

drop table if exists ncit_syns cascade;

create table ncit_syns (
    code varchar(100),
    syn_name text,
    l_syn_name text
);

create index ncit_syns_code_idx on ncit_syns(code);

create index ncit_syns_syn_name on ncit_syns(syn_name);

create index ncit_lsyns_syn_name on ncit_syns(l_syn_name);

create index ncit_lower on ncit(lower(pref_name));

drop table if exists candidate_criteria cascade;

create table candidate_criteria (
    nct_id varchar(100),
    criteria_type_id int,
    display_order int,
    inclusion_indicator bool,
    candidate_criteria_text text,
    candidate_criteria_norm_form text,
    candidate_criteria_expression text,
    generated_date date,
    marked_done_date date
);

-- alter table candidate_criteria add candidate_criteria_norm_form text
-- alter table candidate_criteria add candidate_criteria_expression text
-- indexes --
drop view if exists candidate_criteria_view;

create view candidate_criteria_view as
SELECT
    cc.nct_id,
    cc.criteria_type_id,
    ct.criteria_type_title,
    tc.trial_criteria_orig_text,
    tc.trial_criteria_refined_text,
    tc.trial_criteria_expression,
    cc.display_order,
    cc.inclusion_indicator,
    cc.candidate_criteria_text
from
    candidate_criteria cc
    join criteria_types ct on cc.criteria_type_id = ct.criteria_type_id
    left outer join trial_criteria tc on cc.nct_id = tc.nct_id
    and cc.criteria_type_id = tc.criteria_type_id
order by
    cc.nct_id,
    cc.criteria_type_id;





--
-- PostgreSQL database dump complete
--

-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/nci_api_db.sql
SET search_path TO public;

-- Leave room for imported criteria






-----------------------------------------------------------------------------------------
-- sec_poc/db_api_etl/fhirops_schema.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fhirops; Type: SCHEMA; Schema: -; Owner: sec
--

DROP SCHEMA IF EXISTS fhirops CASCADE;
CREATE SCHEMA fhirops;


ALTER SCHEMA fhirops OWNER TO sec;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE fhirops.ar_internal_metadata OWNER TO sec;

--
-- Name: authentications; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.authentications (
    id bigint NOT NULL,
    access_token character varying,
    token_type character varying,
    expires_at timestamp without time zone,
    scope character varying,
    id_token character varying,
    state character varying,
    patient character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    oauth_callback_id bigint
);


ALTER TABLE fhirops.authentications OWNER TO sec;

--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: fhirops; Owner: sec
--

drop sequence if exists fhirops.authentications_id_seq ;
create sequence fhirops.authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhirops.authentications_id_seq OWNER TO sec;

--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: fhirops; Owner: sec
--

ALTER SEQUENCE fhirops.authentications_id_seq OWNED BY fhirops.authentications.id;


--
-- Name: foobar; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.foobar (
    v1 integer
);


ALTER TABLE fhirops.foobar OWNER TO sec;

--
-- Name: jobs; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.jobs (
    id character varying NOT NULL,
    search_session_id character varying,
    username character varying,
    percent_done double precision,
    total_steps integer,
    current_step integer,
    current_step_name character varying,
    job_type character varying,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE fhirops.jobs OWNER TO sec;

--
-- Name: ncit_tc_all; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.ncit_tc_all (
    parent text,
    descendant text
);


ALTER TABLE fhirops.ncit_tc_all OWNER TO sec;

--
-- Name: ncit_tc_with_path_all; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.ncit_tc_with_path_all (
    parent text,
    descendant text,
    level integer,
    path text
);


ALTER TABLE fhirops.ncit_tc_with_path_all OWNER TO sec;

--
-- Name: oauth_callbacks; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.oauth_callbacks (
    id bigint NOT NULL,
    verified_state boolean,
    code character varying,
    state character varying,
    oauth_url character varying,
    response_body_raw character varying,
    response_code integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE fhirops.oauth_callbacks OWNER TO sec;

--
-- Name: oauth_callbacks_id_seq; Type: SEQUENCE; Schema: fhirops; Owner: sec
--

drop sequence if exists fhirops.oauth_callbacks_id_seq ;
create sequence fhirops.oauth_callbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhirops.oauth_callbacks_id_seq OWNER TO sec;

--
-- Name: oauth_callbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: fhirops; Owner: sec
--

ALTER SEQUENCE fhirops.oauth_callbacks_id_seq OWNED BY fhirops.oauth_callbacks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE fhirops.schema_migrations OWNER TO sec;

--
-- Name: search_session; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.search_session (
    session_uuid character varying NOT NULL,
    submit_date character varying,
    nodename character varying DEFAULT 'VA Lighthouse'::character varying,
    username character varying
);


ALTER TABLE fhirops.search_session OWNER TO sec;

--
-- Name: search_session_data; Type: TABLE; Schema: fhirops; Owner: sec
--

CREATE TABLE fhirops.search_session_data (
    id bigint NOT NULL,
    search_session_id character varying,
    session_uuid character varying,
    concept_cd character varying,
    original_concept_cd character varying,
    valtype_cd character varying,
    tval_char character varying,
    nval_num double precision,
    units_cd character varying,
    comment character varying
);


ALTER TABLE fhirops.search_session_data OWNER TO sec;

--
-- Name: search_session_data_id_seq; Type: SEQUENCE; Schema: fhirops; Owner: sec
--

drop sequence if exists fhirops.search_session_data_id_seq ;
create sequence fhirops.search_session_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fhirops.search_session_data_id_seq OWNER TO sec;

--
-- Name: search_session_data_id_seq; Type: SEQUENCE OWNED BY; Schema: fhirops; Owner: sec
--

ALTER SEQUENCE fhirops.search_session_data_id_seq OWNED BY fhirops.search_session_data.id;


--
-- Name: authentications id; Type: DEFAULT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.authentications ALTER COLUMN id SET DEFAULT nextval('fhirops.authentications_id_seq'::regclass);


--
-- Name: oauth_callbacks id; Type: DEFAULT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.oauth_callbacks ALTER COLUMN id SET DEFAULT nextval('fhirops.oauth_callbacks_id_seq'::regclass);


--
-- Name: search_session_data id; Type: DEFAULT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.search_session_data ALTER COLUMN id SET DEFAULT nextval('fhirops.search_session_data_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: oauth_callbacks oauth_callbacks_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.oauth_callbacks
    ADD CONSTRAINT oauth_callbacks_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: search_session_data search_session_data_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.search_session_data
    ADD CONSTRAINT search_session_data_pkey PRIMARY KEY (id);


--
-- Name: search_session search_session_pkey; Type: CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.search_session
    ADD CONSTRAINT search_session_pkey PRIMARY KEY (session_uuid);


--
-- Name: fhirops_tc_all_descendant; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX fhirops_tc_all_descendant ON fhirops.ncit_tc_all USING btree (descendant);


--
-- Name: fhirops_tc_all_parent; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX fhirops_tc_all_parent ON fhirops.ncit_tc_all USING btree (parent);


--
-- Name: index_authentications_on_oauth_callback_id; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX index_authentications_on_oauth_callback_id ON fhirops.authentications USING btree (oauth_callback_id);


--
-- Name: index_jobs_on_search_session_id; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX index_jobs_on_search_session_id ON fhirops.jobs USING btree (search_session_id);


--
-- Name: index_search_session_data_on_search_session_id; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX index_search_session_data_on_search_session_id ON fhirops.search_session_data USING btree (search_session_id);


--
-- Name: ncit_tc_path_all_descendant; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX ncit_tc_path_all_descendant ON fhirops.ncit_tc_with_path_all USING btree (descendant);


--
-- Name: ncit_tc_path_all_parent; Type: INDEX; Schema: fhirops; Owner: sec
--

CREATE INDEX ncit_tc_path_all_parent ON fhirops.ncit_tc_with_path_all USING btree (parent);


--
-- Name: authentications fk_rails_41fdce0738; Type: FK CONSTRAINT; Schema: fhirops; Owner: sec
--

ALTER TABLE ONLY fhirops.authentications
    ADD CONSTRAINT fk_rails_41fdce0738 FOREIGN KEY (oauth_callback_id) REFERENCES fhirops.oauth_callbacks(id);

-- -----------------------------------------------------------------------------------------
-- sec_nlp/nlp_schema.sql




