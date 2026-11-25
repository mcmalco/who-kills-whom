import sys
from pathlib import Path

import plotly.express as px
import streamlit as st

# Let this file find the pipeline/ folder one level up
sys.path.append(str(Path(__file__).resolve().parents[1]))
from pipeline.connection import get_connection  # noqa: E402

st.set_page_config(page_title="Who Kills Whom", layout="wide")


@st.cache_data(ttl=3600)  # remember query results for an hour so the page is fast
def load(sql):
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute(sql)
        df = cur.fetch_pandas_all()
    df.columns = df.columns.str.lower()
    return df


states = load("select * from HOMICIDE.DEV_MARTS.MART_STATE_YEAR")

# ---------- Header and year filter ----------
st.title("Who Kills Whom in America?")
st.caption("FBI Supplementary Homicide Reports, via the Murder Accountability Project")

first, last = int(states.year.min()), int(states.year.max())
years = st.slider("Years", first, last, (2000, last))
filtered = states[states.year.between(*years)]

# ---------- KPI tiles ----------
t = filtered.sum(numeric_only=True)
knew_them = t.partner_victims + t.family_victims + t.acquaintance_victims

c1, c2, c3, c4 = st.columns(4)
c1.metric("Murder victims", f"{int(t.victims):,}")
c2.metric("Cases solved", f"{t.solved_victims / t.victims:.0%}")
c3.metric("Killed by someone they knew", f"{knew_them / t.relationship_known_victims:.0%}")
c4.metric("Killers who were women", f"{t.female_offender_victims / t.offender_sex_known_victims:.0%}")

# ---------- Map ----------
st.subheader("How it varies by state")

# Each option = (numerator column, denominator column)
options = {
    "Cases solved": ("solved_victims", "victims"),
    "Killed by a partner": ("partner_victims", "relationship_known_victims"),
    "Killed by a stranger": ("stranger_victims", "relationship_known_victims"),
    "Killed with a gun": ("gun_victims", "weapon_known_victims"),
    "Killers who were women": ("female_offender_victims", "offender_sex_known_victims"),
}
choice = st.selectbox("Color the map by", list(options))
numerator, denominator = options[choice]

by_state = filtered.groupby(["state_abbr", "state_name"], as_index=False).sum(numeric_only=True)
by_state["pct"] = by_state[numerator] / by_state[denominator]

fig = px.choropleth(
    by_state,
    locations="state_abbr",
    locationmode="USA-states",
    scope="usa",
    color="pct",
    hover_name="state_name",
    hover_data={"state_abbr": False, "pct": ":.1%", denominator: ":,"},
    color_continuous_scale="Reds",
    labels={"pct": choice},
)
fig.update_layout(coloraxis_colorbar_tickformat=".0%", margin=dict(l=0, r=0, t=0, b=0))
st.plotly_chart(fig, use_container_width=True)