#!/usr/bin/env python3
"""
perfrun.py - build and run the sieve / e / tm / ttt benchmarks for each compiler
and record the numbers used by images/table.xlsx:

    sieve ms, e ms, tm ms, ttt ms (per iteration), ttt app file size

Times are ntvcm's "approx ms at 4Mhz" (emulated cycles / 4000), so they don't
depend on how fast this machine is or how many runs happen in parallel.

Each compiler is built and run in a temporary copy of its folder. Nothing in
the repo is modified; all binaries and temp files are deleted when the run
finishes or is interrupted. Results go to perfrun_results.csv, with rows named
exactly as in column A of the spreadsheet. A benchmark whose output doesn't
show the expected result (e.g. 1899 primes, 6493 moves) is recorded as FAIL.

usage: perfrun.py [-j jobs] [-t seconds] [-k] [--ntvcm path] [name-filter ...]

Works on Linux, macOS, and Windows (Python 3.8+). perfrun.sh and perfrun.bat
are wrappers for this script.
"""

import argparse
import concurrent.futures
import csv
import os
import re
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time

IS_WINDOWS = os.name == "nt"

# One line per spreadsheet row. Fields are separated by '|'; '-' means none.
#   name    : spreadsheet row name (column A)
#   folder  : folder in this repo
#   benches : benchmarks to run
#   build   : m = the folder's m.sh (m.bat on Windows), plm = Intel PL/M tools,
#             systemz = scripted BASIC/Z session, - = none (interpreters),
#             or an ntvcm command line
#   run     : com = ntvcm -c -p {B}.COM, @m = timing printed by the build itself,
#             or an ntvcm command line (may end with <file for keyboard input)
#   tttdiv  : ttt iterations performed by the benchmark (sheet shows per-iteration ms)
#   size    : file whose size is the "ttt app file size" (A-B means size(A)-size(B))
#   sieve   : - or a scale applied as a spreadsheet formula (smaller sieve arrays)
#   flags   : optional; serial = run alone after everything else (see TDL below)
# {B} is replaced by the benchmark name in uppercase (SIEVE, E, TM, TTT).
TABLE = r"""
8080 Assembly|asm|sieve,e,ttt|m|com|1|TTT.COM|-
Intel PL/M-80 v4.1 (PDP-10 Fortran)|intel plm-80 v4.1|sieve,e,ttt|plm|com|1|TTT.COM|-
Z80 Assembly|m80|sieve,e,ttt|m|com|1|TTT.COM|-
Microsoft BASIC  Rev. 4.51|microsoft basic-80 v451|sieve,e,ttt|-|ntvcm -c -p OBASIC {B}.BAS|1|TTT.BAS|-
TDL Z-80 8-K BASIC sbasic v1.3|tdl z-80 8-k BASIC v1.3|sieve,e,ttt|-|ntvcm -p SBASIC <{B}.TXT|1|TTT.BAS|-|serial
Algol-M v1.1|Algol-M v11|sieve,e,ttt|ntvcm ALGOLM.COM {B}|ntvcm -c -p RUNALG.COM {B}|1|TTT.AIN|-
RML Algol v4.1C|rml algol60 v41c|sieve,e,ttt|ntvcm ALGOL.COM {B}|ntvcm -c -p ARUN.COM {B}|10|TTT.ASC|-
Microsoft BASIC Rev. 5.03|microsoft basic-80 v503|sieve,e,ttt|-|ntvcm -c -p MBASIC {B}.BAS|1|TTT.BAS|-
BDS C v1.1|bds c v11|sieve,e,ttt|m|com|10|TTT.COM|-
Sorcim PASCAL/M v12.08|Sorcim Pascal M v12.08|sieve,e,ttt|ntvcm -c PRUN PASCAL {B}.PAS, L={B}.LST|ntvcm -c -p PRUN {B}.PCO|10|TTT.PCO|-
Tarbell BASIC v10.7|tbasic v10.7 and v12.10|sieve,e,ttt|-|ntvcm -c -p TBASIC <{B}.TXT|1|TTT.BAS|-
Tarbell BASIC v12.10|tbasic v10.7 and v12.10|sieve,e,ttt|-|ntvcm -c -p TBASIC12 <{B}.TXT|1|TTT.BAS|-
BDS C v1.3|bds c v13|sieve,e,ttt|m|com|10|TTT.COM|-
Whitesmith C v2.0|Whitesmith C v2|sieve,e,ttt|m|com|10|TTT.COM|-
Whitesmith C v2.1|Whitesmith C v2.1|sieve,e,ttt|m|com|10|TTT.COM|-
Whitesmith Pascal (built on C v2.1)|Whitesmith Pascal|sieve,e,ttt|m|com|10|TTT.COM|-
Microsoft BASIC Rev. 5.1|microsoft basic-80 v51|sieve,e,ttt|-|ntvcm -c -p MBASIC {B}.BAS|1|TTT.BAS|-
Microsoft BASIC Rev. 5.2 (apple II CP/M)|microsoft basic-80 v52|sieve,e,ttt|-|ntvcm -c -p MBASICA {B}.BAS|1|TTT.BAS|-
MT MicroSYSTEMS Pascal/MT Compiler v3.0b|mt pascal v3.0b|sieve,e,ttt|m|com|10|TTT.COM|-
G.Ohnysty S-BASIC v5.4b|g Ohnysty S-BASIC v5.4b|sieve,e,ttt|ntvcm -8 SBASIC {B}.BAS|ntvcm -c -p -n {B}.COM|1|TTT.COM|-
Transam TCL Pascal v1.4|transam tcl pascal v1.4|sieve,e,ttt|m|com|10|TTT.COM|-
Systems Consultants PLMX v2.3|Systems Consultants PLMX v23|sieve,e,ttt|m|com|1|TTT.COM|-
Digital Research PL/I-80 v1.0|dr pli-80 v1|sieve,e,ttt|m|com|1|TTT.COM|-
InterSystems Pascal/Z v4.0|InterSystems Pascal-Z v4|sieve,e,ttt|m|com|10|TTT.COM|-
Microsoft COBOL-80 v4.01|Microsoft Cobol v401|sieve,e,ttt|m|com|1|TTT.COM|-
Pascal Pascal (Robert A Van Valzah) v1|pascal pascal Robert A. Van Valzah v1|sieve,e,ttt|m|com|10|TTT.COM|-
Pascal Pascal (Robert A Van Valzah) v2|pascal pascal Robert A. Van Valzah|sieve,e,ttt|m|com|10|TTT.COM|-
Digital Research MT+ Pascal v5.2|DR MT+ Pascal v52|sieve,e,ttt|m|com|10|TTT.COM|-
Sorcim PASCAL/M v1981 8080|Sorcim Pascal M 1981|sieve,e,ttt|ntvcm -c PRUN PASCAL {B}.PAS, L={B}.LST|ntvcm -c -p PRUN {B}.PCO|10|TTT.PCO|-
Sorcim PASCAL/M v1981 Z80|Sorcim Pascal M 1981|sieve,e,ttt|ntvcm -c PRUN PASCAL {B}.PAS, L={B}.LST|ntvcm -c -p PRUNZ80 {B}.PCO|10|TTT.PCO|-
BLS Pascal v1.0|BLS Pascal v1.0|sieve,e,ttt|m|com|10|TTT.COM|-
BASICE v2.1 + run.com v2.3|basice|sieve,e,ttt|ntvcm BASIC {B}.BAS|ntvcm -c -p RUN {B}.INT|1|TTT.INT|-
BDS C v1.44|bds c v144|sieve,e,ttt|m|com|10|TTT.COM|-
Microsoft FORTRAN-80 v3.44|Microsoft fortran v344|sieve,e,ttt|m|com|10|TTT.COM|-
Compiler Systems CB80 BASIC v1.00|Compiler Systems CB80 v1|sieve,e,ttt|m|com|1|TTT.COM|-
Digital Research CB80 BASIC v1.3|dr cbasic v1.3|sieve,e,ttt|m|com|1|TTT.COM|-
Digital Research MT+ Pascal v5.5|DR MT+ Pascal v55|sieve,e,ttt|m|com|1|TTT.COM|-
Clive Partridge BCPL|Clive Partridge BCPL|sieve,e,ttt|m|com|10|TTT.COM|-
Microsoft BASIC-80 Rev. 5.21|Microsoft BASIC-80 v521|sieve,e,ttt|-|ntvcm -c -p MBASIC {B}.BAS|1|TTT.BAS|-
Microsoft BASCOM v5|Microsoft BASCOM v5|sieve,e,ttt|m|com|10|TTT.COM|-
Q/C Compiler v1.0|qc compiler v1|sieve,e,ttt|m|com|10|TTT.COM|-
SuperSoft Ada v1.00a|supersoft ada v100a|sieve,e,ttt|m|com|10|TTT.COM|-
SuperSoft Ada v1.20a|supersoft ada v120a|sieve,e,ttt|m|com|10|TTT.COM|-
Janus ADA v1.4.5|Janus Ada v145|sieve,e,ttt|m|com|10|TTT.COM|-
Prospero Software Pro Pascal v2.1|pro pascal v2.1|sieve,e,ttt|m|com|10|TTT.COM|-
JRT Pascal v2.0|JRT Pascal v2|sieve,e,ttt|ntvcm JRTPAS2 {B}|ntvcm -c -p EXEC {B}.INT|10|TTT.INT|-
JRT Pascal v2.2|JRT Pascal v22|sieve,e,ttt|ntvcm JRTPAS2 {B}|ntvcm -c -p EXEC {B}.INT|10|TTT.INT|-
BDS C v1.50a|bds c v150|sieve,e,tm,ttt|m|com|10|TTT.COM|-
Digital Research PL/I-80 v1.3|dr pli-80 v13|sieve,e,ttt|m|com|1|TTT.COM|-
Digital Research PL/I-80 v1.4|dr pli-80 v14|sieve,e,ttt|m|com|1|TTT.COM|-
Microsoft COBOL v4.65|Microsoft Cobol v465|sieve,e,ttt|m|com|1|TTT.COM|-
SuperSoft C v1.1.25|SuperSoft C v1125|sieve,e,ttt|m|com|10|TTT.COM|-
Whitesmith C v2.2|Whitesmith C v2.2|sieve,e,tm,ttt|m|com|10|TTT.COM|-
System/z BASIC/Z v1.11|SystemZ BASICZ v111|sieve,e,ttt|systemz|com|10|TTT.COM|-
Nevada NVBASIC v2.2|Nevada BASIC v2.2|sieve,e,ttt|-|ntvcm -n -c -p BASIC {B}|10|TTT.BAS|*8190/4195
Nevada FORTRAN v3.0 (mod 0)|Nevada fortran v3|sieve,e,ttt|m|com|1|TTT.COM|*8190/2000
SuperSoft FORTRAN v3.2|SuperSoft fortran v32|sieve,e,ttt|m|com|1|TTT.COM|-
SuperSoft Ada v2.10|SuperSoft ada v21|sieve,e,ttt|m|com|1|TTT.COM|-
Digital Research CBASIC CB-80 v2.0|dr CBASIC v2|sieve,e,ttt|m|com|1|TTT.COM|-
COMPAS-80 v3.03|COMPAS-80 v3.03|sieve,e,ttt|m|com|10|TTT.COM|-
Borland Turbo Pascal v1.00|borland turbo pascal v1|sieve,e,ttt|m|com|1|TTT.COM|-
Digital Research MT+ Pascal v5.6.1|dr mt+ pascal v561|sieve,e,ttt|m|com|1|TTT.COM|-
JRT Pascal v3.0|JRT Pascal v3|sieve,e,ttt|ntvcm JRTPAS3 {B}|ntvcm -c -p EXEC {B}.INT|10|TTT.INT|-
JRT Pascal v4.0|jrt pascal v4|sieve,e,ttt|ntvcm PAS4 {B}|ntvcm -c -p EXEC4 {B}.INT|10|TTT.INT|-
MANX Aztec C v1.05|manx aztec c v105|sieve,e,ttt|m|com|10|TTT.COM|-
MI - C v3.18I|mi - c v318|sieve,e,ttt|m|com|1|TTT.COM|-
Q/C Compiler v3.1a|qc compiler v31a|sieve,e,ttt|m|com|10|TTT.COM|-
Software Tookworks C/80 v3.0|software toolworks c 80 v3.0|sieve,e,tm,ttt|m|com|1|TTT.COM|-
Software Tookworks C/80 v3.0a|software toolworks c 80 v3.0a|sieve,e,tm,ttt|m|com|1|TTT.COM|-
8080 Forth 83 v2.1.0|8080 Forth 83 v2.1.0|sieve,e,ttt|-|ntvcm -n -c -p F83.COM <{B}.F|10|TTT.F|-
8080 Forth 83 v2.1.1|8080 Forth 83 v2.1.1|sieve,e,ttt|-|ntvcm -n -c -p F83.COM <{B}.F|10|TTT.F|-
Nevada NVBASIC v2.5|Nevada BASIC v2.5|sieve,e,ttt|-|ntvcm -n -c -p NVBASIC {B}|10|TTT.BAS|*8190/4195
JRT Modula-2 v1.0|JRT Modula-2 v1|sieve,e,ttt|m|@m|10|TTT.LIB-MODULA.LIB|-
Small-C v1.2|small-c v12|sieve,e,ttt|m|com|10|TTT.COM|-
BDS C v1.60|BDS C v160|sieve,e,tm,ttt|m|com|10|TTT.COM|-
BDS C vZ2.0 (for ZCPR3)|bds c vZ20|sieve,e,tm,ttt|m|com|10|TTT.COM|-
Janus Ada v1.5.0|Janus Ada v150|sieve,e,ttt|m|com|1|TTT.COM|-
Borland Turbo Pascal v2.00A|borland turbo pascal v2|sieve,e,ttt|m|com|1|TTT.COM|-
MANX Aztec C v1.06B|manx aztec c v106b|sieve,e,tm,ttt|m|com|1|TTT.COM|-
MANX Aztec C v1.06D|manx aztec c v106d|sieve,e,tm,ttt|m|com|1|TTT.COM|-
Software Tookworks C/80 v3.1|software toolworks c80 v3.1|sieve,e,tm,ttt|m|com|1|TTT.COM|-
Draco v2.3|draco v2.3|sieve,e,ttt|m|com|10|TTT.COM|-
Hochstrasser Modula-2 v2.01|Hochstrasser Modula-2 v201|sieve,e,ttt|m|com|10|TTT.COM|-
Borland Turbo Pascal v3.01A|borland turbo pascal v3|sieve,e,ttt|m|com|1|TTT.COM|-
Eco-C v3.43|eco-c v343|sieve,e,tm,ttt|m|com|1|TTT.COM|-
HiSoft HI-TECH C v1.35|hisoft hi-tech c v135|sieve,e,tm,ttt|m|com|1|TTT.COM|-
Mix C v2.0.0|mix c v2|sieve,e,ttt|m|com|10|TTT.COM|-
Mix C v2.1.0|mix c v2.1|sieve,e,ttt|m|com|10|TTT.COM|-
Oxford Pascal v2.1|Oxford Pascal v21|sieve,e,ttt|m|com|10|TTT.COM|-
HiSoft Pascal 30 October 1985|hisoft pascal 1985|sieve,e,ttt|m|com|10|TTT.COM|-
HiSoft Pascal 30 May 1986|hisoft pascal 1986|sieve,e,ttt|m|com|10|TTT.COM|-
Borland Turbo Modula-2 (interpreted)|borland turbo modula-2|sieve,e,ttt|m|ntvcm -c -p M2RUN {B}|1|TTT.MCD|-
Borland Turbo Modula-2 (compiled)|borland turbo modula-2|sieve,e,ttt|m|com|1|TTT.COM|-
Small-C v2.7|small-c v27|sieve,e,ttt|m|com|10|TTT.COM|-
FTL Modula-2 v1.18|ftl modula-2 v118|sieve,e,ttt|m|com|10|TTT.COM|-
Arnor BCPL v2.00|Arnor BCPL v2.00|sieve,e,ttt|m|com|10|TTT.COM|-
S. Kelley Z80 BCPL|z80 BCPL|sieve,e,ttt|m|com|10|TTT.COM|-
HiSoft HI-TECH C v3.09|hisoft hi-tech c v3.09|sieve,e,tm,ttt|m|com|1|TTT.COM|-
Small-C/Plus v1.00|small-c plus v1|sieve,e,tm,ttt|m|com|10|TTT.COM|-
FTL Modula-2 v1.30|ftl modula-2 v130|sieve,e,ttt|m|com|10|TTT.COM|-
Z80 CamelForth v1.01|Z80 CamelForth v101|sieve,e,ttt|-|ntvcm -c -p CAMEL80 <{B}.F|10|TTT.F|-
DX-Forth v4.30|DX-FORTH for CPM 4.30|sieve,e,ttt|-|ntvcm -c -p FORTH.COM - include {B}.F {B} bye|10|TTT.F|-
DX-Forth v4.56|DX-FORTH for CPM 4.56|sieve,e,ttt|-|ntvcm -c -p FORTH.COM - include {B}.F {B} bye|10|TTT.F|-
MESCC v1.24 - 14 Sep 2021|MESCC v1.24|sieve,e,tm,ttt|m|com|10|TTT.COM|-
Cowgol 0.6.1|Cowgol 0.6.1/all|sieve,e,ttt|m|com|10|TTT.COM|-
"""

