# IT Asset Management - User Guide

## 📖 Introduction

The IT Asset Management application is a web-based system for tracking and managing IT assets, users, and assignments within an organization. This application helps you:

- 📦 Track IT hardware, accessories, and software licenses
- 👤 Manage users and their assigned assets
- 📊 Monitor inventory levels and stock valuation
- 💰 Calculate total asset value by category

The application runs on Kubernetes and uses NFS storage for persistent data, ensuring your information is saved even if the application restarts.

## 🌐 Accessing the Application

1. **Get the Application URL:**
   - After deployment, get the ALB DNS name from Terraform:
     ```bash
     cd terraform
     terraform output load_balancer_dns
     ```

2. **Open in Browser:**
   - Open your web browser
   - Navigate to: `http://<ALB_DNS>`
   - Example: `http://app-load-balancer-123456789.us-east-1.elb.amazonaws.com`

3. **Initial Load:**
   - The application loads with dummy data on first access
   - You'll see sample items and users already in the system

[Screenshot: Application Homepage]

## 📊 Dashboard Overview

The dashboard (homepage) displays key statistics about your IT assets:

- **Total Users** 👥 - Number of registered users in the system
- **Total Items** 📦 - Total number of assets in inventory
- **Items In Stock** ✅ - Items available for assignment
- **Items Assigned** 🔗 - Items currently assigned to users
- **Items by Category** 📋 - Breakdown showing:
  - Assets count
  - Accessories count
  - Licenses count

[Screenshot: Dashboard with Statistics]

## 🗂️ Navigation Menu

The application has a navigation menu at the top with the following options:

1. **Add New Item** ➕
2. **Delete Item** 🗑️
3. **Modify Item** ✏️
4. **Assign Item** 🔗
5. **Add New User** 👤
6. **Show All Users** 📋
7. **Show Items by User** 🔍
8. **Show All Items** 📦
9. **Calculate Stock** 💰

Click any menu item to navigate to that feature.

## 📦 Asset Management Features

### Adding a New Item

To add a new IT asset to your inventory:

1. Click **"Add New Item"** in the navigation menu
2. Fill in the form:
   - **Main Category**: Select from:
     - **Assets** - Hardware like computers and laptops
     - **Accessories** - Peripherals and add-ons
     - **Licenses** - Software licenses and subscriptions
   
   - **Sub Category**: Based on your main category selection:
     - **Assets**: 
       - PC
       - Laptop
     - **Accessories**:
       - Mouse
       - Keyboard
       - Docking Station
       - Monitor
       - Headset
     - **Licenses**:
       - Serial Number
       - Subscription
   
   - **Manufacturer**: Company name (e.g., "Dell", "Microsoft")
   - **Model**: Product model (e.g., "XPS 15", "Office 365")
   - **Price per Unit (₪)**: Price in Israeli Shekels (e.g., 1299.99)

3. Click **"Add Item"** button
4. You'll see a success message and be redirected to the dashboard

**Note:** The item is automatically saved and will persist even if you refresh the page.

[Screenshot: Add Item Form]

### Deleting an Item

To remove an item from inventory:

1. Click **"Delete Item"** in the navigation menu
2. Select the item ID from the dropdown list
3. Click **"Delete Item"** button
4. Confirm the deletion
5. The item is permanently removed from the system

**Warning:** Deletion cannot be undone. Make sure you want to delete the item before confirming.

[Screenshot: Delete Item Form]

### Modifying an Item

To update item details:

1. Click **"Modify Item"** in the navigation menu
2. Select the item you want to modify from the dropdown
3. Update any of the following fields:
   - **Manufacturer** - Change the manufacturer name
   - **Model** - Update the model number
   - **Price** - Adjust the price per unit
4. Click **"Update Item"** button
5. Changes are saved immediately

**Note:** Main category, sub category, and quantity cannot be modified after creation.

[Screenshot: Modify Item Form]

### Assigning Items to Users

To assign an asset to a user:

1. Click **"Assign Item"** in the navigation menu
2. Select the item from the dropdown (only "In Stock" items are shown)
3. Select the user from the dropdown
4. Click **"Assign"** button
5. The item status changes from "In Stock" to "Assigned"
6. The item is now linked to the selected user

**Note:** Once assigned, the item cannot be assigned to another user until it's unassigned (by modifying its status).

[Screenshot: Assign Item Form]

## 👤 User Management Features

### Adding a New User

