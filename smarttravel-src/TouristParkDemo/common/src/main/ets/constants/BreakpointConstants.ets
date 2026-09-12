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

export class BreakpointConstants {
  static readonly BREAKPOINT_SM: string = 'sm';

  static readonly BREAKPOINT_MD: string = 'md';

  static readonly BREAKPOINT_LG: string = 'lg';

  static readonly CURRENT_BREAKPOINT: string = 'currentBreakpoint';

  static readonly RANGE_SM: string = '(320vp<=width<520vp)';

  static readonly RANGE_MD: string = '(520vp<=width<840vp)';

  static readonly RANGE_LG: string = '(840vp<=width)';
}