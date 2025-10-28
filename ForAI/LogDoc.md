# 训练日志 JSON 格式说明文档

## 📋 文档概述

### 文档目的

本文档详细说明了 Fit 应用训练日志系统的 JSON 数据格式，旨在为 AI 系统和技术人员提供清晰的数据结构说明，便于训练日志数据的解析、处理和分析。

## 📊 JSON 结构示例

### 完整 JSON 示例

```json
{
  "workoutName": "A组卧推深蹲",
  "workoutDate": "2025年10月14日",
  "startTime": "10:31",
  "endTime": "11:20",
  "totalDuration": "00:49:30",
  "entries": [
    {
      "exercise": "杠铃卧推",
      "setOrder": 1,
      "targetWeight": 45.0,
      "actualWeight": {
        "value": 45.0
      },
      "targetReps": 5,
      "actualReps": {
        "value": 5.0
      },
      "trainingDuration": {
        "value": 35.5
      },
      "restTime": 90.0,
      "notes": ""
    },
    {
      "exercise": "杠铃卧推",
      "setOrder": 2,
      "targetWeight": 45.0,
      "actualWeight": {
        "value": 45.0
      },
      "targetReps": 5,
      "actualReps": {
        "value": 5.0
      },
      "trainingDuration": {
        "value": 42.3
      },
      "restTime": 90.0,
      "notes": ""
    },
    {
      "exercise": "杠铃深蹲",
      "setOrder": 1,
      "targetWeight": 62.5,
      "actualWeight": {
        "na": "N/A"
      },
      "targetReps": 5,
      "actualReps": {
        "na": "N/A"
      },
      "trainingDuration": {
        "na": "N/A"
      },
      "restTime": 120.0,
      "notes": "放弃"
    }
  ]
}
```

## 🔧 字段详细说明

### 顶层对象 (WorkoutLog)

| 字段名        | 类型   | 含义         | 格式要求                 | 示例值                | 必填 |
| ------------- | ------ | ------------ | ------------------------ | --------------------- | ---- |
| workoutName   | String | 训练计划名称 | UTF-8 字符串，长度 1-100 | "A 组卧推深蹲"        | ✅   |
| workoutDate   | String | 训练日期     | "yyyy 年 M 月 d 日"格式  | "2025 年 10 月 14 日" | ✅   |
| startTime     | String | 开始时间     | "HH:mm" 24 小时制        | "10:31"               | ✅   |
| endTime       | String | 结束时间     | "HH:mm" 24 小时制        | "11:20"               | ✅   |
| totalDuration | String | 总训练时长   | "HH:mm:ss"或"mm:ss"格式  | "00:49:30"            | ✅   |
| entries       | Array  | 训练条目列表 | WorkoutLogEntry 对象数组 | 见下方说明            | ✅   |

### 训练条目对象 (WorkoutLogEntry)

| 字段名           | 类型         | 含义     | 格式要求                  | 示例值     | 必填 |
| ---------------- | ------------ | -------- | ------------------------- | ---------- | ---- |
| exercise         | String       | 动作名称 | UTF-8 字符串，长度 1-50   | "杠铃卧推" | ✅   |
| setOrder         | Int          | 组序号   | 正整数，从 1 开始         | 1          | ✅   |
| targetWeight     | Double       | 目标重量 | 正数，单位 kg，精度 0.1kg | 45.0       | ✅   |
| actualWeight     | WorkoutValue | 实际重量 | 见特殊值处理说明          | 见下方     | ✅   |
| targetReps       | Int          | 目标次数 | 正整数                    | 5          | ✅   |
| actualReps       | WorkoutValue | 实际次数 | 见特殊值处理说明          | 见下方     | ✅   |
| trainingDuration | WorkoutValue | 训练时长 | 见特殊值处理说明，单位秒  | 见下方     | ✅   |
| restTime         | Double       | 组间休息 | 正数，单位秒              | 90.0       | ✅   |
| notes            | String       | 备注     | UTF-8 字符串，长度 0-200  | ""、"放弃" | ✅   |

## 🎯 特殊值处理规则

### WorkoutValue 联合类型

`WorkoutValue`是一个联合类型，用于处理数值和"N/A"特殊情况：

