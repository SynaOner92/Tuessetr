//
//  AlbumCell.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import UIKit

class AlbumCell: UITableViewCell {
    
    // MARK: IBOutlet
    @IBOutlet private weak var labelTitle: UILabel!
    
    // MARK: Public function
    func configure(withAlbumViewModel _albumViewModel: AlbumCellViewModel) {
        
        labelTitle.text = _albumViewModel.valueTitle
    }
}
