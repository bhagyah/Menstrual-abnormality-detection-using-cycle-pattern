## 🩸📈 Cycle Pattern Analysis for Menstrual Abnormality Detection 🔍

### 📌 Project Overview
Menstrual cycle irregularities can indicate underlying health issues such as hormonal imbalances or reproductive disorders. Early detection of abnormal cycles can help clinicians provide timely interventions. This project aims to develop a predictive system to identify irregular menstrual cycles using time-series modeling and deep learning, making predictions interpretable for clinical use.

### 🎯 Objectives

- Predict the next menstrual cycle length for each individual.  
- Detect abnormal cycles by comparing predicted vs. actual cycle length.  
- Incorporate additional features such as pain score, bleeding volume, and pattern disruption to improve prediction accuracy.  
- Provide interpretable outputs for clinicians to better understand menstrual irregularities.  

### 📂 Dataset

The dataset contains user-level menstrual data, including:

- **Average cycle length** (`avg_cycle_length`)  
- **Cycle length variation** (`cycle_length_variation`)  
- **Pain score** (`pain_score`)  
- **Bleeding volume score** (`bleeding_volume_score`)  
- **Pattern disruption score** (`pattern_disruption_score`)  
- **Duration abnormality flag** (`duration_abnormality_flag`)  
- **Target labels**:  
  - Oligomenorrhea  
  - Polymenorrhea  
  - Menorrhagia  
  - Amenorrhea  
  - Intermenstrual  

#### 🛠 Handling Missing Values
- Numeric features → filled with default values  
- Categorical features → filled with `'unknown'`  
- Target columns → filled with `0`  


### ⚙️ Data Preprocessing

- **Feature Identification**: Separated numeric and categorical features.  
- **Synthetic Time-Series Generation**:  
  - Generated realistic per-cycle data using a normal distribution based on average cycle length and variation.  
  - Cycle start dates were created sequentially to simulate real menstrual cycles.  
- **Clipping**: Restricted cycle lengths to **21–40 days** to ensure biologically realistic values.  
- **Normalization**: Scaled features using **MinMaxScaler** for deep learning models.  


### 👩‍🎓 Team Members

| Name                      | Reg No     |
|---------------------------|------------|
| K. Gobishan               | 21UG1-1020 |
| Yugadharshini             | 22UG1-0289 |
| T. R. A. Dinesh Rodriguez | 22UG1-0753 |
| S. Piranavan              | 22UG1-0923 |
| H.P.N. Kariyawasam        | 21UG1-1139 |
| T. Pagngnasara            | 22UG1-0081 |
| W. Chathushka Fernando    | 21UG1-1160 |
| J. Hashanraj              | 22UG1-0330 |
| S. Kajipan                | 22UG1-0927 |
| E.K.B.H. Jayarathna       | 22UG1-0938 |

### ✅ Conclusion

The menstrual abnormality prediction system integrates both classical machine learning and deep learning approaches to detect irregular cycles.  
It transforms raw user-level data into **cycle-by-cycle time-series**, predicts upcoming cycle lengths, and flags anomalies in an interpretable manner.  

This system can support clinicians by:  
- Enabling **early detection** of menstrual irregularities  
- Assisting in **monitoring patient health over time**  
- Providing **actionable insights** that improve menstrual healthcare  


