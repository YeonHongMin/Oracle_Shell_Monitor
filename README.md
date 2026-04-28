# oracle_shell_monitor

A small toolkit of shell + SQL\*Plus scripts for monitoring an Oracle
Database instance from the command line.

## Layout

```
oracle_shell_monitor/
├── README.md                <- this file (main page, walkthroughs)
├── setup_executable_permissions.sh
└── monitor/                 <- interactive menu and SQL scripts
    └── README.md            <- menu reference + auto_refresh.sh details
```

## Quick start

```sh
export ORACLE_HOME=/oracle/db/19c
export ORACLE_SID=PROD                  # adjust to your instance
cd oracle_shell_monitor
sh setup_executable_permissions.sh
monitor/monitor                         # launch the interactive menu
```

Override the login when the default `system/manager` doesn't apply:

```sh
DB_USER=dba_user DB_PASS=mypass monitor/monitor
DB_USER=sys      DB_PASS=manager DB_ROLE=sysdba monitor/monitor
```

## Walkthrough: launching `monitor/monitor`

When you run `monitor/monitor`, the main menu appears. Type a category
digit (`1`-`9`, `0`) to drill in, **or** type a 2-digit option code
(e.g. `32`) to jump directly to that report.

```
=============================
 Oracle RDBMS Monitor Ver1.0
=============================
==================================================
 (Disclaimer)
 These scripts come without warranty of any kind.
 Use them at your own risk.
==================================================
  Oracle Version : 19  (SQL_ID_FORMAT: column sql_id format a13)
  Connect as     : system/manager  | ORACLE_SID=PROD
 -----------------------------------------------------------------------------------
  1.GENERAL                               |  2.SHARED MEMORY
  11 - Instance/Database Info             |  21 - Database Buffer Hit Ratio
  12 - Parameter Info (non-default)       |  22 - Shared Pool / Library Hit Ratio
  13 - Memory Info (SGA/PGA)              |  23 - Latch Contention
  14 - Backup Status                      |
  3.SESSION                               |  4.WAIT EVENT/LOCK
  31 - Current Session Info               |  41 - Current Lock Info
  32 - Current Active Session Info        |  42 - Hierarchical Lock Info
  33 - Active Session Wait Info           |  43 - Hierarchical Lock Info(RAC)
  34 - Active Session Running SQL         |  44 - System Event
  35 - Current Transaction                |  45 - Session Event
  36 - Open Cursor                        |  46 - Session Wait
  ...
  9.AWR (Use Carefully)                   |  0.OTHER
  91 - Create AWR Snapshot                |  M - Auto Refresh Monitoring
  92 - Create AWR Snapshot (RAC)          |  S - Save To File
  93 - Show AWR Snapshot List             |
  94 - Create AWR Report                  |  X - EXIT
 -----------------------------------------------------------------------------------

 Choose the Number or Command :
```

Two ways to navigate:

**(a) Drill into a category** — type the section digit, press Enter,
then type the 2-digit code:

```
 Choose the Number or Command : 3
====================
 3.SESSION
====================
 31 - Current Session Info
 32 - Current Active Session Info
 33 - Active Session Wait Info
 ...

 Choose the Number or Command : 32
```

**(b) Direct shortcut** — type the 2-digit code on the main menu:

```
 Choose the Number or Command : 32
```

After a report runs, the screen shows the result and pauses with
`Press Enter Key to continue...`. Press Enter to return to the menu.
Type `X` on the main menu to exit.

## Common workflows

Each row below is one monitoring goal and the menu path that gets you
there. All sample output comes from a CDB with two PDBs (`con_id` 3
and 4) under load.

### 1. "What's running right now?"

Path: **32** (Current Active Session Info)

```
Sid,Serial    Username       Status   Machine     Logon_Time           Program            SQL_ID          Client_Pid  Server_Pid    Con
------------- -------------- -------- ----------- -------------------- ------------------ --------------- ----------- ------------- -----
1228,23204    APP            ACTIVE   vibevm      2026/04/27 13:13:48  JDBC Thin Client   0d1xmhavvz7td   1234        1434023           4
1245,30502    SYSTEM         ACTIVE   red178      2026/04/27 13:25:03  sqlplus@red178     bxh1x9pup8a6c   1437262     1437264           1
65,45850      APP            ACTIVE   vibevm      2026/04/27 13:13:48  JDBC Thin Client   0d1xmhavvz7td   1234        1434025           4
```

`Con` is the container id — `1` is `CDB$ROOT`, `3`/`4` are PDBs.

### 2. "Who is blocking whom?"

Path: **41** (Current Lock Info) → optionally **42** (Hierarchical Lock)

```
  Sid Status     User         Object             Lock_time   Lock mode         SQL_ID         Con
----- ---------- ------------ ------------------ ----------- ----------------- -------------- -----
   74 ACTIVE     APP          APP.LOAD_TEST      0:0:32      [3] Row-X         cfp05p0vvtc3s     4
  839 ACTIVE     APP          APP.LOAD_TEST      0:0:30      [3] Row-X         cfp05p0vvtc3s     4
   67 ACTIVE     APP          .                  0:1:05      [6] Exclusive     cfp05p0vvtc3s     4
```

The `Con` column tells you which PDB the lock is in — useful when the
same object name (e.g. a per-tenant table) exists in multiple PDBs.

### 3. "Find the heaviest SQL"

Path: **82** (Top SQL) — three sections: by Elapsed Time, Buffer Gets,
and Elap/Exec. Then drill into a specific `SQL_ID` with **81**.

