const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("../utils/firebase");

exports.sendDiscountNotification = onDocumentCreated(
  "discounts/{voucherId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const voucherId = event.params.voucherId;
    const tenVoucher = data.ten_voucher || "Ưu đãi mới";

    const message = {
      notification: {
        title: "Ưu đãi mới!",
        body: tenVoucher,
      },
      data: {
        type: "discount",
        voucherId,
        tenVoucher,
      },
      topic: "allUsers",
    };

    await getMessaging().send(message);
    return true;
  }
);
