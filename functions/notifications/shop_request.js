const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("../utils/firebase");
const { getFirestore } = require("firebase-admin/firestore");

exports.sendShopApprovalNotification = onDocumentWritten(
  "requesttoopentshops/{requestId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    if (!beforeData || !afterData) return;

    if (beforeData.status === afterData.status) return;

    const status = afterData.status;
    const userId = afterData.userId;
    const shopName = afterData.shopName || "Cửa hàng của bạn";

    if (!userId) {
      console.error(" userId không tồn tại trong requesttoopentshops document");
      return;
    }

    // Lấy token từ Firestore users/{userId}
    const userSnapshot = await getFirestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userSnapshot.exists) {
      console.error(` Không tìm thấy tài khoản user: ${userId}`);
      return;
    }

    const userToken = userSnapshot.data()?.notificationToken;

    if (!userToken) {
      console.error(` User ${userId} chưa có notificationToken`);
      return;
    }

    // Thiết lập thông báo
    let title, body;

    if (status === "approved") {
      title = "Yêu cầu mở shop đã được chấp thuận!";
      body = `Chúc mừng ${shopName} đã được phê duyệt. Bắt đầu bán hàng ngay hôm nay!`;
    } else if (status === "rejected") {
      title = "Yêu cầu mở shop không được chấp thuận";
      body = `Rất tiếc, yêu cầu mở shop của ${shopName} bị từ chối. Vui lòng liên hệ hỗ trợ để biết thêm chi tiết.`;
    } else {
      return; // Không gửi loại status khác
    }

    // Message gửi theo token người dùng
    const message = {
      notification: { title, body },
      data: {
        type: "shop_request",
        status,
        shopName,
      },
      token: userToken,
    };

    try {
      await getMessaging().send(message);
      console.log(` Đã gửi notification đến user: ${userId}`);
    } catch (err) {
      console.error(" Lỗi gửi FCM:", err);
    }

    return true;
  }
);
