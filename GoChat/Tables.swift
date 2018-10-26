//
//  Tables.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/11/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

extension UITableView
{
    func deselect()
    {
        // unselect any selected cells
        if let selectedCellIndexPath = self.indexPathForSelectedRow {
            self.deselectRow(at: selectedCellIndexPath, animated: true)
        }
    }
}
