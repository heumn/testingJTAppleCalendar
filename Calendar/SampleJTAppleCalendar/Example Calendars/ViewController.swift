//
//  ViewController.swift
//  JTAppleCalendar iOS Example
//
//  Created by JayT on 2016-08-10.
//
//

import JTAppleCalendar
import UIKit

final class ViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var weekViewStack: UIStackView!
    @IBOutlet var numbers: [UIButton]!
    @IBOutlet var outDates: [UIButton]!
    @IBOutlet var inDates: [UIButton]!

    var numberOfRows = 6
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var prePostVisibility: ((CellState, CellView?) -> Void)?
    var hasStrictBoundaries = false
    let disabledColor = UIColor.lightGray
    let enabledColor = UIColor.blue
    var monthSize: MonthSize?
    var prepostHiddenValue = false
    var outsideHeaderVisibilityIsOn = true
    var insideHeaderVisibilityIsOn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.register(UINib(nibName: "PinkSectionHeaderView", bundle: Bundle.main),
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: "PinkSectionHeaderView")

        calendarView.visibleDates { [unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }

        calendarView.minimumInteritemSpacing = 3.5
        calendarView.minimumLineSpacing = 3.5
        calendarView.sectionInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        currentScrollModeIndex = 6

//        calendarView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        calendarView.cellSize = ((UIScreen.main.bounds.size.width - 32) / 7)

        calendarView.scrollingMode = allScrollModes[currentScrollModeIndex]
        calendarView.reloadData()
    }

    var currentScrollModeIndex = 0
    let allScrollModes: [ScrollingMode] = [
        .none,
        .nonStopTo(customInterval: 374, withResistance: 0.5),
        .nonStopToCell(withResistance: 0.5),
        .nonStopToSection(withResistance: 0.5),
        .stopAtEach(customInterval: 374),
        .stopAtEachCalendarFrame,
        .stopAtEachSection,
    ]

    @IBAction func changeScroll(_ sender: Any) {
        currentScrollModeIndex += 1
        if currentScrollModeIndex >= allScrollModes.count { currentScrollModeIndex = 0 }
        calendarView.scrollingMode = allScrollModes[currentScrollModeIndex]
        print("ScrollMode = \(allScrollModes[currentScrollModeIndex])")
        let sender = sender as! UIButton
        sender.setTitle("\(allScrollModes[currentScrollModeIndex])", for: .normal)
    }

    @IBAction func next(_: UIButton) {
        calendarView.scrollToSegment(.next)
    }

    @IBAction func previous(_: UIButton) {
        calendarView.scrollToSegment(.previous)
    }

    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else { return }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month - 1) % 12]
        // 0 indexed array
        let year = testCalendar.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }

    func handleCellConfiguration(cell: JTACDayCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        prePostVisibility?(cellState, cell as? CellView)
    }

    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView else { return }

        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = .white
        }
    }

    override func viewWillTransition(to _: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleDates = calendarView.visibleDates()
        calendarView.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
    }

    // Function to handle the calendar selection
    func handleCellSelection(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView else { return }

        if cellState.isSelected {
            myCustomCell.backgroundColor = .systemGreen
        } else {
            myCustomCell.backgroundColor = .systemGray4
        }
    }
}

// MARK: JTAppleCalendarDelegate

extension ViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    func configureCalendar(_: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale

        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = Date()

        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: testCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: .monday,
                                                 hasStrictBoundaries: hasStrictBoundaries)
        return parameters
    }

    func configureVisibleCell(myCustomCell: CellView, cellState: CellState, date: Date, indexPath _: IndexPath) {
        myCustomCell.dayLabel.text = cellState.text
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.isHidden = false
        } else {
            myCustomCell.isHidden = true
        }

        if testCalendar.isDateInToday(date) {
            myCustomCell.backgroundColor = .red
        } else {
            myCustomCell.backgroundColor = .white
        }

        handleCellConfiguration(cell: myCustomCell, cellState: cellState)
    }

    func calendar(_: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
        return myCustomCell
    }

    func calendar(_: JTACMonthView, didDeselectDate _: Date, cell: JTACDayCell?, cellState: CellState, indexPath _: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_: JTACMonthView, didSelectDate _: Date, cell: JTACDayCell?, cellState: CellState, indexPath _: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_: JTACMonthView, didScrollToDateSegmentWith _: DateSegmentInfo) {
//        print("After: \(calendar.contentOffset.y)")
    }

    func calendar(_: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }

    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let date = range.start
        let month = testCalendar.component(.month, from: date)
        formatter.dateFormat = "MMM"
        let header: JTACMonthReusableView
        if month % 2 > 0 {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "WhiteSectionHeaderView", for: indexPath)
            (header as! WhiteSectionHeaderView).title.text = formatter.string(from: date)
        } else {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "PinkSectionHeaderView", for: indexPath)
            (header as! PinkSectionHeaderView).title.text = formatter.string(from: date)
        }
        return header
    }

    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        let stride = calendarView.frame.width * CGFloat(indexPath.section)
        return CGRect(x: stride + 5, y: 5, width: calendarView.frame.width - 10, height: calendarView.frame.height - 10)
    }

    func calendarSizeForMonths(_: JTACMonthView?) -> MonthSize? {
        return monthSize
    }
}
