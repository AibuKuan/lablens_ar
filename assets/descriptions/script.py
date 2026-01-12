import json
import os

def merge_json_files(input_folder, output_file):
    combined_data = {}

    for filename in os.listdir(input_folder):
        if filename.endswith(".json") and filename != output_file:
            file_path = os.path.join(input_folder, filename)
            
            with open(file_path, 'r') as f:
                try:
                    data = json.load(f)
                    
                    item_name = data.get("name")
                    if item_name:
                        # Create a copy and remove 'name' from the nested object
                        details = data.copy()
                        del details["name"]
                        
                        combined_data[item_name] = details
                except json.JSONDecodeError:
                    print(f"Error parsing {filename}. Skipping.")

    with open(output_file, 'w') as f:
        json.dump(combined_data, f, indent=4)

if __name__ == "__main__":
    # Specify your folder path and desired output name
    target_folder = "./assets/descriptions/" 
    output_filename = "combined_equipment.json"
    
    merge_json_files(target_folder, output_filename)
    print(f"Successfully created {output_filename}")