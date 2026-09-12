import { EcoTravelService } from '../service/EcoTravelService';
import { CarbonFootprintRecord, EcoGoal, EcoSuggestion, GreenAttraction, 
         EcoAccommodation, EcoTransportation, EcoStats, EcoReport, 
         EcoActionType, CarbonFootprintType, EcoLevel } from '../model/EcoTravelModel';
import { AnimationUtils } from '../utils/AnimationUtils';

/**
 * 碳足迹卡片组件
 * 显示用户的碳足迹记录
 */
@Component
export struct CarbonFootprintCard {
  @Prop record: CarbonFootprintRecord;
  @State isExpanded: boolean = false;

  // 格式化时间
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  // 获取行为类型图标
  private getActionIcon(action: EcoActionType): string {
    const icons: Record<EcoActionType, string> = {
      [EcoActionType.WALKING]: '🚶',
      [EcoActionType.CYCLING]: '🚴',
      [EcoActionType.PUBLIC_TRANSPORT]: '🚇',
      [EcoActionType.ELECTRIC_VEHICLE]: '🚗',
      [EcoActionType.CARPOOLING]: '🚙',
      [EcoActionType.OFFSET_CARBON]: '🌱',
      [EcoActionType.PLASTIC_FREE]: '♻️',
      [EcoActionType.LOCAL_FOOD]: '🍃',
      [EcoActionType.GREEN_ACCOMMODATION]: '🏨',
      [EcoActionType.WASTE_REDUCTION]: '🗑️'
    };
    return icons[action] || '🌍';
  }

  // 获取行为类型名称
  private getActionName(action: EcoActionType): string {
    const names: Record<EcoActionType, string> = {
      [EcoActionType.WALKING]: '步行',
      [EcoActionType.CYCLING]: '骑行',
      [EcoActionType.PUBLIC_TRANSPORT]: '公共交通',
      [EcoActionType.ELECTRIC_VEHICLE]: '电动车',
      [EcoActionType.CARPOOLING]: '拼车',
      [EcoActionType.OFFSET_CARBON]: '碳抵消',
      [EcoActionType.PLASTIC_FREE]: '无塑料',
      [EcoActionType.LOCAL_FOOD]: '本地食物',
      [EcoActionType.GREEN_ACCOMMODATION]: '绿色住宿',
      [EcoActionType.WASTE_REDUCTION]: '减少浪费'
    };
    return names[action] || '环保行为';
  }

  build() {
    Column() {
      // 主要信息
      Row() {
        Text(this.getActionIcon(this.record.action))
          .fontSize(24)
          .margin({ right: 12 })
        
        Column() {
          Text(this.getActionName(this.record.action))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .alignSelf(ItemAlign.Start)
          
          Text(`${this.record.carbonEmission.toFixed(2)} kg CO₂`)
            .fontSize(14)
            .fontColor('#059669')
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Column() {
          Text(this.formatTime(this.record.timestamp))
            .fontSize(12)
            .fontColor('#6b7280')
            .alignSelf(ItemAlign.End)
          
          if (this.record.distance) {
            Text(`${this.record.distance} km`)
              .fontSize(12)
              .fontColor('#6b7280')
              .alignSelf(ItemAlign.End)
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 详细信息（可展开）
      if (this.isExpanded) {
        Column() {
          if (this.record.location) {
            Row() {
              Text('📍')
                .fontSize(14)
                .margin({ right: 6 })
              
              Text(this.record.location.address)
                .fontSize(12)
                .fontColor('#6b7280')
            }
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: 8 })
          }
          
          if (this.record.duration) {
            Row() {
              Text('⏱️')
                .fontSize(14)
                .margin({ right: 6 })
              
              Text(`${this.record.duration} 小时`)
                .fontSize(12)
                .fontColor('#6b7280')
            }
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: 8 })
          }
          
          Row() {
            Text('📊')
              .fontSize(14)
              .margin({ right: 6 })
            
            Text(`${this.record.amount || 1} ${this.record.unit}`)
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f8fafc')
        .borderRadius(8)
        .margin({ bottom: 8 })
      }

      // 展开/收起按钮
      Button() {
        Text(this.isExpanded ? '收起' : '详情')
          .fontSize(12)
          .fontColor('#1e40af')
      }
      .height(24)
      .backgroundColor(Color.Transparent)
      .borderRadius(12)
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 12 })
  }
}

/**
 * 环保建议卡片组件
 * 显示环保建议和提示
 */
@Component
export struct EcoSuggestionCard {
  @Prop suggestion: EcoSuggestion;
  @State isExpanded: boolean = false;

