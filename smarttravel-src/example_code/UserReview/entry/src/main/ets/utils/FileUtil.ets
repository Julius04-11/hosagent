/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * PhotoViewPicker
 *
 * @returns 选择图片的uri
 */
export async function photoSelect(maxSelectNumber: number): Promise<Array<string>> {
  // 设置打开picker的选项
  let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  // 只能选择图片类型
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  // 可选择的数量
  photoSelectOptions.maxSelectNumber = maxSelectNumber;

  // 创建picker
  let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  try {
    let photoSelectResult = await photoViewPicker.select(photoSelectOptions); // 拉起图片选择框
    if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
      return photoSelectResult.photoUris;
    } else {
      return [];
    }
  } catch (err) {
    if (err instanceof Error) {
      hilog.error(0, 'SelectedImage failed: %{public}s\nStack: %{public}s', err.message,
        err.stack || 'No stack available');
    }
    return [];
  }
}
