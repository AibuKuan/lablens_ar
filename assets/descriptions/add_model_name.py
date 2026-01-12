import json
import os

file_path = 'assets/descriptions/descriptions.json'

with open(file_path, 'r') as f:
    data = json.load(f)

for key, details in data.items():
    if "modelPath" in details:
        path = details["modelPath"]
        # Extracts 'operating-table' from 'assets/models/operating-table.glb'
        model_name = os.path.splitext(os.path.basename(path))[0]
        details["modelName"] = model_name

with open(file_path, 'w') as f:
    json.dump(data, f, indent=4)

print("JSON updated successfully.")