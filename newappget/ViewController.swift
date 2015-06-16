import UIKit

class ViewController: UIViewController
    , UITableViewDataSource
    , UITableViewDelegate
{

    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var listdata: iTunesRSSData!;
    
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
        var url = iTunesRSSGenerator.instance.makeURL(country: iTunesRSSGenerator.Country.jp
            , feedtype: iTunesRSSGenerator.FeedType.newapp
            , limit: 200
            , outputformat: iTunesRSSGenerator.OutputFormat.json
            , genre: iTunesRSSGenerator.Genre.game);
        if let tmp = url
        {
            var myRequest:NSURLRequest  = NSURLRequest(URL: url);
            NSURLConnection.sendAsynchronousRequest(myRequest
                , queue: NSOperationQueue.mainQueue()
                , completionHandler: self.responseRSSFeed)
        }
        else
        {
            NSLog("load error");
        }
    }
    
    func responseRSSFeed(res:NSURLResponse?, data:NSData?, error:NSError?) {
        
        // レスポンスをを文字列に変換.
        if let nsstr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        {
            // パース
            listdata = iTunesRSSGenerator.instance.parseJSON(nsstr as String);
            
            tableView.reloadData();
        }
        else
        {
            println("load error");
        }
    }

    @IBAction func refreshAction(sender: UIBarButtonItem) {
    }
    
    @IBAction func anyAction(sender: UIBarButtonItem) {
    }
    
    
    //
    // テーブルビュー
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let list = listdata {
            return list.enrtyList.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AppListItem", forIndexPath: indexPath) as! AppListTableViewCell;

        cell.imageView?.image = nil;
        cell.textLabel?.text = "";
        
        let data = listdata.enrtyList[indexPath.row];

        cell.appTitle?.text = data.appname;
        cell.appGenre?.text = data.category_genre;
        if data.price_amount == 0
        {
            cell.appPrice?.text = "無料";
        }
        else
        {
            cell.appPrice?.text = "\(data.price_amount)";
        }
        
        cell.appIcon?.image = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            // 画像更新
            if( data.images.count > 0 )
            {
                let imageURL = data.images[data.images.count-1].urllabel;
                if let url = NSURL(string: imageURL) {
                    if let imagedata = NSData(contentsOfURL: url) {
                        let image = UIImage(data: imagedata);
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.appIcon?.image = image;
                            
                            cell.layoutSubviews();
                        })
                    }
                }
            }
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

