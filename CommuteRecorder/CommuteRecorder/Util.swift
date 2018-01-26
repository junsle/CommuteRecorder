//
//  Util.swift
//  CommuteRecorder
//
//  Created by 마로 on 2018. 1. 23..
//  Copyright © 2018년 maro. All rights reserved.
//

import Foundation
import UIKit

public func normalToast( _ text:String, on viewCtrl:UIViewController )
{
    let alertController = UIAlertController(title: "", message: text, preferredStyle: .alert)
    viewCtrl.present(alertController, animated: true, completion: nil)
    let time = DispatchTime.now() + .milliseconds( 2 * 1000 )
    DispatchQueue.main.asyncAfter(deadline: time, execute: {
        alertController.dismiss(animated: true, completion: nil)
    })
}

public func dateToMMddString(date:Date?) -> String?{
    if let val = date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: val)
    }
    return nil
}

public func dateToHHmmString(date:Date?) -> String?{
    if let val = date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: val)
    }
    return nil
}

public func dateToOriginalHHmmString(date:Date?) -> String?{
    if let val = date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        return formatter.string(from: val)
    }
    return nil
}

public func dateToString(date:Date?) -> String?{
    if let val = date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: val)
    }
    return nil
}

public func stringToDate(date:String) -> Date? {
    // date 형태로 바꿈
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let resultDate = dateFormatter.date(from: date)
    
    return resultDate
}

public func 날짜크기비교(targetDate:Date){
    let cal = Calendar(identifier: .gregorian)
    var componenets = cal.dateComponents([.day], from: Date(), to: targetDate)
}

public func checkDayOfTheWeek() -> Int? {
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: Date())
    return weekDay
}

public func resetWokringTime(){
    WorkingDataManage.sharedManager.월출근 = ""
    WorkingDataManage.sharedManager.월퇴근 = ""
    WorkingDataManage.sharedManager.화출근 = ""
    WorkingDataManage.sharedManager.화퇴근 = ""
    WorkingDataManage.sharedManager.수출근 = ""
    WorkingDataManage.sharedManager.수퇴근 = ""
    WorkingDataManage.sharedManager.목출근 = ""
    WorkingDataManage.sharedManager.목퇴근 = ""
    WorkingDataManage.sharedManager.금출근 = ""
    WorkingDataManage.sharedManager.금퇴근 = ""
    WorkingDataManage.sharedManager.휴가 = 0
    WorkingDataManage.sharedManager.출근중 = false
}
