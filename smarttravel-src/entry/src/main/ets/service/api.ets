import axios from '@ohos/axios'
import { SignupInfo } from '../pages/activity/SignUpPage';
import { AxiosResponse, FormData } from '@ohos/axios'

interface Response {
  code: number,
  msg: string,
  data: SignupInfo[]
}

const baseURL = 'http://10.0.2.2:8000';

const api = axios.create({
  baseURL,
  timeout: 5000
});

function toFormData(data: SignupInfo): string {
  let formData: string[] = [];

  formData.push(`id=${encodeURIComponent(data.id)}`);
  formData.push(`name=${encodeURIComponent(data.name)}`);
  formData.push(`sex=${encodeURIComponent(data.sex)}`);
  formData.push(`age=${encodeURIComponent(String(data.age))}`);
  formData.push(`activity=${encodeURIComponent(data.activity)}`);
  formData.push(`activityId=${encodeURIComponent(String(data.activityId))}`);
  console.error(formData.join('&'));
  return formData.join('&');
}

export async function postSignUpData(signInfo: SignupInfo): Promise<void> {
  try {
    const formData: FormData = new FormData();
    formData.append('id', signInfo.id);
    formData.append('name', signInfo.name);
    formData.append('sex', signInfo.sex);
    formData.append('age', signInfo.age.toString());       // number 转 string
    // 如果提供了手机号，添加到表单数据中
    if (signInfo.phoneNo && signInfo.phoneNo.trim().length > 0) {
      formData.append('phoneNo', signInfo.phoneNo);
    }
    formData.append('activity', signInfo.activity);
    formData.append('activityId', signInfo.activityId.toString()); // number 转 string
    await api.post('/signup', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    console.log('请求成功');
  } catch (err) {
    console.error('请求失败：', err);
  }
}

export async function getSignUpData(): Promise<SignupInfo[]> {
  try {
    const res: AxiosResponse<Response> = await api.get<Response>('/signup');
    return res.data.data;
  } catch (err) {
    console.error('获取失败：', err);
    if (err instanceof Error) {
      throw err;
    }
    throw new Error('未知错误');
  }
}
