import XCTest
@testable import Fit

final class WorkoutLogRecorderTests: XCTestCase
{
    private var recorder: WorkoutLogRecorder!
    private var logFileManager: EnhancedWorkoutLogFileManager!
    private var generatedLogURLs: [URL] = []

    override func setUp()
    {
        super.setUp()
        recorder = WorkoutLogRecorder()
        logFileManager = EnhancedWorkoutLogFileManager()
    }

    override func tearDown()
    {
        generatedLogURLs.forEach
        { url in
            try? FileManager.default.removeItem(at: url)
        }

        generatedLogURLs.removeAll()
        recorder = nil
        logFileManager = nil
        super.tearDown()
    }

    func testRecordCompletedSet_preservesPlanNoteWhenUserNoteIsEmpty() throws
    {
        let note = try recordSingleSetAndReadExportedNote(
            planNote: "A1. 哑铃平板卧推 - 17.5kg。",
            userNote: ""
        )

        XCTAssertEqual(note, "A1. 哑铃平板卧推 - 17.5kg。")
    }

    func testRecordCompletedSet_preservesUserNoteWhenPlanNoteIsEmpty() throws
    {
        let note = try recordSingleSetAndReadExportedNote(
            planNote: nil,
            userNote: "最后两次借力"
        )

        XCTAssertEqual(note, "最后两次借力")
    }

    func testRecordCompletedSet_mergesPlanAndUserNotes() throws
    {
        let note = try recordSingleSetAndReadExportedNote(
            planNote: "A1. 哑铃平板卧推 - 17.5kg。",
            userNote: "最后两次借力"
        )

        XCTAssertEqual(note, "A1. 哑铃平板卧推 - 17.5kg。 | 最后两次借力")
    }

    private func recordSingleSetAndReadExportedNote(planNote: String?, userNote: String) throws -> String
    {
        let exercise = Exercise(name: "超级组 A：胸背对抗")
        let exerciseSet = ExerciseSet(
            exercise: exercise,
            targetReps: 10,
            targetWeight: 17.5,
            restTime: 90,
            notes: planNote
        )
        let workoutPlan = WorkoutPlan(
            name: "测试计划",
            duration: 30,
            exercises: [exerciseSet]
        )

        let outputURL = logFileManager.getLogFileURL()
        generatedLogURLs.append(outputURL)
        try? FileManager.default.removeItem(at: outputURL)

        recorder.startWorkout(workoutPlan: workoutPlan)
        recorder.startExercise(exercise: exercise)
        recorder.recordCompletedSet(
            exerciseSet: exerciseSet,
            actualReps: 10,
            actualWeight: 17.5,
            notes: userNote
        )

        XCTAssertTrue(recorder.finishWorkout(workoutPlan: workoutPlan))

        let data = try Data(contentsOf: outputURL)
        let workoutLog = try JSONDecoder().decode(WorkoutLog.self, from: data)

        guard let entry = workoutLog.entries.first
        else
        {
            XCTFail("日志中应至少存在一条训练记录")
            return ""
        }

        return entry.notes
    }
}
