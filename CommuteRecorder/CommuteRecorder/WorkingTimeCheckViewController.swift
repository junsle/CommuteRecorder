//
//  WorkingTimeCheckViewController.swift
//  CommuteRecorder
//
//  Created by marojun on 2018. 1. 23..
//  Copyright © 2018년 maro. All rights reserved.
//

import UIKit
import Firebase

class NCNavigationCtrl: UINavigationController {
    func commonSet()
    {
        self.navigationBar.tintColor = Colors.ncBlue
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:Colors.navigationText]
        self.navigationBar.setBackgroundImage(UIImage.fromColor(Colors.navigationBack), for: .default)
        self.navigationBar.shadowImage = UIImage.fromColor(Colors.navigationBack)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        // iPad 에서만 회전 지원하고, iPhone 에서는 Portrait 으로만 작동한다.
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        }
        return UIInterfaceOrientationMask.all
    }
    
}

class WorkingTimeCheckViewNavigationCtrl: NCNavigationCtrl {
    
    var gSettingViewCtrl: WorkingTimeCheckViewController?
    
    convenience init()
    {
        let chatInfoViewController = WorkingTimeCheckViewController()
        self.init( rootViewController: chatInfoViewController )
        
        self.commonSet()
        self.gSettingViewCtrl = chatInfoViewController
    }
}

class WorkingTimeCheckViewController: UIViewController {

    @IBOutlet weak var 월출근입력: UITextField!
    @IBOutlet weak var 화출근입력: UITextField!
    @IBOutlet weak var 수출근입력: UITextField!
    @IBOutlet weak var 목출근입력: UITextField!
    @IBOutlet weak var 금출근입력: UITextField!
    
    @IBOutlet weak var 월퇴근입력: UITextField!
    @IBOutlet weak var 화퇴근입력: UITextField!
    @IBOutlet weak var 수퇴근입력: UITextField!
    @IBOutlet weak var 목퇴근입력: UITextField!
    @IBOutlet weak var 금퇴근입력: UITextField!
    
    @IBOutlet weak var 휴가입력: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationInit()
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setCustomNavigationInit()
    {
        self.navigationController?.navigationBar.tintColor = Colors.ncBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:Colors.navigationText]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(Colors.navigationBack), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.fromColor(Colors.navigationBack)
        
