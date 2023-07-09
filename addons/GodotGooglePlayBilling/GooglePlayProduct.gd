class_name GooglePlayProduct


var icon_url : String
var original_price : String
var original_price_amount_micros : int
var introductory_price_period : String
var description : String
var title : String
var type : String
var price_amount_micros : int
var price_currency_code : String
var introductory_price_cycles : int
var introductory_price : String
var introductory_price_amount_micros : int
var price : String
var free_trial_period : String
var subscription_period : String
var sku : String


func _init(dict : Dictionary):
	for key in dict:
		set(key, dict[key])
	
