//
//  TodayViewController.swift
//  todayWidget
//
//  Created by 마로 on 2018. 1. 19..
//  Copyright © 2018년 maro. All rights reserved.
//

import UIKit
import NotificationCenter
import UserNotifications

class TodayViewController: UIViewController, NCWidgetProviding {
    var defaults = UserDefaults(suiteName: "group.com.maro.CommuteRecorder")

    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var checkOutBtn: UIButton!
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkInBtn.layer.cornerRadius = 0.5
        checkOutBtn.layer.cornerRadius = 0.5
        if 출근중 {
            checkInBtn.setTitle("출근중", for: .normal)
        }else {
            checkInBtn.setTitle("출근", for: .normal)
        }
        
        
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func clickCheckInBtn(_ sender: Any) {
        let checkInTime:String = dateToHHmmString(date: Date()) ?? ""
        setCheckIn(isCheckIn: true)
        출근중 = true
        checkInBtn.zoomIn()
        createMsg(msg: "\(이름) \(checkInTime) 출근 \n이번주잔여시간 : \(totalWorkingTime() ?? "")\n")
        if 출근중 {
            checkInBtn.setTitle("출근중", for: .normal)
        }else {
            checkInBtn.setTitle("출근", for: .normal)
        }
    }
    
    @IBAction func clickCheckOutBtn(_ sender: Any) {
        let checkInTime:String = dateToHHmmString(date: Date()) ?? ""
        setCheckIn(isCheckIn: false)
        출근중 = false
        checkOutBtn.zoomIn()
        createMsg(msg: "\(이름) \(checkInTime) 퇴근 \n 오늘일한시간 : \(todayWorkingTime() ?? "")\n 이번주잔여시간 : \(totalWorkingTime() ?? "")")
        if 출근중 {
            checkInBtn.setTitle("출근중", for: .normal)
        }else {
            checkInBtn.setTitle("출근", for: .normal)
        }
    }
    
}

// MARK: - 네트워크
extension TodayViewController {
    func setCheckIn(isCheckIn:Bool){
        if let val = dateToString(date: Date()) {
            if 2 == checkDayOfTheWeek(){  // 월
                if isCheckIn {
                    월출근 = val
                    월퇴근 = ""
                }else {
                    월퇴근 = val
                }
            }else if 3 == checkDayOfTheWeek(){  // 화
                if isCheckIn {
                    화출근 = val
                    화퇴근 = ""
                }else {
                    화퇴근 = val
                }
            }else if 4 == checkDayOfTheWeek(){  // 수
                if isCheckIn {
                    수출근 = val
                    수퇴근 = ""
                }else {
                    수퇴근 = val
                }
            }else if 5 == checkDayOfTheWeek(){  // 목
                if isCheckIn {
                    목출근 = val
                    목퇴근 = ""
                }else {
                    목퇴근 = val
                }
            }else if 6 == checkDayOfTheWeek(){  // 금
                if isCheckIn {
                    금출근 = val
                    금퇴근 = ""
                    setNotification()
                }else {
                    금퇴근 = val
                }
            }
            최근기록시간 = val
        }
        totalWorkingTime()
    }
    
    fileprivate func createMsg(msg:String = ""){
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        var chatIds:[String] = []
//        chatIds.append( "000000000000068d" )
        chatIds.append( "00000000000003u4" ) //나혼자
        
        let parameters = ["chatIds": chatIds, "text": msg ] as [String : AnyObject]
        
        //create the url with URL
        let url = URL(string: "https://nexus-mink.ncsoft.com/mink/v1/apis/messages/text/create")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("0ae57416-fb59-11e7-a64f-d70e2d6b1ade", forHTTPHeaderField: "X-API-TOKEN")
        request.addValue("1.0", forHTTPHeaderField: "X-API-VERSION")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func dateToString(date:Date?) -> String?{
        if let val = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter.string(from: val)
        }
        return nil
    }
    
