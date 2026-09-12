/**
 * 旅程阶段枚举（对齐后端 JourneyState）。
 */
export type JourneyState =
  | '出发准备'
  | '去车站'
  | '候车'
  | '乘车'
  | '到站换乘'
  | '前往目的地'
  | '入场或入住准备'
  | '已抵达';

export const JOURNEY_STATES: JourneyState[] = [
  '出发准备', '去车站', '候车', '乘车', '到站换乘', '前往目的地', '入场或入住准备', '已抵达'
];
