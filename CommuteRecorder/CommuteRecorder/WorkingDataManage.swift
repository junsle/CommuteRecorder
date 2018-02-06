//
//  WorkingDataManage.swift
//  CommuteRecorder
//
//  Created by 마로 on 2018. 1. 23..
//  Copyright © 2018년 maro. All rights reserved.
//

import Foundation

class WorkingDataManage {
    static let sharedManager: WorkingDataManage = {
        return WorkingDataManage()
    }()
    
    var defaults = UserDefaults(suiteName: "group.com.maro.CommuteRecorder")

    var 월출근:String {
        get {
            if let mon = defaults?.object(forKey: "KEY_USER_MON") as? String {
                return mon
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_MON")
        }
    }
    
    var 월퇴근:String {
        get {
            if let mon = defaults?.object(forKey: "KEY_USER_MON_EXIT") as? String {
                return mon
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_MON_EXIT")
        }
    }
    
    var 화출근:String {
        get {
            if let tue = defaults?.object(forKey: "KEY_USER_TUE") as? String {
                return tue
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_TUE")
        }
    }
    
    var 화퇴근:String {
        get {
            if let tue = defaults?.object(forKey: "KEY_USER_TUE_EXIT") as? String {
                return tue
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_TUE_EXIT")
        }
    }
    
    var 수출근:String {
        get {
            if let wed = defaults?.object(forKey: "KEY_USER_WED") as? String {
                return wed
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_WED")
        }
    }
    
    var 수퇴근:String {
        get {
            if let wed = defaults?.object(forKey: "KEY_USER_WED_EXIT") as? String {
                return wed
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_WED_EXIT")
        }
    }
    
    var 목출근:String {
        get {
            if let thu = defaults?.object(forKey: "KEY_USER_THU") as? String {
                return thu
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_THU")
        }
    }
    
    var 목퇴근:String {
        get {
            if let thu = defaults?.object(forKey: "KEY_USER_THU_EXIT") as? String {
                return thu
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_THU_EXIT")
        }
    }
    
    var 금출근:String {
        get {
            if let fri = defaults?.object(forKey: "KEY_USER_FRI") as? String {
                return fri
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_FRI")
        }
    }
    
    var 금퇴근:String {
        get {
            if let fri = defaults?.object(forKey: "KEY_USER_FRI_EXIT") as? String {
                return fri
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_FRI_EXIT")
        }
    }
    
    var 최근기록시간:String {
        get {
            if let fri = defaults?.object(forKey: "KEY_USER_LATEST") as? String {
                return fri
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_LATEST")
        }
    }
    
    var 최근기록주:String {
        get {
            if let fri = defaults?.object(forKey: "KEY_USER_LATEST_WEEK") as? String {
                return fri
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_LATEST_WEEK")
        }
    }
    
    var 이름:String {
        get {
            if let fri = defaults?.object(forKey: "KEY_USER_NAME") as? String {
                return fri
            }
            return ""
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_NAME")
        }
    }
    
    var 출근중:Bool {
        get {
            if let checkIn = defaults?.object(forKey: "KEY_USER_CHECKIN") as? Bool {
                return checkIn
            }
            return false
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_CHECKIN")
        }
    }
    
    var 휴가:Float {
        get {
            if let vacation = defaults?.object(forKey: "KEY_USER_VACATION") as? Float {
                return vacation
            }
            return 0
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_VACATION")
        }
    }
    
    var 제외:Float {
        get {
            if let vacation = defaults?.object(forKey: "KEY_USER_EX") as? Float {
                return vacation
            }
            return 0
        }
        set {
            defaults?.set(newValue, forKey: "KEY_USER_EX")
        }
    }
}
