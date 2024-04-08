//@input Component.Text3D key1Text;
//@input Component.Text3D key2Text;

// This will use FallbackData if global.launchParams has not been filled out 
var launchParams = global.launchParams;

/* Storage accessors */
var value1;
var value2; 

var storageKeys = ["key1","key2"]

/****************/
function getData() {
    if (launchParams) {
        if (launchParams.has(storageKeys[0]) &&
            launchParams.has(storageKeys[1]) ) {
            
            value1 = launchParams.getString(storageKeys[0]);
            value2 = launchParams.getString(storageKeys[1]);            
            return true;
        }
        
    return false;
    }
}

function populateFields() {
    
    script.key1Text.text = "key1: " + value1;
    script.key2Text.text = "key2: " + value2;
}


if(getData()) { 
    populateFields();
} else {
    script.key1Text.text = "failed to get launchParams";
    script.key2Text.text = "";
}