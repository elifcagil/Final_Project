//
//  Filmler.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 11.03.2025.
//

import Foundation

class Product:Codable{
    
    var product_id : String?
    var product_name : String?
    var product_brand : String?
    var product_image: String?
    var category : String?
    var ingeridents: String?
    var food_values: [String:String]
    var isFavorites:Bool?
    var barcode :String?
    var carbohydrates : Int?
    var energy : Int?
    var fat : Int?
    var proteins: Int?
    var salt:Double?
    var saturated_fat:Double?
    var sugars:Int?
    var fiber:Double?

    
    
    init(product_id:String,product_name:String,product_brand:String,product_image:String,category:String?,ingeridents:String,food_values:[String:String],isFavorites:Bool?,barcode:String,carbohydrates : Int?,energy : Int?,fat:Int?,proteins: Int?,
         salt:Double?,saturated_fat:Double?,sugars:Int?,fiber:Double?){
        self.product_id = product_id
        self.product_name = product_name
        self.product_brand = product_brand
        self.product_image = product_image
        self.category = category
        self.ingeridents = ingeridents
        self.food_values = food_values
        self.isFavorites = isFavorites
        self.barcode = barcode
        self.carbohydrates = carbohydrates
        self.energy = energy
        self.fat = fat
        self.proteins = proteins
        self.salt = salt
        self.saturated_fat = saturated_fat
        self.sugars = sugars
        self.fiber = fiber
        
    
    }
    
    
    
}
