//: Playground - noun: a place where people can play

import UIKit

let ONE_DAY = 60 * 60 * 24  // segundos en un dia
let formatter = DateFormatter()
formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
let EPOCH = formatter.date(from: "1980/1/06 00:00:00")

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
    let currentSeconds = gpsWeek * 7 * ONE_DAY + gpsSecondsOfWeek
    let timeInt = TimeInterval( currentSeconds )
    let fecha = Date(timeInterval: timeInt, since: EPOCH!)
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Europe/London")!
    let components = calendar.dateComponents([.hour,.minute,.second,.year,.month,.day,.weekOfYear,.weekday], from: fecha)
    return components
}

func dayOfYear( dateComponents: DateComponents ) -> Int
{
    return (dateComponents.weekOfYear! - 1) * 7 + dateComponents.weekday!
}

func secondsOfDay( dateComponents: DateComponents ) -> Int
{
    return( dateComponents.second! + dateComponents.minute! * 60 + dateComponents.hour! * 60 * 60 )
}

var arrResult = greg2gps(year: 2017, month: 9, day: 24, hours: 8, minutes: 36, seconds: 54)

print( "GPS week : \(arrResult[0])" )
print( "GPS week mod : \(arrResult[0] % 1024)" )
print( "GPS seconds of weeks : \(arrResult[1])" )

var dataComps = gps2greg(gpsWeek: 1968, gpsSecondsOfWeek: 31014)

print( "\(dataComps.day!)-\(dataComps.month!)-\(dataComps.year!) \(dataComps.hour!):\(dataComps.minute!):\(dataComps.second!)" )

let dayYear = dayOfYear( dateComponents: dataComps )

print( "\(dayYear)" )

let secondsDay = secondsOfDay( dateComponents: dataComps )

print( "\(secondsDay)" )
