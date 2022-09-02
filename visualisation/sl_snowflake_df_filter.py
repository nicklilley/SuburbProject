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
AND suburb IN ('Willetton', 'Harrisdale')
ORDER BY dim_date_sk ASC
 """)
cur.execute(sql)

# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df = cur.fetch_pandas_all()
df.set_index('DIM_DATE_SK')
#df['DIM_DATE_SK']=pd.to_datetime(df['DIM_DATE_SK'])
df['VALUE']=pd.to_numeric(df['VALUE'])


#############FILTERS###########
#Get unique values for a column inside the dataframe
unique_suburbs = df['SUBURB'].unique()

# Using object notation
select_suburbs = st.sidebar.multiselect(
    "Where you live?",
    (unique_suburbs),
    default=["Willetton"]
)

#Filters data frame based on selected states
df = df[df.SUBURB.isin(select_suburbs)]


st.write(df)

##### PLOT CHART #####
chart = alt.Chart(df).mark_line(
    
    point={
        "filled": False,
        "fill": "white",
        "tooltip": True
        }
).encode(
    alt.X('DIM_DATE_SK',
        axis=alt.Axis(title='Date', grid=False)),
    alt.Y('VALUE',
        axis=alt.Axis(title='Value', grid=False)),
    color='SUBURB',
    #strokeDash='SUBURB',
    opacity=alt.value(0.8)
)
st.altair_chart(chart, use_container_width=True)

st.line_chart(df)