```
========  Top 10 SQL Ordered by Elapsed Time =========

USERNAME       Elapsed_Time(s)  EXECUTIONS    Gets/Exec  Elap/Exec(s)  MODULE              SQL_ID            Con
-------------- ---------------- ----------- ------------ ------------ ------------------- --------------- -----
APP                    240.409     988,283        9.281         .000  JDBC Thin Client    gmh99f26fu48c       3
APP                    239.348     988,302        9.240         .000  JDBC Thin Client    530u0m36cx23p       3
C##ORAMON               99.393         190       75.137         .523  oracledb_exporter   9zxyvzpzp3h9g       1
APP                     54.892     319,476        9.102         .000  JDBC Thin Client    gmh99f26fu48c       4
```

Then path **81** to see the plan for one of these SQLs:

```
 Choose the Number or Command : 81
INPUT SQL_ID                  : gmh99f26fu48c
INPUT CHILD NUMBER (default 0):
```

(prints `dbms_xplan.display_cursor(... format=>'ALLSTATS LAST')`)

### 4. "Tablespace fill check"

Path: **52** (Tablespace Usage) → **51** if you need datafile detail
→ **74** for the top 50 segments by size

```
  Con Tablespace Name         Bytes(MB)     Used(MB)  Percent(%)     Free(MB)  Free(%) MaxBytes(MB)
----- -------------------- ------------ ------------ ----------- ------------ -------- ------------
    1 SYSAUX                        690          653       94.65           37     5.35       32,768
    1 SYSTEM                        700          633       90.38           67     9.63       32,768
    3 SYSTEM                        360          353       98.06            7     1.94       32,768
    4 IOPS                        1,024            1         .10        1,023    99.90            0
```

### 5. "Investigate a specific session"

Path: **45** (Session Event) — prompts for SIDs:

```
 Choose the Number or Command : 45
Enter Session ID (ex: 9,10,12) : 1228,65
```

Then:

```
       SID EVENT                                    TOTAL_WAITS  TIME_WAITED  AVERAGE_WAIT  MAX_WAIT   Con
---------- --------------------------------------- ------------ ------------ ------------- ---------- -----
      1228 db file sequential read                       18,243        2,431          0.13         15     4
      1228 enq: TM - contention                              12        1,205        100.42        892     4
        65 SQL*Net message from client                    9,842       12,033          1.22         34     4
```

### 6. "Continuous monitor during a load test"

Path: **M** (Auto Refresh Monitoring) → choose option name + interval.
This calls `monitor/auto_refresh.sh` under the hood.

```
 Choose the Number or Command : M
================================
 Oracle Auto Refresh Monitoring
================================

Usage : .../auto_refresh.sh <Option> <Interval>

   Option     Description
   --------   -----------------------------------
   redowait   redo wait statistics
   runsess    current active session
   session    current session
   ...
   topwait    top wait events
   tempseg    temp segment usage
   tran       current transaction

Option   : runsess
Interval : 5
```

The screen now refreshes every 5 seconds, showing current active
sessions. Press `X<ENTER>` to stop.

You can also run `auto_refresh.sh` directly without going through the
menu:

```sh
monitor/auto_refresh.sh topwait 10        # top wait events every 10 s
monitor/auto_refresh.sh swait   3         # session wait info every 3 s
monitor/auto_refresh.sh tempseg 30        # temp usage every 30 s
```

### 7. "Save a full report to a file"

Path: **S** (Save To File) — confirms with `Y`, writes
`monitor/log/monitor_<timestamp>.log` containing every category in one
sweep. Useful for sharing a snapshot during an incident.

```
 Choose the Number or Command : S
==========================
 Oracle Monitoring Report
==========================
Create Monitoring Report? (Y/N): Y
... (runs every report, spools to monitor/log/monitor_YYMMDDHHMM.log)
```

## Connecting to a multitenant DB

The default `system/manager` connection from `monitor/monitor` lands
in **CDB$ROOT**. From there:

- `v$session`, `v$lock`, `v$sqlarea` etc. show **all containers** at
  once — the `Con` column in each report tells you which PDB owns the
  row.
- `CDB_*` dictionary views (used by space/object reports) show every
  PDB's tablespaces, datafiles, segments, and objects.

If you connect directly to a PDB instead (`DB_USER=app DB_PASS=… ` with
a service for that PDB), each report will only show that PDB's data —
the `Con` column will be a single value.

## Running individual reports without the menu

Each `monitor/sql/*.sql` file is a standalone sqlplus script:

```sh
cd oracle_shell_monitor/monitor
export MONITOR=$PWD
sqlplus -s -L 'system/manager' @sql/3_run_session.sql
sqlplus -s -L 'system/manager' @sql/5_tablespace.sql
sqlplus -s -L 'system/manager' @sql/8_topquery.sql
```

This is convenient for piping into `grep`/`awk`, scheduled snapshots,
or embedding in other shell scripts.

## Generated runtime files

Created on first run, ignored by Git:

- `monitor/log/monitor_YYMMDDHHMM.log` — saved reports from menu **S**
- `monitor/sql/0_save_file.sql` — generated by `monitor/sql/0_save_file.sh`
- `monitor/sql/4_session_event.sql` — generated each time menu **45** is used
- `monitor/sql/sqlid_format.sql` — generated by `monitor/monitor` and `monitor/auto_refresh.sh`

## Requirements

- Oracle Database 19c (CDB or non-CDB)
- `sqlplus` on `$PATH`
- DBA catalog access (`system/manager` or any user with
  `SELECT_CATALOG_ROLE`); for cross-PDB visibility, connect as a
  common user to `CDB$ROOT`
- POSIX shell (`/bin/sh`); developed on Linux x86_64
- Diagnostic Pack license **only** when using AWR menu items (9*)

## More documentation

See [`monitor/README.md`](monitor/README.md) for:

- Full menu reference table
- `auto_refresh.sh` option list
- Implementation notes
- Troubleshooting (`ORA-01017`, `ORA-00942`, etc.)
