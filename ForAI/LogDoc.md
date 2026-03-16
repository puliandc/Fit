# 训练日志 JSON 格式说明

本文档基于当前 Fit 应用实际导出的日志结构编写，供 AI 系统和开发者解析训练日志使用。

## 顶层结构

```json
{
  "workoutName": "A组卧推深蹲",
  "workoutDate": "2025年10月14日",
  "startTime": "10:31",
  "endTime": "11:20",
  "totalDuration": "49:30",
  "entries": [
    {
      "exercise": "超级组 A：胸背对抗 (连续做完A1+A2再休息)",
      "setOrder": 1,
      "targetWeight": 17.5,
      "actualWeight": { "value": 17.5 },
      "targetReps": 10,
      "actualReps": { "value": 10.0 },
      "trainingDuration": { "value": 38.2 },
      "restTime": 0.0,
      "notes": "A1. 哑铃平板卧推 - 控制离心。 | 最后一组略晃"
    },
    {
      "exercise": "超级组 A：胸背对抗 (连续做完A1+A2再休息)",
      "setOrder": 2,
      "targetWeight": 40.0,
      "actualWeight": { "value": 40.0 },
      "targetReps": 12,
      "actualReps": { "value": 12.0 },
      "trainingDuration": { "value": 41.7 },
      "restTime": 90.0,
      "notes": "A2. 坐姿划船 - 挤压背部。"
    },
    {
      "exercise": "杠铃深蹲",
      "setOrder": 1,
      "targetWeight": 80.0,
      "actualWeight": { "na": "N/A" },
      "targetReps": 5,
      "actualReps": { "na": "N/A" },
      "trainingDuration": { "na": "N/A" },
      "restTime": 120.0,
      "notes": "深蹲到底，控制节奏。 | 放弃"
    }
  ]
}
```

## 字段说明

### WorkoutLog

| 字段 | 类型 | 说明 | 示例 |
| --- | --- | --- | --- |
| `workoutName` | `String` | 训练名称 | `"A组卧推深蹲"` |
| `workoutDate` | `String` | 训练日期，格式固定为 `yyyy年M月d日` | `"2025年10月14日"` |
| `startTime` | `String` | 开始时间，`HH:mm` | `"10:31"` |
| `endTime` | `String` | 结束时间，`HH:mm` | `"11:20"` |
| `totalDuration` | `String` | 总时长，可能是 `mm:ss` 或 `HH:mm:ss` | `"49:30"` |
| `entries` | `[WorkoutLogEntry]` | 训练条目列表 | 见上方示例 |

### WorkoutLogEntry

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `exercise` | `String` | 动作名称。若原计划用了超级组名称，这里会保留同一名称 |
| `setOrder` | `Int` | 组序号，从 `1` 开始 |
| `targetWeight` | `Double` | 目标重量，单位 kg。自重动作通常为 `0.0` |
| `actualWeight` | `WorkoutValue` | 实际重量 |
| `targetReps` | `Int` | 目标次数 |
| `actualReps` | `WorkoutValue` | 实际次数 |
| `trainingDuration` | `WorkoutValue` | 该组训练时长，单位秒 |
| `restTime` | `Double` | 该组后休息时间，单位秒 |
| `notes` | `String` | 导出备注，始终存在，可能为空字符串 |

## WorkoutValue

`WorkoutValue` 是日志中的联合类型，用于同时表示有效数值和跳过状态。

### 数值情况

```json
{ "value": 45.0 }
```

### 跳过情况

```json
{ "na": "N/A" }
```

### 规则

1. 实际完成的训练组使用 `value`
2. 跳过的训练组使用 `na`
3. `na` 的值固定是 `"N/A"`
4. `actualWeight.value` 可以为 `0.0`，这表示自重动作，不表示跳过

## 备注字段的真实语义

当前应用不会只导出用户在弹窗里输入的备注，而是会按下面规则生成 `notes`：

1. 只有计划备注：直接导出计划备注
2. 只有用户备注：直接导出用户备注
3. 两者都有：按 `计划备注 | 用户备注` 合并
4. 跳过某组时：
   - 无计划备注：`notes` 为 `放弃`
   - 有计划备注：`notes` 为 `计划备注 | 放弃`
5. 两边都没有：`notes` 为空字符串

示例：

```json
{ "notes": "A1. 哑铃平板卧推 - 控制离心。 | 最后一组略晃" }
```

## 格式约束

### 时间格式

- `workoutDate`: `yyyy年M月d日`
- `startTime`: `HH:mm`
- `endTime`: `HH:mm`
- `totalDuration`: `mm:ss` 或 `HH:mm:ss`

### 数值格式

- `targetWeight`: `Double`
- `targetReps`: `Int`
- `restTime`: `Double`
- `WorkoutValue.value`: `Double`

## AI / 数据处理建议

1. 判断动作是否跳过时，不要只看 `notes`；应优先检查 `actualWeight`、`actualReps`、`trainingDuration` 是否为 `na`
2. 分析训练表现时，可把 `notes` 当作额外上下文，但它不是结构化字段
3. 如果 `exercise` 名称本身是超级组名称，具体 A1/A2 信息通常会写在 `notes`
4. 解析日期时，不要假设中间有空格，当前应用输出没有空格

## 最小校验清单

处理日志时至少校验以下项目：

1. 顶层必须有 `workoutName`、`workoutDate`、`startTime`、`endTime`、`totalDuration`、`entries`
2. 每个 `entry` 必须有 9 个字段
3. `WorkoutValue` 只能是 `{ "value": number }` 或 `{ "na": "N/A" }`
4. `setOrder` 应从 `1` 开始，且同一动作内通常递增
