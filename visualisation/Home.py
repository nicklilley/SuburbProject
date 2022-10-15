# streamlit_app.py

import streamlit as st
import pandas as pd
import snowflake.connector
import snowflake.connector
import altair as alt

st.set_page_config(
     page_title="Burb Browser",
     page_icon="🏠",
     layout="wide",
     initial_sidebar_state="auto",
   #  menu_items={
   #      'Get Help': 'https://www.extremelycoolapp.com/help',
   #      'Report a bug': "https://www.extremelycoolapp.com/bug",
   #      'About': "# This is a header. This is an *extremely* cool app!"
   #  }
 )
#Icons from https://emojipedia.org/search/?q=police

#Hide hamburger menu
hide_menu_style = """
        <style>
        #MainMenu {visibility: hidden;}
        </style>
        """
st.markdown(hide_menu_style, unsafe_allow_html=True)



####################
### INTRODUCTION ###
####################
st.title('Burb Browser')
st.markdown("Select a page on the sidebar to explore data")

st.sidebar.text('')

st.image("visualisation/images/underconstruction.png", width=400)


