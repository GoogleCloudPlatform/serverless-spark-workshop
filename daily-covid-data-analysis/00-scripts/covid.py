'''
  Copyright 2022 Google LLC
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
'''

import numpy as np
import pandas as pd
import random
import math
import time
import datetime
import operator
from IPython.display import set_matplotlib_formats
set_matplotlib_formats('retina')
import warnings
warnings.filterwarnings("ignore")
import sys



#Reading the arguments and storing them in variables
BUCKET_NAME=sys.argv[1]

#Reading the Input Data
confirmed_df = pd.read_csv("gs://"+BUCKET_NAME+"/daily-covid-data-analysis/01-datasets/confirmed_df.csv")
deaths_df = pd.read_csv("gs://"+BUCKET_NAME+"/daily-covid-data-analysis/01-datasets/death_df.csv")
latest_data = pd.read_csv("gs://"+BUCKET_NAME+"/daily-covid-data-analysis/01-datasets/latest_data.csv")
us_medical_data = pd.read_csv("gs://"+BUCKET_NAME+"/daily-covid-data-analysis/01-datasets/us_medical_data.csv")

confirmed_cols = confirmed_df.keys()
deaths_cols = deaths_df.keys()

confirmed = confirmed_df.loc[:, confirmed_cols[4]:]
deaths = deaths_df.loc[:, deaths_cols[4]:]

num_dates = len(confirmed.keys())
ck = confirmed.keys()
dk = deaths.keys()

world_cases = []
total_deaths = []
mortality_rate = []

for i in range(num_dates):
    confirmed_sum = confirmed[ck[i]].sum()
    death_sum = deaths[dk[i]].sum()

    world_cases.append(confirmed_sum)
    total_deaths.append(death_sum)

    # calculate rates
    mortality_rate.append(death_sum / confirmed_sum)

def daily_increase(data):
    d = []
    for i in range(len(data)):
        if i == 0:
            d.append(data[0])
        else:
            d.append(data[i]-data[i-1])
    return d

def moving_average(data, window_size):
    moving_average = []
    for i in range(len(data)):
        if i + window_size < len(data):
            moving_average.append(np.mean(data[i:i+window_size]))
        else:
            moving_average.append(np.mean(data[i:len(data)]))
    return moving_average

# window size
window = 7

# confirmed cases
world_daily_increase = daily_increase(world_cases)
world_confirmed_avg= moving_average(world_cases, window)
world_daily_increase_avg = moving_average(world_daily_increase, window)

# deaths
world_daily_death = daily_increase(total_deaths)
world_death_avg = moving_average(total_deaths, window)
world_daily_death_avg = moving_average(world_daily_death, window)

days_since_1_22 = np.array([i for i in range(len(ck))]).reshape(-1, 1)
world_cases = np.array(world_cases).reshape(-1, 1)
total_deaths = np.array(total_deaths).reshape(-1, 1)

days_in_future = 10
future_forcast = np.array([i for i in range(len(ck)+days_in_future)]).reshape(-1, 1)
adjusted_dates = future_forcast[:-10]

start = '1/22/2020'
start_date = datetime.datetime.strptime(start, '%m/%d/%Y')
future_forcast_dates = []
for i in range(len(future_forcast)):
    future_forcast_dates.append((start_date + datetime.timedelta(days=i)).strftime('%m/%d/%Y'))

unique_countries =  list(latest_data['Country_Region'].unique())

country_confirmed_cases = []
country_death_cases = []
country_active_cases = []
country_incidence_rate = []
country_mortality_rate = []

no_cases = []
for i in unique_countries:
    cases = latest_data[latest_data['Country_Region'] == i]['Confirmed'].sum()
    if cases > 0:
        country_confirmed_cases.append(cases)
    else:
        no_cases.append(i)

for i in no_cases:
    unique_countries.remove(i)

# sort countries by the number of confirmed cases
unique_countries = [k for k, v in
                    sorted(zip(unique_countries, country_confirmed_cases), key=operator.itemgetter(1), reverse=True)]
for i in range(len(unique_countries)):
    country_confirmed_cases[i] = latest_data[latest_data['Country_Region'] == unique_countries[i]]['Confirmed'].sum()
    country_death_cases.append(latest_data[latest_data['Country_Region'] == unique_countries[i]]['Deaths'].sum())
    country_incidence_rate.append(
        latest_data[latest_data['Country_Region'] == unique_countries[i]]['Incident_Rate'].sum())
    country_mortality_rate.append(country_death_cases[i] / country_confirmed_cases[i])

country_df = pd.DataFrame({'Country Name': unique_countries, 'Number of Confirmed Cases': [format(int(i), ',d') for i in country_confirmed_cases],
                          'Number of Deaths': [format(int(i), ',d') for i in country_death_cases],
                          'Incidence Rate' : country_incidence_rate,
                          'Mortality Rate': country_mortality_rate})
