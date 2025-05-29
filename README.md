# Vision-Based Distance Estimator

This project is a MATLAB App that uses an IP camera to detect blue objects in real time and estimate the real-world distance between them. The output is then sent via serial communication to an embedded system.

## 🎯 Features

- Real-time video processing
- Object detection based on color segmentation (blue channel)
- Real-world distance calculation (cm)
- Object counting
- Live graphical interface (AppDesigner)
- UART communication with microcontroller

## 📸 Demo

A full demo video is available in `examples/demo_video.mp4`.

## 📁 Folder Structure

- `app/` - Contains the main AppDesigner `.m` file
- `examples/` - Example images and demo video
- `doc/` - MATLAB LiveScript with test results and analysis
- `README.md` - This file
- `LICENSE` - MIT License

## 🛠 Requirements

- MATLAB R202x
- Image Processing Toolbox
- App Designer
- IP webcam (e.g. iPhone via IP Camera app)
- USB-UART device (for serial port output)

## ✏️ Author

Filip – Mechatronics student @ AGH  

📧 [ffryczek@gmail.com] | [www.linkedin.com/in/filip-fryczek-1996b02b7]
