//
//  ViewController.swift
//  CommuteRecorder
//
//  Created by 마로 on 2018. 1. 16..
//  Copyright © 2018년 maro. All rights reserved.
//

import UIKit
import CircularSlider
import UserNotifications
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var workingIcon: UIImageView!
    @IBOutlet weak var startEndWeekLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    var isCheckIn:Bool = false
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCircularSlider()
        setupTapGesture()
        
        nameTextField.delegate = self
        nameTextField.text = WorkingDataManage.sharedManager.이름
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
    // my selector that was defined above
    @objc func willEnterForeground() {
        workingIcon.isHidden = true

        if !WorkingDataManage.sharedManager.출근중 {
            checkInBtn.setTitle("출근", for: .normal)
            workingIcon.isHidden = true
        }else {
            checkInBtn.setTitle("퇴근", for: .normal)
            workingIcon.isHidden = false
            workingIcon.blink()
        }
        
        let thisWeek:String = "\(dateToMMddString(date: Date().startOfWeek) ?? "") ~ \(dateToMMddString(date: Date().endOfWeek) ?? "")"
        startEndWeekLabel.text = thisWeek
        
        if WorkingDataManage.sharedManager.최근기록주 != thisWeek && WorkingDataManage.sharedManager.최근기록주 != "" { // 주 변경시 리셋 그러나 초기버전 리셋방지
            resetWokringTime()
        }
            
        WorkingDataManage.sharedManager.최근기록주 = thisWeek
        
        totalWorkingTime()
        
        if WorkingDataManage.sharedManager.출근중 {
            checkInBtn.setTitle("퇴근", for: .normal)
            isCheckIn = true
            workingIcon.isHidden = false
            workingIcon.blink()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isCheckIn {
            checkInBtn.setTitle("출근", for: .normal)
            workingIcon.isHidden = true
        }else {
            checkInBtn.setTitle("퇴근", for: .normal)
            workingIcon.isHidden = false
            workingIcon.blink()
        }
        
        let thisWeek:String = "\(dateToMMddString(date: Date().startOfWeek) ?? "") ~ \(dateToMMddString(date: Date().endOfWeek) ?? "")"
        startEndWeekLabel.text = thisWeek
        
        if WorkingDataManage.sharedManager.최근기록주 != thisWeek && WorkingDataManage.sharedManager.최근기록주 != "" { // 주 변경시 리셋 그러나 초기버전 리셋방지
            resetWokringTime()
        }
        
        WorkingDataManage.sharedManager.최근기록주 = thisWeek
        
        totalWorkingTime()
        
        if WorkingDataManage.sharedManager.출근중 {
            checkInBtn.setTitle("퇴근", for: .normal)
            isCheckIn = true
            workingIcon.isHidden = false
            workingIcon.blink()
        }
    }
    
    @IBAction func clickConfirmWorkingTime(_ sender: Any) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "clickConfirmWorkingTime" as NSObject,
            AnalyticsParameterItemName: "clickConfirmWorkingTime" as NSObject,
            AnalyticsParameterContentType: "cont" as NSObject
            ])
        let infoCtrl = WorkingTimeCheckViewNavigationCtrl()
        infoCtrl.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.present(infoCtrl, animated: true) {}
    }
    
    @IBAction func clickCheckIn(_ sender: Any) {
        if WorkingDataManage.sharedManager.이름 == "" {
            normalToast("이름을 입력해주세요", on: self)
            return
        }
        
        let checkInTime:String = dateToHHmmString(date: Date()) ?? ""
        if isCheckIn {
            checkInBtn.setTitle("출근", for: .normal)
            workingIcon.isHidden = true
            isCheckIn = false
            workingIcon.stopAni()
            normalToast("\(checkInTime) 퇴근", on: self)
            setCheckIn(isCheckIn: false)
            WorkingDataManage.sharedManager.출근중 = false
            createMsg(msg: "\(WorkingDataManage.sharedManager.이름) \(checkInTime) 퇴근 \n 오늘일한시간 : \(todayWorkingTime() ?? "")\n 이번주잔여시간 : \(totalWorkingTime() ?? "")")
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "clickCommute" as NSObject,
                AnalyticsParameterItemName: "checkOut" as NSObject,
                AnalyticsParameterContentType: "cont" as NSObject
                ])
        }else {
            checkInBtn.setTitle("퇴근", for: .normal)
            isCheckIn = true
            workingIcon.isHidden = false
            workingIcon.blink()
            normalToast("\(checkInTime) 출근", on: self)
            setCheckIn(isCheckIn: true)
            WorkingDataManage.sharedManager.출근중 = true
            createMsg(msg: "\(WorkingDataManage.sharedManager.이름) \(checkInTime) 출근 \n이번주잔여시간 : \(totalWorkingTime() ?? "")\n")
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "clickCommute" as NSObject,
                AnalyticsParameterItemName: "checkIn" as NSObject,
                AnalyticsParameterContentType: "cont" as NSObject
                ])
        }
    }
    
    func setCheckIn(isCheckIn:Bool){
        if let val = dateToString(date: Date()) {
            if 2 == checkDayOfTheWeek(){  // 월
                if isCheckIn {
                    WorkingDataManage.sharedManager.월출근 = val
                    WorkingDataManage.sharedManager.월퇴근 = ""
                }else {
                    WorkingDataManage.sharedManager.월퇴근 = val
                }
            }else if 3 == checkDayOfTheWeek(){  // 화
                if isCheckIn {
                    WorkingDataManage.sharedManager.화출근 = val
                    WorkingDataManage.sharedManager.화퇴근 = ""
                }else {
                    WorkingDataManage.sharedManager.화퇴근 = val
                }
            }else if 4 == checkDayOfTheWeek(){  // 수
                if isCheckIn {
                    WorkingDataManage.sharedManager.수출근 = val
                    WorkingDataManage.sharedManager.수퇴근 = ""
                }else {
                    WorkingDataManage.sharedManager.수퇴근 = val
                }
            }else if 5 == checkDayOfTheWeek(){  // 목
                if isCheckIn {
                    WorkingDataManage.sharedManager.목출근 = val
                    WorkingDataManage.sharedManager.목퇴근 = ""
                }else {
                    WorkingDataManage.sharedManager.목퇴근 = val
                }
            }else if 6 == checkDayOfTheWeek(){  // 금
                if isCheckIn {
                    WorkingDataManage.sharedManager.금출근 = val
                    WorkingDataManage.sharedManager.금퇴근 = ""
                    setNotification()
                    // 알람 설정
                }else {
                    WorkingDataManage.sharedManager.금퇴근 = val
                }
            }
        }
        totalWorkingTime()
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
//        let content = UNMutableNotificationContent()
//        content.title = NSString.localizedUserNotificationString(forKey: "Wake up!", arguments: nil)
//        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!",
//                                                                arguments: nil)
//
//        // Configure the trigger for a 7am wakeup.
//        var dateInfo = DateComponents()
//        dateInfo.hour = 7
//        dateInfo.minute = 0
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
//
//        // Create the request object.
//        let request = UNNotificationRequest(identifier: "MorningAlarm", content: content, trigger: trigger)
    }
    
    @IBAction func clickVacation(_ sender: Any) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "clickVacation" as NSObject,
            AnalyticsParameterItemName: "click" as NSObject,
            AnalyticsParameterContentType: "cont" as NSObject
            ])

        let actionSheet = UIAlertController(title: "휴가선택", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction( UIAlertAction(title: "반차 (+4시간)", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "clickVacation" as NSObject,
                AnalyticsParameterItemName: "click4" as NSObject,
                AnalyticsParameterContentType: "cont" as NSObject
                ])
            WorkingDataManage.sharedManager.휴가 = WorkingDataManage.sharedManager.휴가 + 4.0
            self.totalWorkingTime()
        }))
        actionSheet.addAction( UIAlertAction(title: "일차 (+8시간)", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "clickVacation" as NSObject,
                AnalyticsParameterItemName: "click8" as NSObject,
                AnalyticsParameterContentType: "cont" as NSObject
                ])
            WorkingDataManage.sharedManager.휴가 = WorkingDataManage.sharedManager.휴가 + 8.0
            self.totalWorkingTime()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true) { () -> Void in}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setupCircularSlider() {
        circularSlider.delegate = self
    }
    
    fileprivate func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func totalWorkingTime(isMin:Bool = false) -> String?{
        var totalMin:Float = 40 * 60
        let cal = Calendar(identifier: .gregorian)
        
        if let enter = stringToDate(date: WorkingDataManage.sharedManager.월출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.월퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: WorkingDataManage.sharedManager.화출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.화퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: WorkingDataManage.sharedManager.수출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.수퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: WorkingDataManage.sharedManager.목출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.목퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        if let enter = stringToDate(date: WorkingDataManage.sharedManager.금출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.금퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
            if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                workingTime = workingTime - 60
            }
            totalMin = totalMin - workingTime
        }
        
        totalMin = totalMin - (WorkingDataManage.sharedManager.휴가 * 60)
        
        self.circularSlider.setValue(totalMin/60, animated: true)
        
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
    
    private func todayWorkingTime() -> String?{
        var totalMin:Float = 0
        let cal = Calendar(identifier: .gregorian)

        if 2 == checkDayOfTheWeek(){  // 월
            if let enter = stringToDate(date: WorkingDataManage.sharedManager.월출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.월퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 3 == checkDayOfTheWeek(){  // 화
            if let enter = stringToDate(date: WorkingDataManage.sharedManager.화출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.화퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 4 == checkDayOfTheWeek(){  // 수
            if let enter = stringToDate(date: WorkingDataManage.sharedManager.수출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.수퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 5 == checkDayOfTheWeek(){  // 목
            if let enter = stringToDate(date: WorkingDataManage.sharedManager.목출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.목퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                var workingTime = (Float(comps.hour ?? 0) * 60 +  Float(comps.minute ?? 0))
                if workingTime > 4 * 60 { // 4시간 보다 많이 한 경우 점심시간 1시간을 제외 한다.
                    workingTime = workingTime - 60
                }
                totalMin = workingTime
            }
        }else if 6 == checkDayOfTheWeek(){  // 금
            if let enter = stringToDate(date: WorkingDataManage.sharedManager.금출근), let exit =  stringToDate(date: WorkingDataManage.sharedManager.금퇴근) {
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
}

// MARK: - 네트워크
extension ViewController {
    fileprivate func createMsg(msg:String = ""){
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        var chatIds:[String] = []
//        chatIds.append( "000000000000068d" )
        chatIds.append( "00000000000003u4" ) // 나혼자방
        
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
}

// MARK: - CircularSliderDelegate
extension ViewController: CircularSliderDelegate {
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        let aString = String(value)
        let chars = aString.characters
        if let bIndex = chars.index(of: ".") {
            let nextIndex = chars.index(after: bIndex)
            print(aString[aString.startIndex...nextIndex])
            return Float(aString[aString.startIndex...nextIndex]) ?? 0.0

        }
        return 0.0

    }
}

// MARK: - Util
extension ViewController {
    
}

extension UIView {
    func blink() {
        UIView.animate(withDuration: 1.5, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })
    }
    
    func stopAni(){
        DispatchQueue.main.async {
            self.layer.removeAllAnimations()
        }
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
    
    var 월요일: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var 화요일: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 2, to: sunday)
    }
    
    var 수요일: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 3, to: sunday)
    }
    
    var 목요일: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 4, to: sunday)
    }
    
    var 금요일: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 5, to: sunday)
    }
}

extension String {
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "clickName" as NSObject,
                AnalyticsParameterItemName: "enterName" as NSObject,
                AnalyticsParameterContentType: "cont" as NSObject
                ])
            WorkingDataManage.sharedManager.이름 = text
        }
        hideKeyboard()
        return true
    }
}
