import UIKit

class ReviewListController: UIViewController
    , UITableViewDataSource
    , UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewTitle: UINavigationItem!
    
    @IBOutlet weak var pageLabel: UIBarButtonItem!
    
    var targetAppId: UInt = 0;
    var targetAppTitle: String = "";
    
    var isReviewLoading: Bool = false;
    var reviewData: [ReviewData] = [];
    var reviewActive: ReviewData = ReviewData();
    func getReviewDataEntryCount() -> Int {
        var count = 0;
        for i in reviewData {
            count += i.entryList.count;
        }
        return count;
    }
    func reviewDataAllEntry(reverse: Bool = false) -> [ReviewData.Entry] {
        var entrys: [ReviewData.Entry] = [];
        for i in reviewData {
            for j in i.entryList {
                entrys.append(j);
            }
        }
        if reverse {
            entrys.reverse();
        }
        return entrys;
    }
    var reviewPage: UInt = 1;
    
    var refreshControl: UIRefreshControl!;
    
    var loadingIndicator: UIActivityIndicatorView!;
    func settingIndicator() {
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingIndicator.frame = CGRectMake(0, 0, 20, 20);
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true;
        self.view.addSubview(loadingIndicator);
    }
    
    func setting(appId: UInt = 0, title: String = "") {
        
        targetAppId = appId;
        targetAppTitle = title;
        
        // 0ページ目には空データを入れておく
        reviewData.append(ReviewData());
        
        pageLabel.title = "\(reviewPage)/\(reviewData.count)"
        
        loadReview();
    }
    
    func loadReview(page: UInt = 1) {
        isReviewLoading = true;
        
        var url = iTunesRSSGenerator.instance.makeURL_reviews(country: iTunesRSSGenerator.Country.jp
            , page: page
            , appid: targetAppId
            , outputformat: iTunesRSSGenerator.OutputFormat.json);
        if let tmp = url
        {
            if let indicator = loadingIndicator {
                loadingIndicator.startAnimating();
            }
            
            var myRequest:NSURLRequest  = NSURLRequest(URL: url);
            NSURLConnection.sendAsynchronousRequest(myRequest
                , queue: NSOperationQueue.mainQueue()
                , completionHandler: self.responseReview)
        }
        else{ println("reviewlist load error"); }
    }
    
    func responseReview(res:NSURLResponse?, data:NSData?, error:NSError?) {
        
        // レスポンスをを文字列に変換.
        if let nsstr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        {
            if nsstr.hasPrefix("CustomerReviews RSS page depth is limited to") {
                let alert = UIAlertController(title: "これ以上レビューはありません"
                    , message: nil
                    , preferredStyle: UIAlertControllerStyle.Alert);
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Cancel,
                    handler:{
                        (action:UIAlertAction!) -> Void in
                })
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion: nil)
                reviewPage--;
            }
            else {
                // パース
                var review = ReviewData();
                //review.parseXML(data!);
                review.parseJSON(nsstr as String);
                if reviewPage < UInt(reviewData.count) {
                    reviewData[Int(reviewPage)] = review;
                }
                else {
                    reviewData.append(review);
                }
            }
            
            reviewActive = reviewData[Int(reviewPage)];
            tableView.reloadData();
            tableView.setContentOffset(CGPointZero, animated: true);
            pageLabel.title = "\(reviewPage)/\(reviewData.count-1)"
        }
        else { println("responseReview data error"); }

        // テーブルビューのプルで読み込みだった場合は消す
        if let refresh = self.refreshControl {
            if refreshControl.tag == 1 {
                refresh.endRefreshing();
                refreshControl.tag = 0;
            }
        }
        
        isReviewLoading = false;
        
        if let indicator = loadingIndicator {
            loadingIndicator.stopAnimating();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        // 引っ張ってロードする
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "次を読み込み中")
        refreshControl.addTarget(self
            , action: "tablePullLoading"
            , forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tag = 0;
        tableView.addSubview(refreshControl);
        
        viewTitle.title = "\(targetAppTitle)";
        
        settingIndicator();
        
        if isReviewLoading {
            loadingIndicator.startAnimating();
        }
    }
    
    @IBAction func backLoadingAction(sender: AnyObject) {
        if isReviewLoading {
            return;
        }
        backLoading();
    }
    @IBAction func nextLoadingAction(sender: AnyObject) {
        if isReviewLoading {
            return;
        }
        nextLoading();
    }
    
    func tablePullLoading() {
        if isReviewLoading {
            return;
        }
        refreshControl.tag = 1;
        nextLoading();
    }
    
    func nextLoading() {
        
        reviewPage++;
        if reviewPage >= UInt(reviewData.count) {
            loadReview(page: reviewPage);
        }
        else {
            reviewActive = reviewData[Int(reviewPage)];
            tableView.reloadData();
            tableView.setContentOffset(CGPointZero, animated: true);
            pageLabel.title = "\(reviewPage)/\(reviewData.count-1)"
        }
    }
    func backLoading() {
        
        reviewPage--;
        if reviewPage < 1 {
            reviewPage = 1;
            let alert = UIAlertController(title: "これより前はありません。"
                , message: nil
                , preferredStyle: UIAlertControllerStyle.Alert);
            
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler:{
                    (action:UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            pageLabel.title = "\(reviewPage)/\(reviewData.count-1)"
        }
        else if reviewPage >= UInt(reviewData.count) {
            loadReview(page: reviewPage);
        }
        else {
            reviewActive = reviewData[Int(reviewPage)];
            tableView.reloadData();
            tableView.setContentOffset(CGPointZero, animated: true);
            pageLabel.title = "\(reviewPage)/\(reviewData.count-1)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    
    //
    // テーブルビュー
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return reviewActive.entryList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewListItem", forIndexPath: indexPath) as! ReviewListTableViewCell;
        
        cell.imageView?.image = nil;
        cell.textLabel?.text = nil;
        
        var review = reviewActive.entryList;
        
        cell.Name.text = review[indexPath.row].name;
        
        var contenttext = "タイトル：\(review[indexPath.row].title)\n";
        contenttext += review[indexPath.row].content;
        cell.Content.text = contenttext;

        var reviewtextlabel = "評価：";
        var reviewtext = String(format: "%.1f", review[indexPath.row].rating);
        if reviewtext == "0.0" {
            reviewtext = "なし"
        }
        switch review[indexPath.row].rating {
        case let n where n >= 4.5:
            cell.Rating?.textColor = UIColor.redColor();
        case let n where n >= 4.0:
            cell.Rating?.textColor = UIColor.purpleColor();
        case let n where n >= 3.0:
            cell.Rating?.textColor = UIColor.blackColor();
        case let n where n >= 2.0:
            cell.Rating?.textColor = UIColor.blueColor();
        default:
            cell.Rating?.textColor = UIColor.lightGrayColor();
        }
        cell.Rating?.text = reviewtextlabel + reviewtext;

        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        // ハイライト消す
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        var review = reviewActive.entryList;

        // 内容コピー
        var text = "";
        text += "レビュワー : \(review[indexPath.row].name)\n"
        var reviewtextlabel = "評価 : ";
        var reviewtext = String(format: "%.1f", review[indexPath.row].rating);
        if reviewtext == "0.0" {
            reviewtext = "なし"
        }
        text += (reviewtextlabel + reviewtext + "\n");
        var contenttext = "タイトル : \(review[indexPath.row].title)\n";
        contenttext += review[indexPath.row].content;
        text += contenttext;
        
        let generalPasteboard: UIPasteboard = UIPasteboard.generalPasteboard()
        generalPasteboard.string = text;
        
        
        let alert = UIAlertController(title: "クリップボードにコピーしました。"
            , message: nil
            , preferredStyle: UIAlertControllerStyle.Alert);
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)

        
    }

}