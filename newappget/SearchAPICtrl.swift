import Foundation

// シングルトン

class SearchAPICtrl
{
    private init() {
        
    }
    static let instance = SearchAPICtrl();
    
    //static let baseSearchURL = "https://itunes.apple.com/search?";
    static let baseSearchURL = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?";
    //static let baseLookupURL = "https://itunes.apple.com/lookup?";
    static let baseLookupURL = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsLookup?";
    
    enum Country: String {
        case us = "us"
        case jp = "jp"
    }

    func makeSearchURL(term: String = "yelp"
        , country: Country = Country.jp
        , entity: String = "software") -> NSURL!
    {
        // URLエンコーディング
        let encodedTerm = term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        let encodedCountry = country.rawValue.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        let encodedEntity = entity.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        
        return NSURL(string: "\(SearchAPICtrl.baseSearchURL)term=\(encodedTerm)&country=\(encodedCountry)&entity=\(entity)");
    }
    
    func makeLookupURL(bundleid: String = ""
        , country: Country = Country.jp) -> NSURL!
    {
        return NSURL(string: "\(SearchAPICtrl.baseLookupURL)country=\(country.rawValue)&bundleId=\(bundleid)");
    }
}

struct SearchAPIData {
    
    struct Result {
        
        var advisories: String = "";
        
        var artistId: UInt = 0;
        var artistName: String = "";
        var artistViewUrl: String = "";
        var artworkUrl100: String = "";
        var artworkUrl512: String = "";
        var artworkUrl60: String = "";
        
        var averageUserRating: Double = 0.0;
        var averageUserRatingForCurrentVersion: Double = 0.0;
        var userRatingCount: UInt = 0;
        var userRatingCountForCurrentVersion: UInt = 0;
        
        var bundleId: String = "";
        
        var contentAdvisoryRating: String = "";
        
        var currency: String = "";
        
        var description: String = "";
        
        var features: [String] = [];
        
        var fileSizeBytes: String = "0";
        
        var formattedPrice: String = "";
        var price: Double = 0.0;
        
        var genreIds: [String] = [];
        var genres: [String] = [];
        var primaryGenreId: UInt = 0;
        var primaryGenreName: String = "";
        
        var screenshotUrls: [String] = [];
        var ipadScreenshotUrls: [String] = [];
        
        var isGameCenterEnabled: Bool = false;
        
        var isVppDeviceBasedLicensingEnabled: Bool = false;
        
        var kind: String = "";
        
        var languageCodesISO2A: String = "";
        
        var minimumOsVersion: String = "";
        
        var releaseDate: String = "";
        
        var releaseNotes: String = "";
        
        var sellerName: String = "";
        var sellerUrl: String = "";
        var supportedDevices: [String] = [];
        
        var trackCensoredName: String = "";
        var trackContentRating: String = "";
        var trackId: UInt = 0;
        var trackName: String = "";
        var trackViewUrl: String = "";
        
        var version: String = "";
        
        var wrapperType: String = "";
        
