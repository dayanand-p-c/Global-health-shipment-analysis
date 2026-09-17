from urllib.parse import quote_plus
import pandas as pd
import mysql.connector
from sqlalchemy import create_engine

# --- Connect to MySQL and load the raw, untouched table ---
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Daya@sql26",
    database="scms_data"
)

df = pd.read_sql("SELECT * FROM raw_shipments", conn)
print(df.shape)

# --- Fix column name artifact from CSV encoding (UTF-8 BOM) ---
df.columns = df.columns.str.replace('ï»¿', '', regex=False)
df.columns = df.columns.str.strip()

# --- Clean Weight (Kilograms): convert real numbers, categorize the rest ---
def categorize_weight(val):
    val = str(val).strip()
    if val.startswith('See ASN'):
        return 'cross_referenced'
    elif val == 'Weight Captured Separately':
        return 'captured_separately'
    elif val.replace('.', '', 1).isdigit():
        return 'real_number'
    else:
        return 'missing'

df['weight_status'] = df['Weight (Kilograms)'].apply(categorize_weight)
df['weight_kg_clean'] = pd.to_numeric(df['Weight (Kilograms)'], errors='coerce')

# --- Clean Freight Cost (USD): same pattern ---
def categorize_freight(val):
    val = str(val).strip()
    if val.startswith('See ASN'):
        return 'cross_referenced'
    elif val == 'Freight Included in Commodity Cost':
        return 'bundled_in_commodity'
    elif val == 'Invoiced Separately':
        return 'invoiced_separately'
    elif val.replace('.', '', 1).isdigit():
        return 'real_number'
    else:
        return 'missing'

df['freight_status'] = df['Freight Cost (USD)'].apply(categorize_freight)
df['freight_usd_clean'] = pd.to_numeric(df['Freight Cost (USD)'], errors='coerce')

# --- Parse dates: two columns, two different formats ---
df['scheduled_delivery_clean'] = pd.to_datetime(
    df['Scheduled Delivery Date'], format='%d-%b-%y', errors='coerce'
)

df['po_sent_status'] = df['PO Sent to Vendor Date'].apply(
    lambda x: 'not_captured' if x == 'Date Not Captured'
    else 'na_from_rdc' if x == 'N/A - From RDC'
    else 'real_date'
)
df['po_sent_clean'] = pd.to_datetime(
    df['PO Sent to Vendor Date'], format='%m/%d/%y', errors='coerce'
)

# --- Checkpoint: confirm cleaning matches Phase 1's manual SQL audit ---
print(df['weight_status'].value_counts())
print(df['freight_status'].value_counts())
print(df['po_sent_status'].value_counts())

# --- Export clean file ---
df.to_csv('shipments_clean.csv', index=False)
print("Exported shipments_clean.csv")

# --- Load clean table back into MySQL, safely encoding the password ---
password = quote_plus("Daya@sql26")
engine = create_engine(f"mysql+mysqlconnector://root:{password}@localhost/scms_data")
df.to_sql('clean_shipments', engine, if_exists='replace', index=False)
print("Loaded clean_shipments table into MySQL")
