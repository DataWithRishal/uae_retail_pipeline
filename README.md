# 🇦🇪 Enterprise Retail Data Warehouse

![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![Architect](https://img.shields.io/badge/Architect-Data_With_RISHAL-black?style=for-the-badge)

## 📌 Architecture Overview
A production-grade, automated data pipeline engineered for high-scale retail analytics in the UAE market. This system transforms raw point-of-sale transaction data into a highly structured data lakehouse model. It features robust Medallion Architecture (Bronze → Silver → Gold), ACID-compliant transformations, and domain-specific logic (AED standardization, 5% VAT calculation, and regional mapping).

The pipeline is entirely **serverless**, utilizing GitHub Actions to securely orchestrate dbt transformations within a Snowflake data warehouse, adhering to strict FinOps principles for zero-waste compute scaling.

---

## 🏗️ System Design

```mermaid
graph LR
    %% Data Sources
    subgraph Sources [Raw Retail Data]
        POS[(Point of Sale)]
        ECOM[(E-Commerce)]
    end

    %% Medallion Architecture
    subgraph Snowflake [Snowflake Data Lakehouse]
        direction LR
        
        subgraph Bronze [Bronze Layer]
            RAW[Raw Transactions]
        end
        
        subgraph Silver [Silver Layer]
            CLEAN[Cleaned & Conformed<br>AED Standardized]
        end
        
        subgraph Gold [Gold Layer]
            STORE_PERF[Daily Store Performance]
            SEASON[Ramadan Seasonality Mart]
        end
        
        %% Data Flow
        RAW -- dbt run --> CLEAN
        CLEAN -- dbt run --> STORE_PERF
        CLEAN -- dbt run --> SEASON
    end

    %% BI Layer
    subgraph Consumption [Business Intelligence]
        DASH[PowerBI / Tableau]
    end

    %% Connections
    POS --> RAW
    ECOM --> RAW
    STORE_PERF --> DASH
    SEASON --> DASH

    %% Styling
    classDef source fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef bronze fill:#CD7F32,stroke:#333,stroke-width:2px,color:#fff;
    classDef silver fill:#C0C0C0,stroke:#333,stroke-width:2px,color:#000;
    classDef gold fill:#FFD700,stroke:#333,stroke-width:2px,color:#000;
    
    class POS,ECOM,DASH source;
    class RAW bronze;
    class CLEAN silver;
    class STORE_PERF,SEASON gold;
```

---

## 🔐 Security & FinOps Infrastructure
* **Zero-Trust Credentials:** Snowflake credentials are not hardcoded. They are injected securely at runtime via encrypted GitHub Secrets.
* **Ephemeral Compute:** The GitHub Actions runner provisions just long enough to execute the dbt models and is immediately destroyed.
* **Cost Protection:** The Snowflake `COMPUTE_WH` utilizes a strict auto-suspend policy. Daily scheduled triggers are intentionally paused for this repository to enforce a zero-cost baseline.