  // 获取难度颜色
  private getDifficultyColor(difficulty: EcoLevel): string {
    const colors: Record<EcoLevel, string> = {
      [EcoLevel.BEGINNER]: '#10b981',
      [EcoLevel.INTERMEDIATE]: '#f59e0b',
      [EcoLevel.ADVANCED]: '#ef4444',
      [EcoLevel.EXPERT]: '#8b5cf6'
    };
    return colors[difficulty] || '#6b7280';
  }

  // 获取难度名称
  private getDifficultyName(difficulty: EcoLevel): string {
    const names: Record<EcoLevel, string> = {
      [EcoLevel.BEGINNER]: '初级',
      [EcoLevel.INTERMEDIATE]: '中级',
      [EcoLevel.ADVANCED]: '高级',
      [EcoLevel.EXPERT]: '专家'
    };
    return names[difficulty] || '未知';
  }

  // 获取行为类型图标
  private getActionIcon(action: EcoActionType): string {
    const icons: Record<EcoActionType, string> = {
      [EcoActionType.WALKING]: '🚶',
      [EcoActionType.CYCLING]: '🚴',
      [EcoActionType.PUBLIC_TRANSPORT]: '🚇',
      [EcoActionType.ELECTRIC_VEHICLE]: '🚗',
      [EcoActionType.CARPOOLING]: '🚙',
      [EcoActionType.OFFSET_CARBON]: '🌱',
      [EcoActionType.PLASTIC_FREE]: '♻️',
      [EcoActionType.LOCAL_FOOD]: '🍃',
      [EcoActionType.GREEN_ACCOMMODATION]: '🏨',
      [EcoActionType.WASTE_REDUCTION]: '🗑️'
    };
    return icons[action] || '🌍';
  }

