/*
 * 用户信息验证工具类
 * 基于华为官方示例代码实现
 */

// 省份开头码
const PROVINCE_ID =
  ['11', '12', '13', '14', '15', '21', '22', '23', '31', '32', '33', '34', '35', '36', '37', '41', '42', '43', '44',
    '45', '46', '50', '51', '52', '53', '54', '61', '62', '63', '64', '65'];

/**
 * 验证手机号
 * @param num 手机号字符串
 * @returns 是否为有效的手机号
 */
export function checkPhoneNo(num: string): boolean {
  if (!num || num.trim().length === 0) {
    return false;
  }
  const PHONE_REGEXP = new RegExp('^(?:(?:\\+|00)86)?1[3-9]\\d{9}$');
  return PHONE_REGEXP.test(num.trim());
}

/**
 * 验证日期
 * @param dateStr 日期字符串，格式：YYYY-MM-DD
 * @returns 是否为有效的日期（且不能是未来日期）
 */
export function isValidDate(dateStr: string): boolean {
  if (!dateStr || dateStr.trim().length === 0) {
    return false;
  }
  let date = new Date(dateStr);
  if (date.getTime() >= new Date().getTime()) {
    return false;
  }
  let dateList = dateStr.split('-');
  if (dateList.length !== 3) {
    return false;
  }
  let year: number = date.getFullYear();
  let month: number = date.getMonth() + 1;
  let day: number = date.getDate();
  return year.toString() === dateList[0] && month.toString().padStart(2, '0') === dateList[1] &&
    day.toString().padStart(2, '0') === dateList[2];
}

/**
 * 验证身份证号码
 * @param id 身份证号字符串
 * @returns 是否为有效的身份证号
 */
export function checkIDCardNo(id: string): boolean {
  if (!id || id.trim().length === 0) {
    return false;
  }
  const trimmedId = id.trim();
  if (trimmedId.length !== 18 || !PROVINCE_ID.includes(trimmedId.slice(0, 2)) ||
    !isValidDate(`${trimmedId.slice(6, 10)}-${trimmedId.slice(10, 12)}-${trimmedId.slice(12, 14)}`)) {
    return false;
  }
  let ans: number = 0;
  for (let i = 0; i < 17; i++) {
    if (trimmedId[i].charCodeAt(0) === 32) {
      return false;
    }
    ans += (2**(17 - i) % 11) * Number(trimmedId[i]);
  }
  let res = (12 - ans % 11) % 11;
  if (res === 10) {
    return trimmedId[17] === 'X' || trimmedId[17] === 'x';
  } else {
    return trimmedId[17] === res.toString();
  }
}

