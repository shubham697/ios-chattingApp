import Foundation

class StateCityService {
    
    func get(_ url: String, token : String,  body: [String : Any], completion: @escaping CompletionObject<[Dictionary<String,Any>] >) {
       
        //create the url with URL
        let url_str = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let _url = URL(string: url_str!) else {
            completion([])
            return
        }
        
        //create the session object
        let session = URLSession.shared
        //now create the URLRequest object using the url object
        var request = URLRequest(url: _url)
        request.httpMethod = "GET"
//
//        do {
//            let parameters = ["id": 13, "name": "jack"]
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//        } catch let error {
//            print(error.localizedDescription)
//        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + token, forHTTPHeaderField : "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
               {
                    completion(jsonArray)
               } else {
                    completion([])
               }
              
            } catch let error {
                print(error.localizedDescription)
                 completion([])
            }
        })
        task.resume()
    }
    
    
    func get_token(completion: @escaping CompletionObject<Dictionary<String,Any> >) {
           
            //create the url with URL
            let url = "https://www.universal-tutorial.com/api/getaccesstoken"
            let url_str = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let _url = URL(string: url_str!) else {
                completion(["token" : ""])
                return
            }
            
            //create the session object
            let session = URLSession.shared
            //now create the URLRequest object using the url object
            var request = URLRequest(url: _url)
            request.httpMethod = "GET"
 
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("TchLlQSoAmkMv2ZsK9SfkZQfv41TjoCjpJcly2QpHHW7wvt6NiHfCBRqg_ydXjn2dCw", forHTTPHeaderField : "api-token")
            request.addValue("danevhome01@gmail.com", forHTTPHeaderField : "user-email")
        
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

                guard error == nil else {
                    completion(["token" : ""])
                    return
                }
                guard let data = data else {
                    completion(["token" : ""])
                    return
                }

                do {
                    if let jsonObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                   {
                        completion(["token" : jsonObj["auth_token"]])
                   } else {
                       completion(["token" : ""])
                   }
                  
                } catch let error {
                    print(error.localizedDescription)
                     completion(["token" : ""])
                }
            })
            task.resume()
        }
}
