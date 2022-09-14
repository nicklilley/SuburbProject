# streamlit_app.py

import streamlit as st
import pandas as pd
import snowflake.connector
import streamlit as st
import snowflake.connector
import altair as alt

# Initialize connection.
# Uses st.experimental_singleton to only run once.
@st.experimental_singleton
def init_connection():
    return snowflake.connector.connect(**st.secrets["snowflake"])

ctx = init_connection()

# Create a cursor object.
cur = ctx.cursor()



add_radio2 = st.sidebar.radio(
    "How sick is Jarrad",
    ("Not very", "Some", "A lot")
)

# Using object notation
add_selectbox = st.sidebar.selectbox(
    "How would you like to be contacted?",
    ("Pidegon", "Rat", "Mobile phone")
)




# Execute a statement that will generate a result set.
sql = ("""
SELECT 
dim_date_sk
,suburb
,metric
,value
FROM ANALYTICS.DBT_NLILLEYMAN_COMMON.FCT_SUBURB_REALTY_PERFORMANCE PERF
LEFT JOIN ANALYTICS.DBT_NLILLEYMAN_COMMON.DIM_SUBURB_GEOGRAPHY GEO on GEO.dim_suburb_sk = PERF.dim_suburb_sk
WHERE metric = 'medianSoldPrice'
AND suburb = 'Willetton'
ORDER BY dim_date_sk ASC
 """)

cur.execute(sql)

# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df = cur.fetch_pandas_all()
df.set_index('DIM_DATE_SK')
df['DIM_DATE_SK']=pd.to_datetime(df['DIM_DATE_SK'])

st.write(df)
st.line_chart(df, x='DIM_DATE_SK', y='VALUE')
# ...

#
#chart = alt.Chart(df).mark_line().encode(
#    x='DIM_DATE_SK',
#    y='VALUE',
#    color='SUBURB',
#    strokeDash='SUBURB',
#)
#st.altair_chart(chart)
#