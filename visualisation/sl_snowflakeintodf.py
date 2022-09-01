# streamlit_app.py

import streamlit as st
import pandas as pd
import snowflake.connector
import streamlit as st
import snowflake.connector

# Initialize connection.
# Uses st.experimental_singleton to only run once.
@st.experimental_singleton
def init_connection():
    return snowflake.connector.connect(**st.secrets["snowflake"])

ctx = init_connection()

# Create a cursor object.
cur = ctx.cursor()

# Execute a statement that will generate a result set.
sql = "SELECT DIM_DATE_SK, sum(VALUE) AS VALUE from ANALYTICS.DBT_NLILLEYMAN_COMMON.FCT_SUBURB_DEMOGRAPHICS group by 1;"
cur.execute(sql)

# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df = cur.fetch_pandas_all()

st.write(df)
st.line_chart(df, x='DIM_DATE_SK', y='VALUE')
# ...