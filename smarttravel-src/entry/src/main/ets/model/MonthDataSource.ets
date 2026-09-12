import { MonthItem } from './CalendarDataType';

/**
 * LazyForEach 数据源 - 用于月份列表的懒加载
 */
export class MonthDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private monthList: MonthItem[] = [];

  constructor(monthList: MonthItem[]) {
    this.monthList = monthList;
  }

  // 获取数据总数
  totalCount(): number {
    return this.monthList.length;
  }

  // 获取指定索引的数据
  getData(index: number): MonthItem {
    return this.monthList[index];
  }

  // 注册数据变化监听器
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 注销数据变化监听器
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // 通知数据重新加载
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  // 通知单项数据变化
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChanged(index);
    });
  }

  // 通知数据添加
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdded(index);
    });
  }

  // 通知数据删除
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDeleted(index);
    });
  }

  // 添加月份数据
  addMonth(month: MonthItem): void {
    this.monthList.push(month);
    this.notifyDataAdd(this.monthList.length - 1);
  }

  // 更新月份数据
  updateMonth(index: number, month: MonthItem): void {
    if (index >= 0 && index < this.monthList.length) {
      this.monthList[index] = month;
      this.notifyDataChange(index);
    }
  }

  // 删除月份数据
  deleteMonth(index: number): void {
    if (index >= 0 && index < this.monthList.length) {
      this.monthList.splice(index, 1);
      this.notifyDataDelete(index);
    }
  }

  // 重新加载数据
  reloadData(monthList: MonthItem[]): void {
    this.monthList = monthList;
    this.notifyDataReload();
  }
}
