import pandas as pd

county_resource_codes = {"Digby": "wpsu-7fer"}

for county, resource_code in county_resource_codes.items():
    url = f"https://data.novascotia.ca/resource/{resource_code}.csv"
    df = pd.read_csv(url)
    col = "timestamp_utc"
    timestamp_na_count = df[col].isna().sum()

    print(f"The {county} dataset has {timestamp_na_count} NA values in the {col} column.")
