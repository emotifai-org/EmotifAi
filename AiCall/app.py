from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from deepface import DeepFace
import shutil
import numpy as np
import os

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to your frontend's URL for better security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def convert_emotions_to_float(emotions):
    """Convert all numpy types in the emotions dict to Python floats."""
    return {k: float(v) if isinstance(v, (np.floating, np.integer)) else v for k, v in emotions.items()}

@app.post("/detect_emotion/")
async def detect_emotion(file: UploadFile = File(...)):
    try:
        # Save the uploaded file
        with open("temp.jpg", "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        # Analyze with DeepFace
        result = DeepFace.analyze(img_path="temp.jpg", actions=['emotion'], enforce_detection=False )
        # Handle multiple faces (list) or single face (dict)
        if isinstance(result, list):
            first_face = result[0]
            dominant_emotion = first_face.get("dominant_emotion")
            emotions = convert_emotions_to_float(first_face.get("emotion", {}))
        else:
            dominant_emotion = result.get("dominant_emotion")
            emotions = convert_emotions_to_float(result.get("emotion", {}))
        return {
            "dominant_emotion": dominant_emotion,
            "emotions": emotions
        }
    except Exception as e:
        print(f"Error: {e}")
        return {"error": str(e)}
    finally:
        # Clean up temp file if it exists
        try:
            os.remove("temp.jpg")
        except Exception:
            pass

@app.get("/")
def root():
    return {"message": "Emotifai API is running!"}
