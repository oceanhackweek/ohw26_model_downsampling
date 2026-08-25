import pandas as pd

county_resource_codes = {"Digby": "wpsu-7fer"}

output_file = "downloaded_data.csv"

for county, resource_code in county_resource_codes.items():
    url = f"https://data.novascotia.ca/resource/{resource_code}.csv"
    df = pd.read_csv(url)
    df.to_csv(output_file, index=False)

