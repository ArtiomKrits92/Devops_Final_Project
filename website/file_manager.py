import json
import os
import tempfile
import time

# Simple file manager for saving/loading data
class FileManager:
    def __init__(self):
        # Use /data for NFS mount (set via environment variable or default to /data)
        self.data_dir = os.environ.get("DATA_DIR", "/data")
        self.items_file = os.path.join(self.data_dir, "items.json")
        self.users_file = os.path.join(self.data_dir, "users.json")
        
        # Create data directory if it doesn't exist
        if not os.path.exists(self.data_dir):
            os.makedirs(self.data_dir)
    
    def _atomic_write(self, filepath, data, max_retries=5):
        """Atomically write data to file with file locking and retries"""
        lock_file = filepath + ".lock"
        temp_file = None
        
        for attempt in range(max_retries):
            try:
                # Create lock file
                lock_fd = os.open(lock_file, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                try:
                    # Write to temporary file first
                    temp_file = filepath + ".tmp"
                    with open(temp_file, 'w') as f:
                        json.dump(data, f, indent=2)
                    
                    # Atomic rename (works on most filesystems including NFS)
                    os.rename(temp_file, filepath)
                    return True
                finally:
                    os.close(lock_fd)
                    if os.path.exists(lock_file):
                        os.remove(lock_file)
            except (OSError, IOError) as e:
                if attempt < max_retries - 1:
                    time.sleep(0.1 * (attempt + 1))  # Exponential backoff
                    continue
                else:
                    print(f"ERROR: Failed to write {filepath} after {max_retries} attempts: {e}")
                    # Fallback: try direct write without locking
                    try:
                        with open(filepath, 'w') as f:
                            json.dump(data, f, indent=2)
                        return True
                    except Exception as fallback_error:
                        print(f"ERROR: Fallback write also failed: {fallback_error}")
                        raise
            finally:
                if temp_file and os.path.exists(temp_file):
                    os.remove(temp_file)
        return False
    
    def save_items(self, items_db):
        # Save items to JSON file with atomic write and locking
        self._atomic_write(self.items_file, items_db)
    
    def save_users(self, users_db):
        # Save users to JSON file with atomic write and locking
        self._atomic_write(self.users_file, users_db)
    
    def load_items(self):
        # Load items from JSON file
        if os.path.exists(self.items_file) and os.path.getsize(self.items_file) > 0:
            try:
                with open(self.items_file, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, ValueError):
                # File exists but is corrupted/empty, return None to use dummy data
                return None
        return None
    
    def load_users(self):
        # Load users from JSON file
        if os.path.exists(self.users_file) and os.path.getsize(self.users_file) > 0:
            try:
                with open(self.users_file, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, ValueError):
                # File exists but is corrupted/empty, return None to use dummy data
                return None
        return None