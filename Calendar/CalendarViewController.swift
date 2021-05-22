//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Richard Topchii on 09.05.2021.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

final class CalendarViewController: DayViewController {
    private let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        // The app must have access to the user's calendar to show the events on the timeline
        requestAccessToCalendar()
        // Subscribe to notifications to reload the UI when 
        subscribeToNotifications()
    }

    private func requestAccessToCalendar() {
        // Request access to the events
        eventStore.requestAccess(to: .event) { granted, error in
            // Handle the response to the request.
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: eventStore)
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    // MARK: - DayViewDataSource
    
    // This is the `DayViewDataSource` method that the client app has to implement in order to display events with CalendarKit
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        // The `date` always has it's Time components set to 00:00:00 of the day requested
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        // By adding one full `day` to the `startDate`, we're getting to the 00:00:00 of the *next* day
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, // Start of the current day
                                                      end: endDate, // Start of the next day
                                                      calendars: nil) // Search in all calendars
        
        let eventKitEvents = eventStore.events(matching: predicate) // All events happening on a given day
        
        // The `eventKitEvents` has a type of `[EKEvent]`, we need to convert them to CalendarKit Events
        let calendarKitEvents = eventKitEvents.map { ekEvent -> Event in
            let ckEvent = Event() // Creating a new CalendarKit.Event
            ckEvent.startDate = ekEvent.startDate // Copying all of the properties of the `EKEvent` to the newly created CalendarKit.Event
            ckEvent.endDate = ekEvent.endDate
            ckEvent.isAllDay = ekEvent.isAllDay
            ckEvent.text = ekEvent.title
            if let eventColor = ekEvent.calendar.cgColor {
                ckEvent.color = UIColor(cgColor: eventColor)
            }
            
            ckEvent.userInfo = ekEvent
            
            return ckEvent
        }

        return calendarKitEvents
    }
    
    // MARK: - DayViewDelegate
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? Event,
              let ekEvent = ckEvent.userInfo as? EKEvent else {
            return
        }
        presentDetailViewForEvent(ekEvent)
    }
    
    private func presentDetailViewForEvent(_ ekEvent: EKEvent) {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        
        navigationController?.pushViewController(eventController,
                                                 animated: true)
    }
}
