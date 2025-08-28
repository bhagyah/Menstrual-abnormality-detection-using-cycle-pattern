from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
import joblib
import traceback
from sklearn.preprocessing import OneHotEncoder
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# =====================
# Load model & scalers
# =====================
try:
    model = joblib.load("rf_cycle_model.pkl")
    print("✅ Model loaded successfully.")
except Exception as e:
    print("❌ Error loading model:", e)
    model = None

try:
    scalers = joblib.load("scalers.pkl")
    print("✅ Scalers loaded successfully.")
except Exception as e:
    print("❌ Error loading scalers:", e)
    scalers = None

# =====================
# Define features
# =====================
numerical_features = [
    "age", "bmi", "tracking_duration_months", "pain_score",
    "avg_cycle_length", "cycle_length_variation", "avg_bleeding_days",
    "bleeding_volume_score", "intermenstrual_episodes",
    "cycle_variation_coeff", "pattern_disruption_score",
    "duration_abnormality_flag"
]
categorical_features = ["life_stage"]

# Ensure life_stage categories are exactly as used in training
life_stage_categories = ["adolescent", "reproductive", "perimenopausal", "nan"]
onehot_encoder = OneHotEncoder(
    sparse=False,
    handle_unknown="ignore",
    categories=[life_stage_categories]
)
onehot_encoder.fit(pd.DataFrame({"life_stage": life_stage_categories}))

# =====================
# Prediction endpoint
# =====================
@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON received"}), 400

        # --- Process numerical features ---
        input_data = {}
        for feat in numerical_features:
            try:
                input_data[feat] = float(data.get(feat, 0))
            except ValueError:
                return jsonify({"error": f"Invalid value for {feat}"}), 400

        # --- Handle life_stage safely ---
        life_stage = str(data.get("life_stage", "nan")).lower()
        if life_stage not in [x.lower() for x in life_stage_categories]:
            life_stage = "nan"
        input_data["life_stage"] = life_stage

        # --- Scale numerical features ---
        scaled_array = []
        for feat in numerical_features:
            scaled_array.append(
                scalers[feat].transform([[input_data[feat]]])[0, 0]
            )
        scaled_array = np.array(scaled_array).reshape(1, -1)

        # --- Encode categorical features ---
        life_stage_encoded = onehot_encoder.transform(
            pd.DataFrame({"life_stage": [input_data["life_stage"]]})
        )

        # --- Combine final input ---
        input_array = np.hstack([scaled_array, life_stage_encoded])

        # --- Predict ---
        prediction_scaled = model.predict(input_array)

        # Ensure prediction is inverse transformed correctly
        predicted_cycle_length = float(
            scalers["avg_cycle_length"].inverse_transform(
                prediction_scaled.reshape(-1, 1)
            )[0, 0]
        )

        # --- Calculate anomaly ---
        actual_cycle_length = input_data["avg_cycle_length"]
        residual = abs(actual_cycle_length - predicted_cycle_length)

        # Instead of tiny threshold, use realistic threshold (e.g., ±2 days)
        anomaly_threshold = 2.0  
        is_anomaly = residual > anomaly_threshold

        # --- Return clean JSON ---
        return jsonify({
            "predicted_cycle_length": round(predicted_cycle_length, 2),
            "actual_cycle_length": round(actual_cycle_length, 2),
            "residual": round(residual, 2),
            "is_anomaly": bool(is_anomaly),
            "message": (
                "⚠️ Cycle shows abnormal pattern."
                if is_anomaly else
                "✅ Cycle is within normal range."
            )
        })

    except Exception as e:
        print("❌ Error traceback:\n", traceback.format_exc())
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    app.run(debug=True)