# TDL BASIC can't load text files, so its programs are typed in from a .TXT
# file that ends with filler and ^X (its only way back to CP/M). ntvcm hands
# typed keys to a polling program at a rate tied to real time, so on a busy
# machine the ^X can arrive before the benchmark finishes. That row runs on its
# own after everything else and is retried if its output is incomplete.
SERIAL_RETRIES = 3

# Spreadsheet rows this script can't produce.
NOT_COVERED = [
    "HiSoft HI-TECH C v4.11 (DOS x-comp), BA BASIC compiler, PASTA/80, "
    "Z88DK sccz80/zsdcc, pint, dcc (cross-compilers)",
]

# Text a correct run prints; without it the timing is meaningless.
EXPECTED = {
    "sieve": re.compile(rb"\b(1899|1548|1027|551)\b"),  # smaller sieves: tbasic, Nevada
    "e": re.compile(rb"(?i)\bdo(ne)?\b|27182818"),
    "tm": re.compile(rb"(?i)success"),
    "ttt": re.compile(rb"6493"),
}

MS_RE = re.compile(rb"approx ms at \d+Mhz:\s*([\d,]+)")

print_lock = threading.Lock()
active_procs = set()
active_lock = threading.Lock()
stopping = threading.Event()


def say(text=""):
    with print_lock:
        print(text, flush=True)


