Kaggle Report
========================================================
Introduction
------------------

Methods
-------------------
### Data Sources
1. EHR: Practice Fusion provided Kaggle with a dateset of de-identified electronic health records.
2. Census: I downloaded census data from data.gov for the 2010 census. For population data, I used the estimates for 2011. 

### Data Prep
#### 1. Age
The EHR data provided year of birth for the patients. I transformed this to age by subtracting year of birth from 2012. The census data also includes age. For interpretation, I binned age data into three age groups: young (18-34), middle (35-64), old (65+). EHR does not include any patients under 18. 
#### 2. Sex
#### 3. Smoking Status
The EHR data used NIST codes to identify smoking status of patients. I binned the NIST codes into a single binary smoker/non-smoker variate. 
4. Space (state and division)
There was not good enough spatial coverage in the EHR dataset to generate good summary statistics for all states. So, I aggregated the states into division. The upside to this is that it is much easier to understand nine division than 50+ states. The downside is that smoking rates do tend to vary due to state level anti-smoking policies. I included D.C. in the South Atlantic division and removed the thirty patients from Puerto Rico. 
