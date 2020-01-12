//
//  CellView.swift
//  testApplicationCalendar
//
//  Created by JayT on 2016-03-04.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import JTAppleCalendar
import UIKit

class CellView: JTACDayCell {
    @IBOutlet var dayLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 6
    }
}
