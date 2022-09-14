# streamlit_app.py

import streamlit as st
import pandas as pd
import snowflake.connector
import streamlit as st
import snowflake.connector
import altair as alt

# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
data  = {'DIM_DATE_SK': ['2021-09-01','2021-12-01','2021-09-01','2021-12-01'],
        'VALUE': [841000,913000,880000,960000],
        'SUBURB': ['Willetton','Willetton','Highgate','Highgate'],
        'STATE': ['WA','WA','NSW','NSW'],
        'METRIC': ['medianSoldPrice','medianSoldPrice','medianSoldPrice','medianSoldPrice']
       }
#df.set_index('DIM_DATE_SK')
#df['DIM_DATE_SK']=pd.to_datetime(df['DIM_DATE_SK'])
df = pd.DataFrame(data)

#Get unique values for a column inside the dataframe
unique_states = df['STATE'].unique()


# Using object notation
#add_selectbox = st.sidebar.selectbox(
#    "How would you like to be contacted?",
#    (filter_state)
#)

# Using object notation
#add_selectbox2 = st.sidebar.multiselect(
#    "Where you live?",
#    (filter_state),
#    default=["NSW"]
#)

# Using object notation
select_states = st.sidebar.multiselect(
    "Where you live?",
    (unique_states),
    default=["WA"]
)

#Filters data frame based on selected states
df = df[df.STATE.isin(select_states)]

st.write(df)
st.line_chart(df, x='DIM_DATE_SK', y='VALUE')


chart = alt.Chart(df).mark_line().encode(
    alt.X('DIM_DATE_SK',
        axis=alt.Axis(title='Date', grid=False)),
    alt.Y('VALUE',
        axis=alt.Axis(title='Value', grid=False)),
    color='SUBURB',
    strokeDash='SUBURB',
    opacity=alt.value(0.8)
)
st.altair_chart(chart, use_container_width=True)


# Fetch the result set from the cursor and deliver it as the Pandas DataFrame.
df1  = {'Year': [1920,1930,1940,1950,1960,1970,1980,1990,2000,2010],
        'Unemployment_Rate': [9.8,12,8,7.2,6.9,7,6.5,6.2,5.5,6.3]
       }
