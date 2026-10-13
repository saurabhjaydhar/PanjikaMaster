"""HTML diff report for a validation run (spec §6.7). Every row of every check is
listed; mismatches first and highlighted."""

from html import escape

from validate.checks import Check

STYLE = """
body{font:14px/1.5 system-ui,sans-serif;margin:2rem;color:#1F1A3D}
table{border-collapse:collapse;margin:.5rem 0 2rem;width:100%}
th,td{border:1px solid #E2DFEE;padding:.3rem .5rem;text-align:left}
tr.bad td{background:#FBE9EA}
.passed{color:#2E7A4E}.failed{color:#B4232C}.waiting{color:#5B567A}
"""


def render(pack_name: str, checks: list[Check], generated: str) -> str:
    out = [
        "<!doctype html><meta charset=utf-8>",
        f"<title>Validation — {escape(pack_name)}</title><style>{STYLE}</style>",
        "<h1>Validation report</h1>",
        f"<p>Pack <code>{escape(pack_name)}</code> · {escape(generated)}</p>",
        "<table><tr><th>Check</th><th>Reference</th><th>Tolerance</th><th>Rows</th>"
        "<th>Mismatches</th><th>Status</th></tr>",
    ]
    for c in checks:
        cls = "waiting" if c.missing else c.status
        out.append(
            f"<tr><td>{escape(c.name)}</td><td>{escape(c.reference)}</td>"
            f"<td>{escape(c.tolerance)}</td><td>{len(c.rows)}</td><td>{len(c.failures)}</td>"
            f"<td class={cls}>{escape(c.status)}</td></tr>"
        )
    out.append("</table>")
    for c in checks:
        out.append(f"<h2>{escape(c.name)}</h2>")
        if c.note:
            out.append(f"<p>{escape(c.note)}</p>")
        if c.missing:
            out.append(f"<p class=waiting>Waiting for <code>{escape(c.reference)}</code>.</p>")
            continue
        out.append("<table><tr><th>Item</th><th>Ours</th><th>Reference</th><th>Diff</th></tr>")
        for r in sorted(c.rows, key=lambda r: r.ok):
            out.append(
                f"<tr class={'ok' if r.ok else 'bad'}><td>{escape(r.key)}</td>"
                f"<td>{escape(r.ours)}</td><td>{escape(r.reference)}</td><td>{escape(r.diff)}</td></tr>"
            )
        out.append("</table>")
    return "\n".join(out) + "\n"