        let backBtn = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(dissmissView(_:)))
        backBtn.image = UIImage(named: "icNavigationbarsClose")
        self.navigationItem.leftBarButtonItem = backBtn
        
        let editBtn = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(confirm(_:)))
        editBtn.image = UIImage(named: "icNavigationbarsCheck")
        self.navigationItem.rightBarButtonItem = editBtn
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 16.5, weight: UIFontWeightHeavy), NSForegroundColorAttributeName:UIColor(hexString:"#545453")]
        self.navigationItem.title = "근무시간현황"
    }
    
    func setData(){
        if let 월출근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.월출근)) {
            월출근입력.text = 월출근
        }
        
        if let 월퇴근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.월퇴근)) {
            월퇴근입력.text = 월퇴근
        }
        
        if let 화출근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.화출근)) {
            화출근입력.text = 화출근
        }
        
        if let 화퇴근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.화퇴근)) {
            화퇴근입력.text = 화퇴근
        }
        
        if let 수출근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.수출근)) {
            수출근입력.text = 수출근
        }
        
        if let 수퇴근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.수퇴근)) {
            수퇴근입력.text = 수퇴근
        }
        
        if let 목출근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.목출근)) {
            목출근입력.text = 목출근
        }
        
        if let 목퇴근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.목퇴근)) {
            목퇴근입력.text = 목퇴근
        }
        
        if let 금출근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.금출근)) {
            금출근입력.text = 금출근
        }
        
        if let 금퇴근 = dateToOriginalHHmmString(date: stringToDate(date: WorkingDataManage.sharedManager.금퇴근)) {
            금퇴근입력.text = 금퇴근
        }
        
        휴가입력.text = String(WorkingDataManage.sharedManager.휴가)
    }
    
    func dissmissView( _ sender:UIButton ){
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "dissmissView" as NSObject,
            AnalyticsParameterItemName: "workingTimeDissmissView" as NSObject,
            AnalyticsParameterContentType: "cont" as NSObject
            ])
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirm( _ sender:UIButton){
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "confirm" as NSObject,
            AnalyticsParameterItemName: "workingTimeConfirm" as NSObject,
            AnalyticsParameterContentType: "cont" as NSObject
            ])
        if let text = 월출근입력.text {
            if text.count > 3 {
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("월출근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().월요일 {
                        if let 출근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.월출근 = 출근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.월출근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.월출근
        }
        
        if let text = 월퇴근입력.text {
            if text.count > 3 {
                
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("월퇴근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().월요일 {
                        if let 퇴근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.월퇴근 = 퇴근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.월퇴근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.월퇴근
        }
        
        if let text = 화출근입력.text {
            if text.count > 3 {
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("화출근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().화요일 {
                        if let 출근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.화출근 = 출근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.화출근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.화출근
        }
        
        if let text = 화퇴근입력.text {
            if text.count > 3 {
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("화퇴근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().화요일 {
                        if let 퇴근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.화퇴근 = 퇴근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.화퇴근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.화퇴근
        }
        
        if let text = 수출근입력.text {
            if text.count > 3 {
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("수출근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().수요일 {
                        if let 출근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.수출근 = 출근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.수출근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.수출근
        }
        
        if let text = 수퇴근입력.text {
            if text.count > 3 {
                
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("수퇴근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().수요일 {
                        if let 퇴근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.수퇴근 = 퇴근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.수퇴근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.수퇴근
        }
        
        if let text = 목출근입력.text {
            if text.count > 3 {
            let nextIndex = text.index(after: text.startIndex)
            let hour = text[text.startIndex...nextIndex]
            
            let index = text.index(text.startIndex, offsetBy: 2)
            let min = text.substring(from: index)  // Swift
            
            if let hourInt = Int(hour), let minInt = Int(min) {
                print("목출근 : \(hourInt) \(minInt)")
                if let 요일 = Date().목요일 {
                    if let 출근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                        WorkingDataManage.sharedManager.목출근 = 출근
                    }
                }
            }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.목출근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.목출근
        }
        
        if let text = 목퇴근입력.text {
            if text.count > 3 {
                
                let nextIndex = text.index(after: text.startIndex)
                let hour = text[text.startIndex...nextIndex]
                
                let index = text.index(text.startIndex, offsetBy: 2)
                let min = text.substring(from: index)  // Swift
                
                if let hourInt = Int(hour), let minInt = Int(min) {
                    print("목퇴근 : \(hourInt) \(minInt)")
                    if let 요일 = Date().목요일 {
                        if let 퇴근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                            WorkingDataManage.sharedManager.목퇴근 = 퇴근
                        }
                    }
                }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.목퇴근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.목퇴근
        }
        
        if let text = 금출근입력.text {
            if text.count > 3 {

            let nextIndex = text.index(after: text.startIndex)
            let hour = text[text.startIndex...nextIndex]
            
            let index = text.index(text.startIndex, offsetBy: 2)
            let min = text.substring(from: index)  // Swift
            
            if let hourInt = Int(hour), let minInt = Int(min) {
                print("금출근 : \(hourInt) \(minInt)")
                if let 요일 = Date().금요일 {
                    if let 출근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                        WorkingDataManage.sharedManager.금출근 = 출근
                    }
                }
            }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.금출근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.금출근
        }
        
        if let text = 금퇴근입력.text {
            if text.count > 3 {

            let nextIndex = text.index(after: text.startIndex)
            let hour = text[text.startIndex...nextIndex]
            
            let index = text.index(text.startIndex, offsetBy: 2)
            let min = text.substring(from: index)  // Swift
            
            if let hourInt = Int(hour), let minInt = Int(min) {
                print("금퇴근 : \(hourInt) \(minInt)")
                if let 요일 = Date().금요일 {
                    if let 퇴근 = dateToString(date: dateChange(date: 요일 , hour: hourInt , min: minInt )) {
                        WorkingDataManage.sharedManager.금퇴근 = 퇴근
                    }
                }
            }
            }else if text.count == 0 {
                WorkingDataManage.sharedManager.금퇴근 = ""
            }
            WorkingDataManage.sharedManager.최근기록시간 = WorkingDataManage.sharedManager.금퇴근
        }
        
        if let text = 휴가입력.text {
            if text.count > 0 {
                if let hourInt = Float(text){
                    print("휴가 : \(hourInt)")
                    WorkingDataManage.sharedManager.휴가 = hourInt
                }
            }else {
                WorkingDataManage.sharedManager.휴가 = 0
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func dateChange(date:Date, hour:Int, min:Int) -> Date{
        let gregorian = Calendar(identifier: .gregorian)
        let now = date
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        // Change the time to 9:30:00 in your locale
        components.hour = hour
        components.minute = min
        
        return gregorian.date(from: components)!
    }
}

public typealias Colors = Style.Color

public struct Style {
    public struct Color {
        public static let navigationBack = UIColor(hexString: "#F5F4F1")  // new 대화창 네비게이션 바탕
        public static let ncBlue = UIColor(hexString: "#70A2D4")
        public static let navigationText = UIColor(hexString: "#545453")  // h
    }
}

extension UIColor {
    // 사용 형식 : let myColor = UIColor(hexString:"#A0A0FF")
    public convenience init(hexString: String) {
        var rgbValue: CUnsignedInt = 0
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 1 // bypass '#' character
        scanner.scanHexInt32(&rgbValue)
        
        let red = CGFloat(Double((rgbValue & 0xFF0000) >> 16) / 255.0)
        let green = CGFloat(Double((rgbValue & 0xFF00) >> 8) / 255.0)
        let blue = CGFloat(Double(rgbValue & 0xFF) / 255.0)
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// Hexadecimal representation of the UIColor.
    /// For example, UIColor.blackColor() becomes "#000000".
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)
        
        let str = String(format: "#%02x%02x%02x", r, g, b)
        return str
    }
}

extension UIImage {
    static func fromColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension Date {
    public func setTime(hour: Int, min: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)
        
        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        
        return cal.date(from: components)
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
