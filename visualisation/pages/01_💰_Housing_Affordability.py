# streamlit_app.py
import streamlit as st
import pandas as pd
import snowflake.connector
import altair as alt
import datetime
import json
import plotly.express as px
import plotly.graph_objects as go
from datetime import date, datetime, timedelta
from urllib.request import urlopen


##############################################
# PAGE CONFIGURATION #########################
##############################################

st.set_page_config(
     page_title="Housing Affordability",
     page_icon="🏠",
     layout="wide",
     initial_sidebar_state="auto",
     menu_items={
         'Get Help': 'https://www.extremelycoolapp.com/help',
         'Report a bug': "https://www.extremelycoolapp.com/bug",
         'About': "# This is a header. This is an *extremely* cool app!"
     }
 )

#Remove excessive padding at top of page
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
with st.spinner('Loadings lots of data...'):
    @st.experimental_singleton(show_spinner=False)
    def init_connection():
        return snowflake.connector.connect(**st.secrets["snowflake"],client_session_keep_alive=True)
    init_con = init_connection()

    #Define function for running queries after creating cache and cursor
    @st.experimental_memo(ttl=600,show_spinner=False)
    def run_query(query):
        with init_con.cursor() as cursor: #create cursor
            cursor.execute(query)
            return cursor.fetch_pandas_all() #return results as Pandas dataframe

    # Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
    df = run_query("""
    SELECT *, upper(SUBURB) as "wa_local_2" FROM SBX_ANALYTICS.dbt_NLilleyman_common.md_suburb_realty_performance
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
# FILTERS SETUP ###############################
###############################################

#Set Date variables
today = date.today()
xyearsago = today - timedelta(days=5*365)
min_date = date(2011, 1, 1) #API only goes back to 2011

#Get unique values for columns inside the dataframe 
unique_suburbs = df['SUBURB'].unique()
unique_property_type = df['PROPERTY_TYPE'].unique()
unique_metrics_type = df['METRIC_TYPE'].unique()

#Sort order of Metrics
metrics_sorted = ['Median Sold Price','Median Listing Price','Discount Percentage (Listing Price/Sold Price)']
#                       'Days on Market','Number of Listings','Number Sold','Number Auctioned',
#                       'Number of Sold Auctions','Highest Sold Price','Lowest Sold Price','Median Rent',
#                       'Number of Rent Listings','Lowest Rent','Highest Rent'] #Manually sorted metrics

#Filter dataframe by metrics_sorted
df = df[df['METRIC'].isin(metrics_sorted)] 

#Create Dataframe for metrics and sort by metrics_sorted
metrics_df = df[['METRIC_TYPE', 'METRIC']].drop_duplicates()
metrics_df['METRIC_SORT'] = metrics_df['METRIC'].apply(lambda x: metrics_sorted.index(x))
metrics_df = metrics_df.sort_values(by=['METRIC_SORT'])


###############################################
# SIDEBAR FILTERS #############################
###############################################

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

#########################################################
# MAIN PAGE FILTERS #####################################
#########################################################
#Display Metric and Property Type filter in columns
col1, col2 = st.columns(2,gap="small")
with col1:
   select_metric_types = st.selectbox(
        "Buy or Rent",
        (unique_metrics_type))

   #Restrict Metric list by selected Metric Type
   metrics_filt = metrics_df[metrics_df['METRIC_TYPE']==select_metric_types]['METRIC']

   select_metric = st.selectbox(
        "Select a Metric",
        (metrics_filt),
        index=0)

with col2:
    select_property_types = st.multiselect(
        "Select Property Type(s)",
        (unique_property_type),
        default=["House"])

    select_suburbs = st.multiselect(
        "Select Suburb(s)",
        (unique_suburbs),
        default=["Willetton","Harrisdale"])


#Filter Dataframe based on user filter selections
df['DIM_DATE_SK'] = pd.to_datetime(df['DIM_DATE_SK']).dt.date
#df['DIM_DATE_SK'] = pd.to_datetime(df['DIM_DATE_SK']).dt.strftime('%b-%Y')
df_filt_1 = df.query("METRIC == @select_metric") #Metric Filter
df_filt_2 = df_filt_1[df.PROPERTY_TYPE.isin(select_property_types)] #Property Type Filter
df_filt_3 = df_filt_2.loc[df['DIM_DATE_SK'].between(date_range[0], date_range[1])] #Date Range Filter
df_filt_4 = df_filt_3[df.SUBURB.isin(select_suburbs)] #Suburb Filter

#Get latest record for EVERY suburb for Top 10 and Bottom 10 charts
df_latest_global = df_filt_3.sort_values('DIM_DATE_SK').groupby('SUBURB').tail(1)

#Get the 2 latest records for FILTERED suburbs for metrics
#To Do: Use 2nd latest record in metric delta
df_latest_record = df_filt_4.sort_values('DIM_DATE_SK',ascending=False).groupby('SUBURB').nth([0]).reset_index() #Most recent record for each suburb, 
#df_2nd_latest_record    = df_filt_4.sort_values('DIM_DATE_SK',ascending=False).groupby('SUBURB').nth([1]).reset_index()  #2nd most recent record for each suburb

#df_latest_record = df_latest_n_records.groupby('SUBURB').iloc[-1]
#df_latest_record = df[df_latest_n_records.cumcount() == n - 1]

#Create dataframes to put suburbs into seperate columns by alternating rows
df_latest_record_col1= df_latest_record.iloc[1::2, :]
df_latest_record_col2 = df_latest_record.iloc[::2, :]

###############################################
# PLOT CHARTS #################################
###############################################

st.markdown("""---""") #add horizontal line for section break
#st.markdown('#') adds an empty space on page

#Latest Month Metrics 
#col1, col2  = st.columns(2,gap="small")
#col1.metric("Willetton", "$600k","$-9k")
#col2.metric("Canning Vale", "$504k", "$12k")

###############################################
########### Lastest Month Metrics #############

# Create columns for latest suburb metrics
col4, col5  = st.columns(2,gap="small")
with col4: 
    for index, row in df_latest_record_col1.iterrows():
        #st.metric((row["SUBURB"] + ' (' +str(row["DIM_DATE_SK"].datetime.datetime.strptime('%Y%m%d')) + ')'), row["VALUE"])
        st.metric((row["SUBURB"] + ' (' +str(row["DIM_DATE_SK"].strftime('%b-%Y')) + ')'), str(row["VALUE_PREFIX"]) + str(row["VALUE_CONDITIONAL_ROUND"]) + str(row["VALUE_SUFFIX"]))
with col5:
    for index, row in df_latest_record_col2.iterrows():
        st.metric((row["SUBURB"] + ' (' +str(row["DIM_DATE_SK"].strftime('%b-%Y')) + ')'), str(row["VALUE_PREFIX"]) + str(row["VALUE_CONDITIONAL_ROUND"]) + str(row["VALUE_SUFFIX"]))


#col3, col4, col5  = st.columns(3,gap="small")
#with col3:
#    st.subheader("**Suburb**")
#    for index, row in df_test.iterrows():
#        st.markdown(row["SUBURB"])
#with col4:
#    st.subheader("Date")
#    for index, row in df_skip_2.iterrows():
#        st.metric(row["SUBURB"],row["VALUE"])
#with col5:
#    st.subheader("Date")
#    for index, row in df_2nd.iterrows():
#        st.metric(row["SUBURB"],row["VALUE"])

###############################################
######### Metric line chart over time #########

st.markdown('#') #adds an empty space on page

#Section Title
st.markdown(f'**Quarterly Trend - {select_metric}**')

chart = alt.Chart(df_filt_4).mark_line(
    point={
        "filled": False,
        #"fill": "white",
        #"tooltip": True
        }
).encode(
    alt.X('DIM_DATE_SK',
        axis=alt.Axis(title='Date', grid=False, format='%b-%Y')),
    alt.Y('VALUE',
        #axis=alt.Axis(title='Value', grid=False, format='$,r')), #add $ to axis 
        axis=alt.Axis(title='', grid=False)),
    color=alt.Color('SUBURB', title='Suburb',
                    legend=alt.Legend(orient='top')),
    strokeDash=alt.StrokeDash('PROPERTY_TYPE', title='Property Type',
                    legend=alt.Legend(orient='top')),
    opacity=alt.value(0.75),
    strokeWidth=alt.value(4),
    tooltip=[alt.Tooltip('VALUE', title=f'{select_metric}'),
             alt.Tooltip('SUBURB', title='Suburb'),
             alt.Tooltip('DIM_DATE_SK', title='Date', format='%b-%Y')],
).properties(
    #title=select_metric
)
st.altair_chart(chart, use_container_width=True)

###############################################
####### Top 10 and Bottom Charts ##############

#Transform data to get top 10 and bottom suburbs by metric
df_top_10 = df_latest_global.sort_values('VALUE',ascending=False).head(10)
df_bottom_10 = df_latest_global.sort_values('VALUE',ascending=True).head(10)

##########Top 10 Suburbs by Metric#############
#Define Axis
barchart_top10 = alt.Chart(df_top_10).mark_bar(
).encode(
    x=alt.X('VALUE',
        axis=alt.Axis(title=select_metric, grid=False)),
    y=alt.Y('SUBURB', sort=alt.EncodingSortField(field="VALUE", op="sum", order="descending"),
        axis=alt.Axis(title='', grid=False)),
    #tooltip=['VALUE', 'SUBURB'],
    tooltip=[alt.Tooltip('VALUE', title=f'{select_metric}'),
             alt.Tooltip('SUBURB', title='Suburb'),
             alt.Tooltip('DIM_DATE_SK', title='Date', format='%b-%Y')],
    color=alt.value('#4e79a7'),
    opacity=alt.value(0.9)
)
#Add global mean line
domain = ['setosa']
range_ = ['red']
rule_top10 = alt.Chart(df_latest_global).mark_rule().encode(
    x='mean(VALUE)',
    tooltip=[alt.Tooltip('mean(VALUE)', title='National Average')],
    opacity=alt.value(0.90),
    strokeWidth=alt.value(4),
    #legend=alt.Legend(orient='top'),
    strokeDash=alt.value([5, 5]), #5 pixel length with 5 pixel gap
    #strokeDash=alt.StrokeDash('mean(VALUE)', scale=alt.Scale(domain=domain1, range=range1), title='Property Type',
    #                legend=alt.Legend(orient='top')),
    #strokeDash=alt.condition(
    #    alt.datum.symbol == 'GOOG',
    #    alt.value([5, 5]),  # dashed line: 5 pixels  dash + 5 pixels space
    #    alt.value([0]),  # solid line
    #)
    #color=alt.Color('mean(VALUE)', legend=alt.Legend(orient='top'))
    #color=alt.Color('mean(VALUE)')
    #color=alt.Color(color='red', scale=None, legend=alt.Legend(orient='top'))
    #color=alt.Color('mean(VALUE)', scale=alt.Scale(domain=domain, range=range_))
    color=alt.value('#FF4B4B')
)

#Add bar label
text_top10 = barchart_top10.mark_text(
    align='left',
    baseline='middle',
    dx=3  # Nudges text to right so it doesn't appear on top of the bar
).encode(
    text='VALUE'
)

########## Bottom 10 Suburbs by Metric ############
#Define Axis
barchart_bottom10 = alt.Chart(df_bottom_10).mark_bar(
).encode(
    x=alt.X('VALUE',
        axis=alt.Axis(title=select_metric, grid=False)),
    y=alt.Y('SUBURB', sort=alt.EncodingSortField(field="VALUE", op="sum", order="ascending"),
        axis=alt.Axis(title='', grid=False)),
    tooltip=[alt.Tooltip('VALUE', title=f'{select_metric}'),
             alt.Tooltip('SUBURB', title='Suburb'),
             alt.Tooltip('DIM_DATE_SK', title='Date', format='%b-%Y')],
    color=alt.value('#4e79a7'),
    opacity=alt.value(0.9)
    
)
#Add global mean line
rule_bottom10 = alt.Chart(df_latest_global).mark_rule().encode(
    x='mean(VALUE)',
    tooltip=[alt.Tooltip('mean(VALUE)', title='National Average')],
    opacity=alt.value(0.90),
    strokeWidth=alt.value(4),
    strokeDash=alt.value([5, 5]), #5 pixel length with 5 pixel gap
    color=alt.value('#FF4B4B')
)

#Add bar label
text_bottom10 = barchart_bottom10.mark_text(
    align='left',
    baseline='middle',
    dx=3  # Nudges text to right so it doesn't appear on top of the bar
).encode(
    text='VALUE'
)

#Plot Top 10 and Bottom 10 Charts in columns
col6, col7  = st.columns(2,gap="small")

with col6:
    st.markdown(f'**Top 10 Suburbs - {select_metric}**')
    st.altair_chart(barchart_top10 + rule_top10 + text_top10, use_container_width=True)    
with col7:
    st.markdown(f'**Bottom 10 Suburbs - {select_metric}**')
    st.altair_chart(barchart_bottom10 + rule_bottom10 + text_bottom10, use_container_width=True)

######################################################
################# Suburb Metric Map ##################

with st.spinner('Building a big map...'):
    #Title
    st.markdown(f'**Surburb Map - {select_metric}**')

    #Load geojson file of suburb boundaries
    with urlopen('https://raw.githubusercontent.com/nicklilley/SuburbProject/NickL/SBX-Visualisation/visualisation/geojson/suburb-2-wa-edit.geojson') as response:
        counties = json.load(response)

    #Set colour scale for map           
    lower_colour_scale = df_latest_global.VALUE.quantile(0.02) # 5th percentile to ensure outliers don't skew the colour scale
    upper_colour_scale = df_latest_global.VALUE.quantile(0.98) # 95th percentile to ensure outliers don't skew the colour scale

    #To Do: Create mapbox access token and add to config.toml file
    mapbox_access_token =  'pk.eyJ1IjoibmljaG9sYXNsaWxsZXltYW4iLCJhIjoiY2w4bHFtNHYwMDZxczN2dGhwZXV3YTJ2cCJ9.R0Nrbbu8C4phcU62W4ld4w'
    px.set_mapbox_access_token(mapbox_access_token)
    fig = px.choropleth_mapbox(df_latest_global, geojson=counties,
                            locations='wa_local_2', 
                            featureidkey="properties.wa_local_2", #This is the key in the geojson file
                            color='VALUE',
                            color_continuous_scale="Greens",
                            range_color=(lower_colour_scale, upper_colour_scale),
                            mapbox_style="carto-positron",
                            zoom=10, center = {"lat": -31.9698, "lon": 115.9350},
                            opacity=0.85,
                            labels={'VALUE':f'{select_metric}',
                                    'wa_local_2':'Suburb',
                                    },
                            )
    #Hide Mode Bar with zoom and pan tools
    config = {'displayModeBar': False}
    
    #Format legend
    fig.update_coloraxes(colorbar_title_text='',
                         colorbar_orientation='h',
                         #colorbar_yanchor='bottom',
                         colorbar_thickness=20)

    fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0})

    #Plot Chart
    st.plotly_chart(fig, config=config, use_container_width=True,)
