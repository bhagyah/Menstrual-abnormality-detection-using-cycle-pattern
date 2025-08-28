## 🩸📈 Cycle Pattern Analysis for Menstrual Abnormality Detection 🔍

### 📌 Project Overview
Menstrual cycle irregularities can indicate underlying health issues such as hormonal imbalances or reproductive disorders. Early detection of abnormal cycles can help clinicians provide timely interventions. This project aims to develop a predictive system to identify irregular menstrual cycles using time-series modeling and deep learning, making predictions interpretable for clinical use.

### 🎯 Objectives

- Predict the next menstrual cycle length for each individual.  
- Detect abnormal cycles by comparing predicted vs. actual cycle length.  
- Incorporate additional features such as pain score, bleeding volume, and pattern disruption to improve prediction accuracy.  
- Provide interpretable outputs for clinicians to better understand menstrual irregularities.  

### 🛠️ Tech Stack
Frontend (Mobile Application)

Flutter - Cross-platform mobile development framework
Dart - Programming language for Flutter development
Provider - State management for Flutter
Firebase SDK - For authentication and database connectivity

Backend (API Server)

Python Flask - Lightweight web framework for API development
Flask-CORS - Cross-Origin Resource Sharing support

Database

Firebase Firestore - NoSQL cloud database for storing user data and predictions

Machine Learning

scikit-learn - Machine learning library featuring Random Forest Regressor
pandas - Data manipulation and analysis
numpy - Numerical computing
joblib - Model serialization and persistence

Data Preprocessing

MinMaxScaler - Feature scaling and normalization
OneHotEncoder - Categorical variable encoding
SimpleImputer - Missing value handling

Development Tools

Android Studio / VS Code - IDE for Flutter development
Python 3.x - Backend runtime environment

🚀 Setup Steps
Prerequisites

Flutter SDK (version 3.29.0 or higher)
Python 3.8+
Android Studio (for Android development)
Xcode (for iOS development, macOS only)
Firebase project setup

1. Clone the Repository
bashgit clone <repository-url>
cd menstrual_abnormality
2. Flutter App Setup
bash# Install Flutter dependencies
flutter pub get

# Configure Firebase
# Add your google-services.json (Android) and GoogleService-Info.plist (iOS)
# Update firebase_options.dart with your Firebase configuration

# Run the Flutter app
flutter run
3. Machine Learning Backend Setup
bash# Navigate to the ML model directory
cd ml_model

# Install Python dependencies
pip install flask pandas numpy scikit-learn joblib flask-cors

# Train the model (optional - pre-trained models included)
python menstrual_model_cleaned.py

# Start the Flask API server
python app.py
The Flask server will run on http://127.0.0.1:5000 by default.
4. Firebase Configuration

Create a new Firebase project at https://console.firebase.google.com
Enable Authentication and Firestore Database
Download configuration files:

google-services.json for Android (place in android/app/)
GoogleService-Info.plist for iOS (place in ios/Runner/)


Update lib/firebase_options.dart with your project configuration

5. Running the Complete System

Start the Flask API server: python ml_model/app.py
Launch the Flutter app: flutter run
The app will communicate with the Flask API for predictions
User data and predictions are stored in Firebase Firestore

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

### 🤖 Model Explanation
Random Forest Regressor
The core prediction model uses a Random Forest Regressor with the following characteristics:
Model Architecture:

Algorithm: Random Forest with 100 decision trees (n_estimators=100)
Target Variable: avg_cycle_length (average menstrual cycle length in days)
Random State: 42 (for reproducible results)

Feature Engineering:

Numerical Features (12 features):

age, bmi, tracking_duration_months, pain_score
avg_cycle_length, cycle_length_variation, avg_bleeding_days
bleeding_volume_score, intermenstrual_episodes
cycle_variation_coeff, pattern_disruption_score, duration_abnormality_flag


Categorical Features (1 feature):

life_stage (adolescent, reproductive, perimenopausal)
Processed using One-Hot Encoding


Preprocessing Pipeline:

Missing Value Imputation: SimpleImputer with mean strategy for numerical features
Feature Scaling: MinMaxScaler applied to all numerical features and target variable
Categorical Encoding: OneHotEncoder for life_stage categories
Data Split: 80% training, 20% testing with stratified sampling

Anomaly Detection:

Residual Calculation: Absolute difference between predicted and actual cycle lengths
Threshold: 2.0 days (realistic clinical threshold)
Classification: Cycles with residual > threshold flagged as anomalous
Output: Binary anomaly flag with interpretable message

Model Performance:

Evaluation Metric: Mean Squared Error (MSE)
Prediction Range: 21-40 days (biologically realistic cycle lengths)
Output Format: JSON response with prediction, residual, and anomaly status

Model Persistence:

Serialization: joblib for model, scalers, and encoders
Files: rf_cycle_model.pkl, scalers.pkl, life_stage_encoder.pkl

Prediction Workflow

Input Validation: Validate and preprocess user input data
Feature Scaling: Apply trained MinMaxScaler to numerical features
Encoding: Transform categorical variables using trained OneHotEncoder
Prediction: Generate cycle length prediction using trained Random Forest
Post-processing: Inverse transform scaled prediction to original scale
Anomaly Detection: Compare prediction with actual cycle length
Response: Return structured JSON with prediction results and clinical interpretation

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


