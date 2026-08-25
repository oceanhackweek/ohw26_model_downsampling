import importlib
scp = importlib.import_module("socrata-py")
import yaml

with open('config.yaml', 'r') as file:
    config = yaml.safe_load(file)

resource_code = "knwz-4bap"

auth = scp.Socrata.Authorization(f"https://data.novascotia.ca/resource/{resource_code}.csv",
                                 username = config['username'],
                                 password = config['password'])