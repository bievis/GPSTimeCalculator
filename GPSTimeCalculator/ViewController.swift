//
//  ViewController.swift
//  GPSCalculator
//
//  Created by Diego on 24/9/17.
//  Copyright © 2017 Diego Moreno. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 || component == 3
        {
            return 1
        }
        
        if component == 2 || component == 4
        {
            return 60
        }
        
        if component == 0
        {
            return 24
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 2
        {
            if arrMinutos[row] < 10
            {
                return "0" + String(arrMinutos[row])
            }
            else
            {
                return String(arrMinutos[row])
            }
        }
        else if component == 4
        {
            if arrSegundos[row] < 10
            {
                return "0" + String(arrSegundos[row])
            }
            else
            {
                return String(arrSegundos[row])
            }
            
        }
        else if component == 0
        {
            return String(arrHoras[row])
        }
        else if component == 1 || component == 3
        {
            return ":"
        }
        
        return ""
    }
    
    //    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    //        // Hora seleccionada
    //        if component == 2
    //        {
    //            minuto = row
    //        }
    //        else if component == 4
    //        {
    //            segundo = row
    //        }
    //        else if component == 0
    //        {
    //            hora = row
    //        }
    //    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0,y:150), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bannerView.adUnitID = "ca-app-pub-9225943803373012/3668310835"
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        self.hideKeyboardWhenTappedAround()
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        selecHora.dataSource = self
        selecHora.delegate = self
        
        textfieldTOW.delegate = self
        textfieldWN.delegate = self
        textfieldWN1024.delegate = self
        
        initialize()
        
        selecHora.selectRow( hour, inComponent:0, animated:true )
        selecHora.selectRow( minute, inComponent:2, animated:true )
        selecHora.selectRow( second, inComponent:4, animated:true )
        
        // Para que aparezca la pantalla de inicio durante 1 segundo al menos
        sleep(1)
    }
    
    // Variables
    
    let ONE_DAY = 60 * 60 * 24  // segundos en un dia
    var formatter = DateFormatter()
    var EPOCH : Date?
    var arrHoras = [Int]()
    var arrMinutos = [Int]()
    var arrSegundos = [Int]()
    var año : Int = 0
    var mes : Int = 0
    var dia : Int = 0
    var hora : Int = 0
    var minuto : Int = 0
    var segundo : Int = 0
    
    // IBOutlet
    @IBOutlet weak var selecFecha: UIDatePicker!
    @IBOutlet weak var selecHora: UIPickerView!
    @IBOutlet weak var textfieldWN: UITextField!
    @IBOutlet weak var textfieldWN1024: UITextField!
    @IBOutlet weak var textfieldTOW: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    // IBActions
    @IBAction func convert2WNTOW(_ sender: Any) {
        var arrResult : [Int] = [0,0]
        
        almacenaFecha()
        
        almacenaHora()
        
        arrResult = greg2gps(year: año, month: mes, day: dia, hours: hora, minutes: minuto, seconds: segundo)
        
        textfieldWN.text = String(arrResult[0])
        textfieldWN1024.text = String(arrResult[0] % 1024)
        textfieldTOW.text = String(arrResult[1])
    }
    
    @IBAction func convert2DateTime(_ sender: Any) {
        
        if textfieldWN1024.text!.isEmpty
        {
            showAlert(titulo: "Campo WN", mensaje: "Campo Vacio")
            return
        }
        if Int(textfieldWN1024.text!)! < 0
        {
            showAlert(titulo: "Campo WN", mensaje: "Usar sólo valores positivos")
            return
        }
        
        if textfieldTOW.text!.isEmpty
        {
            showAlert(titulo: "Campo TOW", mensaje: "Campo Vacio")
            return
        }
        if Int(textfieldTOW.text!)! < 0
        {
            showAlert(titulo: "Campo TOW", mensaje: "Usar sólo valores positivos")
            return
        }
        
        let dateComp = gps2greg(gpsWeek: Int(textfieldWN1024.text!)! + 1024, gpsSecondsOfWeek: Int(textfieldTOW.text!)! )
        
        let dateString : String = "\(String(describing: dateComp.year!))-\(String(describing: dateComp.month!))-\(String(describing: dateComp.day!))"
        print("DIEGO")
        print(dateString)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: dateString)
        
        selecFecha.setDate(date!, animated: true)
        
        selecHora.selectRow( dateComp.hour!, inComponent:0, animated:true )
        selecHora.selectRow( dateComp.minute!, inComponent:2, animated:true )
        selecHora.selectRow( dateComp.second!, inComponent:4, animated:true )
        
    }
    
    // Funciones
    
    func almacenaFecha() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour,.minute,.second,.year,.month,.day,.weekOfYear,.weekday], from: selecFecha.date)
        dia = components.day!
        mes = components.month!
        año = components.year!
        print ("\(dia)/\(mes)/\(año)")
    }
    
    func almacenaHora() {
        hora = selecHora.selectedRow(inComponent: 0)
        minuto = selecHora.selectedRow(inComponent: 2)
        segundo = selecHora.selectedRow(inComponent: 4)
        
        print("\(hora):\(minuto):\(segundo)")
    }
    
    func initialize() {
        
        for index in 0...23 {
            arrHoras.append(index)
        }
        
        for index in 0...59 {
            arrMinutos.append(index)
            arrSegundos.append(index)
        }
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        EPOCH = formatter.date(from: "1980/1/06 00:00:00")
    }
    
    func showAlert(titulo : String, mensaje : String) {
        let alertView = UIAlertView();
        alertView.addButton(withTitle: "Ok");
        alertView.title = titulo;
        alertView.message = mensaje;
        alertView.show();
    }
    
    func greg2gps(year: Int, month: Int, day: Int, hours: Int, minutes: Int, seconds: Int) -> [Int]
    {
        let gregDate = formatter.date(from: "\(year)/\(month)/\(day) \(hours):\(minutes):\(seconds)")
        var result = [0, 0]
        
        if ( gregDate != nil )
        {
            if ( gregDate! < EPOCH! ) {
                print("Date is before GPS epoch");
                return result;
            }
            
            let days = Int(gregDate!.timeIntervalSince(EPOCH!)) / ONE_DAY
            //let days = days_between( date1: gregDate!, date2: EPOCH! );
            let weeks = Int( days / 7 );
            let secondsInWeek = ( days * ONE_DAY ) - ( weeks * 7 * ONE_DAY ) + hours * 60 * 60 + minutes * 60 + seconds
            
            result[0] = weeks
            result[1] = secondsInWeek
        }
        
        return result
    }
    
    func gps2greg(gpsWeek: Int, gpsSecondsOfWeek: Int) -> DateComponents
    {
        print("\(gpsWeek):\(gpsSecondsOfWeek)")
        let currentSeconds = gpsWeek * 7 * ONE_DAY + gpsSecondsOfWeek
        let timeInt = TimeInterval( currentSeconds )
        let fecha = Date(timeInterval: timeInt, since: EPOCH!)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Europe/Madrid")!
        return calendar.dateComponents([.hour,.minute,.second,.year,.month,.day], from: fecha)
    }
    
    func dayOfYear( dateComponents: DateComponents ) -> Int
    {
        return (dateComponents.weekOfYear! - 1) * 7 + dateComponents.weekday!
    }
    
    func secondsOfDay( dateComponents: DateComponents ) -> Int
    {
        return( dateComponents.second! + dateComponents.minute! * 60 + dateComponents.hour! * 60 * 60 )
    }
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}