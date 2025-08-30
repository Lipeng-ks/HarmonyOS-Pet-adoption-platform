import { Animal } from '../services/ApiService';
import { OrderStatus } from '../services/ApiService';

/**
 * AdoptionRecord used by frontend display: contains full Animal and order-related fields
 */
export interface AdoptionRecord {
  id: number; // 订单ID
  orderNo?: string;
  userId?: number;
  animal: Animal;
  shippingAddress?: string;
  petExperience?: string;
  applicationReason?: string;
  status: OrderStatus;
  applicationTime: string;
  createdAt?: string;
  updatedAt?: string;
  completedAt?: string;
  contactInfo?: string;
  adoptionFee?: number;
  urgencyLevel?: 'low' | 'medium' | 'high';
}


