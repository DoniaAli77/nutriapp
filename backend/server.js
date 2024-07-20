const express = require('express');
const multer = require('multer');
const axios = require('axios');
const fs = require('fs');
const app = express();
const port = 3000;

const upload = multer({ dest: 'uploads/' });

app.post('/analyze-image', upload.single('image'), async (req, res) => {
  const imagePath = req.file.path;
  
  // Replace with your food recognition API URL
  const apiUrl = 'https://api.example.com/food-recognition';
  const apiKey = process.env.API_KEY; // Use environment variable for API key

  try {
    const response = await axios.post(apiUrl, {
      image: fs.createReadStream(imagePath)
    }, {
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'multipart/form-data'
      }
    });

    // Clean up uploaded file
    fs.unlinkSync(imagePath);

    // Return response from the API
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to analyze image.' });
  }
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
