import cv2
import streamlit as st
import numpy as np
from collections import deque
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import tensorflow as tf
import json
import os

st.set_page_config(page_title="ISL Sign Detector", layout="wide")
st.title("Live ISL Detection")
st.write("Using a simple Streamlit interface with your trained model.")

@st.cache_resource
def load_assets():
    # Load TFLite Model
    interpreter = tf.lite.Interpreter(model_path="tms_isl_final_int8.tflite")
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    return interpreter, input_details, output_details

interpreter, input_details, output_details = load_assets()

# Try loading the label map if it exists (Hot Reloadable block)
id_to_name = None
if os.path.exists("label_map.json"):
    try:
        with open("label_map.json", "r") as f:
            label_map = json.load(f)
            id_to_name = {int(v): k for k, v in label_map.items()}
    except Exception as e:
        st.error(f"Error loading label map: {e}")

# Set up MediaPipe tasks
base_options = python.BaseOptions(model_asset_path='hand_landmarker.task')
options = vision.HandLandmarkerOptions(
    base_options=base_options,
    num_hands=2,
    min_hand_detection_confidence=0.5,
    min_hand_presence_confidence=0.5,
    min_tracking_confidence=0.5
)

def draw_landmarks(image, hand_landmarks):
    h, w, _ = image.shape
    for lm in hand_landmarks:
        cx, cy = int(lm.x * w), int(lm.y * h)
        cv2.circle(image, (cx, cy), 4, (0, 255, 255), cv2.FILLED)

st.markdown("---")
col1, col2 = st.columns([2, 1])

with col1:
    run = st.checkbox('Start Webcam', key="run_webcam")
    FRAME_WINDOW = st.image([])

with col2:
    st.markdown("### Detection Result")
    st_label = st.empty()
    st_label.info("Start the webcam and perform gestures.")
    
# Initialize rolling buffer matching the model's sequence length (64)
SEQ_LEN = 64
frame_buffer = deque(maxlen=SEQ_LEN)

for _ in range(SEQ_LEN):
    frame_buffer.append(np.zeros(126)) # Initialize with zeroes

if run:
    cap = cv2.VideoCapture(0)
    
    # Create the HandLandmarker inside the runtime logic
    with vision.HandLandmarker.create_from_options(options) as detector:
        while run and cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                st.error("Failed to read from webcam.")
                break
                
            frame = cv2.flip(frame, 1) # Mirror for natural feel
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Use MediaPipe Tasks API
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame_rgb)
            results = detector.detect(mp_image)
            
            features = np.zeros(126) # 2 hands * 21 landmarks * 3 coords
            
            if results.hand_landmarks:
                for hand_idx, landmarks in enumerate(results.hand_landmarks):
                    hand_info = results.handedness[hand_idx][0]
                    hand_label = hand_info.category_name # 'Left' or 'Right'
                    
                    # Draw custom reliable dots instead of crashing with drawing_utils
                    draw_landmarks(frame_rgb, landmarks)
                    
                    # The Left hand (from the user's perspective, mirrored) -> 0:63
                    # The Right hand -> 63:126 
                    offset = 0 if hand_label == 'Left' else 63
                    
                    for i, lm in enumerate(landmarks):
                        features[offset + i*3] = lm.x
                        features[offset + i*3 + 1] = lm.y
                        features[offset + i*3 + 2] = lm.z
                        
            frame_buffer.append(features)
            
            # Predict once the buffer has sequence length
            input_data = np.array(frame_buffer, dtype=np.float32)
            input_data = np.expand_dims(input_data, axis=0) # Expected shape (1, 64, 126)
            
            interpreter.set_tensor(input_details[0]['index'], input_data)
            interpreter.invoke()
            output_data = interpreter.get_tensor(output_details[0]['index'])
            
            predicted_id = np.argmax(output_data, axis=1)[0]
            confidence = np.max(output_data, axis=1)[0]
            
            if id_to_name:
                sign = id_to_name.get(predicted_id, f"Class {predicted_id}")
            else:
                sign = f"Class ID: {predicted_id}"
                
            # Display detection output on the interface
            st_label.success(f"**Sign:** {sign}\n\n**Confidence:** {confidence:.2f}")
            
            FRAME_WINDOW.image(frame_rgb)
            
    cap.release()
else:
    st_label.warning("Webcam is stopped.")

