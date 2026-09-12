/*
 *
 *    Copyright (c) 2025 Huawei Device Co., Ltd.
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 *
 */

// 用户首选项为应用提供Key-Value键值型的数据处理能力，支持应用持久化轻量级数据，并对其修改和查询。
//一个应用内部可以创建多个首选项实例，每个实例都会对应沙箱中的持久化文件
//key是string类型，最大长度限制为80字节
//value为数字型、字符型、布尔型以及这3种类型的数组类型。最大长度为8192个字节

import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import Logger from '@ohos/common/src/main/ets/utils/Logger';

class PreferencesUtil{
  preMap:Map<string,dataPreferences.Preferences> = new Map()
  //创建Preferences实例
  async loadPreferences(context:common.UIAbilityContext,name:string){
    try {
      let pref = await dataPreferences.getPreferences(context,name)
      this.preMap.set(name,pref)
      Logger.info('dataPreferences',`获取dataPreferences【${name}】实例成功`)
    } catch (e) {
      Logger.info('dataPreferences',`获取dataPreferences【${name}】实例失败`,JSON.stringify(e))
    }
  }



  //写入数据
  async putPreferencesValue(name:string,key:string,value:dataPreferences.ValueType){
    if(!this.preMap.has(name)){
      Logger.info('dataPreferences',`dataPreferences【${name}】实例未创建`)
      return
    }
    try {
      let pref = this.preMap.get(name) as dataPreferences.Preferences
      //写入数据
      await pref.put(key,value)
      //写入文件
      await pref.flush()
      Logger.info('dataPreferences',`写入dataPreferences【${name}】实例成功，key=${key} value=${value}`)
    } catch (e) {
      Logger.info('dataPreferences',`写入dataPreferences【${name}】实例失败，key=${key} value=${value}`,JSON.stringify(e))
    }
  }

  //获取数据
  async getPreferencesValue(name:string,key:string,defValue:dataPreferences.ValueType):Promise<dataPreferences.ValueType | undefined>{
    if(!this.preMap.has(name)){
      Logger.info('dataPreferences',`dataPreferences【${name}】实例未创建`)
      return
    }
    try {
      let pref = this.preMap.get(name) as dataPreferences.Preferences
      //写入数据
      let value = await pref.get(key,defValue)
      Logger.info('dataPreferences',`读取dataPreferences【${name}】实例成功，key=${key} value=${value}`)
      return value
    } catch (e) {
      Logger.info('dataPreferences',`写入dataPreferences【${name}】实例失败，key=${key} value=`,JSON.stringify(e))
      return
    }
  }

  //判断是否包含key
  hasPreferenceskey(name:string,key:string):boolean | undefined{
    if(!this.preMap.has(name)){
      Logger.info('dataPreferences',`dataPreferences【${name}】实例未创建`)
      return
    }
    let pref = this.preMap.get(name) as dataPreferences.Preferences
    let isExist: boolean = pref.hasSync(key);
    return isExist
  }

  //删除指定key
  async deletePreferenceskey(name:string,key:string){
    if(!this.preMap.has(name)){
      Logger.info('dataPreferences',`dataPreferences【${name}】实例未创建`)
      return
    }
    let pref = this.preMap.get(name) as dataPreferences.Preferences
    //删除
    pref.deleteSync(key);
    //刷盘
    await pref.flush()
  }

}

const preferencesUtil = new PreferencesUtil()
export  default  preferencesUtil as PreferencesUtil