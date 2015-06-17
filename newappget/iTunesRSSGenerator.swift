import Foundation

// シングルトン

class iTunesRSSGenerator
{
    private init() {
        
    }
    static let instance = iTunesRSSGenerator();
    
    let baseURL = "https://itunes.apple.com";
    
    enum Country: String {
        case us = "us"
        case jp = "jp"
    }
    
    enum FeedType: String {
        case newapp = "newapplications"
        case newfreeapp = "newfreeapplications"
        case newpaidapp = "newpaidapplications"
    }
    
    enum OutputFormat: String {
        case xml = "xml"
        case json = "json"
    }
    
    enum Genre: String {
        case all = ""
        case game = "6014"
    }
    
    func makeURL(country: Country = Country.us
        , feedtype: FeedType = FeedType.newapp
        , limit: UInt = 50
        , outputformat: OutputFormat = OutputFormat.json
        , genre: Genre = Genre.all) -> NSURL!
    {
        var url = "\(baseURL)/";
        url +=  "\(country.rawValue)/";
        url += "rss/";
        url += "\(feedtype.rawValue)/";
        url += "limit=\(limit)/";
        if genre != Genre.all {
            url += "genre=\(genre.rawValue)/";
        }
        url += "\(outputformat.rawValue)";
        return NSURL(string: url);
    }
    
    func makeURL_reviews(country: Country = Country.us
        , appid: String = ""
        , outputformat: OutputFormat = OutputFormat.json) -> NSURL!
    {
        var url = "\(baseURL)/";
        url +=  "\(country.rawValue)/";
        url += "rss/";
        url += "customerreviews/";
        url += "id=\(appid)/";
        url += "\(outputformat.rawValue)";
        return NSURL(string: url);
    }
}

struct iTunesRSSData {
    
    var nameLabel: String = "";
    var uriLabel: String = "";
    
    struct Entry {
        
        var category_id: String = "";
        var category_genre: String = "";
        var category_scheme: String = "";
        var category_term: String = "";
        
        var bundleId: String = "";
        var id: String = "";
        var label: String = "";
        
        var artist_href: String = "";
        var artist_label: String = "";
        
        var contenttype_label: String = "";
        var contenttype_term: String = "";
        
        struct Image {
            var height: String = "";
            var urllabel: String = "";
            
            mutating func parse(json: JSON)
            {
                if let s = json["attributes"]["height"].asString { height = s; }
                if let s = json["label"].asString { urllabel = s; }
            }
        }
        var images: [Image] = [];
        
        var appname: String = "";
        
        var price_amount: Double = 0;
        var price_currency: String = "";
        var price_label: String = "";
        
        var releasedate: String = "";
        var releasedate_label: String = "";
        
        var link_href: String = "";
        var link_rel: String = "";
        var link_type: String = "";
        
        var rights_label: String = "";
        
        var titlelabel: String = "";
        
        mutating func parse(json: JSON)
        {
            if let s = json["category"]["attributes"]["im:id"].asString { category_id = s; }
            if let s = json["category"]["attributes"]["label"].asString { category_genre = s; }
            if let s = json["category"]["attributes"]["scheme"].asString { category_scheme = s; }
            if let s = json["category"]["attributes"]["term"].asString { category_term = s; }
            
            if let s = json["id"]["attributes"]["im:bundleId"].asString { bundleId = s; }
            if let s = json["id"]["attributes"]["im:id"].asString { id = s; }
            if let s = json["id"]["label"].asString { label = s; }
            
            if let s = json["im:artist"]["attributes"]["href"].asString { artist_href = s; }
            if let s = json["im:artist"]["label"].asString { artist_label = s; }
            
            if let s = json["im:contentType"]["attributes"]["label"].asString { contenttype_label = s; }
            if let s = json["im:contentType"]["attributes"]["term"].asString { contenttype_term = s; }
            
            let imageArray = json["im:image"].asArray!;
            
            for i in imageArray {
                
                var imageBuf = iTunesRSSData.Entry.Image();
                imageBuf.parse(i);
                images += [imageBuf];
            }
            
            if let s = json["im:name"]["label"].asString { appname = s; }
            
            if let s = json["im:price"]["attributes"]["amount"].asString {
                price_amount = NSString(string: s).doubleValue;
            }
            if let s = json["im:price"]["attributes"]["currency"].asString { price_currency = s; }
            if let s = json["im:price"]["label"].asString { price_label = s; }
            
            if let s = json["im:releaseDate"]["attributes"]["label"].asString { releasedate = s; }
            if let s = json["im:releaseDate"]["label"].asString { releasedate = s; }
            
            if let s = json["link"]["attributes"]["href"].asString { link_href = s; }
            if let s = json["link"]["attributes"]["rel"].asString { link_rel = s; }
            if let s = json["link"]["attributes"]["type"].asString { link_type = s; }
            
            if let s = json["rights"]["label"].asString { rights_label = s; }
            
            if let s = json["title"]["label"].asString { rights_label = s; }
        }
    }
    
    var enrtyList: [Entry] = [];
    
    mutating func parseJSON(jsonStr: String, targetGenre: [iTunesRSSGenerator.Genre] = []) {
        
        println(jsonStr);
        
        let json = JSON.parse(jsonStr);
        
        let feed = json["feed"];
        
        if let s = feed["author"]["name"]["label"].asString { nameLabel = s; }
        if let s = feed["author"]["uri"]["label"].asString { uriLabel = s; }
        
        let entrys = feed["entry"].asArray!;
        
        for e in entrys {
            var entryBuf = iTunesRSSData.Entry();
            entryBuf.parse(e);
            
            for genre in targetGenre {
                if entryBuf.category_id  == genre.rawValue {
                    enrtyList += [entryBuf];
                    break;
                }
            }
        }
    }
    
    mutating func reset() {
        nameLabel = "";
        uriLabel = "";
        enrtyList = [];
    }
}
