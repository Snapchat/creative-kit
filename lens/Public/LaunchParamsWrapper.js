//@input string keyToCheck = "example_launch_param_key"
//@input int fallbackData = 0 {"widget": "combobox" ,"values":[{"label":"data set 0", "value":0}, {"label":"data set 1", "value":1}, {"label":"data set 2", "value":2}, {"label":"data set 3", "value":3}, {"label":"data set 4", "value":4}, {"label":"No Data", "value":5}]}
//@input bool advanced = false
//@input Component.ScriptComponent fallbackDataSource {"showIf" : "advanced"}

if (!script.keyToCheck) {
    print("LaunchParamsWrapper: Please set Key To Check. We'll check if key is available in launchParams. If not we will go to fallback data.");
    return;
}

if (!(script.fallbackDataSource && script.fallbackDataSource.api && script.fallbackDataSource.api.dataSets)) {
    print("LaunchParamsWrapper: Please set fallbackDataSource in Advanced section. Make sure FallbackDataSource is initialized before this script.");
    return;
}

// Mimic launchParams API
function mockLaunchParams () {
    this.isMocked = true;

    const storedTypes = ["Float", "String"];

    this.store = {};

    this.has = function (key) {
        return this.store[key] !== undefined;
    }

    for (var k in storedTypes) {
        var typeName = storedTypes[k];
        
        this["put" + typeName] = function (key, value) {
            this.store[key] = value;
        };
        
        this["put" + typeName + "Array"] = function (key, value) {
            this.store[key] = value;
        };
        
        this["get" + typeName] = function (key) {
            return this.store[key];
        };
        
        this["get" + typeName + "Array"] = function (key) {
            return this.store[key];
        };
    }
}

function getLaunchParams() {    
    //Check for valid data being passed in
    if (global.launchParams &&
        script.keyToCheck &&
        global.launchParams.has(script.keyToCheck)) { 
        return global.launchParams;
    } 
    // replace global.launchParams with mocked version so we can write into it
    global.launchParams = new mockLaunchParams();
    print("LaunchParamsWrapper: Using data from fallbackDataSource");
    
    script.fallbackDataSource.api.dataSets[script.fallbackData]();
    return launchParams;
}

// Export
global.launchParamsStore = getLaunchParams(); // returns launch parameters