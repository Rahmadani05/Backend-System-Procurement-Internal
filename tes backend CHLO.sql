-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION postgres;

-- DROP TYPE public.request_status;

CREATE TYPE public.request_status AS ENUM (
	'DRAFT',
	'SUBMITTED',
	'APPROVED',
	'REJECTED',
	'IN_PROCUREMENT',
	'COMPLETED');

-- DROP SEQUENCE public.approvals_id_seq;

CREATE SEQUENCE public.approvals_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.departments_id_seq;

CREATE SEQUENCE public.departments_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.migrations_id_seq;

CREATE SEQUENCE public.migrations_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.personal_access_tokens_id_seq;

CREATE SEQUENCE public.personal_access_tokens_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.procurement_orders_id_seq;

CREATE SEQUENCE public.procurement_orders_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.request_items_id_seq;

CREATE SEQUENCE public.request_items_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.requests_id_seq;

CREATE SEQUENCE public.requests_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.status_history_id_seq;

CREATE SEQUENCE public.status_history_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.stock_id_seq;

CREATE SEQUENCE public.stock_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.users_id_seq;

CREATE SEQUENCE public.users_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.vendors_id_seq;

CREATE SEQUENCE public.vendors_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;-- public.departments definition

-- Drop table

-- DROP TABLE public.departments;

CREATE TABLE public.departments (
	id serial4 NOT NULL,
	"name" varchar(255) NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT departments_pkey PRIMARY KEY (id)
);


-- public.migrations definition

-- Drop table

-- DROP TABLE public.migrations;

CREATE TABLE public.migrations (
	id serial4 NOT NULL,
	migration varchar(255) NOT NULL,
	batch int4 NOT NULL,
	CONSTRAINT migrations_pkey PRIMARY KEY (id)
);


-- public.personal_access_tokens definition

-- Drop table

-- DROP TABLE public.personal_access_tokens;

CREATE TABLE public.personal_access_tokens (
	id serial4 NOT NULL,
	tokenable_type varchar(255) NOT NULL,
	tokenable_id int4 NOT NULL,
	"name" varchar(255) NOT NULL,
	"token" varchar(255) NOT NULL,
	abilities text NULL,
	last_used_at timestamp NULL,
	expires_at timestamp NULL,
	created_at timestamp NULL,
	updated_at timestamp NULL,
	CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id),
	CONSTRAINT personal_access_tokens_token_key UNIQUE (token)
);
CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


-- public.stock definition

-- Drop table

-- DROP TABLE public.stock;

CREATE TABLE public.stock (
	id serial4 NOT NULL,
	item_name varchar(255) NOT NULL,
	category varchar(100) NOT NULL,
	available_quantity int4 DEFAULT 0 NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT stock_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_stock_item_name ON public.stock USING btree (item_name);


-- public.vendors definition

-- Drop table

-- DROP TABLE public.vendors;

CREATE TABLE public.vendors (
	id serial4 NOT NULL,
	"name" varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	phone varchar(50) NOT NULL,
	address text NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamp NULL,
	CONSTRAINT vendors_pkey PRIMARY KEY (id)
);


-- public.users definition

-- Drop table

-- DROP TABLE public.users;

CREATE TABLE public.users (
	id serial4 NOT NULL,
	department_id int4 NULL,
	"name" varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	"password" varchar(255) NOT NULL,
	"role" varchar(50) NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamp NULL,
	CONSTRAINT users_pkey PRIMARY KEY (id),
	CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);


-- public.requests definition

-- Drop table

-- DROP TABLE public.requests;

CREATE TABLE public.requests (
	id serial4 NOT NULL,
	user_id int4 NULL,
	department_id int4 NULL,
	status public.request_status DEFAULT 'DRAFT'::request_status NULL,
	total_amount numeric(15, 2) DEFAULT 0 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamp NULL,
	CONSTRAINT requests_pkey PRIMARY KEY (id),
	CONSTRAINT requests_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id),
	CONSTRAINT requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE INDEX idx_requests_status ON public.requests USING btree (status);
CREATE INDEX idx_requests_user_id ON public.requests USING btree (user_id);


-- public.status_history definition

-- Drop table

-- DROP TABLE public.status_history;

CREATE TABLE public.status_history (
	id serial4 NOT NULL,
	request_id int4 NULL,
	changed_by int4 NULL,
	old_status public.request_status NULL,
	new_status public.request_status NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT status_history_pkey PRIMARY KEY (id),
	CONSTRAINT status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id),
	CONSTRAINT status_history_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id)
);


-- public.approvals definition

-- Drop table

-- DROP TABLE public.approvals;

CREATE TABLE public.approvals (
	id serial4 NOT NULL,
	request_id int4 NULL,
	approver_id int4 NULL,
	status varchar(50) NOT NULL,
	notes text NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT approvals_pkey PRIMARY KEY (id),
	CONSTRAINT approvals_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id),
	CONSTRAINT approvals_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id)
);


-- public.procurement_orders definition

-- Drop table

-- DROP TABLE public.procurement_orders;

CREATE TABLE public.procurement_orders (
	id serial4 NOT NULL,
	request_id int4 NULL,
	vendor_id int4 NULL,
	status varchar(50) DEFAULT 'PENDING'::character varying NULL,
	total_cost numeric(15, 2) DEFAULT 0 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamp NULL,
	CONSTRAINT procurement_orders_pkey PRIMARY KEY (id),
	CONSTRAINT procurement_orders_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id),
	CONSTRAINT procurement_orders_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id)
);
CREATE INDEX idx_po_request_id ON public.procurement_orders USING btree (request_id);
CREATE INDEX idx_po_vendor_id ON public.procurement_orders USING btree (vendor_id);


-- public.request_items definition

-- Drop table

-- DROP TABLE public.request_items;

CREATE TABLE public.request_items (
	id serial4 NOT NULL,
	request_id int4 NULL,
	item_name varchar(255) NOT NULL,
	category varchar(100) NOT NULL,
	quantity int4 NOT NULL,
	price numeric(15, 2) DEFAULT 0 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT request_items_pkey PRIMARY KEY (id),
	CONSTRAINT request_items_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id) ON DELETE CASCADE
);