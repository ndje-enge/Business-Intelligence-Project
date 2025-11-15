# Advanced Database Management Project

## Project Description

This project is a Business Intelligence (BI) application developed as part of an Advanced Database Management course. It analyzes purchase order, vendor, and product data to provide strategic insights into business performance.

---

## Objectives

- Design and implementation of an optimized relational database
- Creation of complex SQL queries for data analysis
- Performance optimization with appropriate indexes
- Development of interactive Power BI reports
- Implementation of triggers for data integrity management

---

## Database Structure

### Main Tables

#### 1. **vendor** (Vendors)
```sql
- businessentityid (PK)
- accountnumber
- name
- creditrating
- preferredvendorstatus
- activeflag
- purchasingwebserviceurl
- modifieddate
```

#### 2. **productvendor** (Product-Vendor)
```sql
- productid (PK, FK)
- businessentityid (PK, FK)
- averageleadtime
- standardprice
- lastreceiptcost
- lastreceiptdate
- minorderqty
- maxorderqty
- onorderqty
- unitmeasurecode
- modifieddate
```

#### 3. **purchaseorderheader** (Purchase Order Headers)
```sql
- purchaseorderid (PK)
- revisionnumber
- status
- employeeid
- vendorid
- shipmethodid
- orderdate
- shipdate
- subtotal
- taxamt
- freight
- modifieddate
```

#### 4. **purchaseorderdetail** (Purchase Order Details)
```sql
- purchaseorderid (PK, FK)
- purchaseorderdetailid (PK)
- duedate
- orderqty
- productid
- unitprice
- receivedqty
- rejectedqty
- modifieddate
```

### Database Diagram

The following diagram illustrates the relationships between the tables:

![Database Schema](Visualizations/Table%20management.png)

The database uses a relational structure with primary and foreign keys to maintain data integrity:
- **vendor** is linked to **productvendor** via `businessentityid`
- **purchaseorderheader** references **vendor** through `vendorid`
- **purchaseorderdetail** is linked to **purchaseorderheader** via `purchaseorderid`
- **productvendor** connects products to vendors through composite keys

---

## Queries and Analysis

The project includes several advanced SQL analyses:

### 1. Vendor Analysis
- **Query A**: Vendors with credit rating of 5 and products > 500
- **Query D**: Order count and total cost per vendor
- **Query E**: Average orders and costs
- **Query F**: Top 50 vendors by rejection rate
- **Query G**: Top 10 vendors by total quantity ordered

### 2. Product Analysis
- **Query B**: Orders with quantity > 500
- **Query C**: Order details between 1400 and 1600
- **Query H**: Top 10 most ordered products
- **Query I**: Product ranking by vendor


---

## Triggers and Data Integrity

### Trigger 1: `trg_before_update_purchaseorderdetail`
**Function:**
- Records modification history in `transaction_history`
- Automatically updates `modifieddate`
- Recalculates `subtotal` in `purchaseorderheader`

### Trigger 2: `trg_before_update_purchaseorderheader`
**Function:**
- Verifies data consistency between `purchaseorderheader` and `purchaseorderdetail`
- Prevents inconsistent updates to `subtotal`

---

## Power BI Reports

The project includes several interactive reports:

1. **Top 5 Best Selling Products.pbix**
   - Visualization of the 5 best-selling products
   - Sales trend analysis

2. **Top Vendors.pbix**
   - Performance of top vendors
   - Order volume comparison

3. **Lowest vendors.pbix**
   - Analysis of vendors with lowest performance
   - Identification of improvement opportunities

4. **Order Quantity of Product 319.pbix**
   - Detailed analysis of orders for product 319
   - History and trends

### Power BI Visualizations

Below are screenshots of some key visualizations from the Power BI reports:

#### Visualization 1: Top Products Analysis
![Top Products Visualization](Visualizations/Viz%201.png)

This visualization shows the top-selling products with detailed metrics including order quantities and revenue contribution.

#### Visualization 2: Vendor Performance Dashboard
![Vendor Performance](Visualizations/Viz%202.png)

An interactive dashboard displaying vendor performance metrics, including order volumes, delivery times, and quality ratings.

#### Visualization 3: Trend Analysis
![Trend Analysis](Visualizations/Viz%203.png)

Time-series analysis showing purchase trends, seasonal patterns, and forecasting insights.

---

## Installation and Usage

### Prerequisites
- Oracle Database (or SQL compatible)
- SQL Developer or any other SQL client
- Microsoft Power BI Desktop
- Permissions to create tables, indexes, and triggers

## Sample Results

### Top 10 Vendors by Volume
```sql
SELECT v.businessentityid, v.name, SUM(pod.orderqty) AS total_quantity_purchased
FROM vendor v
JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
GROUP BY v.businessentityid, v.name
ORDER BY total_quantity_purchased DESC
FETCH FIRST 10 ROWS ONLY;
```

### Top 5 Best Selling Products
```sql
SELECT pd.productid, SUM(pd.orderqty) AS total_quantity_sold
FROM purchaseorderdetail pd
GROUP BY pd.productid
ORDER BY total_quantity_sold DESC
FETCH FIRST 5 ROWS ONLY;
```

---
## Important Notes

1. **Performance**: Indexes have been carefully placed to optimize frequent queries
2. **Integrity**: Triggers ensure data consistency between tables
3. **History**: Modifications are tracked in the `transaction_history` table
4. **Data**: CSV files in the `csv nettoyé/` folder contain pre-processed data
5. **Visualizations**: All images are stored at the root level of the project directory

---

## Authors

Project completed as part of the Advanced Database Management course.
