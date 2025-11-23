# 🖥️ IT Asset Management System

![Technion](https://img.shields.io/badge/Technion-DevOps_2025-blue)
![Python](https://img.shields.io/badge/Python-3.13-blue.svg)
![Flask](https://img.shields.io/badge/Flask-3.0-green.svg)
![Status](https://img.shields.io/badge/Status-Phase_1_Complete-success)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

> A Flask web application for managing IT assets with persistent file-based storage. Track hardware, accessories, licenses, and user assignments through an intuitive web interface.

**Author:** Artiom Krits | **GitHub:** [@ArtiomKrits92](https://github.com/ArtiomKrits92)

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Key Highlights](#-key-highlights)
- [Architecture Evolution](#-architecture-evolution)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
- [Data Persistence](#-data-persistence)
- [Getting Started](#-getting-started)
  - [Containerization with Docker](#23-containerization-with-docker)
- [Project Structure](#-project-structure)
- [API Endpoints](#-api-endpoints)
- [Lessons Learned](#-lessons-learned)
- [License](#-license)

---

## 🎯 Overview

The IT Asset Management System is a Flask web application designed to track, manage, and organize IT assets within an organization. The application provides a user-friendly web interface for managing inventory, users, and asset assignments with automatic data persistence to JSON files.

**Key Capabilities:**
- Track IT assets, accessories, and software licenses
- Assign assets to users
- Monitor inventory levels and stock valuation
- Generate reports by category and user
- Persistent data storage with JSON file-based backend

---

## 🎯 Key Highlights

- **Full CRUD operations with persistent storage** - Create, read, update, and delete assets and users with automatic JSON file persistence
- **Bootstrap-powered responsive UI** - Modern, mobile-friendly interface built with Bootstrap 5.3
- **Real-time inventory analytics** - Dashboard with live statistics, stock valuation, and category-based reporting
- **Multi-user asset assignment system** - Assign and track IT assets across multiple users with detailed assignment history
- **RESTful API design** - Clean, intuitive route structure following REST principles for easy extension

---

## 🏗️ Architecture Evolution

The project evolved from a command-line interface to a full-featured web application:

```mermaid
graph LR
    A[Phase 1: CLI App<br/>Python Script<br/>In-Memory Storage] --> B[Phase 2: Web App<br/>Flask + HTML<br/>JSON File Persistence]
    
    style A fill:#bf616a,stroke:#2e3440,stroke-width:3px,color:#eceff4
    style B fill:#5e81ac,stroke:#2e3440,stroke-width:3px,color:#eceff4
```

**Phase 1 → Phase 2 Improvements:**
- **Interface**: Command-line → Web-based UI with Bootstrap styling
- **Data Storage**: In-memory dictionaries → Persistent JSON files
- **User Experience**: Terminal interactions → Intuitive web forms and navigation
- **Accessibility**: Single-user script → Multi-user web application

---

## 🛠️ Tech Stack

### Frontend
- **HTML5/CSS3** - Modern, responsive web interface
- **Bootstrap 5.3** - UI framework for professional styling
- **Jinja2 Templates** - Server-side templating engine

### Backend
- **Python 3.13** - Core programming language
- **Flask 3.0** - Lightweight web framework
- **JSON** - File-based data persistence

### Development Tools
- **Git** - Version control
- **Virtual Environment** - Python dependency isolation

---

## ✨ Features

### Asset Management
- ➕ Add new IT assets (hardware, accessories, licenses)
- 🗑️ Delete assets from inventory
- ✏️ Modify existing asset details
- 📋 View all assets with filtering options

### User Management
- 👤 Add new users to the system
- 📊 View all registered users
- 🔗 Assign assets to specific users
- 📦 View assets assigned to each user

### Reporting & Analytics
- 📈 Dashboard with key metrics (total users, items, stock status)
- 💰 Stock valuation by category (Assets, Accessories, Licenses)
- 📊 Inventory status tracking (In Stock / Assigned)
- 🔍 Category-based filtering and reporting

---

## 💾 Data Persistence

The application uses JSON file-based persistence for simplicity and portability:

- **Storage Location**: `website/data/` directory
- **Files**: 
  - `items.json` - Asset inventory data
  - `users.json` - User registry and assignments
- **Automatic Operations**:
  - Data is automatically saved after each modification
  - Data is loaded on application startup
  - Files are created automatically if they don't exist

**File Format Example:**
```json
{
  "1": {
    "id": "1",
    "main_category": "Assets",
    "sub_category": "Laptop",
    "manufacturer": "Dell",
    "model": "XPS 15",
    "price": 1299.99,
    "quantity": 1,
    "status": "In Stock",
    "assigned_to": null
  }
}
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.13 or higher
- pip (Python package manager)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/ArtiomKrits92/it-asset-management.git
   cd it-asset-management
   ```

2. **Create and activate virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   cd website
   python app.py
   ```

5. **Access the application**
   - Open your browser and navigate to `http://localhost:31415`
   - The application will automatically create data files in `website/data/` on first run

### 2.3 Containerization with Docker

The application has been containerized using Docker for consistent deployment across different environments. Docker ensures that the application runs the same way on any machine, whether it's a developer's laptop or a production server.

**Why Python 3.9-slim?**

We chose Python 3.9-slim as the base image for a good balance between image size and compatibility:
- **Size**: The slim variant is approximately 226MB, compared to ~900MB for the full Python image
- **Compatibility**: Python 3.9 provides excellent compatibility with Flask and all required dependencies
- **Alpine Alternative**: While Alpine Linux images are smaller (~50MB), they can have compatibility issues with some Python packages that require compiled extensions

**Docker Files Overview:**

1. **Dockerfile** - Defines how to build the container image:
   - Uses Python 3.9-slim base image
   - Copies application files from `website/` directory
   - Installs Flask and dependencies
   - Creates data directory for persistence
   - Exposes port 31415 for the Flask application

2. **.dockerignore** - Excludes unnecessary files from the build context:
   - Python cache files (`__pycache__/`, `*.pyc`)
   - Git files and virtual environments
   - Documentation and log files
   - This reduces build time and image size

3. **docker-compose.yml** - Simplifies container management:
   - Defines service configuration
   - Maps port 31415 to host
   - Mounts `./data` volume for persistent storage
   - Sets environment variables

**Docker Commands:**

**Build the image:**
```bash
docker build -t asset-manager:latest .
```

**Run container manually:**
```bash
docker run -d -p 31415:31415 -v $(pwd)/data:/data asset-manager:latest
```

**Run with Docker Compose (recommended):**
```bash
docker-compose up -d
```

**Stop the container:**
```bash
docker-compose down
```

**Access the application:**
- Once running, navigate to `http://localhost:31415` in your browser
- Data files are persisted in the `./data` directory on your host machine

**Docker Hub:**
The containerized application is available on Docker Hub:
- **Image**: [artie92/asset-manager:latest](https://hub.docker.com/r/artie92/asset-manager)

You can pull and run the image directly:
```bash
docker pull artie92/asset-manager:latest
docker run -d -p 31415:31415 -v $(pwd)/data:/data artie92/asset-manager:latest
```

---

## 📁 Project Structure

```
Devops_Final_Project/
│
├── website/                               # Main application directory
│   ├── app.py                             # Flask application entry point
│   ├── data.py                            # Data models and in-memory databases
│   ├── file_manager.py                    # File persistence layer
│   ├── demo.py                            # Demo data initialization
│   │
│   ├── data/                              # Data persistence directory
│   │   ├── items.json                     # Asset inventory data
│   │   └── users.json                     # User registry data
│   │
│   └── templates/                         # Jinja2 HTML templates
│       ├── base.html                      # Base template with navigation
│       ├── index.html                     # Dashboard/homepage
│       ├── add_item.html                  # Add asset form
│       ├── delete_item.html               # Delete asset form
│       ├── modify_item_select.html        # Select item to modify
│       ├── modify_item_form.html          # Modify asset form
│       ├── assign_item.html               # Assign asset to user
│       ├── add_user.html                  # Add user form
│       ├── show_users.html                # User listing
│       ├── show_user_items_select.html    # Select user to view items
│       ├── show_user_items.html           # View user's assigned assets
│       ├── show_stock_items.html          # Inventory listing
│       └── stock_by_categories.html       # Category reports
│
├── venv/                                  # Python virtual environment
├── requirements.txt                       # Python dependencies
├── Dockerfile                             # Docker container definition
├── .dockerignore                          # Docker build exclusions
├── docker-compose.yml                     # Docker Compose configuration
└── README.md                              # This file
```

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Dashboard with statistics |
| `GET/POST` | `/add_item` | Add new asset to inventory |
| `GET/POST` | `/delete_item` | Remove asset from inventory |
| `GET` | `/modify_item` | Select item to modify |
| `GET/POST` | `/modify_item_form` | Update asset details |
| `GET/POST` | `/assign_item` | Assign asset to user |
| `GET/POST` | `/add_user` | Register new user |
| `GET` | `/show_users` | List all users |
| `GET/POST` | `/show_user_items` | View user's assigned assets |
| `GET` | `/show_stock_items` | Display all inventory items |
| `GET` | `/stock_by_categories` | Category-based stock valuation |

---

## 💡 Lessons Learned

### Development Phase
- **Modular Design**: Separating concerns (data layer, business logic, presentation) made the codebase maintainable and testable
- **File Persistence**: Implementing a simple file manager abstraction (`FileManager` class) provides a clean interface for data operations and allows for easy migration to database systems in the future
- **User Experience**: Flask's flash messaging system provides excellent feedback for user actions, improving the overall user experience
- **Template Inheritance**: Using Jinja2's template inheritance (`base.html`) reduced code duplication and simplified maintenance
- **Data Validation**: Client-side and server-side validation ensures data integrity and prevents errors

### Technical Insights
- **JSON Persistence**: While simple, JSON file storage works well for small to medium datasets and provides human-readable data
- **Flask Routing**: RESTful route design makes the application intuitive and easy to extend
- **State Management**: Careful handling of in-memory dictionaries and file synchronization prevents data loss
- **Error Handling**: Proper error handling and user feedback prevents confusion and improves reliability

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Artiom Krits**

- GitHub: [@ArtiomKrits92](https://github.com/ArtiomKrits92)
- Project Link: [https://github.com/ArtiomKrits92/it-asset-management](https://github.com/ArtiomKrits92/it-asset-management)
- LinkedIn: [https://www.linkedin.com/in/artiom-krits-%F0%9F%8E%97%EF%B8%8F-855372202/](https://www.linkedin.com/in/artiom-krits-%F0%9F%8E%97%EF%B8%8F-855372202/)

---

## 🙏 Acknowledgments

- Flask community for excellent documentation and framework
- Bootstrap team for the responsive UI framework
- Jinja2 developers for the powerful templating engine
- Open source community for invaluable tools and resources

---

**⭐ If you found this project helpful, please consider giving it a star!**
