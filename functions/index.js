const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// firebase deploy --only functions : dùng để deploy mỗi lần sửa functions
exports.sendDiscountNotification = onDocumentCreated(
  "discounts/{voucherId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }

    const data = snapshot.data();
    const voucherId = event.params.voucherId;
    const tenVoucher = data.ten_voucher || "Ưu đãi mới";

    console.log("New discount created:", voucherId);
    console.log("Discount data:", data);

    const message = {
      notification: {
        title: "Ưu đãi mới!",
        body: tenVoucher,
      },
      data: {
        type: "discount",
        voucherId: voucherId,
        tenVoucher: tenVoucher,
        maVoucher: data.ma_voucher || '',
        title: data.title || '',
        description: data.description || '',
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
      topic: "allUsers",
    };


    try {
      const response = await getMessaging().send(message);
      console.log("Successfully sent message:", response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error("Error sending message:", error);
      throw error;
    }
  },
);