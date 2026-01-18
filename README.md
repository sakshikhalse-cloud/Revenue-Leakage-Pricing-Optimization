Project Overview
This project analyzes revenue leakage and pricing inefficiencies in a subscription-based business.
The goal is to identify where revenue is being lost, why it is happening, and which customers, plans, and regions contribute most to leakage.

The analysis combines:
	•	Python for data preparation and feature engineering
	•	SQL logic for leakage reasoning and aggregation
	•	Power BI for executive-level visualization and decision-making

Business Problems Solved
	•	How much revenue is being leaked due to discounts, refunds, and failed payments?
	•	Which subscription plans contribute most to leakage?
	•	Which regions show higher pricing risk?
	•	Do a small number of customers drive most of the leakage? (Pareto Principle)
	•	Is the leakage within acceptable business thresholds or a high-risk scenario?

Key KPIs Tracked
	•	Total Revenue
	•	Total Revenue Leakage
	•	Leakage %
	•	Refund Rate
	•	High-Risk Orders %

Each KPI is dynamically filtered by:
	•	Date range
	•	Plan (Basic / Standard / Premium)
	•	Region (India / UK / US)

Conditional indicators and arrows are used to highlight risk levels.

Dashboard Highlights

Revenue Leakage by Plan
Identifies which subscription plans suffer from the highest revenue loss due to pricing and discounting issues.

Revenue Leakage by Region
Compares regional performance to identify markets with weak pricing controls.

Daily Leakage Trend
Tracks leakage patterns over time to detect spikes and abnormal behavior.

Customer Leakage Pareto Analysis
Uses cumulative percentage logic to show that:
A small percentage of customers contribute to a large share of revenue leakage.
This supports targeted intervention strategies rather than broad pricing changes.

Executive Risk Insight
An automated insight card classifies the business as:
	•	HIGH RISK or
	•	HEALTHY
based on leakage thresholds and refund behavior.

Technical Approach

Python
	•	Data cleaning and validation
	•	Revenue leakage calculations
	•	Risk flags and aggregation tables

SQL Logic (Conceptual)
	•	Discount vs expected price comparison
	•	Refund and failed payment impact analysis
	•	Window functions for Pareto logic

Power BI
	•	Star-schema modeling with Calendar table
	•	DAX measures using DIVIDE, COALESCE, and conditional logic
	•	Interactive slicers and executive-ready layout

Dataset
	•	Simulated transactional dataset
	•	Includes orders, pricing, discounts, refunds, regions, and plans
	•	Designed to reflect real-world revenue leakage scenarios

Key Business Insights
	•	Revenue leakage exceeds acceptable thresholds, indicating ineffective discounting controls
	•	Premium plans contribute disproportionately to total leakage
	•	A small subset of customers drives the majority of losses
	•	Leakage trends show volatility, requiring monitoring and governance

Outcome
This dashboard enables:
	•	Faster executive decision-making
	•	Identification of pricing risks
	•	Data-backed optimization of discounts and refunds
⸻

📌 Next Improvements (Planned)
	•	Advanced anomaly detection
	•	Scenario-based pricing simulations
	•	Cross-project standardization across analytics portfolio
