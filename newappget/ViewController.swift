import UIKit

class ViewController: UIViewController
    , UITableViewDataSource
    , UITableViewDelegate
{

    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var listdata: iTunesRSSData = iTunesRSSData();
    var listLookupData: [LookupAPIData] = [];
    var searchData = SearchAPIData();
    
    var cell_load_stac: [String : UInt8] = [:];
    
    var isListUpdating: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        // リストデータ更新
        //downloadRSSFeed();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadSearchList(term: String) {
        var url = SearchAPICtrl.instance.makeSearchURL(term: term);
        if let tmp = url
        {
            var myRequest:NSURLRequest  = NSURLRequest(URL: url);
            NSURLConnection.sendAsynchronousRequest(myRequest
                , queue: NSOperationQueue.mainQueue()
                , completionHandler: self.responseSearchList)
        }
        else{ println("downloadSearchList load error"); }
    }
    func responseSearchList(res:NSURLResponse?, data:NSData?, error:NSError?) {
        
        // レスポンスをを文字列に変換.
        if let nsstr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        {
            // パース
            searchData.parseJSON(nsstr as String);
            
            tableView.reloadData();
        }
        else { println("downloadSearchList data error"); }
    }
    
    func downloadRSSFeed() {
        
        isListUpdating = true;
        
        // 初期化
        listdata.reset();
        
        var url = iTunesRSSGenerator.instance.makeURL(country: iTunesRSSGenerator.Country.jp
            , feedtype: iTunesRSSGenerator.FeedType.newfreeapp
            , limit: 0
            , outputformat: iTunesRSSGenerator.OutputFormat.json
            , genre: iTunesRSSGenerator.Genre.game);
        if let tmp = url
        {
            var myRequest:NSURLRequest  = NSURLRequest(URL: url);
            NSURLConnection.sendAsynchronousRequest(myRequest
                , queue: NSOperationQueue.mainQueue()
                , completionHandler: self.responseRSSFeed_freeGame)
        }
        else{ println("freegame load error"); }
    }
    
    func responseRSSFeed(data:NSData?) {
        
        // レスポンスをを文字列に変換.
        if let nsstr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        {
            // パース
            listdata.parseJSON(nsstr as String
                , targetGenre: [iTunesRSSGenerator.Genre.game]
                , targetYear: "2015"
                , targetMonth: "07"
                , targetDay: "01"
            );
            
            listLookupData = [LookupAPIData](count: listdata.enrtyList.count, repeatedValue: LookupAPIData());
        }
        else { println("response data error"); }
    }
    
    func responseRSSFeed_freeGame(res:NSURLResponse?, data:NSData?, error:NSError?) {
        
        responseRSSFeed(data);
        
        var url = iTunesRSSGenerator.instance.makeURL(country: iTunesRSSGenerator.Country.jp
            , feedtype: iTunesRSSGenerator.FeedType.newpaidapp
            , limit: 0
            , outputformat: iTunesRSSGenerator.OutputFormat.json
            , genre: iTunesRSSGenerator.Genre.game);
        if let tmp = url
        {
            var myRequest:NSURLRequest  = NSURLRequest(URL: url);
            NSURLConnection.sendAsynchronousRequest(myRequest
                , queue: NSOperationQueue.mainQueue()
                , completionHandler: self.responseRSSFeed_paidGame)
        }
        else{ println("paidgame load error"); }
    }
    
    func responseRSSFeed_paidGame(res:NSURLResponse?, data:NSData?, error:NSError?) {
        
        responseRSSFeed(data);
        
        isListUpdating = false;
        
        tableView.reloadData();
    }


    @IBAction func refreshAction(sender: UIBarButtonItem) {
        //downloadRSSFeed();
        
        let alert = UIAlertController(title:"termを入力",
            message: "",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "やめる",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "検索",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as! Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        self.downloadSearchList(textField.text);
                    }
                }
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        //textfiledの追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
        })
        //実行した分textfiledを追加される。
        /*
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
        })
        */
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func anyAction(sender: UIBarButtonItem) {
    }
    
    
    //
    // テーブルビュー
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //return listdata.enrtyList.count;
        return searchData.results.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AppListItem", forIndexPath: indexPath) as! AppListTableViewCell;
        
        // リストデータ更新中
        if isListUpdating == true { return cell; };

        cell.reuseCount = cell.reuseCount &+ 1;
        cell_load_stac[cell.uuid] = cell.reuseCount;

        let cellreusecount = cell.reuseCount;
        let celluuid = cell.uuid;

        cell.imageView?.image = nil;
        cell.textLabel?.text = "";
        
        /*
        let data = listdata.enrtyList[indexPath.row];

        cell.appTitle?.text = data.appname;
        if data.price_amount == 0
        {
            cell.appPrice?.text = "無料";
        }
        else
        {
            cell.appPrice?.text = data.price_label;
        }
        
        cell.appIcon?.image = nil;
        cell.appGenre?.text = data.category_genre;
        cell.appReview?.text = "";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            // 再利用の場合、このセルを対象に行っていたロードを無視する。
            if self.isListUpdating == false && self.cell_load_stac[celluuid]! == cellreusecount {
                
                var url = SearchAPICtrl.instance.makeLookupURL(bundleid: data.bundleId, country: SearchAPICtrl.Country.jp);
                if let tmp = url
                {
                    var myRequest: NSURLRequest = NSURLRequest(URL: url);
                    var response: NSURLResponse?;
                    var error: NSError?;
                    var res = NSURLConnection.sendSynchronousRequest(myRequest, returningResponse: &response, error: &error);
                    
                    if let httpResponse = response as? NSHTTPURLResponse
                    {
                        if httpResponse.statusCode == 200
                        {
                            if let nsstr = NSString(data: res!, encoding: NSUTF8StringEncoding)
                            {
                                self.listLookupData[indexPath.row].parseJSON(nsstr as String);
                                
                                if self.listLookupData[indexPath.row].results.count > 0
                                {
                                    // 再利用の場合、このセルを対象に行っていたロードを無視する。
                                    if self.isListUpdating == false && self.cell_load_stac[celluuid]! == cellreusecount {
                                        
                                        // メインスレッドでUI更新処理
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            
                                            var reviewtextlabel = "評価：";
                                            var reviewtext = String(format: "%.1f"
                                                , self.listLookupData[indexPath.row].results[0].averageUserRating);
                                            if reviewtext == "0.0" {
                                                reviewtext = "なし"
                                            }
                                            switch self.listLookupData[indexPath.row].results[0].averageUserRating {
                                            case let n where n >= 4.5:
                                                cell.appReview?.textColor = UIColor.redColor();
                                            case let n where n >= 4.0:
                                                cell.appReview?.textColor = UIColor.purpleColor();
                                            case let n where n >= 3.0:
                                                cell.appReview?.textColor = UIColor.blackColor();
                                            case let n where n >= 2.0:
                                                cell.appReview?.textColor = UIColor.blueColor();
                                            default:
                                                cell.appReview?.textColor = UIColor.lightGrayColor();
                                            }
                                            cell.appReview?.text = reviewtextlabel + reviewtext;
                                            
                                            let genres = self.listLookupData[indexPath.row].results[0].genres;
                                            let genreIds = self.listLookupData[indexPath.row].results[0].genreIds;
                                            if genres.count >= 2 && genreIds.count >= 2 && genreIds[0] == "6014" {
                                                cell.appGenre?.text = genres[1];
                                            }
                                            
                                            cell.layoutSubviews();
                                        })
                                    }
                                }
                            }
                            else { println("response error"); }
                        }
                        else { println("response status:%d", httpResponse.statusCode); }
                    }
                    else { println("response error"); }
                } else { println("load error"); }
                
                // 画像更新
                if( self.isListUpdating == false && self.cell_load_stac[celluuid]! == cellreusecount && data.images.count > 0 )
                {
                    let imageURL = data.images[data.images.count-1].urllabel;
                    if let url = NSURL(string: imageURL) {
                        if let imagedata = NSData(contentsOfURL: url) {
                            let image = UIImage(data: imagedata);
                            
                            // 再利用の場合、このセルを対象に行っていたロードを無視する。
                            if self.isListUpdating == false && self.cell_load_stac[celluuid]! == cellreusecount {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    cell.appIcon?.image = image;
                                    
                                    cell.layoutSubviews();
                                })
                            }
                        }
                    }
                }
            }
        })
        */
        
        let data = searchData.results[indexPath.row];
        
        cell.appTitle?.text = data.trackName;
        cell.appPrice?.text = data.formattedPrice;
        
        cell.appIcon?.image = nil;
        cell.appGenre?.text = data.primaryGenreName;
        cell.appReview?.text = "";
        
        var reviewtextlabel = "評価：";
        var reviewtext = String(format: "%.1f", data.averageUserRating);
        if reviewtext == "0.0" {
            reviewtext = "なし"
        }
        switch data.averageUserRating {
        case let n where n >= 4.5:
            cell.appReview?.textColor = UIColor.redColor();
        case let n where n >= 4.0:
            cell.appReview?.textColor = UIColor.purpleColor();
        case let n where n >= 3.0:
            cell.appReview?.textColor = UIColor.blackColor();
        case let n where n >= 2.0:
            cell.appReview?.textColor = UIColor.blueColor();
        default:
            cell.appReview?.textColor = UIColor.lightGrayColor();
        }
        cell.appReview?.text = reviewtextlabel + reviewtext;
        
        let genres = data.genres;
        let genreIds = data.genreIds;
        if genres.count >= 2 && genreIds.count >= 2 && genreIds[0] == "6014" {
            cell.appGenre?.text = genres[1];
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            // 再利用の場合、このセルを対象に行っていたロードを無視する。
            // 画像更新
            if( self.isListUpdating == false && self.cell_load_stac[celluuid]! == cellreusecount)
            {
                let imageURL = data.artworkUrl100;
                if let url = NSURL(string: imageURL) {
                    if let imagedata = NSData(contentsOfURL: url) {
                        let image = UIImage(data: imagedata);
                        
                        // 再利用の場合、このセルを対象に行っていたロードを無視する。
                        if self.isListUpdating == false && self.cell_load_stac[celluuid]! == cellreusecount {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.appIcon?.image = image;
                                
                                cell.layoutSubviews();
                            })
                        }
                    }
                }
            }
        })

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        /*
        let data = listdata.enrtyList[indexPath.row];

        let url = NSURL(string: data.link_href);
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
        */
        
        // ハイライト消す
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        let data = searchData.results[indexPath.row];
        
        let alert = UIAlertController(title:"なにする？",
            message: "",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "やめる",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        let storeAction:UIAlertAction = UIAlertAction(title: "AppStoreへ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                //ストアへ
                let url = NSURL(string: data.trackViewUrl);
                if UIApplication.sharedApplication().canOpenURL(url!){
                    UIApplication.sharedApplication().openURL(url!)
                }
        })
        let reviewAction:UIAlertAction = UIAlertAction(title: "レビュー表示",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                //レビューリストクラスへ
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextview = storyboard.instantiateViewControllerWithIdentifier("ReviewListController") as! ReviewListController
                nextview.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve;
                nextview.setting(appId: data.trackId, title: data.trackName);
                self.presentViewController(nextview, animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(storeAction)
        alert.addAction(reviewAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

