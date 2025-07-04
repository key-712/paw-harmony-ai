/* eslint-disable */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Cloud Functions に送る関数
exports.sendPushNotification = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    console.log("Received request data:", data);

    const { title, body, token } = data;

    if (!title || !body || !token) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required parameters"
      );
    }

    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "default",
          priority: "high",
          defaultSound: true,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      console.log("Sending message:", message);
      const response = await admin.messaging().send(message);
      console.log("Successfully sent message:", response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error("Error sending message:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to send notification: ${error.message}`
      );
    }
  });
