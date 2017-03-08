//
//	SwiftDate, an handy tool to manage date and timezones in swift
//	Created by:				Daniele Margutti
//	Main contributors:		Jeroen Houtzager
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

// MARK: - DateInRegion Formatter Extension -

public extension DateInRegion {

   /**
   This method produces a colloquial representation of time elapsed
   between this `DateInRegion` (`self`) and another reference `DateInRegion` (`refDate`).

   - parameters:
        - refDate: reference date to compare (if not specified current date into `self` region
            is used)
        - style: style of the output string

   - returns: formatted string or nil if representation cannot be provided
   */
	public func toNaturalString(_ refDate: DateInRegion?, style: FormatterStyle = FormatterStyle())
        -> String? {

		let rDate = (refDate != nil ? refDate! : DateInRegion(absoluteTime: Date(),
            region: self.region))
		let formatter: DateComponentsFormatter = sharedDateComponentsFormatter()
		return formatter.beginSessionContext({ (Void) -> (String?) in
			style.restoreInto(formatter)
			formatter.calendar = self.calendar
			// NOTE: why this method still return nil?
			// let str2 = formatter.stringFromDate(refDate.absoluteTime, toDate: self.absoluteTime)
			let diff = fabs(self.absoluteTime.timeIntervalSince(rDate.absoluteTime))
			let str = formatter.string(from: diff)
			return str
		})
	}

    /**
     Return an `ISO8601` string for the date.
	 More information about this standard can be found on
     [Wikipedia/ISO8601](https://en.wikipedia.org/wiki/ISO_8601).

 	 Some examples of the formatted output are:
	* `2016-01-11T17:31:10+00:00`
	* `2016-01-11T17:31:10Z`
	* `20160111T173110Z`

     - returns: a new string or nil if `DateInRegion` does not contains any valid date
     */
	@available(*, deprecated: 3.0.2, obsoleted: 3.1, message: "Use toString(.ISO8601)")
    public func toISO8601String() -> String? {
		return self.toString(.iso8601)
    }

    /**
     Convert a DateInRegion to a string using region's timezone, locale and calendar

     - parameter dateFormat: format of the string

     - returns: a new string or nil if DateInRegion does not contains any valid date
     */
    public func toString(_ dateFormat: DateFormat) -> String? {
        guard let _ = absoluteTime else {
            return nil
        }
		let cachedFormatter = sharedDateFormatter()
		return cachedFormatter.beginSessionContext { (void) -> (String?) in
			let dateFormatString = dateFormat.formatString
			cachedFormatter.dateFormat = dateFormatString
			cachedFormatter.timeZone = self.region.timeZone
			cachedFormatter.calendar = self.region.calendar
			cachedFormatter.locale = self.region.calendar.locale
			let value = cachedFormatter.string(from: self.absoluteTime!)
			return value
		}
    }

    /**
     Convert a `DateInRegion` date into a date with date & time style specific format style

     - parameter style: style to format both date and time (if you specify this you don't need to
        specify dateStyle,timeStyle)
     - parameter dateStyle: style to format the date
     - parameter timeStyle: style to format the time
	 - parameter relative: `true` indicates whether the receiver uses phrases such as “today” and
        “tomorrow” for the date component.

     - returns: a new string which represent the date expressed into the current region or nil if
        region does not contain valid date
     */
	public func toString(_ style: DateFormatter.Style? = nil, dateStyle: DateFormatter.Style? = nil,
        timeStyle: DateFormatter.Style? = nil, relative: Bool = false) -> String? {
        guard let _ = absoluteTime else {
            return nil
        }

		let cachedFormatter = sharedDateFormatter()
		return cachedFormatter.beginSessionContext { (void) -> (String?) in
			cachedFormatter.dateStyle = style ?? dateStyle ?? .none
			cachedFormatter.timeStyle = style ?? timeStyle ?? .none
			if cachedFormatter.dateStyle == .none && cachedFormatter.timeStyle == .none {
				cachedFormatter.dateStyle = .medium
				cachedFormatter.timeStyle = .medium
			}
			cachedFormatter.locale = self.region.locale
			cachedFormatter.calendar = self.region.calendar
			cachedFormatter.timeZone = self.region.timeZone
			cachedFormatter.doesRelativeDateFormatting = relative
			let value = cachedFormatter.string(from: self.absoluteTime)

			return value
		}
    }

