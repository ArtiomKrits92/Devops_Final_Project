import json
import os

# Simple file manager for saving/loading data
class FileManager:
    def __init__(self):
        self.data_dir = "data"
        self.items_file = os.path.join(self.data_dir, "items.json")
        self.users_file = os.path.join(self.data_dir, "users.json")
        
        # Create data directory if it doesn't exist
        if not os.path.exists(self.data_dir):
            os.makedirs(self.data_dir)
    
    def save_items(self, items_db):
        # Save items to JSON file
        with open(self.items_file, 'w') as f:
            json.dump(items_db, f, indent=2)
    
    def save_users(self, users_db):
        # Save users to JSON file
        with open(self.users_file, 'w') as f:
            json.dump(users_db, f, indent=2)
    
    def load_items(self):
        # Load items from JSON file
        if os.path.exists(self.items_file):
            with open(self.items_file, 'r') as f:
                return json.load(f)
        return None
    
    def load_users(self):
        # Load users from JSON file
        if os.path.exists(self.users_file):
            with open(self.users_file, 'r') as f:
                return json.load(f)
        return None