        mutating func parse(json: JSON) {
            
            if let tmp = json["advisories"].asString { advisories = tmp; }
            
            if let tmp = json["artistId"].asInt { artistId = UInt(tmp); }
            if let tmp = json["artistName"].asString { artistName = tmp; }
            if let tmp = json["artistViewUrl"].asString { artistViewUrl = tmp; }
            
            if let tmp = json["artworkUrl100"].asString { artworkUrl100 = tmp; }
            if let tmp = json["artworkUrl512"].asString { artworkUrl512 = tmp; }
            if let tmp = json["artworkUrl60"].asString { artworkUrl60 = tmp; }
            
            if let tmp = json["averageUserRating"].asDouble { averageUserRating = tmp; }
            if let tmp = json["averageUserRatingForCurrentVersion"].asDouble { averageUserRatingForCurrentVersion = tmp; }
            if let tmp = json["userRatingCount"].asInt { userRatingCount = UInt(tmp); }
            if let tmp = json["userRatingCountForCurrentVersion"].asInt { userRatingCountForCurrentVersion = UInt(tmp); }
            
            if let tmp = json["bundleId"].asString { bundleId = tmp; }
            
            if let tmp = json["contentAdvisoryRating"].asString { contentAdvisoryRating = tmp; }
            
            if let tmp = json["currency"].asString { currency = tmp; }
            
            if let tmp = json["description"].asString { description = tmp; }
            
            let featureArray = json["features"].asArray!;
            for feature in featureArray {
                features += [feature.asString!];
            }
            
            if let tmp = json["fileSizeBytes"].asString { fileSizeBytes = tmp; }
            
            if let tmp = json["formattedPrice"].asString { formattedPrice = tmp; }
            if let tmp = json["price"].asDouble { price = tmp; }
            
            let genreIdArray = json["genreIds"].asArray!;
            for genreId in genreIdArray {
                genreIds += [genreId.asString!];
            }
            let genreArray = json["genres"].asArray!;
            for genre in genreArray {
                genres += [genre.asString!];
            }
            if let tmp = json["primaryGenreId"].asInt { primaryGenreId = UInt(tmp); }
            if let tmp = json["primaryGenreName"].asString { primaryGenreName = tmp; }
            
            let screenshotUrlArray = json["screenshotUrls"].asArray!;
            for screenshotUrl in screenshotUrlArray {
                screenshotUrls += [screenshotUrl.asString!];
            }
            let iPadScreenshotUrlArray = json["ipadScreenshotUrls"].asArray!;
            for screenshotUrl in iPadScreenshotUrlArray {
                ipadScreenshotUrls += [screenshotUrl.asString!];
            }
            
            if let tmp = json["isGameCenterEnabled"].asBool { isGameCenterEnabled = tmp; }
            
            if let tmp = json["isVppDeviceBasedLicensingEnabled"].asBool { isVppDeviceBasedLicensingEnabled = tmp; }
            
            if let tmp = json["kind"].asString { kind = tmp; }
            
            if let tmp = json["languageCodesISO2A"].asString { languageCodesISO2A = tmp; }
            
            if let tmp = json["minimumOsVersion"].asString { minimumOsVersion = tmp; }
            
            if let tmp = json["releaseDate"].asString { releaseDate = tmp; }
            
            if let tmp = json["releaseNotes"].asString { releaseNotes = tmp; }
            
            if let tmp = json["sellerName"].asString { sellerName = tmp; }
            if let tmp = json["sellerUrl"].asString { sellerUrl = tmp; }
            
            let supportedDeviceArray = json["supportedDevices"].asArray!;
            for supportedDevice in supportedDeviceArray {
                supportedDevices += [supportedDevice.asString!];
            }
            
            if let tmp = json["trackCensoredName"].asString { trackCensoredName = tmp; }
            if let tmp = json["trackContentRating"].asString { trackContentRating = tmp; }
            if let tmp = json["trackId"].asInt { trackId = UInt(tmp); }
            if let tmp = json["trackName"].asString { trackName = tmp; }
            if let tmp = json["trackViewUrl"].asString { trackViewUrl = tmp; }
            
            if let tmp = json["version"].asString { version = tmp; }
            
            if let tmp = json["wrapperType"].asString { wrapperType = tmp; }
        }
    }
    var results: [Result] = [];
    
    mutating func parseJSON(jsonStr: String) {
        
        println(jsonStr);
        
        let json = JSON.parse(jsonStr);
        
        let resultCount = json["resultCount"];
        
        let resultArray = json["results"].asArray!;
        
        for result in resultArray {
            var resultBuf = Result();
            resultBuf.parse(result);
            results += [resultBuf];
        }
    }
}

struct LookupAPIData {
    
    struct Result {
        
        var artistId: UInt = 0;
        var artistName: String = "";
        var artistViewUrl: String = "";
        var artworkUrl100: String = "";
        var artworkUrl512: String = "";
        var artworkUrl60: String = "";
        
        var averageUserRating: Double = 0.0;
        var averageUserRatingForCurrentVersion: Double = 0.0;
        var userRatingCount: UInt = 0;
        var userRatingCountForCurrentVersion: UInt = 0;
        
        var bundleId: String = "";
        
        var contentAdvisoryRating: String = "";
        
        var currency: String = "";
        
        var description: String = "";
        
        var features: [String] = [];
        
        var fileSizeBytes: String = "0";
        
        var formattedPrice: String = "";
        var price: Double = 0.0;
        
        var genreIds: [String] = [];
        var genres: [String] = [];
        var primaryGenreId: UInt = 0;
        var primaryGenreName: String = "";
        
        var screenshotUrls: [String] = [];
        var ipadScreenshotUrls: [String] = [];
        
        var isGameCenterEnabled: Bool = false;
        
        var isVppDeviceBasedLicensingEnabled: Bool = false;
        
        var kind: String = "";
        
        var languageCodesISO2A: String = "";
        
        var minimumOsVersion: String = "";
        
        var releaseDate: String = "";
        
        var releaseNotes: String = "";
        
        var sellerName: String = "";
        var sellerUrl: String = "";
        var supportedDevices: [String] = [];
        
        var trackCensoredName: String = "";
        var trackContentRating: String = "";
        var trackId: UInt = 0;
        var trackName: String = "";
        var trackViewUrl: String = "";
        
