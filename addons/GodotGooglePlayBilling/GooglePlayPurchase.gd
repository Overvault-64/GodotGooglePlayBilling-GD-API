class_name GooglePlayPurchase


var order_id : String
var package_name : String
var purchase_state : int
var purchase_time : int
var purchase_token : String
var quantity : int
var signature : String
var sku : String
var skus : Array[String]
var is_acknowledged : bool
var is_auto_renewing : bool

enum PurchaseState {
	UNSPECIFIED,
	PURCHASED,
	PENDING,
	}


func _init(dict : Dictionary):
	for key in dict:
		set(key, dict[key])
	
