# streamlit_app.py
import streamlit as st
import pandas as pd
import snowflake.connector
import altair as alt
import datetime
from datetime import date, datetime, timedelta
import plotly.express as px
import plotly.graph_objects as go
from urllib.request import urlopen
import json

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

with urlopen('https://raw.githubusercontent.com/tonywr71/GeoJson-Data/master/suburb-2-wa.geojson') as response:
    counties1 = json.load(response)
#THIS IS THE GEOJSON DATASOURCE

counties1

with open('visualisation/geojson/suburb-10-wa-state-edit.geojson') as response:
    counties = json.load(response)
#THIS IS THE GEOJSON DATASOURCE

counties 
#Get loc_pid from counties geojson
#df_loc_pid = counties['features'][0]['properties']['loc_pid']

#df_loc_pid

df = pd.read_csv("visualisation/subdata1.csv",
                   dtype={"fips": str})

#df = run_query("""
#SELECT * FROM SBX_ANALYTICS.dbt_NLilleyman_common.md_suburb_realty_performance
# """)
#df['VALUE']=pd.to_numeric(df['VALUE'])


mapbox_access_token =  'pk.eyJ1IjoibmljaG9sYXNsaWxsZXltYW4iLCJhIjoiY2w4bHFtNHYwMDZxczN2dGhwZXV3YTJ2cCJ9.R0Nrbbu8C4phcU62W4ld4w'
px.set_mapbox_access_token(mapbox_access_token)
fig = px.choropleth_mapbox(df, geojson=counties, locations='fips', color='unemp',
                           color_continuous_scale="Viridis",
                           range_color=(0, 12),
                           mapbox_style="carto-positron",
                           zoom=11, center = {"lat": -32.0488, "lon": 115.892},
                           opacity=0.5,
                           featureidkey="properties.wa_local_2",
                           labels={'unemp':'unemployment rate'},
                          )
fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0})



#df_swe = df[df['fips']=='WILLETTON']
#df_swe
col_swe = 'Black'
#fig.add_traces(px.choropleth_mapbox(locations=['fips'],
#fig.add_traces(go.Choropleth(locations=['fips'],
#                        z = [1],
#                        colorscale = [[0, col_swe],[1, col_swe]],
#                        colorbar=None,
#                        showscale = True))
                       
fig.add_trace(go.Choropleth(
        #locationmode='USA-states',
        z=[0],
        locations=['fips'],
        colorscale = [[0,'rgba(0, 0, 0, 0)'],[1,'rgba(0, 0, 0, 0)']],
        marker_line_color='Red',
        showscale = True,
    ))
fig.update_layout(
    title_text = '2011 US Agriculture Exports by State',
)

st.plotly_chart(fig, use_container_width=True)