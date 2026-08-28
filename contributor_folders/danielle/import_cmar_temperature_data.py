# August 26, 2026
# this script downloads Digby county Water Quality data from the 
# Nova Scotia Open Data Portal
# https://data.novascotia.ca/Nature-and-Environment/Digby-County-Water-Quality-Data/wpsu-7fer/about_data

# The raw temperature data is filtered for Quality Control Flags of
# "Pass", "Not Evaluated", and "Suspect/Of Interest" (i.e., obervations flagged
# as "Fail" are dropped)

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

output_dir = Path("/home/jovyan/shared-public/ohw26/model_downsampling/")
output_dir.mkdir(parents=True, exist_ok=True)
output_path = output_dir / "cmar_temperature.csv"

resource_code = "wpsu-7fer"

keep_cols = [
    "station", "latitude", "longitude", "sensor_serial_number",
    "timestamp_utc", "sensor_depth_at_low_tide_m", "temperature_degree_c",
    "qc_flag_temperature_degree_c",
]
keep_flags = ["Pass", "Not Evaluated", "Suspect/Of Interest"]

with open("config.yml", "r") as file:
    config = yaml.safe_load(file)
    
with sdp.Socrata(
    "data.novascotia.ca",
    config["default"]["app_token"],
    username=config["default"]["email"],
    password=config["default"]["password"],
) as client:
     df = pd.DataFrame(client.get_all(resource_code))
     #df = pd.DataFrame(client.get(resource_code, limit=1000))
    
print(f"The dataset has been downloaded: ({len(df)} rows).")

df["timestamp_utc"] = pd.to_datetime(df["timestamp_utc"])

df = df.loc[
    (df["qc_flag_temperature_degree_c"].isin(keep_flags)), 
    keep_cols,
].reset_index(drop=True)
df.to_csv(output_path, index=False)
print(f"Wrote {len(df)} rows to {output_path}.")


