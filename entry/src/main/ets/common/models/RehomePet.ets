/**
 * 送养宠物相关数据模型
 */

// 送养宠物状态
export type RehomePetStatus = 'ACTIVE' | 'ADOPTED' | 'CLOSED';

// 送养宠物信息
export interface RehomePet {
  id: number;
  userId: number;
  title: string;
  petName: string;
  type: string; // 宠物类型：狗、猫、其他
  gender: boolean; // true=公，false=母
  age: number;
  breed?: string; // 品种
  description: string;
  vaccinated: boolean; // 是否已免疫
  dewormed: boolean; // 是否已驱虫
  neutered: boolean; // 是否已绝育
  healthStatus: string; // 健康状况描述
  image?: string;
  city: string;
  address: string; // 详细地址
  contactName: string;
  contactPhone: string;
  rehomeReason: string; // 送养原因
  requirements?: string; // 对领养人的要求
  adoptionFee?: number; // 领养费用，0表示免费
  status: RehomePetStatus;
  createdAt?: string;
  updatedAt?: string;
  adoptedAt?: string;
}

// 创建送养宠物请求
export interface CreateRehomePetRequest {
  userId: number;
  title: string;
  petName: string;
  type: string;
  gender: boolean;
  age: number;
  breed?: string;
  description: string;
  vaccinated: boolean;
  dewormed: boolean;
  neutered: boolean;
  healthStatus: string;
  image?: string;
  city: string;
  address: string;
  contactName: string;
  contactPhone: string;
  rehomeReason: string;
  requirements?: string;
  adoptionFee?: number;
}
