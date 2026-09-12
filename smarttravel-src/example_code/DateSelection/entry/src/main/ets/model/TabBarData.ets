/*
 *
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 */

import { TabBarDataType } from './DataType';

// TarBar数据
export const TAB_INFO: TabBarDataType[] = [
  new TabBarDataType($r('app.string.room'), $r('app.media.house_tab')),
  new TabBarDataType($r('app.string.facility'), $r('app.media.facility')),
  new TabBarDataType($r('app.string.mine'), $r('app.media.mine'))
];