# Oracle RDBMS Monitor

Interactive shell + SQL\*Plus monitoring toolkit for Oracle Database.

## Requirements

- Oracle Database (developed against **19c** Enterprise Edition)
- `sqlplus` on `$PATH` and a DBA-capable login (default `system/manager`)
- A POSIX shell (`/bin/sh`) — developed on Linux x86_64
- `ORACLE_HOME` and `ORACLE_SID` exported in your shell

## Layout

```
monitor/
├── monitor              ← main interactive menu  (entry point)
├── auto_refresh.sh      ← auto-refresh wrapper for individual sections
├── mon.sh               ← background OS+DB process logger
├── ha_mon.sh            ← lightweight HA / session count logger
├── dml_view.sh          ← DML search + SQL plan helper
├── orastatus            ← Oracle background-process status (PMON, SMON, …)
├── log/                 ← output of "S — Save To File"
└── sql/
    ├── 0_save_file.sh   ← builds the all-in-one save report
    ├── 1_*.sql          ← General  (instance, parameter, SGA/PGA, backup)
    ├── 2_*.sql          ← Shared Memory (BCHR, library/dict cache, latch)
    ├── 3_*.sql          ← Sessions (current / active / RAC variants, txn, cursors)
    ├── 4_*.sql          ← Wait Event / Lock (blocking, hierarchical, sysstat, …)
    ├── 5_*.sql          ← Space (controlfile, logs, datafiles, tablespace, undo, temp)
    ├── 6_*.sql          ← I/O (file I/O, session I/O, archive log history)
    ├── 7_*.sql          ← Object (counts, invalid objects, top segments)
    ├── 8_*.sql          ← SQL  (sql_plan, top SQL, static-query patterns)
    ├── 9_awr*.sql       ← AWR  (snapshot create / list / report)
    └── 4_session_event.sh ← interactive helper for menu 45
```

Runtime-generated files such as `sql/0_save_file.sql`,
`sql/4_session_event.sql`, and `sql/sqlid_format.sql` are ignored by Git.

## Quick start

```sh
export ORACLE_HOME=/oracle/db/19c
export ORACLE_SID=PROD

cd oracle_shell_monitor
sh setup_executable_permissions.sh
monitor/monitor
```

Override the connection if needed:

```sh
DB_USER=dba_user DB_PASS=mypass monitor/monitor
DB_USER=sys DB_PASS=manager DB_ROLE=sysdba monitor/monitor
MONITOR_HOME=monitor monitor/monitor             # use a different sql/ tree
```

If the checkout does not preserve executable bits, run
`sh setup_executable_permissions.sh` from the `oracle_shell_monitor` root.

## Menu reference

Selecting a category number (`1`-`9` or `0`) shows the section-specific
options. Selecting a detailed menu number runs that monitor query.

```
1.GENERAL                               |  2.SHARED MEMORY
11 - Instance/Database Info             |  21 - Database Buffer Hit Ratio
12 - Parameter Info (non-default)       |  22 - Shared Pool / Library Hit Ratio
13 - Memory Info (SGA/PGA detail)       |  23 - Latch Contention
14 - RMAN Backup / Datafile Status      |
3.SESSION                               |  4.WAIT EVENT/LOCK
31 - Current Session Info               |  41 - Current Lock Info
32 - Current Active Session Info        |  42 - Hierarchical Lock Info
33 - Active Session Wait Info           |  43 - Hierarchical Lock Info(RAC)
34 - Active Session Running SQL         |  44 - System Event
35 - Current Transaction                |  45 - Session Event   (prompts for SIDs)
36 - Open Cursor                        |  46 - Session Wait
37 - Current Session(RAC)               |  47 - Sysstat
38 - Current Active Session(RAC)        |  48 - Top Wait Event
39 - Active Session Wait(RAC)           |  49 - Redo Nowait Info
5.SPACE                                 |  6.I/O
51 - Database File Info                 |  61 - File I/O Info
52 - Tablespace Usage                   |  62 - Session I/O Info
53 - Undo Segment Usage                 |  63 - Archivelog Count
54 - Temp Segment Usage                 |
7.OBJECT                                |  8.SQL
71 - Schema Object Count                |  81 - SQL Plan         (prompts SQL_ID + child#)
72 - Object Invalid Count               |  82 - Top SQL
73 - Object Invalid List                |  83 - Check Static Query Pattern
74 - Segment Size(Top 50)               |
9.AWR (Use Carefully)                   |  0.OTHER
91 - Create AWR Snapshot                |  M - Auto Refresh Monitoring (auto_refresh.sh)
92 - Create AWR Snapshot (RAC)          |  S - Save To File   → log/monitor_*.log
93 - Show AWR Snapshot List             |
94 - Create AWR Report                  |  X - EXIT
```

### RAC menu items (37/38/39/43/92)

These query `gv$session` / `gv$lock` / `gv$undostat`, so they show every
instance in a RAC cluster. On a single-instance database they simply return
the one local instance — they're safe to run anywhere.

## Auto-refresh (`auto_refresh.sh`)

Standalone or invoked from menu **M**. Refreshes a selected section every N
seconds; press `X<ENTER>` to stop.

```sh
./auto_refresh.sh runsess 5         # refresh active sessions every 5 seconds
./auto_refresh.sh swait   3
./auto_refresh.sh topwait 10
```

Available options:

| option      | what it shows                                  |
| ----------- | ---------------------------------------------- |
| `redowait`  | redo wait statistics                           |
| `runsess`   | active sessions (status='ACTIVE', type='USER') |
| `session`   | all sessions                                   |
| `sessio`    | per-session I/O                                |
| `sessevent` | event waits for a chosen list of SIDs          |
| `sevent`    | system-wide event waits                        |
| `spin`      | latch contention                               |
| `swait`     | current session_wait                           |
| `sysstat`   | top sysstat counters                           |
| `topwait`   | top non-idle wait events                       |
| `tempseg`   | temp-segment usage                             |
| `tran`      | open transactions                              |

## Implementation notes

- Each menu option runs one `sqlplus -s -L` invocation against the local
  instance, then waits for `<ENTER>`.
- The `_rac.sql` variants use `gv$*` views; the rest use `v$*`.
- AWR menu items (9*) require Diagnostic Pack license.
- Menu **81** uses `dbms_xplan.display_cursor()`; pass an SQL_ID and child
  number when prompted.
- `prompt` separator lines use `=====` rather than `-----` because
  sqlplus 19c interprets `--` after `prompt` as a SQL comment, which breaks
  the next statement.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `ORA-01017 invalid username/password` | export `ORACLE_SID`, or set `DB_USER`/`DB_PASS` |
| `ORA-00942 table or view does not exist` for `v$…` views | use a DBA-capable user, or set `DB_ROLE=sysdba` with a SYSDBA user |
| `ORA-13717 …` permission errors on AWR | Diagnostic Pack not licensed; do not use 9_* menu options |
| Empty results for option 73 (invalid objects) | nothing invalid — that's the desired state |