	/**
	Convert this `DateInRegion` date in a string representation where you have date/time in short
     form

	Example of this output is:
	`"1/1/15, 11:00 AM"`

	- parameter date: `true` to include date in output string, `false` to omit it
	- parameter time: `true` to include time in output string, `false` to omit it

	- returns: output string representation of the date represented by `self`
	*/
    public func toShortString(date: Bool = true, time: Bool = true) -> String? {
        let dateStyle = date ? DateFormatter.Style.short : DateFormatter.Style.none
        let timeStyle = time ? DateFormatter.Style.short : DateFormatter.Style.none

        return toString(dateStyle: dateStyle, timeStyle: timeStyle)
    }

	/**
	Convert this `DateInRegion` date in a string representation where you have date/time in medium
     form

	Example of this output is:
	`"Jan 1, 2015, 11:00:00 AM"`

	- parameter date: `true` to include date in output string, `false` to omit it
	- parameter time: `true` to include time in output string, `false` to omit it

	- returns: output string representation of the date represented by `self`
	*/
    public func toMediumString(date: Bool = true, time: Bool = true) -> String? {
        let dateStyle = date ? DateFormatter.Style.medium : DateFormatter.Style.none
        let timeStyle = time ? DateFormatter.Style.medium : DateFormatter.Style.none

        return toString(dateStyle: dateStyle, timeStyle: timeStyle)
    }

	/**
	Convert this `DateInRegion` date in a string representation where you have date/time in long form

	Example of this output is:
	`"January 1, 2015 at 11:00:00 AM GMT+1"`

	- parameter date: `true` to include date in output string, `false` to omit it
	- parameter time: `true` to include time in output string, `false` to omit it

	- returns: output string representation of the date represented by `self`
	*/
    public func toLongString(date: Bool = true, time: Bool = true) -> String? {
        let dateStyle = date ? DateFormatter.Style.long : DateFormatter.Style.none
        let timeStyle = time ? DateFormatter.Style.long : DateFormatter.Style.none

        return toString(dateStyle: dateStyle, timeStyle: timeStyle)
    }

	@available(*, deprecated: 2.2,
        message: "Use toString(style:dateStyle:timeStyle:relative:) with relative parameters")
	/**
	Output relative string representation of the date.
	**This method was deprecated: use `toString(style:dateStyle:timeStyle:)` instead.**

	- parameter style: style of the formatted output

	- returns: string representation
	*/
	public func toRelativeCocoaString(style: DateFormatter.Style =
        DateFormatter.Style.medium) -> String? {

        let cachedFormatter = sharedDateFormatter()
		return cachedFormatter.beginSessionContext { (void) -> (String?) in
			cachedFormatter.locale = self.region.locale
			cachedFormatter.calendar = self.region.calendar
			cachedFormatter.timeZone = self.region.timeZone
			cachedFormatter.dateStyle = style
			cachedFormatter.doesRelativeDateFormatting = true
			let str = cachedFormatter.string(from: self.absoluteTime)
			return str
		}
	}