    func checkDayOfTheWeek() -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: Date())
        return weekDay
    }
    
    func dateToHHmmString(date:Date?) -> String?{
        if let val = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: val)
        }
        return nil
    }
    
    func stringToDate(date:String) -> Date? {
        // date 형태로 바꿈
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let resultDate = dateFormatter.date(from: date)
        
        return resultDate
    }
    
    func totalWorkingTime(isMin:Bool = false) -> String?{
        var totalMin:Float = 40 * 60
        let cal = Calendar(identifier: .gregorian)
        
        if let last = stringToDate(date: 최근기록시간), let start =  Date().startOfWeek {
            let comps = cal.dateComponents([.day], from: last  , to: start)
            if comps.day ?? 0 >= 1 { // 한주가 바뀌면 데이터 리셋
                resetWokringTime()
            }
        }
        
        if let enter = stringToDate(date: 월출근), let exit =  stringToDate(date: 월퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: 화출근), let exit =  stringToDate(date: 화퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: 수출근), let exit =  stringToDate(date: 수퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: 목출근), let exit =  stringToDate(date: 목퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: 금출근), let exit =  stringToDate(date: 금퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        totalMin = totalMin - (휴가 * 60)
        
        func showHour() -> String{
            let aString = String(totalMin/60)
            let chars = aString.characters
            if let bIndex = chars.index(of: ".") {
                let nextIndex = chars.index(after: bIndex)
                return aString[aString.startIndex...nextIndex]
            }
            return ""
        }
        
        if !isMin {
            return showHour()
        }else {
            return String(totalMin)
        }
    }
    
    func setNotification(){
        
        // Swift
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = "이번주 근무 완료"
                content.body = "퇴근합시다!!"
                content.sound = UNNotificationSound.default()
                
                if let time = self.totalWorkingTime(isMin:  true){
                    if let min = Int(time) {
                        let date = Date(timeIntervalSinceNow: TimeInterval(min * 60)) //초
                        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                                    repeats: false)
                        // Swift
                        let identifier = "MAROLocalNotification"
                        let request = UNNotificationRequest(identifier: identifier,
                                                            content: content, trigger: trigger)
                        self.center.add(request, withCompletionHandler: { (error) in
                            if let error = error {
                                // Something went wrong
                            }
                        })
                    }
                }
            }
        }
    }
    
    func resetWokringTime(){
        월출근 = ""
        월퇴근 = ""
        화출근 = ""
        화퇴근 = ""
        수출근 = ""
        수퇴근 = ""
        목출근 = ""
        목퇴근 = ""
        금출근 = ""
        금퇴근 = ""
        휴가 = 0
        최근기록시간 = ""
        출근중 = false
    }
    
    func todayWorkingTime() -> String?{
        var totalMin:Float = 0
        let cal = Calendar(identifier: .gregorian)
        
        if 2 == checkDayOfTheWeek(){  // 월
            if let enter = stringToDate(date: 월출근), let exit =  stringToDate(date: 월퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 3 == checkDayOfTheWeek(){  // 화
            if let enter = stringToDate(date: 화출근), let exit =  stringToDate(date: 화퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 4 == checkDayOfTheWeek(){  // 수
            if let enter = stringToDate(date: 수출근), let exit =  stringToDate(date: 수퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 5 == checkDayOfTheWeek(){  // 목
            if let enter = stringToDate(date: 목출근), let exit =  stringToDate(date: 목퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 6 == checkDayOfTheWeek(){  // 금
            if let enter = stringToDate(date: 금출근), let exit =  stringToDate(date: 금퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }
        
        let aString = String(totalMin/60)
        let chars = aString.characters
        if let bIndex = chars.index(of: ".") {
            let nextIndex = chars.index(after: bIndex)
            return aString[aString.startIndex...nextIndex]
        }
        
        return ""
    }
    
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
}

extension UIView {
    
    /**
     Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }
    
    /**
     Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
        }
    }
    
    /**
     Zoom in any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform.identity
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }
    
    /**
     Zoom out any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }
}

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 5, to: sunday)
    }
}
