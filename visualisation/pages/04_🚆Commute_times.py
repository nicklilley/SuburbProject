import streamlit as st
import time
import numpy as np

st.set_page_config(
     page_title="Commute Times",
     page_icon="🚆",
     layout="wide",
     initial_sidebar_state="auto",
     menu_items={
         'Get Help': 'https://www.extremelycoolapp.com/help',
         'Report a bug': "https://www.extremelycoolapp.com/bug",
         'About': "# This is a header. This is an *extremely* cool app!"
     }
 )

progress_bar = st.sidebar.progress(0)
status_text = st.sidebar.empty()




