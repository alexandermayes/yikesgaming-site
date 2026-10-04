#!/usr/bin/env python3
"""Big Yikes voice check: flags site copy that drifts from the voice guide (.claude/skills/big-yikes-voice/SKILL.md).

    python tools/voice-check.py                 # pages changed since the last commit
    python tools/voice-check.py index.html bot/terms.html

Two passes over the visible text of each page:
  1. Rules (instant, offline): the guide's banned words and moves, "clan" (we're a guild), exclamation marks outside quoted
     game text, emoji used as icons.
  2. Jev (TypeSafe's System One model) for the judgement calls rules can't make: hype or marketing tone, vague claims where
     the guide wants real numbers, and buttons that don't say what happens. Needs TYPESAFE_API_KEY (env or the Windows user
     environment); skipped without it. One request per page, one Noul question per line, so it costs fractions of a cent.
Exit code 1 when anything is flagged, so it can run as a pre-commit check.
"""
from __future__ import annotations

import html
import json
import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BANNED = ["unleash", "elevate", "seamless", "journey", "epic adventure", "dive in", "embark", "ultimate", "vibrant",
          "next-level", "game-changer", "welcome to the", "whether you're", "it's not just"]
EMOJI = re.compile("[\U0001F300-\U0001FAFF☀-➿]")
JEV_THRESHOLD = 0.7


def typesafe_key() -> str | None:
    key = os.environ.get("TYPESAFE_API_KEY")
    if key or os.name != "nt":
        return key
    try:
        import winreg
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment") as k:
            return str(winreg.QueryValueEx(k, "TYPESAFE_API_KEY")[0]) or None
    except OSError:
        return None


def visible_lines(markup: str) -> list[str]:
    markup = re.sub(r"(?is)<(script|style|template|svg|head)\b.*?</\1>", " ", markup)
    markup = re.sub(r"(?i)<br\s*/?>|</(p|h[1-6]|li|a|button|summary|div|span|td|th|label|figcaption|small|b|strong)>", "\n", markup)
    text = html.unescape(re.sub(r"<[^>]+>", " ", markup))
    lines = [re.sub(r"\s+", " ", l).strip() for l in text.split("\n")]
    seen, out = set(), []
    for l in lines:
        if len(l) >= 3 and re.search(r"[A-Za-z]", l) and l not in seen:
            seen.add(l)
            out.append(l)
    return out


def rule_flags(line: str) -> list[str]:
    low = line.lower()
    flags = [f'banned: "{w}"' for w in BANNED if re.search(r"\b" + re.escape(w) + r"\b", low)]
    if re.search(r"\bclans?\b", low):
        flags.append('say "guild", not "clan"')
    if "!" in re.sub(r'"[^"]*"|“[^”]*”', "", line) and not line.strip().endswith("Yikes!"):
        flags.append("exclamation mark outside quoted game text")
    if EMOJI.search(line):
        flags.append("emoji used as an icon")
    if low.strip(" .") in ("submit", "get started", "learn more", "click here", "read more"):
        flags.append("generic button: say what happens (e.g. \"Join the Discord\")")
    return flags


def jev_flags(lines: list[str], key: str) -> dict[int, list[str]]:
    questions = {}
    for i, line in enumerate(lines[:60]):
        questions[f"hype{i}"] = {"type": "noul", "instructions": f"Is `lines[{i}]` hype or marketing-speak (sales tone, superlatives, empty excitement) instead of plain, warm guild talk?"}
        questions[f"vague{i}"] = {"type": "noul", "instructions": f"Does `lines[{i}]` make a vague claim (\"tons\", \"lots\", \"amazing\") where a real number or a specific fact would be clearer? Answer no for headings and button labels."}
    body = json.dumps({"model": "jev-latest", "state": {"site": "Big Yikes, a WoW and Valheim gaming guild", "lines": lines[:60]}, "questions": questions}).encode()
    req = urllib.request.Request("https://api.typesafe.ai/v1/systemone", data=body, method="POST",
                                 headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        answers = json.load(r)["answers"]
    out: dict[int, list[str]] = {}
    for qid, a in answers.items():
        kind, i = re.match(r"([a-z]+)(\d+)", qid).groups()
        p = float(a.get("noul", 0))
        if p >= JEV_THRESHOLD:
            out.setdefault(int(i), []).append(f"Jev: {'reads like hype' if kind == 'hype' else 'vague where a number would help'} ({p:.2f})")
    return out


def changed_pages() -> list[Path]:
    try:
        names = subprocess.run(["git", "diff", "--name-only", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.split()
        names += subprocess.run(["git", "diff", "--name-only", "--cached"], cwd=ROOT, capture_output=True, text=True).stdout.split()
    except OSError:
        names = []
    return sorted({ROOT / n for n in names if n.endswith(".html") and not n.startswith("tools/")})


def main() -> int:
    pages = [Path(a) for a in sys.argv[1:]] or changed_pages()
    if not pages:
        print("No changed pages. Pass files to check, e.g. python tools/voice-check.py index.html")
        return 0
    key = typesafe_key()
    total = 0
    for page in pages:
        page = page if page.is_absolute() else ROOT / page
        lines = visible_lines(page.read_text(encoding="utf-8", errors="replace"))
        flags = {i: rule_flags(l) for i, l in enumerate(lines)}
        if key:
            try:
                for i, f in jev_flags(lines, key).items():
                    flags[i] = flags.get(i, []) + f
            except Exception as e:
                print(f"  (Jev skipped for {page.name}: {e})")
        hits = [(lines[i], f) for i, f in flags.items() if f]
        name = page.relative_to(ROOT) if page.is_relative_to(ROOT) else page.name
        print(f"{name}: {len(lines)} lines, {len(hits)} flagged" + ("" if key else " (rules only; no TypeSafe key)"))
        for line, f in hits:
            print(f"  - {line[:110]}\n      {'; '.join(f)}")
        total += len(hits)
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