	@available(*, deprecated: 2.2, message: "Use toNaturalString() with relative parameters")
	/**
	Output colloquial representation of the string.
	**This method was deprecated: use `toString(style:dateStyle:timeStyle:)` instead.**

	- parameter fromDate: reference date
	- parameter abbreviated: `true` to use abbreviated form
	- parameter maxUnits: number of non zero units to print

	- returns: colloquial string representation
	*/
	public func toRelativeString(_ fromDate: DateInRegion!, abbreviated: Bool = false,
        maxUnits: Int = 1) -> String {

        let seconds = fromDate.absoluteTime.timeIntervalSince(absoluteTime as Date)
        if fabs(seconds) < 1 {
            return "just now".sdLocalize
        }

        let significantFlags: NSCalendar.Unit = DateInRegion.componentFlags
        let components = region.calendar.components(significantFlags,
            from: fromDate.absoluteTime, to: absoluteTime, options: [])

        var string = String()
        var numberOfUnits: Int = 0
        let unitList: [String] = ["year", "month", "weekOfYear", "day", "hour", "minute",
            "second", "nanosecond"]
        for unitName in unitList {
            let unit: NSCalendar.Unit = unitName.sdToCalendarUnit()
            if ((significantFlags.rawValue & unit.rawValue) != 0) &&
                (absoluteTime.sdCompareCalendarUnit(NSCalendar.Unit.nanosecond, other: unit)
                    != .orderedDescending) {

                    let number: NSNumber = NSNumber(value: fabsf(components.value(forKey: unitName)!.floatValue) as Float)
                    if Bool(number.intValue) {
                        let singular = (number.uintValue == 1)
                        let suffix = String(format: "%@ %@", arguments:
                            [number, absoluteTime.sdLocalizeStringForValue(singular, unit: unit,
                                abbreviated: abbreviated)])
                        if string.isEmpty {
                            string = suffix
                        } else if numberOfUnits < maxUnits {
                            string += String(format: " %@", arguments: [suffix])
                        }
                        numberOfUnits += 1
                    }
            }
        }
        return string
    }
}

//MARK: - DateInRegion Formatters -

public extension String {

    /**
     Convert a string into `NSDate` by passing conversion format

     - parameter format: format used to parse the string

     - returns: a new `NSDate` instance or nil if something went wrong during parsing
     */
    public func toDate(_ format: DateFormat) -> Date? {
        return self.toDateInRegion(format)?.absoluteTime as Date?
    }

    /**
     Convert a string into `DateInRegion` by passing conversion format

     - parameter format: format used to parse the string

     - returns: a new `NSDate` instance or nil if something went wrong during parsing
     */
    public func toDateInRegion(_ format: DateFormat) -> DateInRegion? {
        return DateInRegion(fromString: self, format: format)
    }

    /**
     Convert a string which represent an `ISO8601` date into `NSDate`

     - returns: `NSDate` instance or nil if string cannot be parsed
     */
    public func toDateFromISO8601() -> Date? {
		return toDate(DateFormat.iso8601Format(.Full))
    }

    fileprivate var sdLocalize: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: "SwiftDate")
    }

    fileprivate func sdToCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case "year":
            return NSCalendar.Unit.year
        case "month":
            return NSCalendar.Unit.month
        case "weekOfYear":
            return NSCalendar.Unit.weekOfYear
        case "day":
            return NSCalendar.Unit.day
        case "hour":
            return NSCalendar.Unit.hour
        case "minute":
            return NSCalendar.Unit.minute
        case "second":
            return NSCalendar.Unit.second
        case "nanosecond":
            return NSCalendar.Unit.nanosecond
        default:
            return []
        }
    }
}


internal extension Date {
    fileprivate func sdCompareCalendarUnit(_ unit: NSCalendar.Unit, other: NSCalendar.Unit) ->
        ComparisonResult {

        let nUnit = sdNormalizedCalendarUnit(unit)
        let nOther = sdNormalizedCalendarUnit(other)

        if (nUnit == NSCalendar.Unit.weekOfYear) != (nOther == NSCalendar.Unit.weekOfYear) {
            if nUnit == NSCalendar.Unit.weekOfYear {
                switch nUnit {
                case NSCalendar.Unit.year, NSCalendar.Unit.month:
                    return .orderedAscending
                default:
                    return .orderedDescending
                }
            } else {
                switch nOther {
                case NSCalendar.Unit.year, NSCalendar.Unit.month:
                    return .orderedDescending
                default:
                    return .orderedAscending
                }
            }
        } else {
            if nUnit.rawValue > nOther.rawValue {
                return .orderedAscending
            } else if nUnit.rawValue < nOther.rawValue {
                return .orderedDescending
            } else {
                return .orderedSame
            }
        }
    }