# number of cases per country/region

print(country_df)

unique_provinces =  list(latest_data['Province_State'].unique())

province_confirmed_cases = []
province_country = []
province_death_cases = []
province_incidence_rate = []
province_mortality_rate = []

no_cases = []
for i in unique_provinces:
    cases = latest_data[latest_data['Province_State'] == i]['Confirmed'].sum()
    if cases > 0:
        province_confirmed_cases.append(cases)
    else:
        no_cases.append(i)

# remove areas with no confirmed cases
for i in no_cases:
    unique_provinces.remove(i)

unique_provinces = [k for k, v in
                    sorted(zip(unique_provinces, province_confirmed_cases), key=operator.itemgetter(1), reverse=True)]
for i in range(len(unique_provinces)):
    province_confirmed_cases[i] = latest_data[latest_data['Province_State'] == unique_provinces[i]]['Confirmed'].sum()
    province_country.append(
        latest_data[latest_data['Province_State'] == unique_provinces[i]]['Country_Region'].unique()[0])
    province_death_cases.append(latest_data[latest_data['Province_State'] == unique_provinces[i]]['Deaths'].sum())
    #     province_recovery_cases.append(latest_data[latest_data['Province_State']==unique_provinces[i]]['Recovered'].sum())
    #     province_active.append(latest_data[latest_data['Province_State']==unique_provinces[i]]['Active'].sum())
    province_incidence_rate.append(
        latest_data[latest_data['Province_State'] == unique_provinces[i]]['Incident_Rate'].sum())
    province_mortality_rate.append(province_death_cases[i] / province_confirmed_cases[i])

# number of cases per province/state/city top 100
province_limit = 100
province_df = pd.DataFrame({'Province/State Name': unique_provinces[:province_limit], 'Country': province_country[:province_limit], 'Number of Confirmed Cases': [format(int(i), ',d') for i in province_confirmed_cases[:province_limit]],
                          'Number of Deaths': [format(int(i), ',d') for i in province_death_cases[:province_limit]],
                        'Incidence Rate' : province_incidence_rate[:province_limit], 'Mortality Rate': province_mortality_rate[:province_limit]})
# number of cases per country/region

print(province_df)


# return the data table with province/state info for a given country
def country_table(country_name):
    states = list(latest_data[latest_data['Country_Region'] == country_name]['Province_State'].unique())
    state_confirmed_cases = []
    state_death_cases = []
    # state_recovery_cases = []
    #     state_active = []
    state_incidence_rate = []
    state_mortality_rate = []

    no_cases = []
    for i in states:
        cases = latest_data[latest_data['Province_State'] == i]['Confirmed'].sum()
        if cases > 0:
            state_confirmed_cases.append(cases)
        else:
            no_cases.append(i)

    # remove areas with no confirmed cases
    for i in no_cases:
        states.remove(i)

    states = [k for k, v in sorted(zip(states, state_confirmed_cases), key=operator.itemgetter(1), reverse=True)]
    for i in range(len(states)):
        state_confirmed_cases[i] = latest_data[latest_data['Province_State'] == states[i]]['Confirmed'].sum()
        state_death_cases.append(latest_data[latest_data['Province_State'] == states[i]]['Deaths'].sum())
        #     state_recovery_cases.append(latest_data[latest_data['Province_State']==states[i]]['Recovered'].sum())
        #         state_active.append(latest_data[latest_data['Province_State']==states[i]]['Active'].sum())
        state_incidence_rate.append(latest_data[latest_data['Province_State'] == states[i]]['Incident_Rate'].sum())
        state_mortality_rate.append(state_death_cases[i] / state_confirmed_cases[i])

    state_df = pd.DataFrame(
        {'State Name': states, 'Number of Confirmed Cases': [format(int(i), ',d') for i in state_confirmed_cases],
         'Number of Deaths': [format(int(i), ',d') for i in state_death_cases],
         'Incidence Rate': state_incidence_rate, 'Mortality Rate': state_mortality_rate})
    # number of cases per country/region
    return state_df

us_table = country_table('US')
print(us_table)

india_table = country_table('India')
print(india_table)

brazil_table = country_table('Brazil')
print(brazil_table)

russia_table = country_table('Russia')
print(russia_table)

uk_table = country_table('United Kingdom')
print(uk_table)

france_table = country_table('France')
print(france_table)

italy_table = country_table('Italy')
print(italy_table)

germany_table = country_table('Germany')
print(germany_table)

spain_table = country_table('Spain')
print(spain_table)

china_table = country_table('China')
print(china_table)

mexico_table = country_table('Mexico')
print(mexico_table)


