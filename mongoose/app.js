// Install required packages:
// npm install express mongoose

const express = require('express');
const mongoose = require('mongoose');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to MongoDB
mongoose.connect('mongodb://localhost/hit_counter', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Create a schema for hit counts
const hitSchema = new mongoose.Schema({
  count: { type: Number, default: 0 },
});

const Hit = mongoose.model('Hit', hitSchema);

// Middleware to increment hit count
app.use(async (req, res, next) => {
  try {
    const hit = await Hit.findOneAndUpdate({}, { $inc: { count: 1 } }, { new: true });
    if (!hit) {
      await Hit.create({});
    }
    next();
  } catch (error) {
    console.error('Error updating hit count:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Route to get the current hit count
app.get('/hits', async (req, res) => {
  try {
    const hit = await Hit.findOne();
    res.json({ count: hit ? hit.count : 0 });
  } catch (error) {
    console.error('Error fetching hit count:', error);
    res.status(500).send('Internal Server Error');
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