class Row:
    def __init__(self, index, line):
        f = line.split("|")
        self.index = index
        self.name, self.folder, benches, self.build, self.run = f[:5]
        self.benches = benches.split(",")
        self.tttdiv = int(f[5])
        self.size = f[6]
        self.sieve_scale = f[7]
        self.serial = len(f) > 8 and f[8] == "serial"


def parse_table():
    return [Row(i, l) for i, l in enumerate(l for l in TABLE.splitlines() if l.strip())]


def kill_tree(p):
    try:
        if IS_WINDOWS:
            subprocess.run(["taskkill", "/T", "/F", "/PID", str(p.pid)],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            os.killpg(p.pid, signal.SIGKILL)
    except (OSError, ProcessLookupError):
        pass


def run_proc(args, cwd, env, timeout, stdin_path=None):
    """Run a command, return (output bytes, timed_out). Kills the whole process
    tree on timeout (m.sh / m.bat start ntvcm as a child)."""
    if stopping.is_set():
        return b"", False
    stdin = open(stdin_path, "rb") if stdin_path else subprocess.DEVNULL
    kw = {}
    if IS_WINDOWS:
        kw["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kw["start_new_session"] = True
    try:
        p = subprocess.Popen(args, cwd=cwd, env=env, stdin=stdin,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT, **kw)
    except OSError as e:
        if stdin_path:
            stdin.close()
        return ("error starting %s: %s\n" % (args[0], e)).encode(), False
    with active_lock:
        active_procs.add(p)
    try:
        out, _ = p.communicate(timeout=timeout)
        return out, False
    except subprocess.TimeoutExpired:
        kill_tree(p)
        out, _ = p.communicate()
        return out + b"\n[perfrun: timed out]\n", True
    finally:
        with active_lock:
            active_procs.discard(p)
        if stdin_path:
            stdin.close()


class Runner:
    def __init__(self, args, root, work, ntvcm):
        self.args = args
        self.root = root
        self.work = work
        self.ntvcm = ntvcm
        self.env = dict(os.environ)
        self.env["PATH"] = os.path.dirname(ntvcm) + os.pathsep + self.env.get("PATH", "")
        self.plm = None
        ntvcm_repo = os.environ.get("NTVCM") or os.path.join(root, "..", "ntvcm")
        compile_py = os.path.join(ntvcm_repo, "plm80", "compile.py")
        if os.path.isfile(compile_py):
            self.plm = os.path.abspath(compile_py)

    def command(self, text, B):
        """Table command line -> (argv, stdin file or None)."""
        text = text.replace("{B}", B)
        cmd, _, stdin_file = text.partition("<")
        argv = shlex.split(cmd)
        if argv[0] == "ntvcm":
            argv[0] = self.ntvcm
        return argv, (stdin_file.strip() or None)

    def run_entry(self, row):
        d = os.path.join(self.work, "%03d" % row.index)
        log = []
        result = {"notes": ""}
        try:
            shutil.copytree(os.path.join(self.root, row.folder), d,
                            ignore=shutil.ignore_patterns("*.pdf", "*.PDF"))
            if not IS_WINDOWS:
                # CP/M wants uppercase names; uppercase lowercase benchmark files
                for f in os.listdir(d):
                    base = f.split(".")[0]
                    if base in ("sieve", "e", "tm", "ttt") and not os.path.exists(os.path.join(d, f.upper())):
                        os.rename(os.path.join(d, f), os.path.join(d, f.upper()))
            for b in row.benches:
                tries = SERIAL_RETRIES if row.serial else 1
                for attempt in range(tries):
                    value, out = self.run_bench(row, b, d, log, result)
                    if value != "FAIL" or stopping.is_set():
                        break
                    if attempt + 1 < tries:
                        log.append(b"[perfrun: incomplete output, retrying]\n")
                result[b] = value
        except OSError as e:
            log.append(("perfrun: %s\n" % e).encode())
            for b in row.benches:
                result.setdefault(b, "FAIL")
        finally:
            shutil.rmtree(d, ignore_errors=True)
            try:
                with open(os.path.join(self.work, "results", "%03d.log" % row.index), "wb") as f:
                    f.write(b"".join(log).replace(b"\0", b""))
            except OSError:
                pass  # work dir already removed after Ctrl-C
        return result

    def run_bench(self, row, b, d, log, result):
        B = b.upper()
        t = self.args.timeout
        build_out = b""

        if row.build != "-":
            com = os.path.join(d, B + ".COM")
            if os.path.exists(com):
                os.remove(com)
            if row.build == "m":
                if IS_WINDOWS:
                    argv = ["cmd", "/d", "/c", r".\m.bat", b]
                else:
                    argv = ["bash", "m.sh", b]
                build_out, _ = run_proc(argv, d, self.env, t)
            elif row.build == "plm":
                if not self.plm:
                    result["notes"] = "needs NTVCM=<ntvcm repo> with plm80/compile.py"
                    if b == "ttt":
                        result["size"] = "SKIP"
                    return "SKIP", b""
                build_out, _ = run_proc([sys.executable, self.plm, B + ".PLM", "-o", B + ".COM"], d, self.env, t)
            elif row.build == "systemz":
                build_out = self.systemz(b, d)
            else:
                argv, stdin_file = self.command(row.build, B)
                build_out, _ = run_proc(argv, d, self.env, t,
                                        os.path.join(d, stdin_file) if stdin_file else None)

        if row.run == "@m":
            out = build_out
        elif row.run == "com":
            if os.path.exists(os.path.join(d, B + ".COM")):
                out, _ = run_proc([self.ntvcm, "-c", "-p", B + ".COM"], d, self.env, t)
            else:
                out = b"[perfrun: build produced no %s.COM]\n" % B.encode()
        else:
            argv, stdin_file = self.command(row.run, B)
            out, _ = run_proc(argv, d, self.env, t, os.path.join(d, stdin_file) if stdin_file else None)

        log.append(("===== %s: %s build\n" % (row.name, B)).encode() + build_out)
        log.append(("===== %s: %s run\n" % (row.name, B)).encode() + out)

        m = MS_RE.findall(out)
        if not m or not EXPECTED[b].search(out):
            result["fail_%s" % b] = build_out[-1500:] + b"\n----- run:\n" + out[-1500:]
            return "FAIL", out
        ms = int(m[-1].replace(b",", b""))

        if b == "ttt":
            value = str((ms + row.tttdiv // 2) // row.tttdiv)
            result["size"] = self.ttt_size(row, d)
        elif b == "sieve" and row.sieve_scale != "-":
            value = "=%d%s" % (ms, row.sieve_scale)
        else:
            value = str(ms)
        return value, out

    def ttt_size(self, row, d):
        a, _, sub = row.size.partition("-")
        pa = os.path.join(d, a)
        if not os.path.isfile(pa):
            return "FAIL"
        s = os.path.getsize(pa)
        if sub and os.path.isfile(os.path.join(d, sub)):
            s -= os.path.getsize(os.path.join(d, sub))
        return str(s)

    def systemz(self, b, d):
        """System/z BASIC/Z has no command-line build; drive BZ.COM with typed
        input. BZ restarts itself after compile and then waits for input
        forever, so the first session is stopped after 30 seconds."""
        B = b.upper()
        for ext in (".BZO", ".BZS"):
            p = os.path.join(d, B + ext)
            if os.path.exists(p):
                os.remove(p)
        with open(os.path.join(d, "IN1.TXT"), "wb") as f:
            f.write(("load %s.bas\r\nsave %s\r\ncompile %s\r\n" % (b, b, b)).encode())
        with open(os.path.join(d, "IN2.TXT"), "wb") as f:
            f.write(("bind\r\nrz\r\n%s\r\n%s\r\ndos\r\n" % (b, b)).encode())
        out1, _ = run_proc([self.ntvcm, "-c", "BZ.COM"], d, self.env, 30, os.path.join(d, "IN1.TXT"))
        out2, _ = run_proc([self.ntvcm, "-c", "BZ.COM"], d, self.env, self.args.timeout, os.path.join(d, "IN2.TXT"))
        return out1 + out2


def find_ntvcm(explicit):
    if explicit:
        return os.path.abspath(explicit) if os.path.isfile(explicit) else None
    name = "ntvcm.exe" if IS_WINDOWS else "ntvcm"
    # search the PATH only, not the current directory
    for p in os.environ.get("PATH", "").split(os.pathsep):
        c = os.path.join(p.strip('"'), name)
        if p and os.path.isfile(c):
            return os.path.abspath(c)
    if IS_WINDOWS and os.path.isfile(r"c:\ntbin\ntvcm.exe"):
        return r"c:\ntbin\ntvcm.exe"
    return None


def fmt(v):
    return v if v else "-"


def main():
    ap = argparse.ArgumentParser(
        description="Build and time the sieve/e/tm/ttt benchmarks for each compiler; "
                    "writes perfrun_results.csv for images/table.xlsx.")
    ap.add_argument("filters", nargs="*",
                    help="only run rows whose spreadsheet name or folder contains one of these (case-insensitive)")
    ap.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 4,
                    help="compilers to run in parallel (default: number of cpus)")
    ap.add_argument("-t", "--timeout", type=int, default=1800,
                    help="timeout in seconds for each build/run step (default 1800)")
    ap.add_argument("-k", "--keep-logs", action="store_true",
                    help="keep the build/run logs (the binaries are still deleted)")
    ap.add_argument("--ntvcm", help="path to ntvcm (default: search the PATH"
                    + (r", then c:\ntbin" if IS_WINDOWS else "") + ")")
    args = ap.parse_args()

    root = os.path.dirname(os.path.abspath(__file__))
    ntvcm = find_ntvcm(args.ntvcm)
    if not ntvcm:
        sys.exit("perfrun: can't find ntvcm; put it on the PATH or use --ntvcm")

    rows = parse_table()
    if args.filters:
        fl = [f.lower() for f in args.filters]
        rows = [r for r in rows if any(f in (r.name + "|" + r.folder).lower() for f in fl)]
        if not rows:
            sys.exit("perfrun: no rows match: " + " ".join(args.filters))

    work = tempfile.mkdtemp(prefix="perfrun.")
    os.makedirs(os.path.join(work, "results"))
    runner = Runner(args, root, work, ntvcm)
    results = {}
    start = time.time()

    say("perfrun: %d compilers, %d at a time, using %s" % (len(rows), args.jobs, ntvcm))

    def do(row):
        res = runner.run_entry(row)
        results[row.index] = res
        say("  %-45s sieve %-10s e %-8s tm %-8s ttt %-8s size %s" % (
            row.name, fmt(res.get("sieve")), fmt(res.get("e")), fmt(res.get("tm")),
            fmt(res.get("ttt")), fmt(res.get("size"))))

    pool = concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs))
    try:
        pending = {pool.submit(do, r) for r in rows if not r.serial}
        while pending:
            # short waits so Ctrl-C is seen promptly (also on Windows)
            done, pending = concurrent.futures.wait(pending, timeout=1)
            for f in done:
                f.result()
        pool.shutdown()
        for r in rows:
            if r.serial:
                do(r)
    except KeyboardInterrupt:
        say("\nperfrun: interrupted, cleaning up")
        stopping.set()
        with active_lock:
            for p in list(active_procs):
                kill_tree(p)
        pool.shutdown(wait=True, cancel_futures=True)
        shutil.rmtree(work, ignore_errors=True)
        sys.exit(130)

    out_csv = os.path.join(root, "perfrun_results.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["compiler", "sieve ms", "e ms", "tm ms", "ttt ms", "ttt app file size", "notes"])
        for r in rows:
            res = results.get(r.index, {})
            w.writerow([r.name, res.get("sieve", ""), res.get("e", ""), res.get("tm", ""),
                        res.get("ttt", ""), res.get("size", ""), res.get("notes", "")])

    failed = [r for r in rows if "FAIL" in results.get(r.index, {}).values()]
    if failed:
        say("\nFailures (last lines of build and run output):")
        for r in failed:
            res = results[r.index]
            for b in r.benches:
                detail = res.get("fail_%s" % b)
                if detail is None:
                    continue
                say("---- %s: %s" % (r.name, b))
                text = detail.replace(b"\0", b"").decode("latin-1").replace("\r", "")
                build, _, run = text.partition("\n----- run:\n")
                for label, part in (("build", build), ("run", run)):
                    lines = [l for l in part.split("\n") if l.strip()]
                    say("  %s:%s" % (label, "" if lines else " (no output)"))
                    for l in lines[-6:]:
                        say("    " + l)
            if res.get("size") == "FAIL":
                say("---- %s: ttt size file %s not found" % (r.name, r.size))

    say("\nNot covered by this script:")
    for n in NOT_COVERED:
        say("  " + n)

    if args.keep_logs:
        say("\nperfrun: kept build/run logs in " + os.path.join(work, "results"))
    else:
        shutil.rmtree(work, ignore_errors=True)
    say("\nResults: %s (%ds)" % (out_csv, time.time() - start))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
