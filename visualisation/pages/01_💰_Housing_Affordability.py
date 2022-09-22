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

st.write('<style>div.block-container{padding-top:1rem;}</style>', unsafe_allow_html=True)

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
init_con = init_connection()

# Create a cursor object.
#cursor = init_con.cursor()

#Define function for running queries after creating cache and cursor
@st.experimental_memo(ttl=600)
def run_query(query):
    with init_con.cursor() as cursor:
        cursor.execute(query)
        return cursor.fetch_pandas_all()

# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df = run_query("""
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
df['VALUE']=pd.to_numeric(df['VALUE'])



##############################################
# INTRODUCTION  ##############################
##############################################
st.title('Housing Affordability')
#st.markdown("Sales & rental prices trends across suburbs")

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
min_date = date(2011, 1, 1) #API only goes back to 2011

#Get unique values for a column inside the dataframe
unique_suburbs = df['SUBURB'].unique()
unique_property_type = df['PROPERTY_TYPE'].unique()
unique_metrics= df['METRIC'].unique()

#Date Slider Filter sidebar
date_range = st.sidebar.slider(
    "Date Range",
    value=(xyearsago, today),
    step=timedelta(weeks=13),
    min_value=min_date,
    format="MMM-YY")

#Metric filter sidebar
#select_metric = st.sidebar.selectbox(
#    "Select a Metric",
#    (unique_metrics),
#    index=0
#)

#Metric filter 
#select_metric = st.selectbox(
#    "Select a Metric",
#    (unique_metrics),
#    index=0
#)

#Suburb Filter sidebar
#select_suburbs = st.sidebar.multiselect(
#    "Select Suburb(s)",
#    (unique_suburbs),
#    default=["Willetton","Harrisdale"]
#)


#Property_type Filter
#select_property_types = st.multiselect(
#    "Select Property Type(s)",
#    (unique_property_type),
#    default=["house"]
#)

################ MAIN PAGE FILTERS ######################

#Display Metric and Property Type filter in columns
col1, col2 = st.columns(2,gap="small")
with col1:
    select_metric = st.selectbox(
        "Select a Metric",
        (unique_metrics),
        index=0
    )

with col2:
   select_property_types = st.multiselect(
         "Select Property Type(s)",
        (unique_property_type),
        default=["house"]
)

#Suburb Filter 
select_suburbs = st.multiselect(
    "Select Suburb(s)",
    (unique_suburbs),
    default=["Willetton","Harrisdale"]
)


#Filter Dataframe based on user filter selections
df['DIM_DATE_SK'] = pd.to_datetime(df['DIM_DATE_SK']).dt.date #convert DIM_DATE_SK to date
df_filt_1 = df[df.SUBURB.isin(select_suburbs)] #Suburb Filter
df_filt_2 = df_filt_1.query("METRIC == @select_metric") #Metric Filter
df_filt_3 = df_filt_2[df.PROPERTY_TYPE.isin(select_property_types)] #Property Type Filter
df_filt_4 = df_filt_3.loc[df['DIM_DATE_SK'].between(date_range[0], date_range[1])] #Date Range Filter


###############################################
# PLOT CHART ##################################
###############################################

#selection = alt.selection_multi(fields=['SUBURB'], bind='legend')

#Latest Month Metrics 
col1, col2  = st.columns(2,gap="small")
col1.metric("Willetton", "$600k","$-9k")
col2.metric("Canning Vale", "$504k", "$12k")


###Metric line chart over time###
chart = alt.Chart(df_filt_4).mark_line(
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


####Top 10 Suburbs by Metric###
#Transform data to get top 10 suburbs by metric
df_top_10 = df.groupby(('SUBURB'), as_index=False).sum().sort_values('VALUE',ascending=False).head(10)

#Define Axis
barchart2 = alt.Chart(df_top_10).mark_bar().encode(
    x=alt.X('VALUE',
        axis=alt.Axis(title=select_metric, grid=False)),
    y=alt.Y('SUBURB', sort=alt.EncodingSortField(field="VALUE", op="sum", order="descending"),
        axis=alt.Axis(title='', grid=False))
)
#Add bar label
text = barchart2.mark_text(
    align='left',
    baseline='middle',
    dx=3  # Nudges text to right so it doesn't appear on top of the bar
).encode(
    text='VALUE'
)
#Plot chart
st.altair_chart(barchart2 + text, use_container_width=True)




