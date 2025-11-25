const discount = require("./notifications/discount");
const shopRequest = require("./notifications/shop_request");

exports.sendDiscountNotification = discount.sendDiscountNotification;
exports.sendShopApprovalNotification = shopRequest.sendShopApprovalNotification;