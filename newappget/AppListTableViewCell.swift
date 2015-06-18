import UIKit

class AppListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var appGenre: UILabel!
    @IBOutlet weak var appPrice: UILabel!    
    @IBOutlet weak var appReview: UILabel!
    
    var uuid: String = NSUUID().UUIDString;
    var reuseCount: UInt8 = 0;
}