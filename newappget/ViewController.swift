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
    
    var cell_load_stac: [AppListTableViewCell : Int] = [:];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        // リストデータ更新
        downloadRSSFeed();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadRSSFeed() {
        
        // 初期化
        listdata.reset();
        
        var url = iTunesRSSGenerator.instance.makeURL(country: iTunesRSSGenerator.Country.jp
            , feedtype: iTunesRSSGenerator.FeedType.newfreeapp
            , limit: 200
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
            listdata.parseJSON(nsstr as String);
            
            listLookupData = [LookupAPIData](count: listdata.enrtyList.count, repeatedValue: LookupAPIData());
        }
        else { println("response data error"); }
    }
    
    func responseRSSFeed_freeGame(res:NSURLResponse?, data:NSData?, error:NSError?) {
        
        responseRSSFeed(data);
        
        var url = iTunesRSSGenerator.instance.makeURL(country: iTunesRSSGenerator.Country.jp
            , feedtype: iTunesRSSGenerator.FeedType.newpaidapp
            , limit: 200
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
        
        tableView.reloadData();
    }


    @IBAction func refreshAction(sender: UIBarButtonItem) {
        downloadRSSFeed();
    }
    
    @IBAction func anyAction(sender: UIBarButtonItem) {
    }
    
    
    //
    // テーブルビュー
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listdata.enrtyList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AppListItem", forIndexPath: indexPath) as! AppListTableViewCell;

        cell.imageView?.image = nil;
        cell.textLabel?.text = "";
        
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
        
        if let i = cell_load_stac[cell] {
            cell_load_stac[cell] = i + 1;
        }
        else {
            cell_load_stac[cell] = 1;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            // 再利用の場合、このセルを対象に行っていたロードを無視する。
            if self.cell_load_stac[cell]! <= 1 {
                
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
                                    if self.cell_load_stac[cell]! <= 1 {
                                        
                                        // メインスレッドでUI更新処理
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            
                                            var reviewtextlabel = "評価：";
                                            var reviewtext = String(format: "%.1f"
                                                , self.listLookupData[indexPath.row].results[0].averageUserRating);
                                            if reviewtext == "0.0" {
                                                reviewtext = "なし"
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
                if( data.images.count > 0 )
                {
                    let imageURL = data.images[data.images.count-1].urllabel;
                    if let url = NSURL(string: imageURL) {
                        if let imagedata = NSData(contentsOfURL: url) {
                            let image = UIImage(data: imagedata);
                            
                            // 再利用の場合、このセルを対象に行っていたロードを無視する。
                            if self.cell_load_stac[cell]! <= 1 {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    cell.appIcon?.image = image;
                                    
                                    cell.layoutSubviews();
                                })
                            }
                        }
                    }
                }
            }
            
            self.cell_load_stac[cell] = self.cell_load_stac[cell]! - 1;
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        let data = listdata.enrtyList[indexPath.row];

        let url = NSURL(string: data.link_href);
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}

