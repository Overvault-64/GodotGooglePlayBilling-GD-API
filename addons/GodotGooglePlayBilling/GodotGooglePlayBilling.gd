# Google documentation https://developer.android.com/google/play/billing/integrate
# Godot documentation https://docs.godotengine.org/en/stable/tutorials/platform/android/android_in_app_purchases.html

extends Node


var plugin

signal connected
signal disconnected
signal connect_error(code : int, message : String)
signal resume
signal price_acknowledged(response_code : int)
signal purchases_query_response(purchases : Array[GooglePlayPurchase]) # See GooglePlayPurchase class for dict fields 
signal purchases_updated(purchases : Array[GooglePlayPurchase])
signal purchase_error(code : int, message : String)
signal sku_query_response(sku_details : Array[GooglePlayProduct])
signal sku_query_error(code : int, message : String, product_SKUs : Array)
signal purchase_acknowledged(token : String)
signal purchase_acknowledgement_error(code : int, message : String, token : String)
signal purchase_consumed(token : String)
signal purchase_consumption_error(code : int, message : String, token : String)

enum PurchaseTypes {INAPP, SUBS}
const _purchase_types := ["inapp", "subs"]

enum ConnectionState {
	DISCONNECTED, # Not yet connected to billing service or was already closed
	CONNECTING, # Currently in process of connecting to billing service
	CONNECTED, # Currently connected to billing service
	CLOSED, # Already closed and shouldn't be used again
	}

enum SubscriptionProrationMode {
	IMMEDIATE_WITH_TIME_PRORATION = 1, # Replacement takes effect immediately, and the remaining time will be prorated and credited to the user.
	IMMEDIATE_AND_CHARGE_PRORATED_PRICE, # Replacement takes effect immediately, and the billing cycle remains the same. The price for the remaining period will be charged. This option is only available for subscription upgrade.
	IMMEDIATE_WITHOUT_PRORATION, # Replacement takes effect immediately, and the new price will be charged on next recurrence time. The billing cycle stays the same.
	DEFERRED, # Replacement takes effect when the old plan expires, and the new price will be charged at the same time.
	IMMEDIATE_AND_CHARGE_FULL_PRICE, # Replacement takes effect immediately, and the user is charged full price of new plan and is given a full billing cycle of subscription, plus remaining prorated time from the old plan.
}


func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		plugin = Engine.get_singleton("GodotGooglePlayBilling")
		plugin.connected.connect(_on_connected)
		plugin.disconnected.connect(_on_disconnected)
		plugin.connect_error.connect(_on_connect_error)
		plugin.billing_resume.connect(_on_resume)
		plugin.price_change_acknowledged.connect(_on_price_acknowledged)
		plugin.query_purchases_response.connect(_on_purchases_query_response)
		plugin.purchases_updated.connect(_on_purchases_updated)
		plugin.purchase_error.connect(_on_purchase_error)
		plugin.sku_details_query_completed.connect(_on_sku_query_completed)
		plugin.sku_details_query_error.connect(_on_sku_query_error)
		plugin.purchase_acknowledged.connect(_on_purchase_acknowledged)
		plugin.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error)
		plugin.purchase_consumed.connect(_on_purchase_consumed)
		plugin.purchase_consumption_error.connect(_on_purchase_consumption_error)
		plugin.startConnection()
#		plugin.enablePendingPurchases() # should be added to the plugin
		print("Google Play Billing plugin loaded.")
	else:
		printerr("Google Play Billing plugin not found. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings!")


#METHODS
func get_connection_state() -> int:
	return plugin.getConnectionState()


func is_ready() -> bool:
	return true if plugin != null and plugin.getConnectionState() == ConnectionState.CONNECTED else false


func query_sku_details(product_SKUs : Array[String], purchase_type : int) -> void:
	plugin.querySkuDetails(product_SKUs, _purchase_types[purchase_type])


func query_purchases(purchase_type : int):
	return plugin.queryPurchases(_purchase_types[purchase_type])


func purchase(SKU : String):
	return plugin.purchase(SKU)


func consume_purchase(token : String) -> void:
	plugin.consumePurchase(token)


func acknowledge_purchase(token : String) -> void:
	plugin.acknowledgePurchase(token)


func update_subscription(token : String, sub_SKU : String, proration_mode : int) -> void:
	plugin.updateSubscription(token, sub_SKU, proration_mode)


func confirm_price_change(SKU : String):
	plugin.confirmPriceChange(SKU)


#SIGNAL MIRRORING
func _on_connected() -> void:
	connected.emit()


func _on_disconnected() -> void:
	disconnected.emit()
	
	
func _on_connect_error(code : int, message : String) -> void:
	connect_error.emit(code, message)


func _on_resume() -> void:
	resume.emit()


func _on_purchases_query_response(response : Dictionary) -> void:
	if response.status == OK:
		var purchases : Array[GooglePlayPurchase]
		for entry in response.purchases:
			purchases.append(GooglePlayPurchase.new(entry))
		purchases_query_response.emit(purchases)
	else:
		printerr("purchases query error, please check: " + str(response))


func _on_purchases_updated(purchases : Array) -> void:
	var updated_purchases : Array[GooglePlayPurchase]
	for entry in purchases:
		updated_purchases.append(GooglePlayPurchase.new(entry))
	purchases_updated.emit(updated_purchases)


func _on_purchase_error(code : int, message : String) -> void:
	printerr("purchase error " + str(code) + ": " + message)
	purchase_error.emit(code, message)


func _on_sku_query_completed(sku_details : Array) -> void:
	var products : Array[GooglePlayProduct]
	for entry in sku_details:
		products.append(GooglePlayProduct.new(entry))
	sku_query_response.emit(products)


func _on_sku_query_error(code : int, message : String, product_SKUs : Array) -> void:
	printerr("sku " + str(product_SKUs) + " query error " + str(code) + ": " + message)
	sku_query_error.emit(code, message, product_SKUs)


func _on_purchase_acknowledged(token : String) -> void:
	purchase_acknowledged.emit(token)
	
	
func _on_purchase_acknowledgement_error(code : int, message : String, token : String) -> void:
	printerr("purchase " + token + " acknowledgement error " + str(code) + ": " + message)
	purchase_acknowledgement_error.emit(code, message, token)


func _on_purchase_consumed(token : String) -> void:
	purchase_consumed.emit(token)
	
	
func _on_purchase_consumption_error(code : int, message : String, token : String) -> void:
	printerr("purchase " + token + " consumption error " + str(code) + ": " + message)
	purchase_consumption_error.emit(code, message, token)


func _on_price_acknowledged(response_code : int) -> void:
	price_acknowledged.emit(response_code)
