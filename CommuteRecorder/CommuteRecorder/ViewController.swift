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

class ViewController: UIViewController {
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var workingIcon: UIImageView!
    @IBOutlet weak var startEndWeekLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    var defaults = UserDefaults(suiteName: "group.com.maro.CommuteRecorder")
    var isCheckIn:Bool = false
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCircularSlider()
        setupTapGesture()
        
        nameTextField.delegate = self
        nameTextField.text = 이름
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

        if !출근중 {
            checkInBtn.setTitle("출근", for: .normal)
            workingIcon.isHidden = true
        }else {
            checkInBtn.setTitle("퇴근", for: .normal)
            workingIcon.isHidden = false
            workingIcon.blink()
        }
        
        startEndWeekLabel.text = "\(dateToMMddString(date: Date().startOfWeek) ?? "") ~ \(dateToMMddString(date: Date().endOfWeek) ?? "")"
        
        totalWorkingTime()
        
        if 출근중 {
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
        
        startEndWeekLabel.text = "\(dateToMMddString(date: Date().startOfWeek) ?? "") ~ \(dateToMMddString(date: Date().endOfWeek) ?? "")"
        
        totalWorkingTime()
        
        if 출근중 {
            checkInBtn.setTitle("퇴근", for: .normal)
            isCheckIn = true
            workingIcon.isHidden = false
            workingIcon.blink()
        }
    }
    
    @IBAction func clickConfirmWorkingTime(_ sender: Any) {
        let total:String = "월 : \(dateToHHmmString(date: stringToDate(date: 월출근)) ?? "") ~ \(dateToHHmmString(date:stringToDate(date: 월퇴근)) ?? "" ) \n"
            + "화 : \(dateToHHmmString(date: stringToDate(date: 화출근)) ?? "") ~ \(dateToHHmmString(date:stringToDate(date: 화퇴근)) ?? "" ) \n"
            + "수 : \(dateToHHmmString(date: stringToDate(date: 수출근)) ?? "") ~ \(dateToHHmmString(date:stringToDate(date: 수퇴근)) ?? "" ) \n"
            + "목 : \(dateToHHmmString(date: stringToDate(date: 목출근)) ?? "") ~ \(dateToHHmmString(date:stringToDate(date: 목퇴근)) ?? "" ) \n"
            + "금 : \(dateToHHmmString(date: stringToDate(date: 금출근)) ?? "") ~ \(dateToHHmmString(date:stringToDate(date: 금퇴근)) ?? "" ) \n"
            + "휴가 : \(휴가)\n"
        
        let actionSheet = UIAlertController(title: "이번주 근무 현황", message: total, preferredStyle: UIAlertControllerStyle.alert)
        actionSheet.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func clickCheckIn(_ sender: Any) {
        if 이름 == "" {
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
            출근중 = false
            createMsg(msg: "\(이름) \(checkInTime) 퇴근 \n 오늘일한시간 : \(todayWorkingTime() ?? "")\n 이번주잔여시간 : \(totalWorkingTime() ?? "")")
        }else {
            checkInBtn.setTitle("퇴근", for: .normal)
            isCheckIn = true
            workingIcon.isHidden = false
            workingIcon.blink()
            normalToast("\(checkInTime) 출근", on: self)
            setCheckIn(isCheckIn: true)
            출근중 = true
            createMsg(msg: "\(이름) \(checkInTime) 출근 \n이번주잔여시간 : \(totalWorkingTime() ?? "")\n")
        }
    }
    
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
                    // 알람 설정
                }else {
                    금퇴근 = val
                }
            }
            최근기록시간 = val
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
        let actionSheet = UIAlertController(title: "휴가선택", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction( UIAlertAction(title: "반차 (+4시간)", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.휴가 = self.휴가 + 4.0
            self.totalWorkingTime()
        }))
        actionSheet.addAction( UIAlertAction(title: "일차 (+8시간)", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.휴가 = self.휴가 + 8.0
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
        
        if let last = stringToDate(date: 최근기록시간), let start =  Date().startOfWeek {
            let comps = cal.dateComponents([.day], from: last  , to: start)
            if comps.day ?? 0 >= 1 { // 한주가 바뀌면 데이터 리셋
                resetWokringTime()
            }
        }
        
        if let enter = stringToDate(date: 월출근), let exit =  stringToDate(date: 월퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            totalMin = totalMin - Float(comps.minute ?? 0)
        }
        
        if let enter = stringToDate(date: 화출근), let exit =  stringToDate(date: 화퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            totalMin = totalMin - Float(comps.minute ?? 0)
        }
        
        if let enter = stringToDate(date: 수출근), let exit =  stringToDate(date: 수퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            totalMin = totalMin - Float(comps.minute ?? 0)
        }
        
        if let enter = stringToDate(date: 목출근), let exit =  stringToDate(date: 목퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            totalMin = totalMin - Float(comps.minute ?? 0)
        }
        
        if let enter = stringToDate(date: 금출근), let exit =  stringToDate(date: 금퇴근) {
            let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
            totalMin = totalMin - Float(comps.minute ?? 0)
        }
        
        totalMin = totalMin - (휴가 * 60)
        
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
            if let enter = stringToDate(date: 월출근), let exit =  stringToDate(date: 월퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                totalMin = Float(comps.minute ?? 0)
            }
        }else if 3 == checkDayOfTheWeek(){  // 화
            if let enter = stringToDate(date: 화출근), let exit =  stringToDate(date: 화퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                totalMin = Float(comps.minute ?? 0)
            }
        }else if 4 == checkDayOfTheWeek(){  // 수
            if let enter = stringToDate(date: 수출근), let exit =  stringToDate(date: 수퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                totalMin = Float(comps.minute ?? 0)
            }
        }else if 5 == checkDayOfTheWeek(){  // 목
            if let enter = stringToDate(date: 목출근), let exit =  stringToDate(date: 목퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                totalMin = Float(comps.minute ?? 0)
            }
        }else if 6 == checkDayOfTheWeek(){  // 금
            if let enter = stringToDate(date: 금출근), let exit =  stringToDate(date: 금퇴근) {
                let comps = cal.dateComponents([.hour, .minute], from: enter, to: exit)
                totalMin = Float(comps.minute ?? 0)
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
        chatIds.append( "000000000000068d" )
//        chatIds.append( "00000000000003u4" )
        
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
    func normalToast( _ text:String, on viewCtrl:UIViewController )
    {
        let alertController = UIAlertController(title: "", message: text, preferredStyle: .alert)
        viewCtrl.present(alertController, animated: true, completion: nil)
        let time = DispatchTime.now() + .milliseconds( 2 * 1000 )
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alertController.dismiss(animated: true, completion: nil)
        })
    }
    
    func dateToMMddString(date:Date?) -> String?{
        if let val = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            return formatter.string(from: val)
        }
        return nil
    }
    
    func dateToHHmmString(date:Date?) -> String?{
        if let val = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: val)
        }
        return nil
    }
    
    func dateToString(date:Date?) -> String?{
        if let val = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
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
    
    func 날짜크기비교(targetDate:Date){
        let cal = Calendar(identifier: .gregorian)
        var componenets = cal.dateComponents([.day], from: Date(), to: targetDate)
    }
    
    func checkDayOfTheWeek() -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: Date())
        return weekDay
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
    }
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
            이름 = text
        }
        hideKeyboard()
        return true
    }
}
