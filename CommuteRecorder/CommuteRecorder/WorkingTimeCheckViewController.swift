//
//  WorkingTimeCheckViewController.swift
//  CommuteRecorder
//
//  Created by marojun on 2018. 1. 23..
//  Copyright © 2018년 maro. All rights reserved.
//

import UIKit

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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
