//
//  FireStoreManager.swift
//  SnackCheck
//
//  Created by ELİF ÇAĞIL on 1.05.2025.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirestoreManager{
    var tempList: [Product] = []
    
    
    //MARK: -PersonalFetch
    
    func FetchPersonel(completion: @escaping ([String]) -> Void) {
        let personelInfoTitles = [
            "Bildirimler",
            "Kişisel Bilgiler",
            "Ayarlar",
            "Oturumu Kapat",
            "Hesabımı Kalıcı Olarak Sil",
            "Sağlık Verileri"
        ]
        completion(personelInfoTitles)
    }

    
    //MARK: -CategoriesFunc
    
    func FetchCategories(completion: @escaping ([Category]) -> Void) {
        
    }
    
    //MARK: -ProductsFunc
    
    func fetchProductByBarcode(_ barcode: String, completion: @escaping (Product?) -> Void) {
        guard let getURL = URL(string: "http://localhost:3000/api/products/\(barcode)") else {
            print("❌ Geçersiz GET URL")
            completion(nil)
            return
        }

        var getRequest = URLRequest(url: getURL)
        getRequest.httpMethod = "GET"

        URLSession.shared.dataTask(with: getRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                // 🔁 Ürün bulunamadı → POST ile ekle
                print("⚠️ Ürün bulunamadı, POST ile ekleniyor...")

                guard let postURL = URL(string: "http://localhost:3000/api/products/\(barcode)") else {
                    print("❌ Geçersiz POST URL")
                    completion(nil)
                    return
                }

                var postRequest = URLRequest(url: postURL)
                postRequest.httpMethod = "POST"

                URLSession.shared.dataTask(with: postRequest) { [self] _, postResponse, postError in
                    if let postError = postError {
                        print("❌ POST hatası: \(postError.localizedDescription)")
                        completion(nil)
                        return
                    }

                    print("✅ Ürün başarıyla eklendi, tekrar GET yapılıyor...")

                    // ✅ POST sonrası tekrar GET yap
                    fetchProductByBarcode(barcode, completion: completion)

                }.resume()

                return
            }

            if let error = error {
                print("❌ Hata: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ Veri gelmedi")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let product = Product(
                        product_id: json["id"] as? String ?? "",
                        product_name: json["name"] as? String ?? "",
                        product_brand: json["brands"] as? String ?? "",
                        product_image: json["image_url"] as? String ?? "",
                        category: json["categories"] as? String ?? "",
                        ingeridents: json["ingredients_text"] as? String ?? "",
                        food_values: json["nutriments"] as? [String: String] ?? [:],
                        isFavorites: false,
                        barcode: json["code"] as? String ?? "",
                        carbohydrates: json["carbohydrates"] as? Int ?? 0,
                        energy: json["energy_kcal"] as? Int ?? 0,
                        fat: json["fat"] as? Int ?? 0,
                        proteins: json["proteins"] as? Int ?? 0,
                        salt: json["salt"] as? Double ?? 0,
                        saturated_fat: json["saturated_fat"] as? Double ?? 0,
                        sugars: json["sugars"] as? Int ?? 0,
                        fiber: json["sodium"]as? Double ?? 0
                    )
                    completion(product)
                } else {
                    print("❌ JSON format hatası")
                    completion(nil)
                }
            } catch {
                print("❌ JSON parse hatası: \(error)")
                completion(nil)
            }

        }.resume()
    }


    
    func fetchProductsByCategory(_ category: String, completion: @escaping ([Product])-> Void) {
        
    }
    
    //MARK: -UserFunc
    
    func createUser(name:String,surname:String, email:String, password:String,completion:@escaping (Result<Void,Error>)->(Void)){
        
        guard let url = URL(string: "http://localhost:3000/api/auth/register") else {
                   completion(.failure(NSError(domain: "Geçersiz URL", code: -1)))
                   return
               }
               
               let requestBody: [String: Any] = [
                   "firstName": name,
                   "lastName": surname,
                   "email": email,
                   "password": password
               ]
               
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
               
               do {
                   request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
               } catch {
                   completion(.failure(error))
                   return
               }
               
               URLSession.shared.dataTask(with: request) { data, response, error in
                   
                   // 1. Hata varsa
                   if let error = error {
                       completion(.failure(error))
                       return
                   }
                   
                   // 2. Geçerli response kontrolü
                   guard let httpResponse = response as? HTTPURLResponse else {
                       completion(.failure(NSError(domain: "Geçersiz yanıt", code: -2)))
                       return
                   }
                   
                   // 3. Status kodu kontrol
                   guard (200...299).contains(httpResponse.statusCode) else {
                       let statusError = NSError(domain: "Sunucu hatası", code: httpResponse.statusCode)
                       completion(.failure(statusError))
                       return
                   }
                   
                   // 4. JSON çözümleme
                   guard let data = data else {
                       completion(.failure(NSError(domain: "Boş veri", code: -3)))
                       return
                   }
                   
                   do {
                       let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                       
                       if let _ = json?["uid"] as? String {
                           completion(.success(()))
                       } else if let errorMessage = json?["error"] as? String {
                           let backendError = NSError(domain: errorMessage, code: -4)
                           completion(.failure(backendError))
                       } else {
                           let unknownError = NSError(domain: "Bilinmeyen hata", code: -5)
                           completion(.failure(unknownError))
                       }
                   } catch {
                       completion(.failure(error))
                   }
                   
               }.resume()
           }
    
       
    let db = Firestore.firestore()
    
    func loginUser(email:String, password:String,completion:@escaping(Result<Void,Error>)->(Void)){
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                   if let error = error {
                       print("kullanıcı girişi yapılamadı")
                       completion(.failure(error))
                       return
                   }
                   guard let uid = authResult?.user.uid else {
                       completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"kullanıcı id sine erişilemedi"])))

                       return
                   }
                   
                   let userRef = self.db.collection("users").document(uid)
                   userRef.getDocument { document , error in
                       if let error = error {
                           try? Auth.auth().signOut()
                           completion(.failure(error))
                           return
                       }
                       guard let document = document,document.exists else {
                           try? Auth.auth().signOut()
                           completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"kullanıcı firestorede bulunamadı"])))
                           return
                       }
                       
                       completion(.success(()))
                   }
                   
               }
    }
    
    func logOutUser(completion:@escaping (Result <Void ,Error>) -> Void){
        do{
                    try Auth.auth().signOut()
                    completion(.success(()))
                }catch let signOutError {
                    completion(.failure(signOutError))
                    
                }
        
    }
    
    func deleteUser(completion: @escaping (Result<Void,Error>) -> Void){
        guard let user = Auth.auth().currentUser else {
                   completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı."])))
                   return
               }
               let uid = user.uid
               db.collection("users").document(uid).delete { error in
                   if let error = error {
                       completion(.failure(error))
                       return
                   }
                   user.delete{ error in
                       if let error = error {
                           print("Kullanıcı silinemedi \(error.localizedDescription)")
                           completion(.failure(error))
                           return
                       }
                       completion(.success(()))
                   }
               }
        
    }
    
    func currenUserInfo(completion: @escaping (Result<User,Error>) -> (Void)){
        guard let user = Auth.auth().currentUser else {
                    completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı."])))
                    return
                }
                let uid = user.uid
                db.collection("users").document(uid).getDocument{ snapshot,error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let data = snapshot?.data(){
                        let name = data["firstName"] as? String ?? ""
                        let id = data["id"] as? String ?? ""
                        let surname = data["lastName"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let user = User(id: id, name: name, surname: surname, email: email)
                        completion(.success(user))
                    }
                    
                }
        
    }
    //MARK: -FavoritesFunc
    
    func fetchFavorites(completion: @escaping (Result<[Product], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı."])))
                return
            }

            // URL’yi uid ile birlikte oluşturuyoruz
            let urlString = "http://localhost:3000/api/favorites?uid=\(uid)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "URLError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Geçersiz URL"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Favori ürünler alınamadı: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "URLError", code: 400, userInfo: [NSLocalizedDescriptionKey: "urun alınammadı"])))
                return
            }

            guard let data = data else {
                print("❌ Veri gelmedi")
                completion(.failure(NSError(domain: "URLError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Veri yok"])))
                return
            }

            // Gelen veriyi kontrol etmek için:
            print("📦 Favori ürünler JSON:\n", String(data: data, encoding: .utf8) ?? "Veri çözümlenemedi")

            do {
                // JSON dizisini manuel decode ediyoruz
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let products: [Product] = jsonArray.compactMap { json in
                        return Product(
                            product_id: json["id"] as? String ?? "",
                            product_name: json["productName"] as? String ?? "",
                            product_brand: json["brands"] as? String ?? "",
                            product_image: json["productImage"] as? String ?? "",
                            category: json["categories"] as? String ?? "",
                            ingeridents: json["ingredients_text"] as? String ?? "",
                            food_values: json["nutriments"] as? [String: String] ?? [:],
                            isFavorites: true,
                            barcode: json["productCode"] as? String ?? "",
                            carbohydrates: json["carbohydrates"] as? Int ?? 0,
                            energy: json["energy_kcal"] as? Int ?? 0,
                            fat: json["fat"] as? Int ?? 0,
                            proteins: json["proteins"] as? Int ?? 0,
                            salt: json["salt"] as? Double ?? 0,
                            saturated_fat: json["saturated_fat"] as? Double ?? 0,
                            sugars: json["sugars"] as? Int ?? 0,
                            fiber: json["sodium"]as? Double ?? 0
                        )
                    }

                    completion(.success(products))

                } else {
                    print("❌ JSON formatı bekleneni karşılamıyor")
                    completion(.failure(NSError(domain: "ParseError", code: 500, userInfo: [NSLocalizedDescriptionKey: "JSON formatı hatalı."])))
                }

            } catch {
                print("❌ JSON parse hatası: \(error)")
                completion(.failure(error))
            }

        }.resume()
        
           
       }
    
    func deleteFavorite(barcode: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Giriş yapmış kullanıcı bulunamadı.", code: 401)))
            return
        }
        guard let url = URL(string: "http://localhost:3000/api/favorites") else {
            completion(.failure(NSError(domain: "URLError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Geçersiz URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "uid": uid,
            "productCode": barcode
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(NSError(domain: "EncodingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "JSON body encode edilemedi."])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Silme isteği hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "ResponseError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Geçersiz yanıt."])))
                return
            }

            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Sunucu hatası"
                completion(.failure(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    print("✅ Favori silindi: \(message)")
                    completion(.success(message))
                } else {
                    completion(.failure(NSError(domain: "ParseError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Yanıt parse edilemedi."])))
                }
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }

    
   
            
            // 1. Firebase Auth ile kullanıcı UID'sini al
    func updateFavorite(productCode: String, completion: @escaping (Result<String, Error>) -> Void) {
           
           // 1. Firebase Auth ile kullanıcı UID'sini al
           guard let uid = Auth.auth().currentUser?.uid else {
               completion(.failure(NSError(domain: "Giriş yapmış kullanıcı bulunamadı.", code: 401)))
               return
           }
           
           // 2. URL oluştur
           guard let url = URL(string: "http://localhost:3000/api/favorites") else {
               completion(.failure(NSError(domain: "Geçersiz URL", code: -1)))
               return
           }
           
           // 3. İstek gövdesi
           let body: [String: Any] = [
               "uid": uid,
               "productCode": productCode
           ]
           
           // 4. URLRequest ayarları
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
           } catch {
               completion(.failure(error))
               return
           }
           
           // 5. URLSession ile istek
           URLSession.shared.dataTask(with: request) { data, response, error in
               
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse,
                     let data = data else {
                   completion(.failure(NSError(domain: "Yanıt alınamadı.", code: -2)))
                   return
               }
               
               switch httpResponse.statusCode {
               case 200:
                   if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let message = json["message"] as? String {
                       completion(.success(message))
                   } else {
                       completion(.success("Favori başarıyla eklendi."))
                   }
                   
               case 404:
                   completion(.failure(NSError(domain: "Ürün bulunamadı, favorilere eklenemedi.", code: 404)))
                   
               case 400:
                   if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let errorMessage = json["error"] as? String {
                       completion(.failure(NSError(domain: errorMessage, code: 400)))
                   } else {
                       completion(.failure(NSError(domain: "Geçersiz istek.", code: 400)))
                   }
                   
               default:
                   completion(.failure(NSError(domain: "Bilinmeyen hata oluştu.", code: httpResponse.statusCode)))
               }
               
           }.resume()
       }

    
}