To register a new user:

1. Click **"Add New User"** in the navigation menu
2. Fill in the form:
   - **Name**: Full name (e.g., "John Doe")
   - **Email**: Email address (e.g., "john@example.com")
   - **Department**: Department name (e.g., "Engineering", "Sales")
3. Click **"Add User"** button
4. The user is registered and can now receive asset assignments

[Screenshot: Add User Form]

### Viewing All Users

To see a list of all registered users:

1. Click **"Show All Users"** in the navigation menu
2. You'll see a table showing:
   - User ID
   - Name
   - Email
   - Department
   - Number of assigned items

This helps you quickly see who has assets assigned and how many.

[Screenshot: All Users List]

### Viewing Items by User

To see all assets assigned to a specific user:

1. Click **"Show Items by User"** in the navigation menu
2. Select the user from the dropdown
3. You'll see a table showing all items assigned to that user:
   - Item ID
   - Main Category
   - Sub Category
   - Manufacturer
   - Model
   - Price

This is useful for tracking what equipment each employee has.

[Screenshot: User Items List]

## 📊 Reporting Features

### Viewing All Items

To see the complete inventory:

1. Click **"Show All Items"** in the navigation menu
2. You'll see a comprehensive table with:
   - Item ID
   - Main Category
   - Sub Category
   - Manufacturer
   - Model
   - Price (₪)
   - Quantity
   - Status (In Stock / Assigned)
   - Assigned To (user name or "None")

This gives you a complete overview of your entire inventory.

[Screenshot: All Items List]

### Calculating Stock by Categories

To see the total value of your inventory by category:

1. Click **"Calculate Stock"** in the navigation menu
2. You'll see a breakdown showing:
   - **Assets** - Total value of all hardware (PCs, Laptops)
   - **Accessories** - Total value of all accessories (Mouse, Keyboard, etc.)
   - **Licenses** - Total value of all licenses (Serial Numbers, Subscriptions)
   - **Grand Total** - Sum of all categories

Values are displayed in Israeli Shekels (₪).

This helps you understand the financial value of your IT assets and plan budgets accordingly.

[Screenshot: Stock Valuation by Categories]

## 💾 Data Persistence

All data in the application is automatically saved to persistent storage:

- **Storage Type**: NFS (Network File System) mounted on Kubernetes
- **Data Files**: 
  - `items.json` - Contains all asset information
  - `users.json` - Contains all user information and assignments
- **Automatic Saving**: Data is saved immediately after any change (add, delete, modify, assign)
- **Persistence**: Data persists even if:
  - The application pod restarts
  - The browser is closed and reopened
  - The page is refreshed

**Important:** Your data is safe and will not be lost when the application restarts or updates.

## 🎯 Quick Reference

### Common Tasks

| Task | Steps |
|------|-------|
| Add a laptop | Add New Item → Assets → Laptop → Fill details → Add |
| Assign equipment | Assign Item → Select item → Select user → Assign |
| Check user's items | Show Items by User → Select user |
| View inventory value | Calculate Stock |
| Update item price | Modify Item → Select item → Change price → Update |

### Category Reference

**Assets:**
- PC - Desktop computers
- Laptop - Portable computers

**Accessories:**
- Mouse - Computer mouse
- Keyboard - Computer keyboard
- Docking Station - Laptop docking station
- Monitor - Display monitor
- Headset - Audio headset

**Licenses:**
- Serial Number - Software license with serial number
- Subscription - Recurring software subscription

## ❓ Tips and Best Practices

1. **Regular Updates**: Keep item prices updated to maintain accurate valuations
2. **User Management**: Add users before assigning items to them
3. **Category Selection**: Choose the correct category and subcategory when adding items
4. **Price Format**: Enter prices in Israeli Shekels (₪) with decimal values (e.g., 1299.99)
5. **Data Verification**: Use "Show All Items" regularly to verify your inventory

## 🔧 Troubleshooting

### Application Not Loading
- Check if the ALB DNS is correct
- Verify the URL starts with `http://`
- Try refreshing the page

### Changes Not Saving
- Check your internet connection
- Refresh the page and try again
- Verify the item/user exists before modifying

### Can't See Items
- Use "Show All Items" to view complete inventory
- Check if items are filtered by status (In Stock vs Assigned)

---

**Need Help?** Refer to the main README.md for deployment and technical information.

**Application Version:** 1.0  
**Last Updated:** 2024
