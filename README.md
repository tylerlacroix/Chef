# Chef

[![Alt text for your video](https://cloud.githubusercontent.com/assets/11801330/17873499/d9db2d16-6893-11e6-9e59-91ec14f01f7a.png)](http://www.youtube.com/watch?v=kxgvDH5xutU)

## Inspiration

Our inspiration comes from all those nights where you come home, look in the fridge, and think “What am I going to make for dinner?”.  The average person may know how spaghetti and marinara go together, but what about beets and chicken?  Some websites exist for such a purpose, but most are clunky and require manual input of every ingredient.  From this, we came up with our solution:  Chef.


## What it does

With the use of your smartphone camera, Chef will detect the food placed in front of the camera and compile a list.  Once prompted by the user, Chef will look for the best recipes that incorporate the selected ingredients.  Each recipe is shown in picture form and in one click, the user will have step-by-step instructions.  On top of this, each recipe will display exactly which scanned ingredients are in the dish.


## How I built it

The project consists of two code bases, the front-end iOS app and the back-end PHP. The iOS app uses the AVFoundation library to display a live feed of the camera and capture the image data. The image data is sent to a PHP server via HTTP POST. The server analyzes the image using the Indico “Image Recognition” machine learning library. The server then returns the results of the analysis to the iOS app. If the object is an ingredient, the app adds the item to the list of ingredients available. When the user requests recipes, it searches through a database of recipes to find recipes requiring just those items. The app displays the recipes through a custom UICollectionView for the user to scroll through and use.


## How is this beneficial?

Chef can be beneficial in two major ways.  The first is a fridge glance.  In the fridge glance (or cupboard), the user points their smartphones into the fridge and Chef automatically detects the food stored there.  From the large list, Chef will determine the best recipes which use ingredients from the fridge.  The other way Chef benefits the user is in  specific ingredient selection.  Instead of giving Chef every possible ingredient, Chef is also great for selecting recipes based on a few selections.  This is particularly great if food is close to expiring or you are in the mood for certain flavors!
