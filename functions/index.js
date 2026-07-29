const functions = require("firebase-functions");
const axios = require("axios");

exports.uploadToGithub = functions.https.onCall(async (data, context) => {
    const token = functions.confing().github.token;
    const { repo, path, content, message, username } = data;

    const apiUrl = `https://api.github.com/repos/${username}/${repo}/contents/${path}`;
    const encodedContent = Buffer.from(content).toString("base64");

    try {
    const res = await axios.put(apiUrl, {
      message,
      content: encodedContent,
    }, {
      headers: {
        Authorization: `token ${token}`,
        Accept: "application/vnd.github.v3+json"
      }
    });

    return { success: true, data: res.data };
  } catch (err) {
    return { success: false, error: (err.response && err.response.data) || err.message };
  }
});