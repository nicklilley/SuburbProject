{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 9,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "DeltaGenerator(_root_container=0, _provided_cursor=None, _parent=None, _block_type=None, _form_data=None)"
      ]
     },
     "execution_count": 9,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "import streamlit as st\n",
    "import pandas as pd\n",
    "\n",
    "st.write(\"\"\"\n",
    "# My First App\n",
    "Hello *world!*\n",
    "\"\"\")\n",
    "\n",
    "df = pd.read_csv(\"suburbdatatest.csv\")\n",
    "st.line_chart(df)"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3.10.6 64-bit (windows store)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.10.6"
  },
  "orig_nbformat": 4,
  "vscode": {
   "interpreter": {
    "hash": "7d768dd2128334442ca1e92e2788cb227a54429e0fad75b40fb8e40e4736d8a3"
   }
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
