# streamlit_app.py
import streamlit as st
import pandas as pd
import snowflake.connector
import snowflake.connector
import altair as alt
import datetime
from datetime import date
from datetime import timedelta

##############################################
# PAGE CONFIGURATION #########################
##############################################


st.set_page_config(
     page_title="Housing Affordability",
     page_icon="💰",
     layout="wide",
     initial_sidebar_state="auto",
     menu_items={
         'Get Help': 'https://www.extremelycoolapp.com/help',
         'Report a bug': "https://www.extremelycoolapp.com/bug",
         'About': "# This is a header. This is an *extremely* cool app!"
     }
 )
#Icons from https://emojipedia.org/search/?q=police

#Hide hamburger menu
hide_menu_style = """
        <style>
        #MainMenu {visibility: hidden;}
        </style>
        """
st.markdown(hide_menu_style, unsafe_allow_html=True)

##############################################
# DATA CONNECTION ############################
##############################################

# Initialize connection
# Uses st.experimental_singleton to only run once.
@st.experimental_singleton
def init_connection():
    return snowflake.connector.connect(**st.secrets["snowflake"],client_session_keep_alive=True)
ctx = init_connection()

# Create a cursor object.
cur = ctx.cursor()

# Execute a statement that will generate a result set.
sql = ("""
SELECT 
dim_date_sk
,suburb
,metric
,property_type
,value
FROM SBX_ANALYTICS.DBT_NLILLEYMAN_COMMON.FCT_SUBURB_REALTY_PERFORMANCE PERF
LEFT JOIN SBX_ANALYTICS.DBT_NLILLEYMAN_COMMON.DIM_SUBURB_GEOGRAPHY GEO on GEO.dim_suburb_sk = PERF.dim_suburb_sk
WHERE 1=1
ORDER BY dim_date_sk ASC
 """)
cur.execute(sql)

# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df = cur.fetch_pandas_all()
#df.set_index('DIM_DATE_SK')
#df['DIM_DATE_SK']=pd.to_datetime(df['DIM_DATE_SK'])
df['VALUE']=pd.to_numeric(df['VALUE'])



##############################################
# INTRODUCTION  ##############################
##############################################
st.title('Housing Affordability')
st.markdown("Sales & rental prices trends across suburbs")

###############################################
# SIDEBAR SELECTION ###########################
###############################################
#st.sidebar.image("visualisation/CityIcon1.jpg", use_column_width=True)
st.sidebar.text('')
st.sidebar.markdown("**Select Filters:** 👇")

###############################################
# SIDE BAR FILTERS ############################
###############################################

#Set Date variables
today = date.today()
xyearsago = today - datetime.timedelta(days=5*365)
min_date = date(2011, 1, 1)

#Get unique values for a column inside the dataframe
unique_suburbs = df['SUBURB'].unique()
unique_property_type = df['PROPERTY_TYPE'].unique()
unique_metrics= df['METRIC'].unique()

#Date Slider Filter
date_range = st.sidebar.slider(
    "Date Range",
    value=(xyearsago, today),
    step=timedelta(weeks=13),
    min_value=min_date,
    format="MMM-YY")

#Suburb Filter
select_suburbs = st.sidebar.multiselect(
    "Select Suburb(s)",
    (unique_suburbs),
    default=["Willetton","Harrisdale"]
)

#Property_type Filter
select_property_types = st.sidebar.multiselect(
    "Select Property Type(s)",
    (unique_property_type),
    default=["house"]
)

#Metric filter
select_metric = st.sidebar.selectbox(
    "Select a Metric",
    (unique_metrics),
    index=0
)

#Filter Dataframe based on user filter selections
#df['DIM_DATE_SK']=pd.to_datetime(df['DIM_DATE_SK'])
#df['DIM_DATE_SK'] = DIM_DATE_SK.dt.date
#df = df.loc[df['DIM_DATE_SK'].between('2021-01-01', '2022-01-01')]
df['DIM_DATE_SK'] = pd.to_datetime(df['DIM_DATE_SK']).dt.date #convert DIM_DATE_SK to date
df = df.loc[df['DIM_DATE_SK'].between(date_range[0], date_range[1])]
df = df[df.SUBURB.isin(select_suburbs)]
df = df[df.PROPERTY_TYPE.isin(select_property_types)]
df = df.query("METRIC == @select_metric")

###############################################
# PLOT CHART ##################################
###############################################
chart = alt.Chart(df).mark_line(
    point={
        "filled": False,
        #"fill": "white",
        "tooltip": True
        }
).encode(
    alt.X('DIM_DATE_SK',
        axis=alt.Axis(title='Date', grid=False)),
    alt.Y('VALUE',
        axis=alt.Axis(title='Value', grid=False)),
    color=alt.Color('SUBURB', title='Suburb',
                    legend=alt.Legend(orient='top')),
    strokeDash=alt.StrokeDash('PROPERTY_TYPE', title='Property Type',
                    legend=alt.Legend(orient='top')),
    opacity=alt.value(0.75),
    strokeWidth=alt.value(4),
    
).properties(
    title=select_metric
)
st.altair_chart(chart, use_container_width=True)

