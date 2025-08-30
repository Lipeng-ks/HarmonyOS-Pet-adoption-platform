/*
 Navicat Premium Data Transfer

 Source Server         : projcet
 Source Server Type    : MySQL
 Source Server Version : 80043
 Source Host           : localhost:3306
 Source Schema         : adoption_platform

 Target Server Type    : MySQL
 Target Server Version : 80043
 File Encoding         : 65001

 Date: 30/08/2025 13:53:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for adoption_orders
-- ----------------------------
DROP TABLE IF EXISTS `adoption_orders`;
CREATE TABLE `adoption_orders`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pet_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宠物名字',
  `pet_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宠物地址',
  `image` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `shipping_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `pet_experience` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `application_reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` enum('审核中','已发货','完成','评价') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '审核中' COMMENT '订单状态',
  `application_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请领养时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_id` bigint NULL DEFAULT NULL,
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `completed_at` datetime NULL DEFAULT NULL COMMENT '订单完成时间',
  `animal_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ux_adoption_orders_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_adoption_orders_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_adoption_orders_animal_id`(`animal_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '领养订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of adoption_orders
-- ----------------------------
INSERT INTO `adoption_orders` VALUES (5, '奶茶', '北京市北京市', 'app.media.lsdrhgd', '张三 13800138000 上海市 浦东新区世纪大道100号', '没有', '没有', '审核中', '2025-08-22 03:51:19', '2025-08-22 03:51:19', '2025-08-29 21:41:23', 1, '2508231503280005', NULL, 6);
INSERT INTO `adoption_orders` VALUES (10, '小白', '上海市上海市', 'app.media.xmxmm', 'bzd 13900139000 北京市 北京市', '一年', '没有', '已发货', '2025-08-22 04:08:28', '2025-08-22 04:08:28', '2025-08-29 21:41:32', 9, '2508231503280010', NULL, 7);
INSERT INTO `adoption_orders` VALUES (11, '小灰', '广东省广州市', 'app.media.ddfchjbd', '张三 13800138000 上海市 浦东新区世纪大道100号', '没有', '没有', '完成', '2025-08-23 08:20:55', '2025-08-23 08:20:55', '2025-08-29 21:41:55', 1, 'AO20250823162055720502', '2025-08-29 18:17:30', 10);
INSERT INTO `adoption_orders` VALUES (12, '小星', '福建省厦门市', 'app.media.xhvffg', '张三 13800138000 上海市 浦东新区世纪大道100号', '没有', '没有', '评价', '2025-08-23 17:18:27', '2025-08-23 17:18:27', '2025-08-29 21:42:04', 1, 'AO20250824011826710658', NULL, 26);

-- ----------------------------
-- Table structure for animals
-- ----------------------------
DROP TABLE IF EXISTS `animals`;
CREATE TABLE `animals`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `age` float NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `vaccinated` tinyint(1) NULL DEFAULT 0,
  `dewormed` tinyint(1) NULL DEFAULT 0,
  `neutered` tinyint(1) NULL DEFAULT 0,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `isFree` tinyint(1) NULL DEFAULT 1,
  `is_free` bit(1) NOT NULL,
  `favorite_count` int NOT NULL DEFAULT 0,
  `user_id` bigint NOT NULL COMMENT '发布用户ID',
  `adopted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已领养：0未领养，1已领养',
  `listed` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否上架：1上架中，0已下架',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_animals_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_animals_adopted`(`adopted` ASC) USING BTREE,
  INDEX `idx_animals_listed`(`listed` ASC) USING BTREE,
  INDEX `idx_type_city`(`type` ASC, `city` ASC) USING BTREE,
  INDEX `idx_age`(`age` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of animals
-- ----------------------------
INSERT INTO `animals` VALUES (1, '小黑', 1, 1, '狗', '小黑是一只精力充沛的黑色小狗，喜欢在公园里奔跑和追逐球，性格活泼开朗，对人非常友好，是家庭的开心果', 1, 1, 0, 'app.media.jdfogpd', '南昌市', 1, b'1', 1, 1, 0, 1);
INSERT INTO `animals` VALUES (2, '花花', 0, 1, '猫', '花花是一只温顺的母猫，毛色斑斓，喜欢在阳光下慵懒地打盹，对家人很亲昵，偶尔会撒娇讨摸摸。', 1, 0, 0, 'app.media.lhmsdf', '成都市', 0, b'0', 2, 1, 0, 1);
INSERT INTO `animals` VALUES (3, '球球', 1, 3, '狗', '球球聪明伶俐，擅长听懂主人的指令，最喜欢和小朋友一起玩球，是一只非常忠诚的伙伴。', 0, 1, 1, 'app.media.dfghidg', '北京市', 1, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (4, '橘子', 0, 2, '猫', '橘子是一只安静的橘猫，喜欢陪伴在主人的身边，偶尔会用头蹭人表达亲昵，是家里的小暖宝。', 1, 1, 1, 'app.media.xjzxmm', '上海市', 0, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (5, '豆豆', 1, 1, '其他', '豆豆是一只活泼可爱的兔子，喜欢吃胡萝卜和新鲜蔬菜，性格温顺，喜欢被轻轻抚摸。', 0, 0, 0, 'app.media.ilsdnvldfg', '东莞市', 1, b'1', 1, 9, 0, 1);
INSERT INTO `animals` VALUES (6, '奶茶', 0, 4, '狗', '奶茶性格温顺，毛发柔软，喜欢安静地趴在主人的脚边，是一只非常懂事又粘人的小狗。', 1, 1, 1, 'app.media.lsdrhgd', '六安市', 0, b'0', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (7, '小白', 0, 2, '猫', '小白是一只纯白色的猫咪，性格独立但不失温柔，喜欢在窗台上晒太阳，偶尔会主动亲近主人。', 0, 1, 0, 'app.media.xmxmm', '上海市', 1, b'1', 0, 10, 0, 0);
INSERT INTO `animals` VALUES (8, '旺财', 1, 5, '狗', '旺财是一只忠诚的成年犬，警觉性高，适合看家护院，对家人非常有保护欲，是值得信赖的伙伴。', 1, 0, 1, 'app.media.tyikjgch', '北京市', 0, b'0', 1, 10, 0, 1);
INSERT INTO `animals` VALUES (9, '咪咪', 0, 3, '猫', '咪咪喜欢撒娇，常常用软软的叫声吸引主人的注意，毛发柔顺，喜欢被梳理和抚摸。', 1, 1, 0, 'app.media.ksdhf', '上海市', 1, b'1', 0, 1, 0, 1);
INSERT INTO `animals` VALUES (10, '小灰', 1, 2, '其他', '小灰是一只活泼的仓鼠，喜欢在笼子里跑轮，偶尔会用小爪子抓食物，非常可爱有趣。', 0, 0, 0, 'app.media.ddfchjbd', '广州市', 0, b'0', 0, 1, 1, 0);
INSERT INTO `animals` VALUES (11, '小七', 1, 1, '狗', '小七聪明伶俐，能快速学会新技能，喜欢和主人互动，是家里的开心果和小帮手。', 1, 1, 0, 'app.media.iuhvnbc', '北京市', 1, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (12, '小橙', 1, 4, '猫', '小橙喜欢抓毛球和玩具，性格活泼，喜欢探索新环境，是一只充满好奇心的小猫。', 0, 1, 1, 'app.media.sdflj', '上海市', 0, b'0', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (13, '小蓝', 0, 2, '狗', '小蓝喜欢游泳和户外活动，毛色亮丽，性格开朗，是运动型家庭的理想宠物。', 1, 0, 1, 'app.media.opiertbc', '北京市', 1, b'1', 0, 1, 0, 1);
INSERT INTO `animals` VALUES (14, '小绿', 1, 3, '猫', '小绿喜欢晒太阳，经常在阳台上打盹，性格温和，喜欢和其他猫咪相处。', 0, 1, 0, 'app.media.iehgrod', '上海市', 0, b'0', 0, 1, 0, 1);
INSERT INTO `animals` VALUES (15, '小紫', 0, 1, '其他', '小紫是一只色彩鲜艳的鹦鹉，喜欢模仿人说话，性格活泼，喜欢和人互动。', 1, 0, 0, 'app.media.cjgdfg', '广州市', 1, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (16, '小棕', 1, 2, '狗', '小棕喜欢在户外奔跑，精力充沛，喜欢和小朋友一起玩耍，是家庭的好伙伴。', 1, 1, 1, 'app.media.ytugfnvg', '北京市', 0, b'0', 1, 1, 0, 1);
INSERT INTO `animals` VALUES (17, '小金', 0, 3, '猫', '小金性格安静，喜欢独处，偶尔会主动亲近主人，是一只懂事的猫咪。', 0, 1, 0, 'app.media.sadfxc', '上海市', 1, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (18, '小银', 1, 4, '狗', '小银喜欢和主人玩耍，喜欢追逐飞盘和球，是一只非常有活力的狗狗。', 1, 0, 1, 'app.media.iodjfgdfg', '北京市', 0, b'0', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (19, '小红', 0, 2, '猫', '小红喜欢爬高，经常在家里的高处观察四周，性格机警，是一只灵巧的猫咪。', 1, 1, 0, 'app.media.fgoihjoi', '上海市', 1, b'1', 0, 1, 0, 1);
INSERT INTO `animals` VALUES (20, '小橙子', 1, 1, '其他', '小橙子是一只活泼的龙猫，喜欢啃木头和跳跃，性格温顺，适合有小孩的家庭。', 0, 0, 0, 'app.media.ohfvsdfgd', '广州市', 0, b'0', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (21, '小雪', 0, 2, '狗', '小雪喜欢撒娇，毛发雪白柔软，喜欢和主人一起散步，是一只非常粘人的小狗。', 1, 1, 1, 'app.media.cnkvn', '北京市', 1, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (22, '小风', 1, 3, '猫', '小风喜欢追逐玩具，性格活泼，喜欢和其他猫咪一起玩耍，是家里的小调皮。', 0, 1, 0, 'app.media.gfhjfdih', '上海市', 0, b'0', 0, 10, 0, 1);
INSERT INTO `animals` VALUES (23, '小雨', 1, 4, '狗', '小雨喜欢在雨天散步，性格温和，喜欢和主人依偎在一起，是一只非常有安全感的狗狗。', 1, 0, 1, 'app.media.lsdrhgd', '北京市', 1, b'1', 0, 10, 0, 1);
INSERT INTO `animals` VALUES (24, '小雷', 1, 2, '猫', '小雷喜欢安静地待在角落，偶尔会用大眼睛观察主人，性格温顺，是一只乖巧的猫咪。', 1, 1, 0, 'app.media.yighch', '上海市', 0, b'0', 0, 10, 0, 1);
INSERT INTO `animals` VALUES (25, '小电', 0, 2, '其他', '小电是一只可爱的仓鼠，喜欢在笼子里跑轮，性格活泼，喜欢吃各种坚果和种子。', 0, 0, 0, 'app.media.odsfgdfg', '茂名市', 1, b'1', 0, 10, 0, 1);
INSERT INTO `animals` VALUES (26, '小星', 1, 2, '狗', '小星喜欢夜晚在院子里散步，喜欢仰望星空，是一只安静又有点神秘的小狗。', 1, 1, 1, 'app.media.xhvffg', '北京市', 0, b'0', 0, 10, 1, 0);
INSERT INTO `animals` VALUES (27, '小月', 0, 3, '猫', '小月喜欢在夜晚安静地陪伴主人，毛发柔顺，性格温柔，是家里的小天使。', 0, 1, 0, 'app.media.fyujtg', '上海市', 1, b'1', 0, 1, 0, 1);
INSERT INTO `animals` VALUES (28, '小阳', 1, 4, '狗', '小阳喜欢在阳光下奔跑，性格开朗，喜欢和小朋友一起玩耍，是一只充满活力的狗狗。', 1, 0, 1, 'app.media.lcvjdfghd', '北京市', 0, b'0', 0, 1, 0, 1);
INSERT INTO `animals` VALUES (29, '小云', 0, 2, '猫', '小云喜欢爬高和探索新环境，性格好奇，喜欢和主人互动，是一只聪明的猫咪。', 1, 1, 0, 'app.media.retoijbv', '上海市', 1, b'1', 0, 9, 0, 1);
INSERT INTO `animals` VALUES (30, '小山', 1, 1, '其他', '小山是一只可爱的仓鼠，喜欢在木屑中打洞，性格温顺，适合做孩子们的宠物。', 0, 0, 0, 'app.media.ofcvjbfghb', '广州市', 0, b'0', 0, 9, 0, 1);

-- ----------------------------
-- Table structure for cities
-- ----------------------------
DROP TABLE IF EXISTS `cities`;
CREATE TABLE `cities`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `pinyin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 398 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cities
-- ----------------------------
INSERT INTO `cities` VALUES (59, '全国', 'quanguo', NULL);
INSERT INTO `cities` VALUES (60, '北京市', 'beijing', '北京市');
INSERT INTO `cities` VALUES (61, '天津市', 'tianjin', '天津市');
INSERT INTO `cities` VALUES (62, '上海市', 'shanghai', '上海市');
INSERT INTO `cities` VALUES (63, '重庆市', 'chongqing', '重庆市');
INSERT INTO `cities` VALUES (64, '石家庄市', 'shijiazhuang', '河北省');
INSERT INTO `cities` VALUES (65, '唐山市', 'tangshan', '河北省');
INSERT INTO `cities` VALUES (66, '秦皇岛市', 'qinhuangdao', '河北省');
INSERT INTO `cities` VALUES (67, '邯郸市', 'handan', '河北省');
INSERT INTO `cities` VALUES (68, '邢台市', 'xingtai', '河北省');
INSERT INTO `cities` VALUES (69, '保定市', 'baoding', '河北省');
INSERT INTO `cities` VALUES (70, '张家口市', 'zhangjiakou', '河北省');
INSERT INTO `cities` VALUES (71, '承德市', 'chengde', '河北省');
INSERT INTO `cities` VALUES (72, '沧州市', 'cangzhou', '河北省');
INSERT INTO `cities` VALUES (73, '廊坊市', 'langfang', '河北省');
INSERT INTO `cities` VALUES (74, '衡水市', 'hengshui', '河北省');
INSERT INTO `cities` VALUES (75, '太原市', 'taiyuan', '山西省');
INSERT INTO `cities` VALUES (76, '大同市', 'datong', '山西省');
INSERT INTO `cities` VALUES (77, '阳泉市', 'yangquan', '山西省');
INSERT INTO `cities` VALUES (78, '长治市', 'changzhi', '山西省');
INSERT INTO `cities` VALUES (79, '晋城市', 'jincheng', '山西省');
INSERT INTO `cities` VALUES (80, '朔州市', 'shuozhou', '山西省');
INSERT INTO `cities` VALUES (81, '晋中市', 'jinzhong', '山西省');
INSERT INTO `cities` VALUES (82, '运城市', 'yuncheng', '山西省');
INSERT INTO `cities` VALUES (83, '忻州市', 'xinzhou', '山西省');
INSERT INTO `cities` VALUES (84, '临汾市', 'linfen', '山西省');
INSERT INTO `cities` VALUES (85, '吕梁市', 'lvliang', '山西省');
INSERT INTO `cities` VALUES (86, '呼和浩特市', 'huhehaote', '内蒙古自治区');
INSERT INTO `cities` VALUES (87, '包头市', 'baotou', '内蒙古自治区');
INSERT INTO `cities` VALUES (88, '乌海市', 'wuhai', '内蒙古自治区');
INSERT INTO `cities` VALUES (89, '赤峰市', 'chifeng', '内蒙古自治区');
INSERT INTO `cities` VALUES (90, '通辽市', 'tongliao', '内蒙古自治区');
INSERT INTO `cities` VALUES (91, '鄂尔多斯市', 'eerduosi', '内蒙古自治区');
INSERT INTO `cities` VALUES (92, '呼伦贝尔市', 'hulunbeier', '内蒙古自治区');
INSERT INTO `cities` VALUES (93, '巴彦淖尔市', 'bayannaoer', '内蒙古自治区');
INSERT INTO `cities` VALUES (94, '乌兰察布市', 'wulanchabu', '内蒙古自治区');
INSERT INTO `cities` VALUES (95, '沈阳市', 'shenyang', '辽宁省');
INSERT INTO `cities` VALUES (96, '大连市', 'dalian', '辽宁省');
INSERT INTO `cities` VALUES (97, '鞍山市', 'anshan', '辽宁省');
INSERT INTO `cities` VALUES (98, '抚顺市', 'fushun', '辽宁省');
INSERT INTO `cities` VALUES (99, '本溪市', 'benxi', '辽宁省');
INSERT INTO `cities` VALUES (100, '丹东市', 'dandong', '辽宁省');
INSERT INTO `cities` VALUES (101, '锦州市', 'jinzhou', '辽宁省');
INSERT INTO `cities` VALUES (102, '营口市', 'yingkou', '辽宁省');
INSERT INTO `cities` VALUES (103, '阜新市', 'fuxin', '辽宁省');
INSERT INTO `cities` VALUES (104, '辽阳市', 'liaoyang', '辽宁省');
INSERT INTO `cities` VALUES (105, '盘锦市', 'panjin', '辽宁省');
INSERT INTO `cities` VALUES (106, '铁岭市', 'tieling', '辽宁省');
INSERT INTO `cities` VALUES (107, '朝阳市', 'chaoyang', '辽宁省');
INSERT INTO `cities` VALUES (108, '葫芦岛市', 'huludao', '辽宁省');
INSERT INTO `cities` VALUES (109, '长春市', 'changchun', '吉林省');
INSERT INTO `cities` VALUES (110, '吉林市', 'jilin', '吉林省');
INSERT INTO `cities` VALUES (111, '四平市', 'siping', '吉林省');
INSERT INTO `cities` VALUES (112, '辽源市', 'liaoyuan', '吉林省');
INSERT INTO `cities` VALUES (113, '通化市', 'tonghua', '吉林省');
INSERT INTO `cities` VALUES (114, '白山市', 'baishan', '吉林省');
INSERT INTO `cities` VALUES (115, '松原市', 'songyuan', '吉林省');
INSERT INTO `cities` VALUES (116, '白城市', 'baicheng', '吉林省');
INSERT INTO `cities` VALUES (117, '哈尔滨市', 'haerbin', '黑龙江省');
INSERT INTO `cities` VALUES (118, '齐齐哈尔市', 'qiqihaer', '黑龙江省');
INSERT INTO `cities` VALUES (119, '鸡西市', 'jixi', '黑龙江省');
INSERT INTO `cities` VALUES (120, '鹤岗市', 'hegang', '黑龙江省');
INSERT INTO `cities` VALUES (121, '双鸭山市', 'shuangyashan', '黑龙江省');
INSERT INTO `cities` VALUES (122, '大庆市', 'daqing', '黑龙江省');
INSERT INTO `cities` VALUES (123, '伊春市', 'yichun', '黑龙江省');
INSERT INTO `cities` VALUES (124, '佳木斯市', 'jiamusi', '黑龙江省');
INSERT INTO `cities` VALUES (125, '七台河市', 'qitaihe', '黑龙江省');
INSERT INTO `cities` VALUES (126, '牡丹江市', 'mudanjiang', '黑龙江省');
INSERT INTO `cities` VALUES (127, '黑河市', 'heihe', '黑龙江省');
INSERT INTO `cities` VALUES (128, '绥化市', 'suihua', '黑龙江省');
INSERT INTO `cities` VALUES (129, '南京市', 'nanjing', '江苏省');
INSERT INTO `cities` VALUES (130, '无锡市', 'wuxi', '江苏省');
INSERT INTO `cities` VALUES (131, '徐州市', 'xuzhou', '江苏省');
INSERT INTO `cities` VALUES (132, '常州市', 'changzhou', '江苏省');
INSERT INTO `cities` VALUES (133, '苏州市', 'suzhou', '江苏省');
INSERT INTO `cities` VALUES (134, '南通市', 'nantong', '江苏省');
INSERT INTO `cities` VALUES (135, '连云港市', 'lianyungang', '江苏省');
INSERT INTO `cities` VALUES (136, '淮安市', 'huaian', '江苏省');
INSERT INTO `cities` VALUES (137, '盐城市', 'yancheng', '江苏省');
INSERT INTO `cities` VALUES (138, '扬州市', 'yangzhou', '江苏省');
INSERT INTO `cities` VALUES (139, '镇江市', 'zhenjiang', '江苏省');
INSERT INTO `cities` VALUES (140, '泰州市', 'taizhou', '江苏省');
INSERT INTO `cities` VALUES (141, '宿迁市', 'suqian', '江苏省');
INSERT INTO `cities` VALUES (142, '杭州市', 'hangzhou', '浙江省');
INSERT INTO `cities` VALUES (143, '宁波市', 'ningbo', '浙江省');
INSERT INTO `cities` VALUES (144, '温州市', 'wenzhou', '浙江省');
INSERT INTO `cities` VALUES (145, '嘉兴市', 'jiaxing', '浙江省');
INSERT INTO `cities` VALUES (146, '湖州市', 'huzhou', '浙江省');
INSERT INTO `cities` VALUES (147, '绍兴市', 'shaoxing', '浙江省');
INSERT INTO `cities` VALUES (148, '金华市', 'jinhua', '浙江省');
INSERT INTO `cities` VALUES (149, '衢州市', 'quzhou', '浙江省');
INSERT INTO `cities` VALUES (150, '舟山市', 'zhoushan', '浙江省');
INSERT INTO `cities` VALUES (151, '台州市', 'taizhou', '浙江省');
INSERT INTO `cities` VALUES (152, '丽水市', 'lishui', '浙江省');
INSERT INTO `cities` VALUES (153, '合肥市', 'hefei', '安徽省');
INSERT INTO `cities` VALUES (154, '芜湖市', 'wuhu', '安徽省');
INSERT INTO `cities` VALUES (155, '蚌埠市', 'bengbu', '安徽省');
INSERT INTO `cities` VALUES (156, '淮南市', 'huainan', '安徽省');
INSERT INTO `cities` VALUES (157, '马鞍山市', 'maanshan', '辽宁省');
INSERT INTO `cities` VALUES (158, '淮北市', 'huaibei', '安徽省');
INSERT INTO `cities` VALUES (159, '铜陵市', 'tongling', '安徽省');
INSERT INTO `cities` VALUES (160, '安庆市', 'anqing', '安徽省');
INSERT INTO `cities` VALUES (161, '黄山市', 'huangshan', '安徽省');
INSERT INTO `cities` VALUES (162, '滁州市', 'chuzhou', '安徽省');
INSERT INTO `cities` VALUES (163, '阜阳市', 'fuyang', '安徽省');
INSERT INTO `cities` VALUES (164, '宿州市', 'suzhou', '安徽省');
INSERT INTO `cities` VALUES (165, '六安市', 'liuan', '安徽省');
INSERT INTO `cities` VALUES (166, '亳州市', 'bozhou', '安徽省');
INSERT INTO `cities` VALUES (167, '池州市', 'chizhou', '安徽省');
INSERT INTO `cities` VALUES (168, '宣城市', 'xuancheng', '安徽省');
INSERT INTO `cities` VALUES (169, '福州市', 'fuzhou', '福建省');
INSERT INTO `cities` VALUES (170, '厦门市', 'xiamen', '福建省');
INSERT INTO `cities` VALUES (171, '莆田市', 'putian', '福建省');
INSERT INTO `cities` VALUES (172, '三明市', 'sanming', '福建省');
INSERT INTO `cities` VALUES (173, '泉州市', 'quanzhou', '福建省');
INSERT INTO `cities` VALUES (174, '漳州市', 'zhangzhou', '福建省');
INSERT INTO `cities` VALUES (175, '南平市', 'nanping', '福建省');
INSERT INTO `cities` VALUES (176, '龙岩市', 'longyan', '福建省');
INSERT INTO `cities` VALUES (177, '宁德市', 'ningde', '福建省');
INSERT INTO `cities` VALUES (178, '南昌市', 'nanchang', '江西省');
INSERT INTO `cities` VALUES (179, '景德镇市', 'jingdezhen', '江西省');
INSERT INTO `cities` VALUES (180, '萍乡市', 'pingxiang', '江西省');
INSERT INTO `cities` VALUES (181, '九江市', 'jiujiang', '江西省');
INSERT INTO `cities` VALUES (182, '新余市', 'xinyu', '江西省');
INSERT INTO `cities` VALUES (183, '鹰潭市', 'yingtan', '江西省');
INSERT INTO `cities` VALUES (184, '赣州市', 'ganzhou', '江西省');
INSERT INTO `cities` VALUES (185, '吉安市', 'jian', '江西省');
INSERT INTO `cities` VALUES (186, '宜春市', 'yichun', '江西省');
INSERT INTO `cities` VALUES (187, '抚州市', 'fuzhou', '江西省');
INSERT INTO `cities` VALUES (188, '上饶市', 'shangrao', '江西省');
INSERT INTO `cities` VALUES (189, '济南市', 'jinan', '山东省');
INSERT INTO `cities` VALUES (190, '青岛市', 'qingdao', '山东省');
INSERT INTO `cities` VALUES (191, '淄博市', 'zibo', '山东省');
INSERT INTO `cities` VALUES (192, '枣庄市', 'zaozhuang', '山东省');
INSERT INTO `cities` VALUES (193, '东营市', 'dongying', '山东省');
INSERT INTO `cities` VALUES (194, '烟台市', 'yantai', '山东省');
INSERT INTO `cities` VALUES (195, '潍坊市', 'weifang', '山东省');
INSERT INTO `cities` VALUES (196, '济宁市', 'jining', '山东省');
INSERT INTO `cities` VALUES (197, '泰安市', 'taian', '山东省');
INSERT INTO `cities` VALUES (198, '威海市', 'weihai', '山东省');
INSERT INTO `cities` VALUES (199, '日照市', 'rizhao', '山东省');
INSERT INTO `cities` VALUES (200, '临沂市', 'linyi', '山东省');
INSERT INTO `cities` VALUES (201, '德州市', 'dezhou', '山东省');
INSERT INTO `cities` VALUES (202, '聊城市', 'liaocheng', '山东省');
INSERT INTO `cities` VALUES (203, '滨州市', 'binzhou', '山东省');
INSERT INTO `cities` VALUES (204, '菏泽市', 'heze', '山东省');
INSERT INTO `cities` VALUES (205, '郑州市', 'zhengzhou', '河南省');
INSERT INTO `cities` VALUES (206, '开封市', 'kaifeng', '河南省');
INSERT INTO `cities` VALUES (207, '洛阳市', 'luoyang', '河南省');
INSERT INTO `cities` VALUES (208, '平顶山市', 'pingdingshan', '河南省');
INSERT INTO `cities` VALUES (209, '安阳市', 'anyang', '河南省');
INSERT INTO `cities` VALUES (210, '鹤壁市', 'hebi', '河南省');
INSERT INTO `cities` VALUES (211, '新乡市', 'xinxiang', '河南省');
INSERT INTO `cities` VALUES (212, '焦作市', 'jiaozuo', '河南省');
INSERT INTO `cities` VALUES (213, '濮阳市', 'puyang', '河南省');
INSERT INTO `cities` VALUES (214, '许昌市', 'xuchang', '河南省');
INSERT INTO `cities` VALUES (215, '漯河市', 'luohe', '河南省');
INSERT INTO `cities` VALUES (216, '三门峡市', 'sanmenxia', '河南省');
INSERT INTO `cities` VALUES (217, '南阳市', 'nanyang', '河南省');
INSERT INTO `cities` VALUES (218, '商丘市', 'shangqiu', '河南省');
INSERT INTO `cities` VALUES (219, '信阳市', 'xinyang', '河南省');
INSERT INTO `cities` VALUES (220, '周口市', 'zhoukou', '河南省');
INSERT INTO `cities` VALUES (221, '驻马店市', 'zhumadian', '河南省');
INSERT INTO `cities` VALUES (222, '武汉市', 'wuhan', '湖北省');
INSERT INTO `cities` VALUES (223, '黄石市', 'huangshi', '湖北省');
INSERT INTO `cities` VALUES (224, '十堰市', 'shiyan', '湖北省');
INSERT INTO `cities` VALUES (225, '宜昌市', 'yichang', '湖北省');
INSERT INTO `cities` VALUES (226, '襄阳市', 'xiangyang', '湖北省');
INSERT INTO `cities` VALUES (227, '鄂州市', 'ezhou', '湖北省');
INSERT INTO `cities` VALUES (228, '荆门市', 'jingmen', '湖北省');
INSERT INTO `cities` VALUES (229, '孝感市', 'xiaogan', '湖北省');
INSERT INTO `cities` VALUES (230, '荆州市', 'jingzhou', '湖北省');
INSERT INTO `cities` VALUES (231, '黄冈市', 'huanggang', '湖北省');
INSERT INTO `cities` VALUES (232, '咸宁市', 'xianning', '湖北省');
INSERT INTO `cities` VALUES (233, '随州市', 'suizhou', '湖北省');
INSERT INTO `cities` VALUES (234, '长沙市', 'changsha', '湖南省');
INSERT INTO `cities` VALUES (235, '株洲市', 'zhuzhou', '湖南省');
INSERT INTO `cities` VALUES (236, '湘潭市', 'xiangtan', '湖南省');
INSERT INTO `cities` VALUES (237, '衡阳市', 'hengyang', '湖南省');
INSERT INTO `cities` VALUES (238, '邵阳市', 'shaoyang', '湖南省');
INSERT INTO `cities` VALUES (239, '岳阳市', 'yueyang', '湖南省');
INSERT INTO `cities` VALUES (240, '常德市', 'changde', '湖南省');
INSERT INTO `cities` VALUES (241, '张家界市', 'zhangjiajie', '湖南省');
INSERT INTO `cities` VALUES (242, '益阳市', 'yiyang', '湖南省');
INSERT INTO `cities` VALUES (243, '郴州市', 'chenzhou', '湖南省');
INSERT INTO `cities` VALUES (244, '永州市', 'yongzhou', '湖南省');
INSERT INTO `cities` VALUES (245, '怀化市', 'huaihua', '湖南省');
INSERT INTO `cities` VALUES (246, '娄底市', 'loudi', '湖南省');
INSERT INTO `cities` VALUES (247, '广州市', 'guangzhou', '广东省');
INSERT INTO `cities` VALUES (248, '韶关市', 'shaoguan', '广东省');
INSERT INTO `cities` VALUES (249, '深圳市', 'shenzhen', '广东省');
INSERT INTO `cities` VALUES (250, '珠海市', 'zhuhai', '广东省');
INSERT INTO `cities` VALUES (251, '汕头市', 'shantou', '广东省');
INSERT INTO `cities` VALUES (252, '佛山市', 'foshan', '广东省');
INSERT INTO `cities` VALUES (253, '江门市', 'jiangmen', '广东省');
INSERT INTO `cities` VALUES (254, '湛江市', 'zhanjiang', '广东省');
INSERT INTO `cities` VALUES (255, '茂名市', 'maoming', '广东省');
INSERT INTO `cities` VALUES (256, '肇庆市', 'zhaoqing', '广东省');
INSERT INTO `cities` VALUES (257, '惠州市', 'huizhou', '广东省');
INSERT INTO `cities` VALUES (258, '梅州市', 'meizhou', '广东省');
INSERT INTO `cities` VALUES (259, '汕尾市', 'shanwei', '广东省');
INSERT INTO `cities` VALUES (260, '河源市', 'heyuan', '广东省');
INSERT INTO `cities` VALUES (261, '阳江市', 'yangjiang', '广东省');
INSERT INTO `cities` VALUES (262, '清远市', 'qingyuan', '广东省');
INSERT INTO `cities` VALUES (263, '东莞市', 'dongguan', '广东省');
INSERT INTO `cities` VALUES (264, '中山市', 'zhongshan', '广东省');
INSERT INTO `cities` VALUES (265, '潮州市', 'chaozhou', '广东省');
INSERT INTO `cities` VALUES (266, '揭阳市', 'jieyang', '广东省');
INSERT INTO `cities` VALUES (267, '云浮市', 'yunfu', '广东省');
INSERT INTO `cities` VALUES (268, '南宁市', 'nanning', '广西壮族自治区');
INSERT INTO `cities` VALUES (269, '柳州市', 'liuzhou', '广西壮族自治区');
INSERT INTO `cities` VALUES (270, '桂林市', 'guilin', '广西壮族自治区');
INSERT INTO `cities` VALUES (271, '梧州市', 'wuzhou', '广西壮族自治区');
INSERT INTO `cities` VALUES (272, '北海市', 'beihai', '广西壮族自治区');
INSERT INTO `cities` VALUES (273, '防城港市', 'fangchenggang', '广西壮族自治区');
INSERT INTO `cities` VALUES (274, '钦州市', 'qinzhou', '广西壮族自治区');
INSERT INTO `cities` VALUES (275, '贵港市', 'guigang', '广西壮族自治区');
INSERT INTO `cities` VALUES (276, '玉林市', 'yulin', '广西壮族自治区');
INSERT INTO `cities` VALUES (277, '百色市', 'baise', '广西壮族自治区');
INSERT INTO `cities` VALUES (278, '贺州市', 'hezhou', '广西壮族自治区');
INSERT INTO `cities` VALUES (279, '河池市', 'hechi', '广西壮族自治区');
INSERT INTO `cities` VALUES (280, '来宾市', 'laibin', '广西壮族自治区');
INSERT INTO `cities` VALUES (281, '崇左市', 'chongzuo', '广西壮族自治区');
INSERT INTO `cities` VALUES (282, '海口市', 'haikou', '海南省');
INSERT INTO `cities` VALUES (283, '三亚市', 'sanya', '海南省');
INSERT INTO `cities` VALUES (284, '三沙市', 'sansha', '海南省');
INSERT INTO `cities` VALUES (285, '儋州市', 'danzhou', '海南省');
INSERT INTO `cities` VALUES (286, '成都市', 'chengdu', '四川省');
INSERT INTO `cities` VALUES (287, '自贡市', 'zigong', '四川省');
INSERT INTO `cities` VALUES (288, '攀枝花市', 'panzhihua', '四川省');
INSERT INTO `cities` VALUES (289, '泸州市', 'luzhou', '四川省');
INSERT INTO `cities` VALUES (290, '德阳市', 'deyang', '四川省');
INSERT INTO `cities` VALUES (291, '绵阳市', 'mianyang', '四川省');
INSERT INTO `cities` VALUES (292, '广元市', 'guangyuan', '四川省');
INSERT INTO `cities` VALUES (293, '遂宁市', 'suining', '四川省');
INSERT INTO `cities` VALUES (294, '内江市', 'neijiang', '四川省');
INSERT INTO `cities` VALUES (295, '乐山市', 'leshan', '四川省');
INSERT INTO `cities` VALUES (296, '南充市', 'nanchong', '四川省');
INSERT INTO `cities` VALUES (297, '眉山市', 'meishan', '四川省');
INSERT INTO `cities` VALUES (298, '宜宾市', 'yibin', '四川省');
INSERT INTO `cities` VALUES (299, '广安市', 'guangan', '四川省');
INSERT INTO `cities` VALUES (300, '达州市', 'dazhou', '四川省');
INSERT INTO `cities` VALUES (301, '雅安市', 'yaan', '四川省');
INSERT INTO `cities` VALUES (302, '巴中市', 'bazhong', '四川省');
INSERT INTO `cities` VALUES (303, '资阳市', 'ziyang', '四川省');
INSERT INTO `cities` VALUES (304, '贵阳市', 'guiyang', '贵州省');
INSERT INTO `cities` VALUES (305, '六盘水市', 'liupanshui', '贵州省');
INSERT INTO `cities` VALUES (306, '遵义市', 'zunyi', '贵州省');
INSERT INTO `cities` VALUES (307, '安顺市', 'anshun', '贵州省');
INSERT INTO `cities` VALUES (308, '毕节市', 'bijie', '贵州省');
INSERT INTO `cities` VALUES (309, '铜仁市', 'tongren', '贵州省');
INSERT INTO `cities` VALUES (310, '昆明市', 'kunming', '云南省');
INSERT INTO `cities` VALUES (311, '曲靖市', 'qujing', '云南省');
INSERT INTO `cities` VALUES (312, '玉溪市', 'yuxi', '云南省');
INSERT INTO `cities` VALUES (313, '保山市', 'baoshan', '云南省');
INSERT INTO `cities` VALUES (314, '昭通市', 'zhaotong', '云南省');
INSERT INTO `cities` VALUES (315, '丽江市', 'lijiang', '云南省');
INSERT INTO `cities` VALUES (316, '普洱市', 'puer', '云南省');
INSERT INTO `cities` VALUES (317, '临沧市', 'lincang', '云南省');
INSERT INTO `cities` VALUES (318, '拉萨市', 'lasa', '西藏自治区');
INSERT INTO `cities` VALUES (319, '日喀则市', 'rikaze', '西藏自治区');
INSERT INTO `cities` VALUES (320, '昌都市', 'changdu', '西藏自治区');
INSERT INTO `cities` VALUES (321, '林芝市', 'linzhi', '西藏自治区');
INSERT INTO `cities` VALUES (322, '山南市', 'shannan', '西藏自治区');
INSERT INTO `cities` VALUES (323, '那曲市', 'naqu', '西藏自治区');
INSERT INTO `cities` VALUES (324, '西安市', 'xian', '陕西省');
INSERT INTO `cities` VALUES (325, '铜川市', 'tongchuan', '陕西省');
INSERT INTO `cities` VALUES (326, '宝鸡市', 'baoji', '陕西省');
INSERT INTO `cities` VALUES (327, '咸阳市', 'xianyang', '陕西省');
INSERT INTO `cities` VALUES (328, '渭南市', 'weinan', '陕西省');
INSERT INTO `cities` VALUES (329, '延安市', 'yanan', '陕西省');
INSERT INTO `cities` VALUES (330, '汉中市', 'hanzhong', '陕西省');
INSERT INTO `cities` VALUES (331, '榆林市', 'yulin', '陕西省');
INSERT INTO `cities` VALUES (332, '安康市', 'ankang', '陕西省');
INSERT INTO `cities` VALUES (333, '商洛市', 'shangluo', '陕西省');
INSERT INTO `cities` VALUES (334, '兰州市', 'lanzhou', '甘肃省');
INSERT INTO `cities` VALUES (335, '嘉峪关市', 'jiayuguan', '甘肃省');
INSERT INTO `cities` VALUES (336, '金昌市', 'jinchang', '甘肃省');
INSERT INTO `cities` VALUES (337, '白银市', 'baiyin', '甘肃省');
INSERT INTO `cities` VALUES (338, '天水市', 'tianshui', '甘肃省');
INSERT INTO `cities` VALUES (339, '武威市', 'wuwei', '甘肃省');
INSERT INTO `cities` VALUES (340, '张掖市', 'zhangye', '甘肃省');
INSERT INTO `cities` VALUES (341, '平凉市', 'pingliang', '甘肃省');
INSERT INTO `cities` VALUES (342, '酒泉市', 'jiuquan', '甘肃省');
INSERT INTO `cities` VALUES (343, '庆阳市', 'qingyang', '甘肃省');
INSERT INTO `cities` VALUES (344, '定西市', 'dingxi', '甘肃省');
INSERT INTO `cities` VALUES (345, '陇南市', 'longnan', '甘肃省');
INSERT INTO `cities` VALUES (346, '西宁市', 'xining', '青海省');
INSERT INTO `cities` VALUES (347, '海东市', 'haidong', '青海省');
INSERT INTO `cities` VALUES (348, '海北藏族自治州', 'haibeizangzuzizhizhou', '青海省');
INSERT INTO `cities` VALUES (349, '黄南藏族自治州', 'huangnanzangzuzizhizhou', '青海省');
INSERT INTO `cities` VALUES (350, '海南藏族自治州', 'hainanzangzuzizhizhou', '青海省');
INSERT INTO `cities` VALUES (351, '果洛藏族自治州', 'guoluozangzuzizhizhou', '青海省');
INSERT INTO `cities` VALUES (352, '玉树藏族自治州', 'yushuzangzuzizhizhou', '青海省');
INSERT INTO `cities` VALUES (353, '海西蒙古族藏族自治州', 'haiximengguzuzizhizhou', '青海省');
INSERT INTO `cities` VALUES (354, '银川市', 'yinchuan', '宁夏回族自治区');
INSERT INTO `cities` VALUES (355, '石嘴山市', 'shizuishan', '宁夏回族自治区');
INSERT INTO `cities` VALUES (356, '吴忠市', 'wuzhong', '宁夏回族自治区');
INSERT INTO `cities` VALUES (357, '固原市', 'guyuan', '宁夏回族自治区');
INSERT INTO `cities` VALUES (358, '中卫市', 'zhongwei', '宁夏回族自治区');
INSERT INTO `cities` VALUES (359, '乌鲁木齐市', 'wulumuqi', '新疆维吾尔自治区');
INSERT INTO `cities` VALUES (360, '克拉玛依市', 'kelamayi', '新疆维吾尔自治区');
INSERT INTO `cities` VALUES (361, '吐鲁番市', 'tulufan', '新疆维吾尔自治区');
INSERT INTO `cities` VALUES (362, '哈密市', 'hami', '新疆维吾尔自治区');
INSERT INTO `cities` VALUES (363, '哈尔滨市', '', '黑龙江省');
INSERT INTO `cities` VALUES (364, '齐齐哈尔市', '', '黑龙江省');
INSERT INTO `cities` VALUES (365, '鸡西市', '', '黑龙江省');
INSERT INTO `cities` VALUES (366, '鹤岗市', '', '黑龙江省');
INSERT INTO `cities` VALUES (367, '双鸭山市', '', '黑龙江省');
INSERT INTO `cities` VALUES (368, '大庆市', '', '黑龙江省');
INSERT INTO `cities` VALUES (369, '伊春市', '', '黑龙江省');
INSERT INTO `cities` VALUES (370, '佳木斯市', '', '黑龙江省');
INSERT INTO `cities` VALUES (371, '七台河市', '', '黑龙江省');
INSERT INTO `cities` VALUES (372, '牡丹江市', '', '黑龙江省');
INSERT INTO `cities` VALUES (373, '黑河市', '', '黑龙江省');
INSERT INTO `cities` VALUES (374, '绥化市', '', '黑龙江省');
INSERT INTO `cities` VALUES (375, '哈尔滨市', '', '黑龙江省');
INSERT INTO `cities` VALUES (376, '齐齐哈尔市', '', '黑龙江省');
INSERT INTO `cities` VALUES (377, '鸡西市', '', '黑龙江省');
INSERT INTO `cities` VALUES (378, '鹤岗市', '', '黑龙江省');
INSERT INTO `cities` VALUES (379, '双鸭山市', '', '黑龙江省');
INSERT INTO `cities` VALUES (380, '大庆市', '', '黑龙江省');
INSERT INTO `cities` VALUES (381, '伊春市', '', '黑龙江省');
INSERT INTO `cities` VALUES (382, '佳木斯市', '', '黑龙江省');
INSERT INTO `cities` VALUES (383, '七台河市', '', '黑龙江省');
INSERT INTO `cities` VALUES (384, '牡丹江市', '', '黑龙江省');
INSERT INTO `cities` VALUES (385, '黑河市', '', '黑龙江省');
INSERT INTO `cities` VALUES (386, '绥化市', '', '黑龙江省');
INSERT INTO `cities` VALUES (387, '哈尔滨市', '', '黑龙江省');
INSERT INTO `cities` VALUES (388, '齐齐哈尔市', '', '黑龙江省');
INSERT INTO `cities` VALUES (389, '鸡西市', '', '黑龙江省');
INSERT INTO `cities` VALUES (390, '鹤岗市', '', '黑龙江省');
INSERT INTO `cities` VALUES (391, '双鸭山市', '', '黑龙江省');
INSERT INTO `cities` VALUES (392, '大庆市', '', '黑龙江省');
INSERT INTO `cities` VALUES (393, '伊春市', '', '黑龙江省');
INSERT INTO `cities` VALUES (394, '佳木斯市', '', '黑龙江省');
INSERT INTO `cities` VALUES (395, '七台河市', '', '黑龙江省');
INSERT INTO `cities` VALUES (396, '牡丹江市', '', '黑龙江省');
INSERT INTO `cities` VALUES (397, '黑河市', '', '黑龙江省');
INSERT INTO `cities` VALUES (398, '绥化市', '', '黑龙江省');

-- ----------------------------
-- Table structure for missing_pets
-- ----------------------------
DROP TABLE IF EXISTS `missing_pets`;
CREATE TABLE `missing_pets`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '发布用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `pet_name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '宠物名称',
  `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '宠物类型（狗/猫/其他）',
  `gender` tinyint(1) NULL DEFAULT NULL COMMENT '性别：1雄/0雌/NULL未知',
  `age` float NULL DEFAULT NULL,
  `lost_time` datetime NULL DEFAULT NULL COMMENT '走失时间',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '走失城市',
  `province_id` int NULL DEFAULT NULL,
  `lost_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '走失详细地址',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '特征描述/备注',
  `contact_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `reward` float NULL DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片URL或资源ID',
  `status` enum('ACTIVE','FOUND','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_missing_pets_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_missing_pets_status`(`status` ASC) USING BTREE,
  INDEX `idx_missing_pets_city_status`(`city` ASC, `status` ASC) USING BTREE,
  INDEX `idx_missing_pets_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_missing_pets_lost_time`(`lost_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '寻宠信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of missing_pets
-- ----------------------------
INSERT INTO `missing_pets` VALUES (1, 1, '寻找我的小花', '小花', '猫', 0, 2, '2025-06-24 00:00:00', '丹东市', NULL, '朝阳区望京SOHO', '一只2岁的橘色花猫。性格温顺，左耳有个小缺口，走失时戴着粉色项圈', '李小姐', '13845455670', 1000, 'app.media.lhmsdf', 'ACTIVE', '2025-08-26 17:49:09', '2025-08-29 20:57:38');
INSERT INTO `missing_pets` VALUES (2, 1, '急寻金毛犬多多', '多多', '狗', 1, 3, '2024-01-16 09:15:00', '上海市', NULL, '浦东新区陆家嘴公园', '3岁金毛犬，体型较大，很亲人，走失时戴蓝色牵引绳，请好心人帮忙寻找', '王先生', '15949341234', 2000, 'app.media.dfghidg', 'ACTIVE', '2025-08-26 17:49:09', '2025-08-27 16:00:23');
INSERT INTO `missing_pets` VALUES (3, 3, '寻找小泰迪豆豆', '豆豆', '狗', 0, 1, '2024-01-17 16:20:00', '固原市', NULL, '天河区天河公园南门', '1岁棕色泰迪，很小只，胆子小怕生人，可能躲在角落，麻烦大家帮忙留意', '陈女士', '18793459876', 1500, 'app.media.xjzxmm', 'ACTIVE', '2025-08-26 17:49:09', '2025-08-29 19:51:32');
INSERT INTO `missing_pets` VALUES (4, 4, '寻找走失的布偶猫', '雪球', '猫', 0, 4, '2024-01-18 11:45:00', '上海市', NULL, '南山区科技园地铁站C出口', '4岁布偶猫，蓝眼睛，毛色很漂亮，性格温顺，不怕人，请看到的朋友联系我', '张先生', '13645234321', 3000, 'app.media.ilsdnvldfg', 'ACTIVE', '2025-08-26 17:49:09', '2025-08-29 19:44:36');

-- ----------------------------
-- Table structure for province_city
-- ----------------------------
DROP TABLE IF EXISTS `province_city`;
CREATE TABLE `province_city`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 303 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of province_city
-- ----------------------------
INSERT INTO `province_city` VALUES (1, '上海市', '上海市');
INSERT INTO `province_city` VALUES (2, '云南省', '临沧市');
INSERT INTO `province_city` VALUES (3, '云南省', '丽江市');
INSERT INTO `province_city` VALUES (4, '云南省', '保山市');
INSERT INTO `province_city` VALUES (5, '云南省', '昆明市');
INSERT INTO `province_city` VALUES (6, '云南省', '昭通市');
INSERT INTO `province_city` VALUES (7, '云南省', '普洱市');
INSERT INTO `province_city` VALUES (8, '云南省', '曲靖市');
INSERT INTO `province_city` VALUES (9, '云南省', '玉溪市');
INSERT INTO `province_city` VALUES (10, '内蒙古自治区', '乌兰察布市');
INSERT INTO `province_city` VALUES (11, '内蒙古自治区', '乌海市');
INSERT INTO `province_city` VALUES (12, '内蒙古自治区', '包头市');
INSERT INTO `province_city` VALUES (13, '内蒙古自治区', '呼伦贝尔市');
INSERT INTO `province_city` VALUES (14, '内蒙古自治区', '呼和浩特市');
INSERT INTO `province_city` VALUES (15, '内蒙古自治区', '巴彦淖尔市');
INSERT INTO `province_city` VALUES (16, '内蒙古自治区', '赤峰市');
INSERT INTO `province_city` VALUES (17, '内蒙古自治区', '通辽市');
INSERT INTO `province_city` VALUES (18, '内蒙古自治区', '鄂尔多斯市');
INSERT INTO `province_city` VALUES (19, '北京市', '北京市');
INSERT INTO `province_city` VALUES (20, '吉林省', '吉林市');
INSERT INTO `province_city` VALUES (21, '吉林省', '四平市');
INSERT INTO `province_city` VALUES (22, '吉林省', '松原市');
INSERT INTO `province_city` VALUES (23, '吉林省', '白城市');
INSERT INTO `province_city` VALUES (24, '吉林省', '白山市');
INSERT INTO `province_city` VALUES (25, '吉林省', '辽源市');
INSERT INTO `province_city` VALUES (26, '吉林省', '通化市');
INSERT INTO `province_city` VALUES (27, '吉林省', '长春市');
INSERT INTO `province_city` VALUES (28, '四川省', '乐山市');
INSERT INTO `province_city` VALUES (29, '四川省', '内江市');
INSERT INTO `province_city` VALUES (30, '四川省', '南充市');
INSERT INTO `province_city` VALUES (31, '四川省', '宜宾市');
INSERT INTO `province_city` VALUES (32, '四川省', '巴中市');
INSERT INTO `province_city` VALUES (33, '四川省', '广元市');
INSERT INTO `province_city` VALUES (34, '四川省', '广安市');
INSERT INTO `province_city` VALUES (35, '四川省', '德阳市');
INSERT INTO `province_city` VALUES (36, '四川省', '成都市');
INSERT INTO `province_city` VALUES (37, '四川省', '攀枝花市');
INSERT INTO `province_city` VALUES (38, '四川省', '泸州市');
INSERT INTO `province_city` VALUES (39, '四川省', '眉山市');
INSERT INTO `province_city` VALUES (40, '四川省', '绵阳市');
INSERT INTO `province_city` VALUES (41, '四川省', '自贡市');
INSERT INTO `province_city` VALUES (42, '四川省', '资阳市');
INSERT INTO `province_city` VALUES (43, '四川省', '达州市');
INSERT INTO `province_city` VALUES (44, '四川省', '遂宁市');
INSERT INTO `province_city` VALUES (45, '四川省', '雅安市');
INSERT INTO `province_city` VALUES (46, '天津市', '天津市');
INSERT INTO `province_city` VALUES (47, '宁夏回族自治区', '中卫市');
INSERT INTO `province_city` VALUES (48, '宁夏回族自治区', '吴忠市');
INSERT INTO `province_city` VALUES (49, '宁夏回族自治区', '固原市');
INSERT INTO `province_city` VALUES (50, '宁夏回族自治区', '石嘴山市');
INSERT INTO `province_city` VALUES (51, '宁夏回族自治区', '银川市');
INSERT INTO `province_city` VALUES (52, '安徽省', '亳州市');
INSERT INTO `province_city` VALUES (53, '安徽省', '六安市');
INSERT INTO `province_city` VALUES (54, '安徽省', '合肥市');
INSERT INTO `province_city` VALUES (55, '安徽省', '安庆市');
INSERT INTO `province_city` VALUES (56, '安徽省', '宣城市');
INSERT INTO `province_city` VALUES (57, '安徽省', '宿州市');
INSERT INTO `province_city` VALUES (58, '安徽省', '池州市');
INSERT INTO `province_city` VALUES (59, '安徽省', '淮北市');
INSERT INTO `province_city` VALUES (60, '安徽省', '淮南市');
INSERT INTO `province_city` VALUES (61, '安徽省', '滁州市');
INSERT INTO `province_city` VALUES (62, '安徽省', '芜湖市');
INSERT INTO `province_city` VALUES (63, '安徽省', '蚌埠市');
INSERT INTO `province_city` VALUES (64, '安徽省', '铜陵市');
INSERT INTO `province_city` VALUES (65, '安徽省', '阜阳市');
INSERT INTO `province_city` VALUES (66, '安徽省', '马鞍山市');
INSERT INTO `province_city` VALUES (67, '安徽省', '黄山市');
INSERT INTO `province_city` VALUES (68, '山东省', '东营市');
INSERT INTO `province_city` VALUES (69, '山东省', '临沂市');
INSERT INTO `province_city` VALUES (70, '山东省', '威海市');
INSERT INTO `province_city` VALUES (71, '山东省', '德州市');
INSERT INTO `province_city` VALUES (72, '山东省', '日照市');
INSERT INTO `province_city` VALUES (73, '山东省', '枣庄市');
INSERT INTO `province_city` VALUES (74, '山东省', '泰安市');
INSERT INTO `province_city` VALUES (75, '山东省', '济南市');
INSERT INTO `province_city` VALUES (76, '山东省', '济宁市');
INSERT INTO `province_city` VALUES (77, '山东省', '淄博市');
INSERT INTO `province_city` VALUES (78, '山东省', '滨州市');
INSERT INTO `province_city` VALUES (79, '山东省', '潍坊市');
INSERT INTO `province_city` VALUES (80, '山东省', '烟台市');
INSERT INTO `province_city` VALUES (81, '山东省', '聊城市');
INSERT INTO `province_city` VALUES (82, '山东省', '菏泽市');
INSERT INTO `province_city` VALUES (83, '山东省', '青岛市');
INSERT INTO `province_city` VALUES (84, '山西省', '临汾市');
INSERT INTO `province_city` VALUES (85, '山西省', '吕梁市');
INSERT INTO `province_city` VALUES (86, '山西省', '大同市');
INSERT INTO `province_city` VALUES (87, '山西省', '太原市');
INSERT INTO `province_city` VALUES (88, '山西省', '忻州市');
INSERT INTO `province_city` VALUES (89, '山西省', '晋中市');
INSERT INTO `province_city` VALUES (90, '山西省', '晋城市');
INSERT INTO `province_city` VALUES (91, '山西省', '朔州市');
INSERT INTO `province_city` VALUES (92, '山西省', '运城市');
INSERT INTO `province_city` VALUES (93, '山西省', '长治市');
INSERT INTO `province_city` VALUES (94, '山西省', '阳泉市');
INSERT INTO `province_city` VALUES (95, '广东省', '东莞市');
INSERT INTO `province_city` VALUES (96, '广东省', '中山市');
INSERT INTO `province_city` VALUES (97, '广东省', '云浮市');
INSERT INTO `province_city` VALUES (98, '广东省', '佛山市');
INSERT INTO `province_city` VALUES (99, '广东省', '广州市');
INSERT INTO `province_city` VALUES (100, '广东省', '惠州市');
INSERT INTO `province_city` VALUES (101, '广东省', '揭阳市');
INSERT INTO `province_city` VALUES (102, '广东省', '梅州市');
INSERT INTO `province_city` VALUES (103, '广东省', '汕头市');
INSERT INTO `province_city` VALUES (104, '广东省', '汕尾市');
INSERT INTO `province_city` VALUES (105, '广东省', '江门市');
INSERT INTO `province_city` VALUES (106, '广东省', '河源市');
INSERT INTO `province_city` VALUES (107, '广东省', '深圳市');
INSERT INTO `province_city` VALUES (108, '广东省', '清远市');
INSERT INTO `province_city` VALUES (109, '广东省', '湛江市');
INSERT INTO `province_city` VALUES (110, '广东省', '潮州市');
INSERT INTO `province_city` VALUES (111, '广东省', '珠海市');
INSERT INTO `province_city` VALUES (112, '广东省', '肇庆市');
INSERT INTO `province_city` VALUES (113, '广东省', '茂名市');
INSERT INTO `province_city` VALUES (114, '广东省', '阳江市');
INSERT INTO `province_city` VALUES (115, '广东省', '韶关市');
INSERT INTO `province_city` VALUES (116, '广西壮族自治区', '北海市');
INSERT INTO `province_city` VALUES (117, '广西壮族自治区', '南宁市');
INSERT INTO `province_city` VALUES (118, '广西壮族自治区', '崇左市');
INSERT INTO `province_city` VALUES (119, '广西壮族自治区', '来宾市');
INSERT INTO `province_city` VALUES (120, '广西壮族自治区', '柳州市');
INSERT INTO `province_city` VALUES (121, '广西壮族自治区', '桂林市');
INSERT INTO `province_city` VALUES (122, '广西壮族自治区', '梧州市');
INSERT INTO `province_city` VALUES (123, '广西壮族自治区', '河池市');
INSERT INTO `province_city` VALUES (124, '广西壮族自治区', '玉林市');
INSERT INTO `province_city` VALUES (125, '广西壮族自治区', '百色市');
INSERT INTO `province_city` VALUES (126, '广西壮族自治区', '贵港市');
INSERT INTO `province_city` VALUES (127, '广西壮族自治区', '贺州市');
INSERT INTO `province_city` VALUES (128, '广西壮族自治区', '钦州市');
INSERT INTO `province_city` VALUES (129, '广西壮族自治区', '防城港市');
INSERT INTO `province_city` VALUES (130, '新疆维吾尔自治区', '乌鲁木齐市');
INSERT INTO `province_city` VALUES (131, '新疆维吾尔自治区', '克拉玛依市');
INSERT INTO `province_city` VALUES (132, '新疆维吾尔自治区', '吐鲁番市');
INSERT INTO `province_city` VALUES (133, '新疆维吾尔自治区', '哈密市');
INSERT INTO `province_city` VALUES (134, '江苏省', '南京市');
INSERT INTO `province_city` VALUES (135, '江苏省', '南通市');
INSERT INTO `province_city` VALUES (136, '江苏省', '宿迁市');
INSERT INTO `province_city` VALUES (137, '江苏省', '常州市');
INSERT INTO `province_city` VALUES (138, '江苏省', '徐州市');
INSERT INTO `province_city` VALUES (139, '江苏省', '扬州市');
INSERT INTO `province_city` VALUES (140, '江苏省', '无锡市');
INSERT INTO `province_city` VALUES (141, '江苏省', '泰州市');
INSERT INTO `province_city` VALUES (142, '江苏省', '淮安市');
INSERT INTO `province_city` VALUES (143, '江苏省', '盐城市');
INSERT INTO `province_city` VALUES (144, '江苏省', '苏州市');
INSERT INTO `province_city` VALUES (145, '江苏省', '连云港市');
INSERT INTO `province_city` VALUES (146, '江苏省', '镇江市');
INSERT INTO `province_city` VALUES (147, '江西省', '上饶市');
INSERT INTO `province_city` VALUES (148, '江西省', '九江市');
INSERT INTO `province_city` VALUES (149, '江西省', '南昌市');
INSERT INTO `province_city` VALUES (150, '江西省', '吉安市');
INSERT INTO `province_city` VALUES (151, '江西省', '宜春市');
INSERT INTO `province_city` VALUES (152, '江西省', '抚州市');
INSERT INTO `province_city` VALUES (153, '江西省', '新余市');
INSERT INTO `province_city` VALUES (154, '江西省', '景德镇市');
INSERT INTO `province_city` VALUES (155, '江西省', '萍乡市');
INSERT INTO `province_city` VALUES (156, '江西省', '赣州市');
INSERT INTO `province_city` VALUES (157, '江西省', '鹰潭市');
INSERT INTO `province_city` VALUES (158, '河北省', '保定市');
INSERT INTO `province_city` VALUES (159, '河北省', '唐山市');
INSERT INTO `province_city` VALUES (160, '河北省', '廊坊市');
INSERT INTO `province_city` VALUES (161, '河北省', '张家口市');
INSERT INTO `province_city` VALUES (162, '河北省', '承德市');
INSERT INTO `province_city` VALUES (163, '河北省', '沧州市');
INSERT INTO `province_city` VALUES (164, '河北省', '石家庄市');
INSERT INTO `province_city` VALUES (165, '河北省', '秦皇岛市');
INSERT INTO `province_city` VALUES (166, '河北省', '衡水市');
INSERT INTO `province_city` VALUES (167, '河北省', '邢台市');
INSERT INTO `province_city` VALUES (168, '河北省', '邯郸市');
INSERT INTO `province_city` VALUES (169, '河南省', '三门峡市');
INSERT INTO `province_city` VALUES (170, '河南省', '信阳市');
INSERT INTO `province_city` VALUES (171, '河南省', '南阳市');
INSERT INTO `province_city` VALUES (172, '河南省', '周口市');
INSERT INTO `province_city` VALUES (173, '河南省', '商丘市');
INSERT INTO `province_city` VALUES (174, '河南省', '安阳市');
INSERT INTO `province_city` VALUES (175, '河南省', '平顶山市');
INSERT INTO `province_city` VALUES (176, '河南省', '开封市');
INSERT INTO `province_city` VALUES (177, '河南省', '新乡市');
INSERT INTO `province_city` VALUES (178, '河南省', '洛阳市');
INSERT INTO `province_city` VALUES (179, '河南省', '漯河市');
INSERT INTO `province_city` VALUES (180, '河南省', '濮阳市');
INSERT INTO `province_city` VALUES (181, '河南省', '焦作市');
INSERT INTO `province_city` VALUES (182, '河南省', '许昌市');
INSERT INTO `province_city` VALUES (183, '河南省', '郑州市');
INSERT INTO `province_city` VALUES (184, '河南省', '驻马店市');
INSERT INTO `province_city` VALUES (185, '河南省', '鹤壁市');
INSERT INTO `province_city` VALUES (186, '浙江省', '丽水市');
INSERT INTO `province_city` VALUES (187, '浙江省', '台州市');
INSERT INTO `province_city` VALUES (188, '浙江省', '嘉兴市');
INSERT INTO `province_city` VALUES (189, '浙江省', '宁波市');
INSERT INTO `province_city` VALUES (190, '浙江省', '杭州市');
INSERT INTO `province_city` VALUES (191, '浙江省', '温州市');
INSERT INTO `province_city` VALUES (192, '浙江省', '湖州市');
INSERT INTO `province_city` VALUES (193, '浙江省', '绍兴市');
INSERT INTO `province_city` VALUES (194, '浙江省', '舟山市');
INSERT INTO `province_city` VALUES (195, '浙江省', '衢州市');
INSERT INTO `province_city` VALUES (196, '浙江省', '金华市');
INSERT INTO `province_city` VALUES (197, '海南省', '三亚市');
INSERT INTO `province_city` VALUES (198, '海南省', '三沙市');
INSERT INTO `province_city` VALUES (199, '海南省', '儋州市');
INSERT INTO `province_city` VALUES (200, '海南省', '海口市');
INSERT INTO `province_city` VALUES (201, '湖北省', '十堰市');
INSERT INTO `province_city` VALUES (202, '湖北省', '咸宁市');
INSERT INTO `province_city` VALUES (203, '湖北省', '孝感市');
INSERT INTO `province_city` VALUES (204, '湖北省', '宜昌市');
INSERT INTO `province_city` VALUES (205, '湖北省', '武汉市');
INSERT INTO `province_city` VALUES (206, '湖北省', '荆州市');
INSERT INTO `province_city` VALUES (207, '湖北省', '荆门市');
INSERT INTO `province_city` VALUES (208, '湖北省', '襄阳市');
INSERT INTO `province_city` VALUES (209, '湖北省', '鄂州市');
INSERT INTO `province_city` VALUES (210, '湖北省', '随州市');
INSERT INTO `province_city` VALUES (211, '湖北省', '黄冈市');
INSERT INTO `province_city` VALUES (212, '湖北省', '黄石市');
INSERT INTO `province_city` VALUES (213, '湖南省', '娄底市');
INSERT INTO `province_city` VALUES (214, '湖南省', '岳阳市');
INSERT INTO `province_city` VALUES (215, '湖南省', '常德市');
INSERT INTO `province_city` VALUES (216, '湖南省', '张家界市');
INSERT INTO `province_city` VALUES (217, '湖南省', '怀化市');
INSERT INTO `province_city` VALUES (218, '湖南省', '株洲市');
INSERT INTO `province_city` VALUES (219, '湖南省', '永州市');
INSERT INTO `province_city` VALUES (220, '湖南省', '湘潭市');
INSERT INTO `province_city` VALUES (221, '湖南省', '益阳市');
INSERT INTO `province_city` VALUES (222, '湖南省', '衡阳市');
INSERT INTO `province_city` VALUES (223, '湖南省', '邵阳市');
INSERT INTO `province_city` VALUES (224, '湖南省', '郴州市');
INSERT INTO `province_city` VALUES (225, '湖南省', '长沙市');
INSERT INTO `province_city` VALUES (226, '甘肃省', '兰州市');
INSERT INTO `province_city` VALUES (227, '甘肃省', '嘉峪关市');
INSERT INTO `province_city` VALUES (228, '甘肃省', '天水市');
INSERT INTO `province_city` VALUES (229, '甘肃省', '定西市');
INSERT INTO `province_city` VALUES (230, '甘肃省', '平凉市');
INSERT INTO `province_city` VALUES (231, '甘肃省', '庆阳市');
INSERT INTO `province_city` VALUES (232, '甘肃省', '张掖市');
INSERT INTO `province_city` VALUES (233, '甘肃省', '武威市');
INSERT INTO `province_city` VALUES (234, '甘肃省', '白银市');
INSERT INTO `province_city` VALUES (235, '甘肃省', '酒泉市');
INSERT INTO `province_city` VALUES (236, '甘肃省', '金昌市');
INSERT INTO `province_city` VALUES (237, '甘肃省', '陇南市');
INSERT INTO `province_city` VALUES (238, '福建省', '三明市');
INSERT INTO `province_city` VALUES (239, '福建省', '南平市');
INSERT INTO `province_city` VALUES (240, '福建省', '厦门市');
INSERT INTO `province_city` VALUES (241, '福建省', '宁德市');
INSERT INTO `province_city` VALUES (242, '福建省', '泉州市');
INSERT INTO `province_city` VALUES (243, '福建省', '漳州市');
INSERT INTO `province_city` VALUES (244, '福建省', '福州市');
INSERT INTO `province_city` VALUES (245, '福建省', '莆田市');
INSERT INTO `province_city` VALUES (246, '福建省', '龙岩市');
INSERT INTO `province_city` VALUES (247, '西藏自治区', '山南市');
INSERT INTO `province_city` VALUES (248, '西藏自治区', '拉萨市');
INSERT INTO `province_city` VALUES (249, '西藏自治区', '日喀则市');
INSERT INTO `province_city` VALUES (250, '西藏自治区', '昌都市');
INSERT INTO `province_city` VALUES (251, '西藏自治区', '林芝市');
INSERT INTO `province_city` VALUES (252, '西藏自治区', '那曲市');
INSERT INTO `province_city` VALUES (253, '贵州省', '六盘水市');
INSERT INTO `province_city` VALUES (254, '贵州省', '安顺市');
INSERT INTO `province_city` VALUES (255, '贵州省', '毕节市');
INSERT INTO `province_city` VALUES (256, '贵州省', '贵阳市');
INSERT INTO `province_city` VALUES (257, '贵州省', '遵义市');
INSERT INTO `province_city` VALUES (258, '贵州省', '铜仁市');
INSERT INTO `province_city` VALUES (259, '辽宁省', '丹东市');
INSERT INTO `province_city` VALUES (260, '辽宁省', '大连市');
INSERT INTO `province_city` VALUES (261, '辽宁省', '抚顺市');
INSERT INTO `province_city` VALUES (262, '辽宁省', '朝阳市');
INSERT INTO `province_city` VALUES (263, '辽宁省', '本溪市');
INSERT INTO `province_city` VALUES (264, '辽宁省', '沈阳市');
INSERT INTO `province_city` VALUES (265, '辽宁省', '盘锦市');
INSERT INTO `province_city` VALUES (266, '辽宁省', '营口市');
INSERT INTO `province_city` VALUES (267, '辽宁省', '葫芦岛市');
INSERT INTO `province_city` VALUES (268, '辽宁省', '辽阳市');
INSERT INTO `province_city` VALUES (269, '辽宁省', '铁岭市');
INSERT INTO `province_city` VALUES (270, '辽宁省', '锦州市');
INSERT INTO `province_city` VALUES (271, '辽宁省', '阜新市');
INSERT INTO `province_city` VALUES (272, '辽宁省', '鞍山市');
INSERT INTO `province_city` VALUES (273, '重庆市', '重庆市');
INSERT INTO `province_city` VALUES (274, '陕西省', '咸阳市');
INSERT INTO `province_city` VALUES (275, '陕西省', '商洛市');
INSERT INTO `province_city` VALUES (276, '陕西省', '安康市');
INSERT INTO `province_city` VALUES (277, '陕西省', '宝鸡市');
INSERT INTO `province_city` VALUES (278, '陕西省', '延安市');
INSERT INTO `province_city` VALUES (279, '陕西省', '榆林市');
INSERT INTO `province_city` VALUES (280, '陕西省', '汉中市');
INSERT INTO `province_city` VALUES (281, '陕西省', '渭南市');
INSERT INTO `province_city` VALUES (282, '陕西省', '西安市');
INSERT INTO `province_city` VALUES (283, '陕西省', '铜川市');
INSERT INTO `province_city` VALUES (284, '青海省', '果洛藏族自治州');
INSERT INTO `province_city` VALUES (285, '青海省', '海东市');
INSERT INTO `province_city` VALUES (286, '青海省', '海北藏族自治州');
INSERT INTO `province_city` VALUES (287, '青海省', '海南藏族自治州');
INSERT INTO `province_city` VALUES (288, '青海省', '海西蒙古族藏族自治州');
INSERT INTO `province_city` VALUES (289, '青海省', '玉树藏族自治州');
INSERT INTO `province_city` VALUES (290, '青海省', '西宁市');
INSERT INTO `province_city` VALUES (291, '青海省', '黄南藏族自治州');
INSERT INTO `province_city` VALUES (292, '黑龙江省', '七台河市');
INSERT INTO `province_city` VALUES (293, '黑龙江省', '伊春市');
INSERT INTO `province_city` VALUES (294, '黑龙江省', '佳木斯市');
INSERT INTO `province_city` VALUES (295, '黑龙江省', '双鸭山市');
INSERT INTO `province_city` VALUES (296, '黑龙江省', '哈尔滨市');
INSERT INTO `province_city` VALUES (297, '黑龙江省', '大庆市');
INSERT INTO `province_city` VALUES (298, '黑龙江省', '牡丹江市');
INSERT INTO `province_city` VALUES (299, '黑龙江省', '绥化市');
INSERT INTO `province_city` VALUES (300, '黑龙江省', '鸡西市');
INSERT INTO `province_city` VALUES (301, '黑龙江省', '鹤岗市');
INSERT INTO `province_city` VALUES (302, '黑龙江省', '黑河市');
INSERT INTO `province_city` VALUES (303, '黑龙江省', '齐齐哈尔市');

-- ----------------------------
-- Table structure for provinces
-- ----------------------------
DROP TABLE IF EXISTS `provinces`;
CREATE TABLE `provinces`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 58 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of provinces
-- ----------------------------
INSERT INTO `provinces` VALUES (32, '云南省');
INSERT INTO `provinces` VALUES (33, '内蒙古自治区');
INSERT INTO `provinces` VALUES (34, '吉林省');
INSERT INTO `provinces` VALUES (35, '四川省');
INSERT INTO `provinces` VALUES (36, '宁夏回族自治区');
INSERT INTO `provinces` VALUES (37, '安徽省');
INSERT INTO `provinces` VALUES (38, '山东省');
INSERT INTO `provinces` VALUES (39, '山西省');
INSERT INTO `provinces` VALUES (40, '广东省');
INSERT INTO `provinces` VALUES (41, '广西壮族自治区');
INSERT INTO `provinces` VALUES (42, '新疆维吾尔自治区');
INSERT INTO `provinces` VALUES (43, '江苏省');
INSERT INTO `provinces` VALUES (44, '江西省');
INSERT INTO `provinces` VALUES (45, '河北省');
INSERT INTO `provinces` VALUES (46, '河南省');
INSERT INTO `provinces` VALUES (47, '浙江省');
INSERT INTO `provinces` VALUES (48, '海南省');
INSERT INTO `provinces` VALUES (49, '湖北省');
INSERT INTO `provinces` VALUES (50, '湖南省');
INSERT INTO `provinces` VALUES (51, '甘肃省');
INSERT INTO `provinces` VALUES (52, '福建省');
INSERT INTO `provinces` VALUES (53, '西藏自治区');
INSERT INTO `provinces` VALUES (54, '贵州省');
INSERT INTO `provinces` VALUES (55, '辽宁省');
INSERT INTO `provinces` VALUES (56, '陕西省');
INSERT INTO `provinces` VALUES (57, '青海省');
INSERT INTO `provinces` VALUES (58, '黑龙江省');

-- ----------------------------
-- Table structure for provinces_cities
-- ----------------------------
DROP TABLE IF EXISTS `provinces_cities`;
CREATE TABLE `provinces_cities`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of provinces_cities
-- ----------------------------
INSERT INTO `provinces_cities` VALUES (1, '临沧市');
INSERT INTO `provinces_cities` VALUES (2, '丽江市');
INSERT INTO `provinces_cities` VALUES (3, '保山市');
INSERT INTO `provinces_cities` VALUES (4, '昆明市');
INSERT INTO `provinces_cities` VALUES (5, '昭通市');
INSERT INTO `provinces_cities` VALUES (6, '普洱市');
INSERT INTO `provinces_cities` VALUES (7, '曲靖市');
INSERT INTO `provinces_cities` VALUES (8, '玉溪市');
INSERT INTO `provinces_cities` VALUES (9, '乌兰察布市');
INSERT INTO `provinces_cities` VALUES (10, '乌海市');
INSERT INTO `provinces_cities` VALUES (11, '包头市');
INSERT INTO `provinces_cities` VALUES (12, '呼伦贝尔市');
INSERT INTO `provinces_cities` VALUES (13, '呼和浩特市');
INSERT INTO `provinces_cities` VALUES (14, '巴彦淖尔市');
INSERT INTO `provinces_cities` VALUES (15, '赤峰市');
INSERT INTO `provinces_cities` VALUES (16, '通辽市');
INSERT INTO `provinces_cities` VALUES (17, '鄂尔多斯市');
INSERT INTO `provinces_cities` VALUES (18, '吉林市');
INSERT INTO `provinces_cities` VALUES (19, '四平市');
INSERT INTO `provinces_cities` VALUES (20, '松原市');
INSERT INTO `provinces_cities` VALUES (21, '白城市');
INSERT INTO `provinces_cities` VALUES (22, '白山市');
INSERT INTO `provinces_cities` VALUES (23, '辽源市');
INSERT INTO `provinces_cities` VALUES (24, '通化市');
INSERT INTO `provinces_cities` VALUES (25, '长春市');
INSERT INTO `provinces_cities` VALUES (26, '乐山市');
INSERT INTO `provinces_cities` VALUES (27, '内江市');
INSERT INTO `provinces_cities` VALUES (28, '南充市');
INSERT INTO `provinces_cities` VALUES (29, '宜宾市');
INSERT INTO `provinces_cities` VALUES (30, '巴中市');
INSERT INTO `provinces_cities` VALUES (31, '广元市');
INSERT INTO `provinces_cities` VALUES (32, '广安市');
INSERT INTO `provinces_cities` VALUES (33, '德阳市');
INSERT INTO `provinces_cities` VALUES (34, '成都市');
INSERT INTO `provinces_cities` VALUES (35, '攀枝花市');
INSERT INTO `provinces_cities` VALUES (36, '泸州市');
INSERT INTO `provinces_cities` VALUES (37, '眉山市');
INSERT INTO `provinces_cities` VALUES (38, '绵阳市');
INSERT INTO `provinces_cities` VALUES (39, '自贡市');
INSERT INTO `provinces_cities` VALUES (40, '资阳市');
INSERT INTO `provinces_cities` VALUES (41, '达州市');
INSERT INTO `provinces_cities` VALUES (42, '遂宁市');
INSERT INTO `provinces_cities` VALUES (43, '雅安市');
INSERT INTO `provinces_cities` VALUES (44, '中卫市');
INSERT INTO `provinces_cities` VALUES (45, '吴忠市');
INSERT INTO `provinces_cities` VALUES (46, '固原市');
INSERT INTO `provinces_cities` VALUES (47, '石嘴山市');
INSERT INTO `provinces_cities` VALUES (48, '银川市');
INSERT INTO `provinces_cities` VALUES (49, '亳州市');
INSERT INTO `provinces_cities` VALUES (50, '六安市');
INSERT INTO `provinces_cities` VALUES (51, '合肥市');
INSERT INTO `provinces_cities` VALUES (52, '安庆市');
INSERT INTO `provinces_cities` VALUES (53, '宣城市');
INSERT INTO `provinces_cities` VALUES (54, '宿州市');
INSERT INTO `provinces_cities` VALUES (55, '池州市');
INSERT INTO `provinces_cities` VALUES (56, '淮北市');
INSERT INTO `provinces_cities` VALUES (57, '淮南市');
INSERT INTO `provinces_cities` VALUES (58, '滁州市');
INSERT INTO `provinces_cities` VALUES (59, '芜湖市');
INSERT INTO `provinces_cities` VALUES (60, '蚌埠市');
INSERT INTO `provinces_cities` VALUES (61, '铜陵市');
INSERT INTO `provinces_cities` VALUES (62, '阜阳市');
INSERT INTO `provinces_cities` VALUES (63, '马鞍山市');
INSERT INTO `provinces_cities` VALUES (64, '黄山市');
INSERT INTO `provinces_cities` VALUES (65, '东营市');
INSERT INTO `provinces_cities` VALUES (66, '临沂市');
INSERT INTO `provinces_cities` VALUES (67, '威海市');
INSERT INTO `provinces_cities` VALUES (68, '德州市');
INSERT INTO `provinces_cities` VALUES (69, '日照市');
INSERT INTO `provinces_cities` VALUES (70, '枣庄市');
INSERT INTO `provinces_cities` VALUES (71, '泰安市');
INSERT INTO `provinces_cities` VALUES (72, '济南市');
INSERT INTO `provinces_cities` VALUES (73, '济宁市');
INSERT INTO `provinces_cities` VALUES (74, '淄博市');
INSERT INTO `provinces_cities` VALUES (75, '滨州市');
INSERT INTO `provinces_cities` VALUES (76, '潍坊市');
INSERT INTO `provinces_cities` VALUES (77, '烟台市');
INSERT INTO `provinces_cities` VALUES (78, '聊城市');
INSERT INTO `provinces_cities` VALUES (79, '菏泽市');
INSERT INTO `provinces_cities` VALUES (80, '青岛市');
INSERT INTO `provinces_cities` VALUES (81, '临汾市');
INSERT INTO `provinces_cities` VALUES (82, '吕梁市');
INSERT INTO `provinces_cities` VALUES (83, '大同市');
INSERT INTO `provinces_cities` VALUES (84, '太原市');
INSERT INTO `provinces_cities` VALUES (85, '忻州市');
INSERT INTO `provinces_cities` VALUES (86, '晋中市');
INSERT INTO `provinces_cities` VALUES (87, '晋城市');
INSERT INTO `provinces_cities` VALUES (88, '朔州市');
INSERT INTO `provinces_cities` VALUES (89, '运城市');
INSERT INTO `provinces_cities` VALUES (90, '长治市');
INSERT INTO `provinces_cities` VALUES (91, '阳泉市');
INSERT INTO `provinces_cities` VALUES (92, '东莞市');
INSERT INTO `provinces_cities` VALUES (93, '中山市');
INSERT INTO `provinces_cities` VALUES (94, '云浮市');
INSERT INTO `provinces_cities` VALUES (95, '佛山市');
INSERT INTO `provinces_cities` VALUES (96, '广州市');
INSERT INTO `provinces_cities` VALUES (97, '惠州市');
INSERT INTO `provinces_cities` VALUES (98, '揭阳市');
INSERT INTO `provinces_cities` VALUES (99, '梅州市');
INSERT INTO `provinces_cities` VALUES (100, '汕头市');
INSERT INTO `provinces_cities` VALUES (101, '汕尾市');
INSERT INTO `provinces_cities` VALUES (102, '江门市');
INSERT INTO `provinces_cities` VALUES (103, '河源市');
INSERT INTO `provinces_cities` VALUES (104, '深圳市');
INSERT INTO `provinces_cities` VALUES (105, '清远市');
INSERT INTO `provinces_cities` VALUES (106, '湛江市');
INSERT INTO `provinces_cities` VALUES (107, '潮州市');
INSERT INTO `provinces_cities` VALUES (108, '珠海市');
INSERT INTO `provinces_cities` VALUES (109, '肇庆市');
INSERT INTO `provinces_cities` VALUES (110, '茂名市');
INSERT INTO `provinces_cities` VALUES (111, '阳江市');
INSERT INTO `provinces_cities` VALUES (112, '韶关市');
INSERT INTO `provinces_cities` VALUES (113, '北海市');
INSERT INTO `provinces_cities` VALUES (114, '南宁市');
INSERT INTO `provinces_cities` VALUES (115, '崇左市');
INSERT INTO `provinces_cities` VALUES (116, '来宾市');
INSERT INTO `provinces_cities` VALUES (117, '柳州市');
INSERT INTO `provinces_cities` VALUES (118, '桂林市');
INSERT INTO `provinces_cities` VALUES (119, '梧州市');
INSERT INTO `provinces_cities` VALUES (120, '河池市');
INSERT INTO `provinces_cities` VALUES (121, '玉林市');
INSERT INTO `provinces_cities` VALUES (122, '百色市');
INSERT INTO `provinces_cities` VALUES (123, '贵港市');
INSERT INTO `provinces_cities` VALUES (124, '贺州市');
INSERT INTO `provinces_cities` VALUES (125, '钦州市');
INSERT INTO `provinces_cities` VALUES (126, '防城港市');
INSERT INTO `provinces_cities` VALUES (127, '乌鲁木齐市');
INSERT INTO `provinces_cities` VALUES (128, '克拉玛依市');
INSERT INTO `provinces_cities` VALUES (129, '吐鲁番市');
INSERT INTO `provinces_cities` VALUES (130, '哈密市');
INSERT INTO `provinces_cities` VALUES (131, '南京市');
INSERT INTO `provinces_cities` VALUES (132, '南通市');
INSERT INTO `provinces_cities` VALUES (133, '宿迁市');
INSERT INTO `provinces_cities` VALUES (134, '常州市');
INSERT INTO `provinces_cities` VALUES (135, '徐州市');
INSERT INTO `provinces_cities` VALUES (136, '扬州市');
INSERT INTO `provinces_cities` VALUES (137, '无锡市');
INSERT INTO `provinces_cities` VALUES (138, '泰州市');
INSERT INTO `provinces_cities` VALUES (139, '淮安市');
INSERT INTO `provinces_cities` VALUES (140, '盐城市');
INSERT INTO `provinces_cities` VALUES (141, '苏州市');
INSERT INTO `provinces_cities` VALUES (142, '连云港市');
INSERT INTO `provinces_cities` VALUES (143, '镇江市');
INSERT INTO `provinces_cities` VALUES (144, '上饶市');
INSERT INTO `provinces_cities` VALUES (145, '九江市');
INSERT INTO `provinces_cities` VALUES (146, '南昌市');
INSERT INTO `provinces_cities` VALUES (147, '吉安市');
INSERT INTO `provinces_cities` VALUES (148, '宜春市');
INSERT INTO `provinces_cities` VALUES (149, '抚州市');
INSERT INTO `provinces_cities` VALUES (150, '新余市');
INSERT INTO `provinces_cities` VALUES (151, '景德镇市');
INSERT INTO `provinces_cities` VALUES (152, '萍乡市');
INSERT INTO `provinces_cities` VALUES (153, '赣州市');
INSERT INTO `provinces_cities` VALUES (154, '鹰潭市');
INSERT INTO `provinces_cities` VALUES (155, '保定市');
INSERT INTO `provinces_cities` VALUES (156, '唐山市');
INSERT INTO `provinces_cities` VALUES (157, '廊坊市');
INSERT INTO `provinces_cities` VALUES (158, '张家口市');
INSERT INTO `provinces_cities` VALUES (159, '承德市');
INSERT INTO `provinces_cities` VALUES (160, '沧州市');
INSERT INTO `provinces_cities` VALUES (161, '石家庄市');
INSERT INTO `provinces_cities` VALUES (162, '秦皇岛市');
INSERT INTO `provinces_cities` VALUES (163, '衡水市');
INSERT INTO `provinces_cities` VALUES (164, '邢台市');
INSERT INTO `provinces_cities` VALUES (165, '邯郸市');
INSERT INTO `provinces_cities` VALUES (166, '三门峡市');
INSERT INTO `provinces_cities` VALUES (167, '信阳市');
INSERT INTO `provinces_cities` VALUES (168, '南阳市');
INSERT INTO `provinces_cities` VALUES (169, '周口市');
INSERT INTO `provinces_cities` VALUES (170, '商丘市');
INSERT INTO `provinces_cities` VALUES (171, '安阳市');
INSERT INTO `provinces_cities` VALUES (172, '平顶山市');
INSERT INTO `provinces_cities` VALUES (173, '开封市');
INSERT INTO `provinces_cities` VALUES (174, '新乡市');
INSERT INTO `provinces_cities` VALUES (175, '洛阳市');
INSERT INTO `provinces_cities` VALUES (176, '漯河市');
INSERT INTO `provinces_cities` VALUES (177, '濮阳市');
INSERT INTO `provinces_cities` VALUES (178, '焦作市');
INSERT INTO `provinces_cities` VALUES (179, '许昌市');
INSERT INTO `provinces_cities` VALUES (180, '郑州市');
INSERT INTO `provinces_cities` VALUES (181, '驻马店市');
INSERT INTO `provinces_cities` VALUES (182, '鹤壁市');
INSERT INTO `provinces_cities` VALUES (183, '丽水市');
INSERT INTO `provinces_cities` VALUES (184, '台州市');
INSERT INTO `provinces_cities` VALUES (185, '嘉兴市');
INSERT INTO `provinces_cities` VALUES (186, '宁波市');
INSERT INTO `provinces_cities` VALUES (187, '杭州市');
INSERT INTO `provinces_cities` VALUES (188, '温州市');
INSERT INTO `provinces_cities` VALUES (189, '湖州市');
INSERT INTO `provinces_cities` VALUES (190, '绍兴市');
INSERT INTO `provinces_cities` VALUES (191, '舟山市');
INSERT INTO `provinces_cities` VALUES (192, '衢州市');
INSERT INTO `provinces_cities` VALUES (193, '金华市');
INSERT INTO `provinces_cities` VALUES (194, '三亚市');
INSERT INTO `provinces_cities` VALUES (195, '三沙市');
INSERT INTO `provinces_cities` VALUES (196, '儋州市');
INSERT INTO `provinces_cities` VALUES (197, '海口市');
INSERT INTO `provinces_cities` VALUES (198, '十堰市');
INSERT INTO `provinces_cities` VALUES (199, '咸宁市');
INSERT INTO `provinces_cities` VALUES (200, '孝感市');
INSERT INTO `provinces_cities` VALUES (201, '宜昌市');
INSERT INTO `provinces_cities` VALUES (202, '武汉市');
INSERT INTO `provinces_cities` VALUES (203, '荆州市');
INSERT INTO `provinces_cities` VALUES (204, '荆门市');
INSERT INTO `provinces_cities` VALUES (205, '襄阳市');
INSERT INTO `provinces_cities` VALUES (206, '鄂州市');
INSERT INTO `provinces_cities` VALUES (207, '随州市');
INSERT INTO `provinces_cities` VALUES (208, '黄冈市');
INSERT INTO `provinces_cities` VALUES (209, '黄石市');
INSERT INTO `provinces_cities` VALUES (210, '娄底市');
INSERT INTO `provinces_cities` VALUES (211, '岳阳市');
INSERT INTO `provinces_cities` VALUES (212, '常德市');
INSERT INTO `provinces_cities` VALUES (213, '张家界市');
INSERT INTO `provinces_cities` VALUES (214, '怀化市');
INSERT INTO `provinces_cities` VALUES (215, '株洲市');
INSERT INTO `provinces_cities` VALUES (216, '永州市');
INSERT INTO `provinces_cities` VALUES (217, '湘潭市');
INSERT INTO `provinces_cities` VALUES (218, '益阳市');
INSERT INTO `provinces_cities` VALUES (219, '衡阳市');
INSERT INTO `provinces_cities` VALUES (220, '邵阳市');
INSERT INTO `provinces_cities` VALUES (221, '郴州市');
INSERT INTO `provinces_cities` VALUES (222, '长沙市');
INSERT INTO `provinces_cities` VALUES (223, '兰州市');
INSERT INTO `provinces_cities` VALUES (224, '嘉峪关市');
INSERT INTO `provinces_cities` VALUES (225, '天水市');
INSERT INTO `provinces_cities` VALUES (226, '定西市');
INSERT INTO `provinces_cities` VALUES (227, '平凉市');
INSERT INTO `provinces_cities` VALUES (228, '庆阳市');
INSERT INTO `provinces_cities` VALUES (229, '张掖市');
INSERT INTO `provinces_cities` VALUES (230, '武威市');
INSERT INTO `provinces_cities` VALUES (231, '白银市');
INSERT INTO `provinces_cities` VALUES (232, '酒泉市');
INSERT INTO `provinces_cities` VALUES (233, '金昌市');
INSERT INTO `provinces_cities` VALUES (234, '陇南市');
INSERT INTO `provinces_cities` VALUES (235, '三明市');
INSERT INTO `provinces_cities` VALUES (236, '南平市');
INSERT INTO `provinces_cities` VALUES (237, '厦门市');
INSERT INTO `provinces_cities` VALUES (238, '宁德市');
INSERT INTO `provinces_cities` VALUES (239, '泉州市');
INSERT INTO `provinces_cities` VALUES (240, '漳州市');
INSERT INTO `provinces_cities` VALUES (241, '福州市');
INSERT INTO `provinces_cities` VALUES (242, '莆田市');
INSERT INTO `provinces_cities` VALUES (243, '龙岩市');
INSERT INTO `provinces_cities` VALUES (244, '山南市');
INSERT INTO `provinces_cities` VALUES (245, '拉萨市');
INSERT INTO `provinces_cities` VALUES (246, '日喀则市');
INSERT INTO `provinces_cities` VALUES (247, '昌都市');
INSERT INTO `provinces_cities` VALUES (248, '林芝市');
INSERT INTO `provinces_cities` VALUES (249, '那曲市');
INSERT INTO `provinces_cities` VALUES (250, '六盘水市');
INSERT INTO `provinces_cities` VALUES (251, '安顺市');
INSERT INTO `provinces_cities` VALUES (252, '毕节市');
INSERT INTO `provinces_cities` VALUES (253, '贵阳市');
INSERT INTO `provinces_cities` VALUES (254, '遵义市');
INSERT INTO `provinces_cities` VALUES (255, '铜仁市');
INSERT INTO `provinces_cities` VALUES (256, '丹东市');
INSERT INTO `provinces_cities` VALUES (257, '大连市');
INSERT INTO `provinces_cities` VALUES (258, '抚顺市');
INSERT INTO `provinces_cities` VALUES (259, '朝阳市');
INSERT INTO `provinces_cities` VALUES (260, '本溪市');
INSERT INTO `provinces_cities` VALUES (261, '沈阳市');
INSERT INTO `provinces_cities` VALUES (262, '盘锦市');
INSERT INTO `provinces_cities` VALUES (263, '营口市');
INSERT INTO `provinces_cities` VALUES (264, '葫芦岛市');
INSERT INTO `provinces_cities` VALUES (265, '辽阳市');
INSERT INTO `provinces_cities` VALUES (266, '铁岭市');
INSERT INTO `provinces_cities` VALUES (267, '锦州市');
INSERT INTO `provinces_cities` VALUES (268, '阜新市');
INSERT INTO `provinces_cities` VALUES (269, '鞍山市');
INSERT INTO `provinces_cities` VALUES (270, '咸阳市');
INSERT INTO `provinces_cities` VALUES (271, '商洛市');
INSERT INTO `provinces_cities` VALUES (272, '安康市');
INSERT INTO `provinces_cities` VALUES (273, '宝鸡市');
INSERT INTO `provinces_cities` VALUES (274, '延安市');
INSERT INTO `provinces_cities` VALUES (275, '榆林市');
INSERT INTO `provinces_cities` VALUES (276, '汉中市');
INSERT INTO `provinces_cities` VALUES (277, '渭南市');
INSERT INTO `provinces_cities` VALUES (278, '西安市');
INSERT INTO `provinces_cities` VALUES (279, '铜川市');
INSERT INTO `provinces_cities` VALUES (280, '果洛藏族自治州');
INSERT INTO `provinces_cities` VALUES (281, '海东市');
INSERT INTO `provinces_cities` VALUES (282, '海北藏族自治州');
INSERT INTO `provinces_cities` VALUES (283, '海南藏族自治州');
INSERT INTO `provinces_cities` VALUES (284, '海西蒙古族藏族自治州');
INSERT INTO `provinces_cities` VALUES (285, '玉树藏族自治州');
INSERT INTO `provinces_cities` VALUES (286, '西宁市');
INSERT INTO `provinces_cities` VALUES (287, '黄南藏族自治州');
INSERT INTO `provinces_cities` VALUES (288, '七台河市');
INSERT INTO `provinces_cities` VALUES (289, '伊春市');
INSERT INTO `provinces_cities` VALUES (290, '佳木斯市');
INSERT INTO `provinces_cities` VALUES (291, '双鸭山市');
INSERT INTO `provinces_cities` VALUES (292, '大庆市');
INSERT INTO `provinces_cities` VALUES (293, '牡丹江市');
INSERT INTO `provinces_cities` VALUES (294, '绥化市');
INSERT INTO `provinces_cities` VALUES (295, '鸡西市');
INSERT INTO `provinces_cities` VALUES (296, '鹤岗市');
INSERT INTO `provinces_cities` VALUES (297, '黑河市');
INSERT INTO `provinces_cities` VALUES (298, '齐齐哈尔市');

-- ----------------------------
-- Table structure for user_address
-- ----------------------------
DROP TABLE IF EXISTS `user_address`;
CREATE TABLE `user_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_default` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKdbvev60cbcacx6d6i7d1m5xe1`(`username` ASC) USING BTREE,
  CONSTRAINT `FKdbvev60cbcacx6d6i7d1m5xe1` FOREIGN KEY (`username`) REFERENCES `user_info` (`username`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_address
-- ----------------------------
INSERT INTO `user_address` VALUES (1, 'admin', '张三', '13800138000', '柳州市', '浦东新区世纪大道100号', 1);
INSERT INTO `user_address` VALUES (2, 'admin', '李四', '13900139000', '北京市', '朝阳区建国路88号', 0);

-- ----------------------------
-- Table structure for user_checkin
-- ----------------------------
DROP TABLE IF EXISTS `user_checkin`;
CREATE TABLE `user_checkin`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `checkin_date` date NOT NULL,
  `created_at` datetime(6) NULL DEFAULT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `checkin_number` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKl72tkvq5clshjppob168kfymc`(`username` ASC) USING BTREE,
  CONSTRAINT `FKl72tkvq5clshjppob168kfymc` FOREIGN KEY (`username`) REFERENCES `user_info` (`username`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_checkin
-- ----------------------------
INSERT INTO `user_checkin` VALUES (8, '2025-08-18', '2025-08-20 15:29:11.201343', 'root', 1);
INSERT INTO `user_checkin` VALUES (9, '2025-08-19', '2025-08-20 15:29:46.928233', 'root', 2);
INSERT INTO `user_checkin` VALUES (10, '2025-08-20', '2025-08-20 15:30:07.953795', 'root', 3);
INSERT INTO `user_checkin` VALUES (11, '2025-08-21', '2025-08-20 16:26:51.265768', 'root', 4);
INSERT INTO `user_checkin` VALUES (12, '2025-08-20', '2025-08-20 16:27:22.257110', 'admin', 1);
INSERT INTO `user_checkin` VALUES (13, '2025-08-21', '2025-08-21 08:58:44.824756', 'admin', 2);
INSERT INTO `user_checkin` VALUES (14, '2025-08-22', '2025-08-22 03:14:30.970225', 'admin', 3);
INSERT INTO `user_checkin` VALUES (15, '2025-08-22', '2025-08-22 04:09:57.773616', 'root', 5);
INSERT INTO `user_checkin` VALUES (16, '2025-08-24', '2025-08-23 17:51:05.521506', 'admin', 4);
INSERT INTO `user_checkin` VALUES (17, '2025-08-24', '2025-08-24 06:15:16.706308', 'demo', 1);
INSERT INTO `user_checkin` VALUES (18, '2025-08-25', '2025-08-25 14:47:38.989916', 'admin', 5);
INSERT INTO `user_checkin` VALUES (19, '2025-08-27', '2025-08-27 16:07:14.089376', 'demo', 2);
INSERT INTO `user_checkin` VALUES (21, '2025-08-29', '2025-08-29 19:32:01.456556', 'admin', 6);
INSERT INTO `user_checkin` VALUES (22, '2025-08-29', '2025-08-29 19:40:52.145951', 'root', 6);
INSERT INTO `user_checkin` VALUES (23, '2025-08-29', '2025-08-29 19:40:58.509832', 'demo', 3);

-- ----------------------------
-- Table structure for user_checkin_summary
-- ----------------------------
DROP TABLE IF EXISTS `user_checkin_summary`;
CREATE TABLE `user_checkin_summary`  (
  `user_id` int NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `checkin_number` int NOT NULL DEFAULT 0,
  `checkin_count` int NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  INDEX `idx_user_checkin_username`(`username` ASC) USING BTREE,
  CONSTRAINT `fk_usercheckin_summary_user` FOREIGN KEY (`user_id`) REFERENCES `user_info` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_checkin_summary
-- ----------------------------
INSERT INTO `user_checkin_summary` VALUES (1, 'admin', 18, NULL);
INSERT INTO `user_checkin_summary` VALUES (9, 'root', 16, NULL);
INSERT INTO `user_checkin_summary` VALUES (10, 'demo', 16, NULL);

-- ----------------------------
-- Table structure for user_favorites
-- ----------------------------
DROP TABLE IF EXISTS `user_favorites`;
CREATE TABLE `user_favorites`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `animal_id` bigint NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ux_user_animal`(`user_id` ASC, `animal_id` ASC) USING BTREE,
  UNIQUE INDEX `UK5q8u6qvs75p0k22n07aq74xif`(`user_id` ASC, `animal_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_animal_id`(`animal_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_favorites
-- ----------------------------
INSERT INTO `user_favorites` VALUES (2, 9, 2, '2025-08-22 04:41:23');
INSERT INTO `user_favorites` VALUES (24, 1, 2, '2025-08-25 16:20:45');
INSERT INTO `user_favorites` VALUES (25, 1, 5, '2025-08-25 16:20:51');
INSERT INTO `user_favorites` VALUES (26, 1, 8, '2025-08-25 16:20:54');
INSERT INTO `user_favorites` VALUES (27, 9, 1, '2025-08-25 17:59:52');

-- ----------------------------
-- Table structure for user_info
-- ----------------------------
DROP TABLE IF EXISTS `user_info`;
CREATE TABLE `user_info`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `avatar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像数据(data URI/base64)',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `birthday` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_user_info_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_user_info_real_name`(`real_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_info
-- ----------------------------
INSERT INTO `user_info` VALUES (1, 'admin', 'app.media.tyikjgch', '男', '13800138001', 'example@email.com', '河北省 保定市', '2000-01-08', '$2a$10$KFy8AyKeCKruPA.nuCfbKOUf2YNmKoSKfczfLp4FeAl.giS9cf8u2', NULL, NULL);
INSERT INTO `user_info` VALUES (9, 'root', 'app.media.tyikjgch', '男', '13434532434', '', '北京市 北京市', '2005-08-20', '$2a$10$.1iDVT4TiD0YWQFixdGGF.QQFweeEZJsc77Vw1SSvfSkkTCjvDONK', NULL, NULL);
INSERT INTO `user_info` VALUES (10, 'demo', 'app.media.tyikjgch', '女', '18878646790', '', '黑龙江省 哈尔滨市', '2007-10-24', '$2a$10$VcPWsTnBPHyiCKLxSYmGu.AzMqTk0j7uk761E5oWk0rBRvUNcDF6S', NULL, NULL);

-- ----------------------------
-- Table structure for user_real_name
-- ----------------------------
DROP TABLE IF EXISTS `user_real_name`;
CREATE TABLE `user_real_name`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
  UNIQUE INDEX `id_number`(`id_number` ASC) USING BTREE,
  UNIQUE INDEX `UKtmj3b1pfem7wcqxn5mmp3ppw2`(`user_id` ASC) USING BTREE,
  UNIQUE INDEX `UK6sgoexdsrd3t68jqsqk6e1i9c`(`id_number` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_id_number`(`id_number` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_real_name
-- ----------------------------
INSERT INTO `user_real_name` VALUES (1, 1, '张三', '110101199001011234');
INSERT INTO `user_real_name` VALUES (2, 9, '李四', '220202198502029876');

-- ----------------------------
-- View structure for adoption_stats
-- ----------------------------
DROP VIEW IF EXISTS `adoption_stats`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `adoption_stats` AS select cast(`adoption_orders`.`created_at` as date) AS `date`,count(0) AS `daily_adoptions`,avg((to_days(`adoption_orders`.`updated_at`) - to_days(`adoption_orders`.`created_at`))) AS `avg_process_days` from `adoption_orders` group by cast(`adoption_orders`.`created_at` as date);

-- ----------------------------
-- View structure for popular_pets
-- ----------------------------
DROP VIEW IF EXISTS `popular_pets`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `popular_pets` AS select `a`.`id` AS `id`,`a`.`name` AS `name`,`a`.`gender` AS `gender`,`a`.`age` AS `age`,`a`.`type` AS `type`,`a`.`description` AS `description`,`a`.`vaccinated` AS `vaccinated`,`a`.`dewormed` AS `dewormed`,`a`.`neutered` AS `neutered`,`a`.`image` AS `image`,`a`.`city` AS `city`,`a`.`isFree` AS `isFree`,`a`.`is_free` AS `is_free`,`a`.`favorite_count` AS `favorite_count`,`a`.`user_id` AS `user_id`,`a`.`adopted` AS `adopted`,`a`.`listed` AS `listed`,((`a`.`favorite_count` * 2) + if((`a`.`adopted` = 0),5,0)) AS `popularity_score` from `animals` `a` where (`a`.`listed` = 1) order by ((`a`.`favorite_count` * 2) + if((`a`.`adopted` = 0),5,0)) desc;

-- ----------------------------
-- Triggers structure for table adoption_orders
-- ----------------------------
DROP TRIGGER IF EXISTS `bi_adoption_orders_order_no`;
delimiter ;;
CREATE TRIGGER `bi_adoption_orders_order_no` BEFORE INSERT ON `adoption_orders` FOR EACH ROW BEGIN
  IF NEW.order_no IS NULL OR NEW.order_no = '' THEN
    SET NEW.order_no = CONCAT(DATE_FORMAT(NOW(), '%y%m%d%H%i%s'), LPAD(FLOOR(RAND()*10000), 4, '0'));
  END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
