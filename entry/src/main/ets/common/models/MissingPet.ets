// 寻宠状态类型
export type MissingPetStatus = 'ACTIVE' | 'FOUND' | 'CLOSED';

// 寻宠信息接口（后端返回的实体）
export interface MissingPet {
  id: number;
  userId: number;
  title: string;           // 寻宠标题
  petName: string;         // 宠物名字
  type: string;            // 宠物类型（猫/狗/其他）
  gender: boolean;         // 性别（true=公，false=母）
  age: number;             // 年龄
  lostTime: string;        // 走失时间
  city: string;            // 城市
  lostAddress: string;     // 走失地点详细地址
  description: string;     // 详细描述
  contactName: string;     // 联系人姓名
  contactPhone: string;    // 联系电话
  reward?: number;         // 悬赏金额（可选）
  image?: string;          // 宠物照片
  status: MissingPetStatus; // 寻宠状态
  createdAt?: string;      // 创建时间
  updatedAt?: string;      // 更新时间
  foundAt?: string;        // 找到时间
}

// 创建寻宠请求接口
export interface CreateMissingPetRequest {
  userId: number;
  title: string;
  petName: string;
  type: string;
  gender: boolean;
  age: number;
  lostTime: string;
  city: string;
  lostAddress: string;
  description: string;
  contactName: string;
  contactPhone: string;
  reward?: number;
  image?: string;
}

// 更新寻宠状态请求接口
export interface UpdateMissingPetStatusRequest {
  id: number;
  status: MissingPetStatus;
  foundAt?: string;
}
