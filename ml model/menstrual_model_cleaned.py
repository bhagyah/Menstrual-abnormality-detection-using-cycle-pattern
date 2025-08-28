import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import joblib


data = pd.read_csv('menstrual_irregularity_dataset.csv')


numerical_features = [
    'age', 'bmi', 'tracking_duration_months', 'pain_score',
    'avg_cycle_length', 'cycle_length_variation', 'avg_bleeding_days',
    'bleeding_volume_score', 'intermenstrual_episodes',
    'cycle_variation_coeff',
    'pattern_disruption_score', 'duration_abnormality_flag'
]
categorical_features = ['life_stage']
target = 'avg_cycle_length' 

# Handle missing values
imputer = SimpleImputer(strategy='mean')
data[numerical_features] = imputer.fit_transform(data[numerical_features])

# Initialize and fit scalers
scalers = {}
for feature in numerical_features + [target]:
    scalers[feature] = MinMaxScaler()
    data[feature] = scalers[feature].fit_transform(data[[feature]])

# Encode categorical feature
onehot_encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')
life_stage_encoded = onehot_encoder.fit_transform(data[categorical_features])
life_stage_columns = onehot_encoder.get_feature_names_out(['life_stage'])
data[life_stage_columns] = life_stage_encoded

# Prepare features
features = numerical_features + list(life_stage_columns)
X = data[features]
y = data[target]

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train Random Forest model
model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluate model
predictions = model.predict(X_test)
mse = mean_squared_error(y_test, predictions)
print(f'Mean Squared Error: {mse}')

# Anomaly detection
residuals = np.abs(predictions - y_test.values)
anomaly_threshold = 0.1
anomalies = residuals > anomaly_threshold

# Create anomalies DataFrame
anomalies_df = pd.DataFrame({
    'predicted_days': scalers[target].inverse_transform(predictions.reshape(-1, 1)).flatten(),
    'actual_days': scalers[target].inverse_transform(y_test.values.reshape(-1, 1)).flatten(),
    'residual_days': scalers[target].inverse_transform(residuals.reshape(-1, 1)).flatten(),
    'is_anomaly': anomalies
})
print(anomalies_df.head())

# Save model and scalers
joblib.dump(model, 'rf_cycle_model.pkl')
joblib.dump(onehot_encoder, 'life_stage_encoder.pkl')
joblib.dump(scalers, 'scalers.pkl')
