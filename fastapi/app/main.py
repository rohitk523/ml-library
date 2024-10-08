from fastapi import FastAPI, File, UploadFile
from pydantic import BaseModel
from PIL import Image
import numpy as np
import torch
from torch import nn
import torch
import torch.nn as nn
import torch.nn.functional as F
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace "*" with your frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, 1)
        self.conv2 = nn.Conv2d(32, 64, 3, 1)
        self.dropout1 = nn.Dropout(0.25)
        self.dropout2 = nn.Dropout(0.5)
        self.fc1 = nn.Linear(9216, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = F.relu(x)
        x = self.conv2(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 2)
        x = self.dropout1(x)
        x = torch.flatten(x, 1)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.dropout2(x)
        x = self.fc2(x)
        output = F.log_softmax(x, dim=1)
        return output

# Instantiate the model and load the weights
net = Net()
net.load_state_dict(torch.load("digit-recognition/mnist_net.pth"))  # Load model weights
net.eval()  # Set model to evaluation mode

# Helper function to preprocess the image
def preprocess_image(image: Image.Image) -> torch.Tensor:
    image = image.convert("L")  # Convert to grayscale
    image = image.resize((28, 28))  # Resize to 28x28 (MNIST size)
    image = np.array(image, dtype=np.float32) / 255.0  # Normalize to [0, 1]
    image = torch.tensor(image).unsqueeze(0).unsqueeze(0)  # Add batch and channel dimensions
    return image



# FastAPI route to handle image uploads and make predictions
@app.post("/predict_digit/")
async def predict_digit(file: UploadFile = File(...)):
    try:
        # Open the image file
        image = Image.open(file.file)
        
        # Preprocess the image
        image_tensor = preprocess_image(image)

        # Run the image through the model
        with torch.no_grad():
            output = net(image_tensor)
            _, predicted = torch.max(output, 1)
        
        # Get the predicted digit
        predicted_digit = predicted.item()

        return {"digit": str(predicted_digit)}
    
    except Exception as e:
        return {"error": str(e)}

