CREATE SCHEMA IF NOT EXISTS "hangfire";

SET search_path = 'hangfire';
--
-- Table structure for table `Schema`
--

create table if not exists schema
(
    version integer not null
    primary key
);

INSERT INTO "schema"("version")
VALUES ('3');

create table if not exists counter
(
    id       bigserial
    primary key,
    key      text   not null,
    value    bigint not null,
    expireat timestamp with time zone
);

create index if not exists ix_hangfire_counter_key
    on counter (key);

create index if not exists ix_hangfire_counter_expireat
    on counter (expireat);

create table if not exists hash
(
    id          bigserial
    primary key,
    key         text              not null,
    field       text              not null,
    value       text,
    expireat    timestamp with time zone,
    updatecount integer default 0 not null,
    unique (key, field)
    );

create index if not exists ix_hangfire_hash_expireat
    on hash (expireat);

create table if not exists job
(
    id             bigserial
    primary key,
    stateid        bigint,
    statename      text,
    invocationdata jsonb                    not null,
    arguments      jsonb                    not null,
    createdat      timestamp with time zone not null,
    expireat       timestamp with time zone,
    updatecount    integer default 0        not null
);

create index if not exists ix_hangfire_job_statename
    on job (statename);

create index if not exists ix_hangfire_job_expireat
    on job (expireat);

create table if not exists state
(
    id          bigserial
    primary key,
    jobid       bigint                   not null
    references job
    on update cascade on delete cascade,
    name        text                     not null,
    reason      text,
    createdat   timestamp with time zone not null,
    data        jsonb,
    updatecount integer default 0        not null
);

create index if not exists ix_hangfire_state_jobid
    on state (jobid);

create table if not exists jobqueue
(
    id          bigserial
    primary key,
    jobid       bigint            not null,
    queue       text              not null,
    fetchedat   timestamp with time zone,
    updatecount integer default 0 not null
);

create index if not exists ix_hangfire_jobqueue_jobidandqueue
    on jobqueue (jobid, queue);

create index if not exists ix_hangfire_jobqueue_queueandfetchedat
    on jobqueue (queue, fetchedat);

create index if not exists jobqueue_queue_fetchat_jobid
    on jobqueue (queue, fetchedat, jobid);

create table if not exists list
(
    id          bigserial
    primary key,
    key         text              not null,
    value       text,
    expireat    timestamp with time zone,
    updatecount integer default 0 not null
);

create index if not exists ix_hangfire_list_expireat
    on list (expireat);

create table if not exists server
(
    id            text                     not null
    primary key,
    data          jsonb,
    lastheartbeat timestamp with time zone not null,
    updatecount   integer default 0        not null
);

create table if not exists set
(
    id          bigserial
    primary key,
    key         text              not null,
    score       double precision  not null,
    value       text              not null,
    expireat    timestamp with time zone,
    updatecount integer default 0 not null,
    unique (key, value)
    );

create index if not exists ix_hangfire_set_key_score
    on set (key, score);

create index if not exists ix_hangfire_set_expireat
    on set (expireat);

create table if not exists jobparameter
(
    id          bigserial
    primary key,
    jobid       bigint            not null
    references job
    on update cascade on delete cascade,
    name        text              not null,
    value       text,
    updatecount integer default 0 not null
);

create index if not exists ix_hangfire_jobparameter_jobidandname
    on jobparameter (jobid, name);

create table if not exists lock
(
    resource    text              not null
    unique,
    updatecount integer default 0 not null,
    acquired    timestamp with time zone
);

create table if not exists aggregatedcounter
(
    id       bigserial
    primary key,
    key      text   not null
    unique,
    value    bigint not null,
    expireat timestamp with time zone
);

RESET search_path;