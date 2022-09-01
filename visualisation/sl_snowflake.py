# streamlit_app.py

import streamlit as st
import pandas as pd
import snowflake.connector


import streamlit as st

# Using object notation
add_selectbox = st.sidebar.selectbox(
    "How would you like to be contacted?",
    ("Email", "Home phone", "Mobile phone")
)

add_radio2 = st.sidebar.radio(
    "How sick is Jarrad",
    ("Not very", "Some", "A lot")
)

# Using "with" notation
with st.sidebar:
    add_radio = st.radio(
        "Choose a shipping method",
        ("Standard (5-15 days)", "Express (2-5 days)")
    )




# Initialize connection.
# Uses st.experimental_singleton to only run once.
@st.experimental_singleton
def init_connection():
    return snowflake.connector.connect(**st.secrets["snowflake"])

conn = init_connection()


#def run_query(query):
#    rows = conn.execute(query, headers=1)
#    rows = rows.fetchall()
#    return rows
#rows = run_query("SELECT DIM_DATE_SK, sum(VALUE) from ANALYTICS.DBT_NLILLEYMAN_COMMON.FCT_SUBURB_DEMOGRAPHICS group by 1;")

# Perform query.
# Uses st.experimental_memo to only rerun when the query changes or after 10 min.
@st.experimental_memo(ttl=600)
def run_query(query):
    with conn.cursor() as cur:
        cur.execute(query)
        return cur.fetchall()

rows = run_query("SELECT DIM_DATE_SK, sum(VALUE) from ANALYTICS.DBT_NLILLEYMAN_COMMON.FCT_SUBURB_DEMOGRAPHICS group by 1;")

st.write(rows)

datax = {'Year': [1920,1930,1940,1950,1960,1970,1980,1990,2000,2010],
        'Unemployment_Rate': [9.8,12,8,7.2,6.9,7,6.5,6.2,5.5,6.3]
       }
st.write(datax)

# Print results.
#for row in rows:
#    st.write(f"{row[0]} has a :{row[1]}:")

###Nick Attempt

df = pd.DataFrame(rows)
#a = df["DIM_DATE_SK"].astype("datetime64")
#bytes = df["VALUE"]
#df1 = df['TOTAL', 'VALUE']

st.line_chart(df, x='DIM_DATE_SK', y='VALUE')
print(df)
