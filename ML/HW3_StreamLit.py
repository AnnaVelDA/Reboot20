import streamlit as st
import pandas as pd
from catboost import CatBoostRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import numpy as np

"""
  Задание:
    1. Добавить в demo_dataframe.py возможность выбора (от 10 до 35% с шагом 5) размера test выборки
       с помощью streamlit.selectbox.
    2. Отобразить результат предсказания - pd.DataFrame(y_test, pred)
"""

@st.cache()
def get_data():
    df_s = pd.read_csv('data/housing.csv')
    return df_s

df = get_data()

st.header('MVP предсказание стоимости жилья')

if st.checkbox('Отобразить данные'):
    st.write(df)
    st.line_chart(df)

_test_size = st.selectbox('размер тестовой выборки: ', (0.1, 0.15, 0.2, 0.25, 0.3, 0.35), index=3,
                          format_func=lambda x: f"{x*100:0.0f}%"
                          )


if st.button('Создать модель'):
    X_train, X_test, y_train, y_test = train_test_split(df.drop('MEDV', axis=1), df['MEDV'], test_size=_test_size,
                                                        random_state=0)
    st.text('Размер данных-'+str(X_train.shape) + str(X_test.shape))

    st.text('Старт модели')
    model = CatBoostRegressor()
    model.fit(X_train, y_train)
    st.text('Обучили модель')
    pred = model.predict(X_test)
    st.text(str(np.sqrt(mean_squared_error(y_test, pred))))

    df1 = pd.DataFrame(np.array(y_test), columns=["y_test"])
    df1["pred"] = pred
    df1.index = y_test.index
    st.write(df1)
