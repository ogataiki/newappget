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
        case game = "genre=6014/"
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
        url += "\(genre.rawValue)";
        url += "\(outputformat.rawValue)";
        return NSURL(string: url);
    }
}

class iTunesRSSData {
    
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
        }
        var images: [Image] = [];
        
        var appname: String = "";
        
        var price_amount: String = "";
        var price_currency: String = "";
        var price_label: String = "";
        
        var releasedate: String = "";
        var releasedate_label: String = "";
        
        var link_href: String = "";
        var link_rel: String = "";
        var link_type: String = "";
        
        var rights_label: String = "";
        
        var titlelabel: String = "";
    }
    
    var enrtyList: [Entry] = [];
}

extension iTunesRSSGenerator {
    
    func parseJSON(jsonStr: String) -> iTunesRSSData {
        
        println(jsonStr);
        
        var data = iTunesRSSData();
        
        let json = JSON.parse(jsonStr);
        
        let feed = json["feed"];

        if let s = feed["author"]["name"]["label"].asString { data.nameLabel = s; }
        if let s = feed["author"]["uri"]["label"].asString { data.uriLabel = s; }
        
        let entrys = feed["entry"].asArray!;
        
        for e in entrys {

            var entryBuf = iTunesRSSData.Entry();
            
            if let s = e["category"]["attributes"]["im:id"].asString { entryBuf.category_id = s; }
            if let s = e["category"]["attributes"]["label"].asString { entryBuf.category_genre = s; }
            if let s = e["category"]["attributes"]["scheme"].asString { entryBuf.category_scheme = s; }
            if let s = e["category"]["attributes"]["term"].asString { entryBuf.category_term = s; }
            
            if let s = e["id"]["attributes"]["im:bundleId"].asString { entryBuf.bundleId = s; }
            if let s = e["id"]["attributes"]["im:id"].asString { entryBuf.id = s; }
            if let s = e["id"]["label"].asString { entryBuf.label = s; }

            if let s = e["im:artist"]["attributes"]["href"].asString { entryBuf.artist_href = s; }
            if let s = e["im:artist"]["label"].asString { entryBuf.artist_label = s; }
            
            if let s = e["im:contentType"]["attributes"]["label"].asString { entryBuf.contenttype_label = s; }
            if let s = e["im:contentType"]["attributes"]["term"].asString { entryBuf.contenttype_term = s; }
            
            let images = e["im:image"].asArray!;
            
            for i in images {
                
                var imageBuf = iTunesRSSData.Entry.Image();
                
                if let s = i["attributes"]["height"].asString { imageBuf.height = s; }
                if let s = i["label"].asString { imageBuf.urllabel = s; }

                entryBuf.images += [imageBuf];
            }
            
            if let s = e["im:name"]["label"].asString { entryBuf.appname = s; }
            
            if let s = e["im:price"]["attributes"]["amount"].asString { entryBuf.price_amount = s; }
            if let s = e["im:price"]["attributes"]["currency"].asString { entryBuf.price_currency = s; }
            if let s = e["im:price"]["label"].asString { entryBuf.price_label = s; }

            if let s = e["im:releaseDate"]["attributes"]["label"].asString { entryBuf.releasedate = s; }
            if let s = e["im:releaseDate"]["label"].asString { entryBuf.releasedate = s; }
            
            if let s = e["link"]["attributes"]["href"].asString { entryBuf.link_href = s; }
            if let s = e["link"]["attributes"]["rel"].asString { entryBuf.link_rel = s; }
            if let s = e["link"]["attributes"]["type"].asString { entryBuf.link_type = s; }
            
            if let s = e["rights"]["label"].asString { entryBuf.rights_label = s; }
            
            if let s = e["title"]["label"].asString { entryBuf.rights_label = s; }
            
            data.enrtyList += [entryBuf];
        }
        
        return data;
    }
}

