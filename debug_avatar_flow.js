// 完整的头像数据流调试脚本
// 模拟从选择图片到数据库存储再到页面显示的完整流程

console.log("=== 头像数据流完整调试 ===\n");

// 1. 模拟图片选择和转换过程
function simulateImageSelection() {
    console.log("1. 图片选择和转换过程");
    console.log("------------------------");
    
    // 模拟不同来源的图片URI
    const imageUris = [
        "file:///storage/emulated/0/Pictures/avatar.jpg",
        "datashare:///media/Photo/1",
        "http://example.com/avatar.png"
    ];
    
    const results = [];
    
    imageUris.forEach((uri, index) => {
        console.log(`\n测试URI ${index + 1}: ${uri}`);
        
        // 模拟AvatarUtils.convertToDataUri的逻辑
        let convertedData;
        if (uri.startsWith('file://') || uri.startsWith('http')) {
            // 模拟成功转换为data URI
            convertedData = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/wA==";
        } else if (uri.startsWith('datashare://')) {
            // 模拟datashare协议处理失败（无权限）
            convertedData = null;
        }
        
        results.push({
            originalUri: uri,
            convertedData: convertedData,
            isValid: convertedData && convertedData.startsWith('data:')
        });
        
        console.log(`转换结果: ${convertedData ? '成功' : '失败'}`);
        console.log(`数据长度: ${convertedData ? convertedData.length : 0}`);
    });
    
    return results;
}

// 2. 模拟数据库存储过程
function simulateDatabaseStorage(avatarData) {
    console.log("\n2. 数据库存储过程");
    console.log("------------------");
    
    const userInfo = {
        username: "testuser",
        avatar: avatarData,
        gender: "男",
        phone: "13800138000",
        email: "test@example.com",
        address: "广东省 广州市",
        birthday: "1990-01-01"
    };
    
    console.log(`存储的头像数据前50字符: ${avatarData?.substring(0, 50)}...`);
    console.log(`头像数据类型: ${typeof avatarData}`);
    console.log(`头像数据长度: ${avatarData?.length || 0}`);
    console.log(`是否为data URI: ${avatarData?.startsWith('data:')}`);
    
    // 模拟API请求体
    const apiPayload = JSON.stringify(userInfo);
    console.log(`API请求体大小: ${apiPayload.length} 字节`);
    
    return userInfo;
}

// 3. 模拟数据库读取过程
function simulateDatabaseRetrieval(storedUserInfo) {
    console.log("\n3. 数据库读取过程");
    console.log("------------------");
    
    // 模拟API响应
    const apiResponse = {
        data: storedUserInfo
    };
    
    console.log(`API响应状态: 200 OK`);
    console.log(`返回的头像数据前50字符: ${storedUserInfo.avatar?.substring(0, 50)}...`);
    console.log(`头像数据完整性检查: ${storedUserInfo.avatar?.startsWith('data:') ? '通过' : '失败'}`);
    
    return apiResponse;
}

// 4. 模拟前端页面显示过程
function simulatePageDisplay(apiResponse) {
    console.log("\n4. 前端页面显示过程");
    console.log("--------------------");
    
    const userData = apiResponse.data;
    
    // 模拟Individual.ets的逻辑
    console.log("Individual.ets 处理逻辑:");
    const individualAvatar = userData.avatar || 'app.media.man';
    console.log(`- 原始头像数据: ${userData.avatar?.substring(0, 30)}...`);
    console.log(`- 最终显示头像: ${individualAvatar === userData.avatar ? '数据库头像' : '默认头像'}`);
    
    // 模拟EditProfile.ets的逻辑
    console.log("\nEditProfile.ets 处理逻辑:");
    const editProfileAvatar = (userData.avatar && userData.avatar.startsWith('data:')) ? userData.avatar : 'app.media.man';
    console.log(`- 头像验证结果: ${userData.avatar?.startsWith('data:') ? '通过' : '失败'}`);
    console.log(`- 最终显示头像: ${editProfileAvatar === userData.avatar ? '数据库头像' : '默认头像'}`);
    
    // 检查一致性
    const isConsistent = individualAvatar === editProfileAvatar;
    console.log(`\n页面显示一致性: ${isConsistent ? '一致' : '不一致'}`);
    
    if (!isConsistent) {
        console.log("⚠️  发现不一致问题:");
        console.log(`   Individual页面: ${individualAvatar.substring(0, 30)}...`);
        console.log(`   EditProfile页面: ${editProfileAvatar.substring(0, 30)}...`);
    }
    
    return { individualAvatar, editProfileAvatar, isConsistent };
}

// 5. 执行完整测试流程
console.log("开始执行完整头像数据流测试...\n");

const imageResults = simulateImageSelection();
const validImage = imageResults.find(r => r.isValid);

if (validImage) {
    const storedData = simulateDatabaseStorage(validImage.convertedData);
    const retrievedData = simulateDatabaseRetrieval(storedData);
    const displayResults = simulatePageDisplay(retrievedData);
    
    console.log("\n=== 测试总结 ===");
    console.log(`图片转换: ${imageResults.filter(r => r.isValid).length}/${imageResults.length} 成功`);
    console.log(`数据库存储: 成功`);
    console.log(`数据库读取: 成功`);
    console.log(`页面显示一致性: ${displayResults.isConsistent ? '✅ 一致' : '❌ 不一致'}`);
    
    if (!displayResults.isConsistent) {
        console.log("\n🔍 问题分析:");
        console.log("Individual.ets 使用: avatar || 'app.media.man'");
        console.log("EditProfile.ets 使用: (avatar && avatar.startsWith('data:')) ? avatar : 'app.media.man'");
        console.log("建议: 统一两个页面的头像验证逻辑");
    }
} else {
    console.log("❌ 没有成功转换的图片数据，无法继续测试");
}

console.log("\n测试完成。");
