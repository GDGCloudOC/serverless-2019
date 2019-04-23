
/*
 * Copyright 2019 Neudesic LLC
 */

 // The message to display, extracted from environment variable MESSAGE
const message = process.env['MESSAGE'] || 'You forget to set the MESSAGE environment variable!'

// The hellogdg function - expressjs-like handler
exports.hellogdg = (req, res) => {
  res.send(message);
}
