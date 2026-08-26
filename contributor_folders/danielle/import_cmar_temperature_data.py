# August 26, 2026
# this script downloads Digby county Water Quality data from the 
# Nova Scotia Open Data Portal
# https://data.novascotia.ca/Nature-and-Environment/Digby-County-Water-Quality-Data/wpsu-7fer/about_data

# The raw temperature data is filtered for Quality Control Flags of
# "Pass", "Not Evaluated", and "Suspect/Of Interest" (i.e., obervations flagged
# as "Fail" are dropped)
# The data is filtered for years 2017 - 2019

##############################################################
# this is really slow - it took over an hour to run.
# Alternatively, download manually from the Open Data Portal:
# https://data.novascotia.ca/Nature-and-Environment/Digby-County-Water-Quality-Data/wpsu-7fer/about_data
# you may need to download in a few smaller chunks
##############################################################

import sodapy as sdp
import pandas as pd
import yaml
from pathlib import Path

output_file = "data/cmar_temperature_data.csv"
output_dir = Path("data")
output_dir.mkdir(parents=True, exist_ok=True)
Path(output_file).parent.mkdir(parents=True, exist_ok=True)

county = "Digby"
resource_code = "wpsu-7fer"

keep_cols = [
    "station", "latitude", "longitude", "sensor_serial_number",
    "timestamp_utc", "sensor_depth_at_low_tide_m", "temperature_degree_c",
    "qc_flag_temperature_degree_c",
]
keep_flags = ["Pass", "Not Evaluated", "Suspect/Of Interest"]

with open("contributor_folders/danielle/config.yml", "r") as file:
    config = yaml.safe_load(file)
    
with sdp.Socrata(
    "data.novascotia.ca",
    config["default"]["app_token"],
    username=config["default"]["email"],
    password=config["default"]["password"],
) as client:
     #df = pd.DataFrame(client.get_all(resource_code))
     df = pd.DataFrame(client.get(resource_code, limit=1000))
    
df = pd.DataFrame(df)
print(f"The {county} dataset has been downloaded ({len(df)} rows).")

df["timestamp_utc"] = pd.to_datetime(df["timestamp_utc"])

df = df.loc[
    (df["qc_flag_temperature_degree_c"].isin(keep_flags)) & 
    (df["timestamp_utc"].dt.year.between(2016, 2019)),
    keep_cols,
].reset_index(drop=True)
#df.to_csv(output_file, index=False)
for station, group in df.groupby("station"):
    safe_name = station.replace(" ", "_").replace("/", "-")
    path = output_dir / f"cmar_temperature_{safe_name}.csv"
    group.to_csv(path, index=False)
    print(f"Wrote {len(group)} rows to {path}.")

#print(f"Wrote {len(df)} rows to {output_file}.")



