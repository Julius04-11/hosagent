/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// 省份开头码
const PROVINCE_ID =
  ['11', '12', '13', '14', '15', '21', '22', '23', '31', '32', '33', '34', '35', '36', '37', '41', '42', '43', '44',
    '45', '46', '50', '51', '52', '53', '54', '61', '62', '63', '64', '65'];

// 验证手机号
export function checkPhoneNo(num: string) {
  const PHONE_REGEXP = new RegExp('^(?:(?:\\+|00)86)?1[3-9]\\d{9}$');
  return PHONE_REGEXP.test(num);
}

// 验证日期
export function isValidDate(dateStr: string) {
  let date = new Date(dateStr);
  if (date.getTime() >= new Date().getTime()) {
    return false;
  }
  let dateList = dateStr.split('-');
  let year: number = date.getFullYear();
  let month: number = date.getMonth() + 1;
  let day: number = date.getDate();
  return year.toString() === dateList[0] && month.toString().padStart(2, '0') === dateList[1] &&
    day.toString().padStart(2, '0') === dateList[2];
}

// 验证身份证号码
export function checkIDCardNo(id: string): boolean {
  if (id.length !== 18 || !PROVINCE_ID.includes(id.slice(0, 2)) ||
    !isValidDate(`${id.slice(6, 10)}-${id.slice(10, 12)}-${id.slice(12, 14)}`)) {
    return false;
  }
  let ans: number = 0;
  for (let i = 0; i < 17; i++) {
    if (id[i].charCodeAt(0) === 32) {
      return false;
    }
    ans += (2**(17 - i) % 11) * Number(id[i]);
  }
  let res = (12 - ans % 11) % 11;
  if (res === 10) {
    return id[17] === 'X' || id[17] === 'x';
  } else {
    return id[17] === res.toString();
  }
}