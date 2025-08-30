// 头像数据流测试脚本
// 模拟从数据库读取头像数据并验证数据格式

const testAvatarData = {
  // 模拟数据库中存储的不同格式头像数据
  validDataUri: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==",
  invalidUrl: "http://example.com/avatar.jpg",
  invalidFile: "file:///storage/avatar.png",
  emptyString: "",
  nullValue: null,
  undefinedValue: undefined
};

function testAvatarValidation(avatarData, description) {
  console.log(`\n=== 测试: ${description} ===`);
  console.log(`输入数据: ${avatarData}`);
  
  // 模拟前端头像验证逻辑
  const isValidDataUri = avatarData && typeof avatarData === 'string' && avatarData.startsWith('data:');
  const finalAvatar = isValidDataUri ? avatarData : 'app.media.man';
  
  console.log(`是否为有效data URI: ${isValidDataUri}`);
  console.log(`最终显示头像: ${finalAvatar}`);
  console.log(`数据长度: ${avatarData ? avatarData.length : 0}`);
  
  return {
    input: avatarData,
    isValid: isValidDataUri,
    output: finalAvatar
  };
}

// 执行测试
console.log("头像数据流验证测试");
console.log("==================");

const results = [];
results.push(testAvatarValidation(testAvatarData.validDataUri, "有效的data URI"));
results.push(testAvatarValidation(testAvatarData.invalidUrl, "无效的HTTP URL"));
results.push(testAvatarValidation(testAvatarData.invalidFile, "无效的文件路径"));
results.push(testAvatarValidation(testAvatarData.emptyString, "空字符串"));
results.push(testAvatarValidation(testAvatarData.nullValue, "null值"));
results.push(testAvatarValidation(testAvatarData.undefinedValue, "undefined值"));

// 总结测试结果
console.log("\n=== 测试总结 ===");
const validCount = results.filter(r => r.isValid).length;
const totalCount = results.length;
console.log(`总测试数: ${totalCount}`);
console.log(`有效数据: ${validCount}`);
console.log(`无效数据: ${totalCount - validCount}`);

// 模拟数据库API响应格式
console.log("\n=== 模拟API响应格式 ===");
const mockApiResponse = {
  data: {
    id: 1,
    username: "testuser",
    avatar: testAvatarData.validDataUri,
    gender: "男",
    phone: "13800138000",
    email: "test@example.com",
    address: "广东省 广州市",
    birthday: "1990-01-01"
  }
};

console.log("API响应结构:");
console.log(JSON.stringify(mockApiResponse, null, 2));

// 验证API响应中的头像数据
const apiAvatar = mockApiResponse.data.avatar;
console.log(`\nAPI返回的头像数据前50字符: ${apiAvatar.substring(0, 50)}...`);
console.log(`头像数据是否为data URI: ${apiAvatar.startsWith('data:')}`);
console.log(`头像数据总长度: ${apiAvatar.length}`);