    fileprivate func sdNormalizedCalendarUnit(_ unit: NSCalendar.Unit) -> NSCalendar.Unit {
        switch unit {
        case NSCalendar.Unit.weekOfMonth, NSCalendar.Unit.weekOfYear:
            return NSCalendar.Unit.weekOfYear
        case NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal:
            return NSCalendar.Unit.day
        default:
            return unit
        }
    }


    fileprivate func sdLocalizeStringForValue(_ singular: Bool, unit: NSCalendar.Unit,
        abbreviated: Bool = false) -> String {

        var toTranslate: String = ""
        switch unit {

        case NSCalendar.Unit.year where singular:
            toTranslate = (abbreviated ? "yr": "year")
        case NSCalendar.Unit.year where !singular:
            toTranslate = (abbreviated ? "yrs": "years")

        case NSCalendar.Unit.month where singular:
            toTranslate = (abbreviated ? "mo": "month")
        case NSCalendar.Unit.month where !singular:
            toTranslate = (abbreviated ? "mos": "months")

        case NSCalendar.Unit.weekOfYear where singular:
            toTranslate = (abbreviated ? "wk": "week")
        case NSCalendar.Unit.weekOfYear where !singular:
            toTranslate = (abbreviated ? "wks": "weeks")

        case NSCalendar.Unit.day where singular:
            toTranslate = "day"
        case NSCalendar.Unit.day where !singular:
            toTranslate = "days"

        case NSCalendar.Unit.hour where singular:
            toTranslate = (abbreviated ? "hr": "hour")
        case NSCalendar.Unit.hour where !singular:
            toTranslate = (abbreviated ? "hrs": "hours")

        case NSCalendar.Unit.minute where singular:
            toTranslate = (abbreviated ? "min": "minute")
        case NSCalendar.Unit.minute where !singular:
            toTranslate = (abbreviated ? "mins": "minutes")

        case NSCalendar.Unit.second where singular:
            toTranslate = (abbreviated ? "s": "second")
        case NSCalendar.Unit.second where !singular:
            toTranslate = (abbreviated ? "s": "seconds")

        case NSCalendar.Unit.nanosecond where singular:
            toTranslate = (abbreviated ? "ns": "nanosecond")
        case NSCalendar.Unit.nanosecond where !singular:
            toTranslate = (abbreviated ? "ns": "nanoseconds")

        default:
            toTranslate = ""
        }
        return toTranslate.sdLocalize
    }

    func localizedSimpleStringForComponents(_ components: DateComponents) -> String {
        if components.year == -1 {
            return "last year".sdLocalize
        } else if components.month == -1 && components.year == 0 {
            return "last month".sdLocalize
        } else if components.weekOfYear == -1 && components.year == 0 && components.month == 0 {
            return "last week".sdLocalize
        } else if components.day == -1 && components.year == 0 && components.month == 0 &&
            components.weekOfYear == 0 {
            return "yesterday".sdLocalize
        } else if components == 1 {
            return "next year".sdLocalize
        } else if components.month == 1 && components.year == 0 {
            return "next month".sdLocalize
        } else if components.weekOfYear == 1 && components.year == 0 && components.month == 0 {
            return "next week".sdLocalize
        } else if components.day == 1 && components.year == 0 && components.month == 0 &&
            components.weekOfYear == 0 {
            return "tomorrow".sdLocalize
        }
        return ""
    }
}
