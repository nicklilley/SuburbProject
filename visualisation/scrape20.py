import streamlit as st
import pandas as pd
from apify_client import ApifyClient

# Initialize the ApifyClient with your API token
client = ApifyClient("apify_api_FhEVuXRcATl4OL0seC2vMaQ5oWYT9R3pDlwi")

@st.cache_data(experimental_allow_widgets=True, show_spinner=True)
def fetch_data_from_apify(search_field, search_location, max_items, max_reviews):
    # Prepare the Actor input
    run_input = {
        "customMapFunction": "(object) => { return {...object} }",
        "extendOutputFunction": "($) => { return {} }",
        "includeReviewerInformation": True,
        "includeReviews": True,
        "language": "en",
        "maxItems": int(max_items),
        "maxReviews": int(max_reviews),
        "proxy": {"useApifyProxy": True},
        "reviewsSort": "newest",
        "search": search_field,
        "searchLocation": search_location,
    }

    # Run the Actor and wait for it to finish
    run = client.actor("YcEbOuZR2CaxXznyD").call(run_input=run_input)

    # Initialize lists for storing data
    restaurant_data = []
    review_data = []

    # Fetch and process Actor results from the run's dataset
    for item in client.dataset(run["defaultDatasetId"]).iterate_items():
        title = item.get("title", "N/A")
        url = item.get("url", "N/A")
        restaurant_data.append({"Title": title, "URL": url})

        if "reviews" in item:
            for review in item["reviews"]:
                stars = review.get("stars", "N/A")
                language = review.get("language", "N/A")
                if isinstance(stars, list):
                    stars = sum(stars) / len(stars)
                review_data.append({"Title": title, "Language": language, "Stars": stars})

    df_restaurants = pd.DataFrame(restaurant_data)
    df_reviews = pd.DataFrame(review_data)



    # Calculate total reviews and overall rating
    df_total_reviews = df_reviews.groupby('Title').size().reset_index(name='total reviews')

    # Calculate overall rating
    df_overall_rating = df_reviews.groupby('Title')['Stars'].mean().reset_index(name='rating - overall')

    # Initialize language count columns
    df_total_reviews['fr count'] = 0
    df_total_reviews['en count'] = 0

    # Define your languages of interest
    languages = ['fr', 'en']

    # Process language-specific reviews
    for lang in languages:
        lang_reviews = df_reviews[df_reviews['Language'] == lang]
        if not lang_reviews.empty:
            # Calculate language-specific ratings and counts
            lang_rating = lang_reviews.groupby('Title')['Stars'].mean().reset_index(name=f'rating - {lang}')
            lang_count = lang_reviews.groupby('Title').size().reset_index(name='temp_count')
            
            # Merge the counts and ratings
            df_total_reviews = pd.merge(df_total_reviews, lang_count, on='Title', how='left')
            df_total_reviews[f'{lang} count'] = df_total_reviews.pop('temp_count').fillna(0)
            
            df_overall_rating = pd.merge(df_overall_rating, lang_rating, on='Title', how='left').fillna(0)
        else:
            # Handle case with no reviews in that language
            df_overall_rating[f'rating - {lang}'] = 0

    # Calculate the total reviews
    df_total_reviews['total reviews'] = df_total_reviews['fr count'] + df_total_reviews['en count']

    # Calculate percentages of reviews in each language
    df_total_reviews['% of reviews in french'] = (df_total_reviews['fr count'] / df_total_reviews['total reviews']) * 100
    df_total_reviews['% of reviews in english'] = (df_total_reviews['en count'] / df_total_reviews['total reviews']) * 100

    # Fill NaN values, if any, resulting from the calculations
    df_total_reviews.fillna(0, inplace=True)
    df_overall_rating.fillna(0, inplace=True)

    # Assuming you want to merge the overall rating back into df_total_reviews or df_restaurants
    df_avg_stars = pd.merge(df_total_reviews, df_overall_rating, on='Title', how='left')

    return df_restaurants, df_reviews, df_avg_stars

# UI for input forms
with st.form(key="user_inputs"):
    search_field = st.text_input("Enter Search Field", "steak and frites in the 9th")
    search_location = st.text_input("Enter Search Location", "Paris")
    max_items = st.number_input("How many businesses to assess", min_value=1, value=1)
    max_reviews = st.number_input("Enter Max Reviews", min_value=1, value=2)
    submit_button = st.form_submit_button("Fetch Data from Apify")

# Adjusted to strictly run on button click
if submit_button:
    # Fetch data and store in session state
    st.session_state.df_restaurants, st.session_state.df_reviews, st.session_state.df_avg_stars = fetch_data_from_apify(
        search_field, search_location, max_items, max_reviews)
    
    # Optional: Immediately display data after fetching
    st.subheader("Average Stars per Restaurant")
    st.dataframe(st.session_state.df_avg_stars)

if 'df_avg_stars' in st.session_state:
    st.sidebar.subheader("Filter Data:")
    selected_filters = {}
    for column in st.session_state.df_avg_stars.columns:
        if column != "Title" and column in st.session_state.df_avg_stars:
            min_value, max_value = float(0), float(st.session_state.df_avg_stars[column].max())
            selected_range = st.sidebar.slider(f"Filter {column}", min_value, max_value, (min_value, max_value), key=column)
            selected_filters[column] = selected_range

    filtered_df_avg_stars = st.session_state.df_avg_stars.copy()
    for column, selected_range in selected_filters.items():
        if column in filtered_df_avg_stars:
            filtered_df_avg_stars = filtered_df_avg_stars[(filtered_df_avg_stars[column] >= selected_range[0]) & (filtered_df_avg_stars[column] <= selected_range[1])]

    # Displaying filtered results
    st.subheader("Average Stars per Restaurant")
    st.dataframe(filtered_df_avg_stars)

    st.subheader("Restaurant Data")
    st.dataframe(st.session_state.df_restaurants)

    st.subheader("Review Data")
    st.dataframe(st.session_state.df_reviews)
