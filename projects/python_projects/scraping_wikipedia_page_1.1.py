import requests
import pandas as pd
from decimal import Decimal
from bs4 import BeautifulSoup


URL = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'

page = requests.get(URL)
soup = BeautifulSoup(page.text, 'html.parser')

table = soup.find_all('table')[1]

world_titles = table.find_all('th')
headers = [title.text.strip() for title in world_titles]

df = pd.DataFrame(columns = headers)

rows = table.find_all('tr')[1:]
for row in rows:
    cells = row.find_all('td')
    row_data = []
    for cell in cells:
        img = cell.find('img')
        if img:
            alt_text = img.get('alt', '').strip()
            row_data.append(cell.text.strip()+ ' ' + alt_text)
        else:
            row_data.append(cell.text.strip())
    row_index = len(df)
    df.loc[row_index] = row_data

df[['Revenue growth rate', 'Revenue growth direction']] = df['Revenue growth'].str.extract(r'([\d\.\-]+%)\s*(Increase|Decrease)')

df['Revenue growth rate'] = df['Revenue growth rate'].str.replace('%', '').apply(Decimal)
df['Revenue growth rate'] = df.apply(lambda row: row['Revenue growth rate'] * (1 if row['Revenue growth direction'] == 'Increase' else -1), axis=1)

df[['Headquarters city', 'Headquarters state']] = df['Headquarters'].str.split(',', n=1, expand=True)

df.to_csv(r"D:/Download/companies.csv", index = False)