#### 数值情况 (实际完成的训练)

```json
{
  "value": 45.0
}
```

#### N/A 情况 (跳过的训练)

```json
{
  "na": "N/A"
}
```

#### 处理规则

1. **实际完成的训练组**：使用`value`字段存储实际数值

   - `actualWeight.value`：实际重量（kg）
   - `actualReps.value`：实际次数（转换为 Double 类型）
   - `trainingDuration.value`：实际训练时长（秒）

2. **跳过的训练组**：使用`na`字段存储"N/A"字符串

   - 当用户跳过某个训练组时，所有实际值字段都使用`{"na": "N/A"}`格式
   - `notes`字段通常设置为"放弃"

3. **数据转换规则**：
   - 数值类型保留 1 位小数
   - N/A 值统一使用大写"N/A"
   - 解析时应检查哪个字段存在来区分情况

## ✅ 数据验证规则

### 必填字段验证

- 所有顶层字段都必须存在
- 所有 entry 字段都必须存在
- 不允许 null 值

### 数据格式验证

#### 数值范围验证

```javascript
// targetWeight和actualWeight.value
{
  "minimum": 0,
  "maximum": 1000,
  "type": "number",
  "precision": 0.1
}

// targetReps和actualReps.value
{
  "minimum": 1,
  "maximum": 100,
  "type": "integer"
}

// restTime
{
  "minimum": 0,
  "maximum": 3600,
  "type": "number"
}
```

#### 时间格式验证

```javascript
// workoutDate格式：yyyy年M月d日
{
  "pattern": "^\\d{4}年\\d{1,2}月\\d{1,2}日$",
  "examples": ["2025年10月14日", "2024年1月5日"]
}

// startTime和endTime格式：HH:mm
{
  "pattern": "^([01]?[0-9]|2[0-3]):[0-5][0-9]$",
  "examples": ["09:00", "14:30", "23:59"]
}

// totalDuration格式：HH:mm:ss或mm:ss
{
  "pattern": "^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$|^[0-5]?[0-9]:[0-5][0-9]$",
  "examples": ["00:49:30", "49:30", "01:15:00"]
}
```

#### WorkoutValue 验证

```javascript
{
  "oneOf": [
    {
      "type": "object",
      "properties": {
        "value": {
          "type": "number",
          "minimum": 0
        }
      },
      "required": ["value"],
      "additionalProperties": false
    },
    {
      "type": "object",
      "properties": {
        "na": {
          "type": "string",
          "enum": ["N/A"]
        }
      },
      "required": ["na"],
      "additionalProperties": false
    }
  ]
}
```

## 🚀 使用场景和最佳实践

### AI 系统集成场景

#### 1. 训练进度跟踪

```python
def track_progress(current_workout, previous_workouts):
    """
    跟踪训练进度变化
    """
    current_date = parse_date(current_workout['workoutDate'])

    # 找到相同训练计划的历史记录
    similar_workouts = [w for w in previous_workouts
                       if w['workoutName'] == current_workout['workoutName']]

    if not similar_workouts:
        return None

    # 计算强度提升
    current_intensity = calculate_average_intensity(current_workout)
    previous_intensity = calculate_average_intensity(similar_workouts[-1])

    improvement = ((current_intensity - previous_intensity) / previous_intensity) * 100

    return {
        'improvement_percentage': improvement,
        'current_intensity': current_intensity,
        'previous_intensity': previous_intensity
    }
```

#### 2. 数据验证和清理

```python
def validate_workout_json(json_data):
    """
    验证训练日志JSON数据的完整性和正确性
    """
    try:
        workout = json.loads(json_data)
    except json.JSONDecodeError:
        return False, "Invalid JSON format"

    # 检查必填字段
    required_fields = ['workoutName', 'workoutDate', 'startTime', 'endTime', 'totalDuration', 'entries']
    for field in required_fields:
        if field not in workout:
            return False, f"Missing required field: {field}"

    # 验证每个entry
    for i, entry in enumerate(workout['entries']):
        entry_validation = validate_entry(entry, i)
        if not entry_validation[0]:
            return entry_validation

    return True, "Validation passed"
```
