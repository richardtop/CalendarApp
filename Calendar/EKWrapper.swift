//
//  EKWrapper.swift
//  Calendar
//
//  Created by Richard Topchii on 22.05.2021.
//

import UIKit
import EventKit
import CalendarKit

final class EKWrapper: EventDescriptor {
    public var startDate: Date {
        get {
            ekEvent.startDate
        }
        set {
            ekEvent.startDate = newValue
        }
    }
    
    public var endDate: Date {
        get {
            ekEvent.endDate
        }
        set {
            ekEvent.endDate = newValue
        }
    }
    
    public var isAllDay: Bool {
        get {
            ekEvent.isAllDay
        }
        set {
            ekEvent.isAllDay = newValue
        }
    }
    
    public var text: String {
        get {
            ekEvent.title
        }
        
        set {
            ekEvent.title = newValue
        }
    }

    public var attributedText: NSAttributedString?
    public var lineBreakMode: NSLineBreakMode?
    
    public var color: UIColor {
        get {
            UIColor(cgColor: ekEvent.calendar.cgColor)
        }
    }
    
    public var backgroundColor = UIColor()
    public var textColor = SystemColors.label
    public var font = UIFont.boldSystemFont(ofSize: 12)
    public var userInfo: Any?
    public weak var editedEvent: EventDescriptor? {
        didSet {
            updateColors()
        }
    }
    
    public private(set) var ekEvent: EKEvent
    
    public init(eventKitEvent: EKEvent) {
        self.ekEvent = eventKitEvent
        applyStandardColors()
    }
    
    public func makeEditable() -> Self {
        let cloned = Self(eventKitEvent: ekEvent)
        cloned.editedEvent = self
        return cloned
    }
    
    public func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.startDate = startDate
        edited.endDate = endDate
    }
    
    private func updateColors() {
        (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
    }
    
    private func applyStandardColors() {
        backgroundColor = color.withAlphaComponent(0.3)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        textColor = UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
    
    private func applyEditingColors() {
        backgroundColor = color
        textColor = .white
    }
}