  build() {
    Column() {
      // 建议头部
      Row() {
        Text(this.getActionIcon(this.suggestion.category))
          .fontSize(24)
          .margin({ right: 12 })
        
        Column() {
          Text(this.suggestion.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
            .alignSelf(ItemAlign.Start)
          
          Text(this.suggestion.description)
            .fontSize(12)
            .fontColor('#6b7280')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 难度标签
        Text(this.getDifficultyName(this.suggestion.difficulty))
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.getDifficultyColor(this.suggestion.difficulty))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 影响和收益
      Row() {
        Column() {
          Text('环保影响')
            .fontSize(10)
            .fontColor('#6b7280')
          
          Text(`${this.suggestion.impact}/5`)
            .fontSize(14)
            .fontColor('#059669')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text('节省碳排放')
            .fontSize(10)
            .fontColor('#6b7280')
          
          Text(`${this.suggestion.savings.carbon}kg CO₂`)
            .fontSize(14)
            .fontColor('#059669')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 20 })
        
        Column() {
          Text('节省费用')
            .fontSize(10)
            .fontColor('#6b7280')
          
          Text(`¥${this.suggestion.savings.money}`)
            .fontSize(14)
            .fontColor('#f59e0b')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 20 })
        
        Blank()
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 详细提示（可展开）
      if (this.isExpanded && this.suggestion.tips.length > 0) {
        Column() {
          Text('💡 实施建议')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          ForEach(this.suggestion.tips, (tip: string, index: number) => {
            Row() {
              Text(`${index + 1}.`)
                .fontSize(12)
                .fontColor('#6b7280')
                .margin({ right: 8 })
              
              Text(tip)
                .fontSize(12)
                .fontColor('#4b5563')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f0f8ff')
        .borderRadius(8)
        .margin({ bottom: 12 })
      }

      // 展开/收起按钮
      Button() {
        Text(this.isExpanded ? '收起' : '查看建议')
          .fontSize(12)
          .fontColor('#1e40af')
      }
      .height(28)
      .backgroundColor('#f0f8ff')
      .borderRadius(14)
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
  }
}

/**
 * 绿色景点卡片组件
 * 显示绿色景点信息
 */
@Component
export struct GreenAttractionCard {
  @Prop attraction: GreenAttraction;
  @State isExpanded: boolean = false;

  build() {
    Column() {
      // 景点图片
      Stack() {
        Image(this.attraction.images[0])
          .width('100%')
          .height(120)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
        
        // 环保评级
        Row() {
          Text('🌱')
            .fontSize(12)
            .margin({ right: 4 })
          
          Text(`${this.attraction.rating}/5`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .backgroundColor('rgba(0,0,0,0.6)')
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius(8)
        .position({ x: 8, y: 8 })
      }
      .width('100%')
      .height(120)
      .margin({ bottom: 12 })

      // 景点信息
      Column() {
        Text(this.attraction.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4 })
        
        Text(this.attraction.description)
          .fontSize(12)
          .fontColor('#6b7280')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        // 环保特色
        if (this.attraction.ecoFeatures.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.attraction.ecoFeatures, (feature: string) => {
              Text(`🌿 ${feature}`)
                .fontSize(10)
                .fontColor('#059669')
                .backgroundColor('#f0fdf4')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(8)
                .margin({ right: 4, bottom: 4 })
            })
          }
          .width('100%')
          .margin({ bottom: 8 })
        }
        
        // 详细活动（可展开）
        if (this.isExpanded && this.attraction.activities.length > 0) {
          Column() {
            Text('🎯 可进行的活动')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1f2937')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 6 })
            
            ForEach(this.attraction.activities, (activity: string) => {
              Text(`• ${activity}`)
                .fontSize(11)
                .fontColor('#4b5563')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 2 })
            })
          }
          .width('100%')
          .padding(8)
          .backgroundColor('#f8fafc')
          .borderRadius(8)
          .margin({ bottom: 8 })
        }
        
        // 展开/收起按钮
        Button() {
          Text(this.isExpanded ? '收起' : '查看详情')
            .fontSize(12)
            .fontColor('#1e40af')
        }
        .height(28)
        .backgroundColor('#f0f8ff')
        .borderRadius(14)
        .onClick(() => {
          this.isExpanded = !this.isExpanded;
        })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
  }
}

/**
 * 环保统计卡片组件
 * 显示用户的环保统计数据
 */
@Component
export struct EcoStatsCard {
  @Prop stats: EcoStats;
  @State isExpanded: boolean = false;

  // 获取等级颜色
  private getLevelColor(level: EcoLevel): string {
    const colors: Record<EcoLevel, string> = {
      [EcoLevel.BEGINNER]: '#6b7280',
      [EcoLevel.INTERMEDIATE]: '#10b981',
      [EcoLevel.ADVANCED]: '#f59e0b',
      [EcoLevel.EXPERT]: '#8b5cf6'
    };
    return colors[level] || '#6b7280';
  }

  // 获取等级名称
  private getLevelName(level: EcoLevel): string {
    const names: Record<EcoLevel, string> = {
      [EcoLevel.BEGINNER]: '环保新手',
      [EcoLevel.INTERMEDIATE]: '环保达人',
      [EcoLevel.ADVANCED]: '环保专家',
      [EcoLevel.EXPERT]: '环保大师'
    };
    return names[level] || '未知';
  }

  build() {
    Column() {
      // 等级和徽章
      Row() {
        Column() {
          Text('🌱')
            .fontSize(24)
            .margin({ bottom: 4 })
          
          Text(this.getLevelName(this.stats.ecoLevel))
            .fontSize(12)
            .fontColor(this.getLevelColor(this.stats.ecoLevel))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Center)
        
        Blank()
        
        // 连续天数
        Column() {
          Text(`${this.stats.currentStreak}`)
            .fontSize(20)
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
          
          Text('连续天数')
            .fontSize(10)
            .fontColor('#6b7280')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 统计数据
      Row() {
        Column() {
          Text(`${this.stats.totalCarbonSaved.toFixed(1)}`)
            .fontSize(16)
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
          
          Text('节省碳排放')
            .fontSize(10)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text(`¥${this.stats.totalMoneySaved.toFixed(0)}`)
            .fontSize(16)
            .fontColor('#f59e0b')
            .fontWeight(FontWeight.Bold)
          
          Text('节省费用')
            .fontSize(10)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 20 })
        
        Column() {
          Text(this.stats.totalEcoActions.toString())
            .fontSize(16)
            .fontColor('#1e40af')
            .fontWeight(FontWeight.Bold)
          
          Text('环保行为')
            .fontSize(10)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 20 })
        
        Blank()
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 详细统计（可展开）
      if (this.isExpanded) {
        Column() {
          Row() {
            Text('最长连续:')
              .fontSize(12)
              .fontColor('#6b7280')
            
            Text(`${this.stats.longestStreak}天`)
              .fontSize(12)
              .fontColor('#059669')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 8 })
          
          if (this.stats.achievements.length > 0) {
            Column() {
              Text('🏆 成就')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1f2937')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 6 })
              
              ForEach(this.stats.achievements, (achievement: string) => {
                Text(`• ${achievement}`)
                  .fontSize(11)
                  .fontColor('#4b5563')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 2 })
              })
            }
            .width('100%')
            .padding(8)
            .backgroundColor('#f8fafc')
            .borderRadius(8)
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#f0f8ff')
        .borderRadius(8)
        .margin({ bottom: 12 })
      }

      // 展开/收起按钮
      Button() {
        Text(this.isExpanded ? '收起' : '查看详情')
          .fontSize(12)
          .fontColor('#1e40af')
      }
      .height(28)
      .backgroundColor('#f0f8ff')
      .borderRadius(14)
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
  }
}
