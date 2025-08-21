// server.js
const express = require('express');
const mongoose = require('mongoose');
const Tasks = require('/Users/matthewlim/Documents/IOS App/ToDoApp/Task.js')

Tasks.find({})
    .then(tasks => {
        // Process tasks
    })
    .catch(err => {
        // Handle error
    });

const app = express();
app.use(express.json()); // For parsing JSON request bodies

mongoose.connect("mongodb://localhost:27017/ToDoApp", {
    authSource: "admin",
    user: "root",
    pass: "12345",
    useNewUrlParser: true,
    useUnifiedTopology: true
});

// Create item
app.post('/Tasks', async (req, res) => {
    try {
        const tasks = await Tasks.create(req.body);
        res.status(201).json(Tasks);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Get all items
app.get('/Tasks', async (req, res) => {
    try {
        const tasks = await Tasks.find();
        res.json(tasks); // Corrected: sending the 'tasks' array
    } catch (err) {
        console.error(err); // Log the error for debugging
        res.status(500).json({ error: err.message });
    }
});

// Delete a task by ID
app.delete('/Tasks/:id', async (req, res) => {
    try {
        const { id } = req.params; // Get the ID from the URL parameters
        const deletedTask = await Tasks.findByIdAndDelete(id); // Find and delete the task by ID

        if (!deletedTask) {
            return res.status(404).json({ message: 'Task not found' }); // If task not found
        }

        res.status(200).json({ message: 'Task deleted successfully', deletedTask }); // Respond with success message and deleted task
    } catch (err) {
        console.error(err); // Log the error for debugging
        res.status(500).json({ error: err.message }); // Respond with a server error
    }
});

// Update item
app.patch('/Tasks/:id', async (req, res) => {
  try {
    const { id } = req.params; // Get the task ID from the URL parameters
    const updatedTask = await Tasks.findByIdAndUpdate(id, req.body, { new: true }); // Find by ID and update, return the updated document

    if (!updatedTask) {
      return res.status(404).json({ error: 'Task not found' }); // Handle case where task doesn't exist
    }

    res.json(updatedTask); // Send the updated task
  } catch (err) {
    console.error(err); // Log the error for debugging
    res.status(500).json({ error: err.message }); // Send a 500 status for server errors
  }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));