        var version: String = "";
        
        var wrapperType: String = "";
        
        mutating func parse(json: JSON) {
            
            if let tmp = json["artistId"].asInt { artistId = UInt(tmp); }
            if let tmp = json["artistName"].asString { artistName = tmp; }
            if let tmp = json["artistViewUrl"].asString { artistViewUrl = tmp; }
            
            if let tmp = json["artworkUrl100"].asString { artworkUrl100 = tmp; }
            if let tmp = json["artworkUrl512"].asString { artworkUrl512 = tmp; }
            if let tmp = json["artworkUrl60"].asString { artworkUrl60 = tmp; }

            if let tmp = json["averageUserRating"].asDouble { averageUserRating = tmp; }
            if let tmp = json["averageUserRatingForCurrentVersion"].asDouble { averageUserRatingForCurrentVersion = tmp; }
            if let tmp = json["userRatingCount"].asInt { userRatingCount = UInt(tmp); }
            if let tmp = json["userRatingCountForCurrentVersion"].asInt { userRatingCountForCurrentVersion = UInt(tmp); }

            if let tmp = json["bundleId"].asString { bundleId = tmp; }

            if let tmp = json["contentAdvisoryRating"].asString { contentAdvisoryRating = tmp; }

            if let tmp = json["currency"].asString { currency = tmp; }

            if let tmp = json["description"].asString { description = tmp; }
            
            let featureArray = json["features"].asArray!;
            for feature in featureArray {
                features += [feature.asString!];
            }

            if let tmp = json["fileSizeBytes"].asString { fileSizeBytes = tmp; }
            
            if let tmp = json["formattedPrice"].asString { formattedPrice = tmp; }
            if let tmp = json["price"].asDouble { price = tmp; }

            let genreIdArray = json["genreIds"].asArray!;
            for genreId in genreIdArray {
                genreIds += [genreId.asString!];
            }
            let genreArray = json["genres"].asArray!;
            for genre in genreArray {
                genres += [genre.asString!];
            }
            if let tmp = json["primaryGenreId"].asInt { primaryGenreId = UInt(tmp); }
            if let tmp = json["primaryGenreName"].asString { primaryGenreName = tmp; }
            
            let screenshotUrlArray = json["screenshotUrls"].asArray!;
            for screenshotUrl in screenshotUrlArray {
                screenshotUrls += [screenshotUrl.asString!];
            }
            let iPadScreenshotUrlArray = json["ipadScreenshotUrls"].asArray!;
            for screenshotUrl in iPadScreenshotUrlArray {
                ipadScreenshotUrls += [screenshotUrl.asString!];
            }

            if let tmp = json["isGameCenterEnabled"].asBool { isGameCenterEnabled = tmp; }
            
            if let tmp = json["isVppDeviceBasedLicensingEnabled"].asBool { isVppDeviceBasedLicensingEnabled = tmp; }

            if let tmp = json["kind"].asString { kind = tmp; }

            if let tmp = json["languageCodesISO2A"].asString { languageCodesISO2A = tmp; }

            if let tmp = json["minimumOsVersion"].asString { minimumOsVersion = tmp; }

            if let tmp = json["releaseDate"].asString { releaseDate = tmp; }

            if let tmp = json["releaseNotes"].asString { releaseNotes = tmp; }

            if let tmp = json["sellerName"].asString { sellerName = tmp; }
            if let tmp = json["sellerUrl"].asString { sellerUrl = tmp; }

            let supportedDeviceArray = json["supportedDevices"].asArray!;
            for supportedDevice in supportedDeviceArray {
                supportedDevices += [supportedDevice.asString!];
            }

            if let tmp = json["trackCensoredName"].asString { trackCensoredName = tmp; }
            if let tmp = json["trackContentRating"].asString { trackContentRating = tmp; }
            if let tmp = json["trackId"].asInt { trackId = UInt(tmp); }
            if let tmp = json["trackName"].asString { trackName = tmp; }
            if let tmp = json["trackViewUrl"].asString { trackViewUrl = tmp; }

            if let tmp = json["version"].asString { version = tmp; }
            
            if let tmp = json["wrapperType"].asString { wrapperType = tmp; }            
        }
    }
    var results: [Result] = [];

    mutating func parseJSON(jsonStr: String) {
        
        println(jsonStr);
        
        let json = JSON.parse(jsonStr);
        
        let resultCount = json["resultCount"];
        
        let resultArray = json["results"].asArray!;
        
        for result in resultArray {
            var resultBuf = Result();
            resultBuf.parse(result);
            results += [resultBuf];
        }
    }
}