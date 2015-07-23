import UIKit

class ReviewListController: UIViewController
    , UITableViewDataSource
    , UITableViewDelegate
    , NSXMLParserDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewTitle: UINavigationItem!
    
    var targetAppId: UInt = 0;
    var targetAppTitle: String = "";
    
    var reviewData: ReviewData = ReviewData();
    
    func setting(appId: UInt = 0, title: String = "") {
        
        targetAppId = appId;
        targetAppTitle = title;
        
        var url = iTunesRSSGenerator.instance.makeURL_reviews(country: iTunesRSSGenerator.Country.jp
            , appid: targetAppId
            , outputformat: iTunesRSSGenerator.OutputFormat.json);
        if let tmp = url
        {
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
            // パース
            reviewData.parseJSON(nsstr as String);
            
            tableView.reloadData();
        }
        else { println("responseReview data error"); }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        viewTitle.title = "\(targetAppTitle) のレビュー";
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    //
    // XMLパーサ
    //
    func parserDidStartDocument(parser: NSXMLParser)
    {
        // Itemオブジェクトを格納するItems配列の初期化など
    }
    func parserDidEndDocument(parser: NSXMLParser)
    {
        // XMLから読み込んだ情報より画面を更新する処理など
    }
    // タグの最初
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject])
    {
        /*
        let _ParseKey = elementName
        
        if elementName == "Items" {
            // Itemオブジェクトを保存するItems配列を初期化
            var _Items = []
            
        } else if elementName == "Item" {
            // Itemオブジェクトの初期化
            var _Item = Item()
        }
        */
    }
    // タグの最後
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        /*
        if elementName == "Item" {
            var _Items.append(_Item!)
        }
        
        var _ParseKey = ""
        */
    }
    // 各項目
    func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        /*
        if var _ParseKey == "ItemName" {
            _Item!.itemName = string
            
        } else if _ParseKey == "ItemPrice" {
            _Item!.itemPrice = string.toInt()
            
        } else {
            // nop
        }
        */
    }
    
    //
    // テーブルビュー
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return reviewData.enrtyList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewListItem", forIndexPath: indexPath) as! ReviewListTableViewCell;
        
        cell.imageView?.image = nil;
        cell.textLabel?.text = nil;
        
        cell.Name.text = reviewData.enrtyList[indexPath.row].name;
        
        var contenttext = "タイトル：\(reviewData.enrtyList[indexPath.row].title)\n";
        contenttext += reviewData.enrtyList[indexPath.row].content;
        cell.Content.text = contenttext;

        var reviewtextlabel = "評価：";
        var reviewtext = String(format: "%.1f", reviewData.enrtyList[indexPath.row].rating);
        if reviewtext == "0.0" {
            reviewtext = "なし"
        }
        switch reviewData.enrtyList[indexPath.row].rating {
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
        
        // 内容コピー
        var text = "";
        text += "レビュワー : \(reviewData.enrtyList[indexPath.row].name)\n"
        var reviewtextlabel = "評価 : ";
        var reviewtext = String(format: "%.1f", reviewData.enrtyList[indexPath.row].rating);
        if reviewtext == "0.0" {
            reviewtext = "なし"
        }
        text += (reviewtextlabel + reviewtext + "\n");
        var contenttext = "タイトル : \(reviewData.enrtyList[indexPath.row].title)\n";
        contenttext += reviewData.enrtyList[indexPath.row].content;
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