import sodapy as sdp
import pandas as pd
import yaml

with open('contributor_folders/danielle/config.yml', 'r') as file:
    config = yaml.safe_load(file)
    
county_resource_codes = {"Digby": "wpsu-7fer"}

with sdp.Socrata(
    "data.novascotia.ca",
    config['default']['app_token'],
    username = config['default']['email'],
    password = config['default']['password']
) as client:
    for county, resource_code in county_resource_codes.items():
        results = client.get_all(resource_code)
        df = pd.DataFrame(results)
        col = "timestamp_utc"
        timestamp_na_count = df[col].isna().sum()
        print(f"The {county} dataset has {timestamp_na_count} NA values in the {col} column, out of {df.shape[0]}.")
    
