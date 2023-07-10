# GodotGooglePlayBilling GDScript API
Simple GDScript API for the [GodotGooglePlayBilling](https://github.com/finepointcgi/godot-google-play-billing) plugin.

Exposes the plugin's signals and methods and adds some classes for extra comfort.

Tested up to Godot 4.1-stable.


## Quick Start

Here's a sample workflow, but you can achieve the same result in other ways and/or using other methods in the API.

1. Add `GodotGooglePlayBilling.gd` as an autoload in the project settings.
<br>

2. Connect to the main signals.
```
func _ready():
    GodotGooglePlayBilling.connected.connect(your_function)
    GodotGooglePlayBilling.purchases_updated.connect(_on_purchase)
```
<br>

3. Retrieve user's "inapp" (or "subs") purchases.

```
func your_function():
    GodotGooglePlayBilling.query_purchases(GodotGooglePlayBilling.PurchaseTypes.INAPP)
    var purchases : Array[GooglePlayPurchase] = await GodotGooglePlayBilling.purchases_query_response
    for purchase in purchases:
        manage_existing_purchase(purchase)
```
<br>

4. Start the purchase flow.
```
func user_wants_to_buy_something():
	GodotGooglePlayBilling.query_sku_details(["something"], GodotGooglePlayBilling.PurchaseTypes.INAPP)
	var query : Array[GooglePlayProduct] = await GodotGooglePlayBilling.sku_query_response
	GodotGooglePlayBilling.purchase(query[0].sku)
```
<br>

5. When the user has completed the purchase, continue the purchase flow (remember to connect to the signal like in step 1). You can __consume__ the purchase if you want the user to be able to buy it more than once, or __acknowledge__ it to keep it in user's purchases for later use (like granting a persistent benefit). If you do neither of those, the purchase will be canceled after some time and the user will be refunded.
```
func _on_purchase(purchases : Array[GooglePlayPurchase]):
    for purchase in purchases:
        if purchase.sku == "something":
            GodotGooglePlayBilling.consume_purchase(purchase.token)
        else:
            GodotGooglePlayBilling.acknowledge_purchase(purchase.token)
```