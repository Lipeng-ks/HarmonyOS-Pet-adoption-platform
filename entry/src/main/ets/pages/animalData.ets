import { ApiService } from '../common/services/ApiService';

// 动物与城市的类型定义
export interface Animal {
  id: number;
  name: string;
  gender: boolean;
  age: number;
  type: string;
  description: string;
  vaccinated: boolean;
  dewormed: boolean;
  neutered: boolean;
  image: string;
  city: string;
  isFree: boolean;
}

export interface City {
  id?: number;
  name: string;
  pinyin?: string;
}

const api = ApiService.getInstance();

// 使用后端 API 获取所有动物
export async function getAnimals(): Promise<Animal[]> {
  return await api.getAnimals();
}

// 使用后端 API 根据 ID 获取动物
export async function getAnimalById(id: number): Promise<Animal | null> {
  return await api.getAnimalById(id);
}

export async function getAllAnimalIds(): Promise<number[]> {
  const animals = await getAnimals();
  return animals.map(a => a.id);
}

export async function getRandomAnimalIds(n: number): Promise<number[]> {
  const animals = await getAnimals();
  const ids = animals.map(a => a.id);
  const result: number[] = [];
  const len = Math.min(n, ids.length);
  while (result.length < len) {
    const idx = Math.floor(Math.random() * ids.length);
    const id = ids[idx];
    if (!result.includes(id)) result.push(id);
  }
  return result;
}

export async function getRandomAnimalImage(): Promise<string> {
  const animals = await getAnimals();
  if (animals.length === 0) return '';
  const idx = Math.floor(Math.random() * animals.length);
  return animals[idx].image;
}

export async function getRandomAnimalName(): Promise<string> {
  const animals = await getAnimals();
  if (animals.length === 0) return '';
  const idx = Math.floor(Math.random() * animals.length);
  return animals[idx].name;
}

// 获取城市列表（从后端）
export async function getCities(): Promise<City[]> {
  return await api.getCities();
}


