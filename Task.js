const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema ({
    _id: {type: Number, required: true},
    title: {type: String, required: true},
    description: {type: String, required: true},
    status: {type: String, required: true}
});

module.exports = mongoose.model('Tasks', taskSchema);
