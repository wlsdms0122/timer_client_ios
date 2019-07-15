//
//  ProductivityViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit
import RxDataSources

class ProductivityViewReactor: Reactor {
    // MARK: - constants
    private static let MAX_TIME_INTERVAL = TimeInterval(99 * Constants.Time.hour + 59 * Constants.Time.minute + 59)
    
    enum Time: Int {
        case hour
        case minute
        case second
    }
    
    enum Action {
        case updateTime(Int)
        case tapTimeKey(Time)
        case clearTimer
        case tapTimeSetLoop
        case addTimer
        case timerSelected(IndexPath)
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setSumOfTimers(TimeInterval)
        case setIsTimeSetLoop(Bool)
        
        case appendTimer(TimerInfo)
        case setSelectedIndexPath(IndexPath)
        
        case setMaxSelectableTime(Time)
    }
    
    struct State {
        var time: Int // The time that user inputed
        var timer: TimeInterval // The time of timer
        var sumOfTimers: TimeInterval // The time that sum of all timers
        var isTimeSetLoop: Bool // Is the time set loop
        
        var timers: [TimerInfo]
        var selectedIndexPath: IndexPath
        
        var maxSelectableTime: Time
        var canTimeSetStart: Bool
        var shouldSectionReload: Bool
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimeSetServicePorotocol
    
    let timeSetInfo: TimeSetInfo // Default timer set info
    
    init(timerService: TimeSetServicePorotocol) {
        self.timerService = timerService
        
        // Create default a timer
        let info = TimerInfo(title: "1 번째 타이머")
        
        // Create default timer set and add default a timer
        self.timeSetInfo = TimeSetInfo(name: "", description: "")
        self.timeSetInfo.timers.append(info)
 
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sumOfTimers: 0,
                                  isTimeSetLoop: false,
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  maxSelectableTime: .hour,
                                  canTimeSetStart: false,
                                  shouldSectionReload: true)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTime(time):
            var setMaxSelectableTimeKey: Observable<Mutation>
            if currentState.timer + TimeInterval(time) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                // Call mutate recursivly through max time value
                return mutate(action: .updateTime(Int(ProductivityViewReactor.MAX_TIME_INTERVAL - currentState.timer)))
            } else if currentState.timer + TimeInterval(time * Constants.Time.minute) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                // Get max selectable time
                setMaxSelectableTimeKey = .just(.setMaxSelectableTime(.second))
            } else if currentState.timer + TimeInterval(time * Constants.Time.hour) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                setMaxSelectableTimeKey = .just(.setMaxSelectableTime(.minute))
            } else {
                setMaxSelectableTimeKey = .just(.setMaxSelectableTime(.hour))
            }
            
            return .concat(.just(Mutation.setTime(time)), setMaxSelectableTimeKey)
        case let .tapTimeKey(key):
            var timeInterval = currentState.timer
            let sumOfTimers = currentState.sumOfTimers - timeInterval
            
            switch key {
            case .hour:
                timeInterval += Double(currentState.time * Constants.Time.hour)
            case .minute:
                timeInterval += Double(currentState.time * Constants.Time.minute)
            case .second:
                timeInterval += Double(currentState.time)
            }
            
            let setTimer = Observable.just(Mutation.setTimer(timeInterval))
            let setSumOfTimers = Observable.just(Mutation.setSumOfTimers(sumOfTimers + timeInterval))
            let setTime = mutate(action: .updateTime(0))
            
            return .concat(setTimer, setSumOfTimers, setTime)
        case .clearTimer:
            let setTimer = Observable.just(Mutation.setTimer(0))
            let setSumOfTimers = Observable.just(Mutation.setSumOfTimers(currentState.sumOfTimers - currentState.timer))
            let setTime = mutate(action: .updateTime(0))
            
            return .concat(setTimer, setTime, setSumOfTimers)
        case .tapTimeSetLoop:
            timeSetInfo.isLoop.toggle()
            return .just(.setIsTimeSetLoop(timeSetInfo.isLoop))
        case .addTimer:
            // Create default a timer (set 0)
            let index = timeSetInfo.timers.count + 1
            let info = TimerInfo(title: "\(index) 번째 타이머")
            // Add timer
            timeSetInfo.timers.append(info)
            
            let appendSectionItem = Observable.just(Mutation.appendTimer(info))
            let setSelectIndexPath = mutate(action: .timerSelected(IndexPath(row: index - 1, section: 0)))
            
            return .concat(appendSectionItem, setSelectIndexPath)
        case let .timerSelected(indexPath):
            let setSelectedIndexPath = Observable.just(Mutation.setSelectedIndexPath(indexPath))
            let setTimer = Observable.just(Mutation.setTimer(timeSetInfo.timers[indexPath.row].endTime))
            let setTime = mutate(action: .updateTime(0))
            
            return .concat(setSelectedIndexPath, setTimer, setTime)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setTimer(timeInterval):
            // Update time
            state.timers[state.selectedIndexPath.row].endTime = timeInterval
            state.timer = timeInterval
            
            state.canTimeSetStart = state.timers.count > 1 || state.timer > 0
            return state
        case let .setSumOfTimers(timeInterval):
            state.sumOfTimers = timeInterval
            return state
        case let .setIsTimeSetLoop(isTimeSetLoop):
            state.isTimeSetLoop = isTimeSetLoop
            return state
        case let .appendTimer(info):
            state.timers.append(info)
            
            state.canTimeSetStart = true
            state.shouldSectionReload = true
            return state
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
        case let .setMaxSelectableTime(time):
            state.maxSelectableTime = time
            return state
        }
    }
}
