import XCTest
@testable import Fit

final class JSONWorkoutParserTests: XCTestCase
{
    private var parser: JSONWorkoutParser!

    override func setUp()
    {
        super.setUp()
        parser = JSONWorkoutParser()
    }

    override func tearDown()
    {
        parser = nil
        super.tearDown()
    }

    func testParseWorkoutPlan_supportsSuperSetSequenceAndNotes() throws
    {
        let json = """
        {
          "训练计划名称": "2月16日 上肢代谢密度训练 (周一升级版)",
          "日期": "2026-02-16",
          "练习项目": [
            {
              "练习名称": "超级组 A：胸背对抗 (连续做完A1+A2再休息)",
              "组数设置": [
                {
                  "组数类型": "正式组",
                  "目标次数": 10,
                  "目标重量": 17.5,
                  "休息时间": 0,
                  "备注": "A1. 哑铃平板卧推 - 17.5kg。"
                },
                {
                  "组数类型": "正式组",
                  "目标次数": 12,
                  "目标重量": 40,
                  "休息时间": 90,
                  "备注": "A2. 坐姿划船 - 40kg。"
                }
              ]
            },
            {
              "练习名称": "主动休息：左踝加固 (插在超级组之间)",
              "组数设置": [
                {
                  "组数类型": "间歇组",
                  "目标次数": 1,
                  "目标重量": 0,
                  "休息时间": 30,
                  "备注": "左脚闭眼单腿站立 45秒。"
                }
              ]
            }
          ]
        }
        """

        let workoutPlan = try parser.parseWorkoutPlan(from: Data(json.utf8))

        XCTAssertEqual(workoutPlan.name, "2月16日 上肢代谢密度训练 (周一升级版)")
        XCTAssertEqual(workoutPlan.exercises.count, 3)

        XCTAssertEqual(workoutPlan.exercises[0].exercise.name, "超级组 A：胸背对抗 (连续做完A1+A2再休息)")
        XCTAssertEqual(workoutPlan.exercises[1].exercise.name, "超级组 A：胸背对抗 (连续做完A1+A2再休息)")
        XCTAssertEqual(workoutPlan.exercises[2].exercise.name, "主动休息：左踝加固 (插在超级组之间)")

        XCTAssertEqual(workoutPlan.exercises[0].targetWeight, 17.5, accuracy: 0.0001)
        XCTAssertEqual(workoutPlan.exercises[1].targetWeight, 40.0, accuracy: 0.0001)

        XCTAssertEqual(workoutPlan.exercises[0].notes, "A1. 哑铃平板卧推 - 17.5kg。")
        XCTAssertEqual(workoutPlan.exercises[1].notes, "A2. 坐姿划船 - 40kg。")
        XCTAssertEqual(workoutPlan.exercises[2].notes, "左脚闭眼单腿站立 45秒。")
    }

    func testParseWorkoutPlan_throwsWhenAnySetFieldIsInvalid()
    {
        let json = """
        {
          "训练计划名称": "错误计划",
          "练习项目": [
            {
              "练习名称": "超级组 A",
              "组数设置": [
                {
                  "目标次数": 10,
                  "目标重量": "40kg",
                  "休息时间": 90
                }
              ]
            }
          ]
        }
        """

        XCTAssertThrowsError(try parser.parseWorkoutPlan(from: Data(json.utf8)))
        { error in
            guard case let JSONParseError.invalidSetConfig(exerciseName, setIndex, reason) = error
            else
            {
                XCTFail("应返回 invalidSetConfig，但收到 \(error)")
                return
            }

            XCTAssertEqual(exerciseName, "超级组 A")
            XCTAssertEqual(setIndex, 1)
            XCTAssertFalse(reason.isEmpty)
        }
    }
}
