// Set Up Mock Data Here

///////////////////
function dataSet0() {
    launchParams.putString("word_of_the_day", "Altruism");
    launchParams.putString("type", "noun");
    launchParams.putString("pronunciation", "AL-troo-iz-um");
    launchParams.putStringArray("definitions", ["unselfish regard for or devotion to the welfare of others", "behavior by an animal that is not beneficial to or may be harmful to itself but that benefits others of its species"]);
    launchParams.putFloatArray("date", [2021, 5, 21]);
}

function dataSet1() {
    launchParams.putString("word_of_the_day", "Copious");
    launchParams.putString("type", "adjective");
    launchParams.putString("pronunciation", "KOH-pee-us");
    launchParams.putStringArray("definitions", ["yielding something abundantly", "plentiful in number", "full of thought, information, or matter"]);
    launchParams.putFloatArray("date", [2021, 5, 20]);
}

function dataSet2() {
    launchParams.putString("word_of_the_day", "Bumptious");
    launchParams.putString("type", "adjective");
    launchParams.putString("pronunciation", "BUMP-shus");
    launchParams.putStringArray("definitions", ["presumptuously, obtusely, and often noisily self-assertive : obtrusive"]);
    launchParams.putFloatArray("date", [2021, 6, 8]);
}

function dataSet3() {
    launchParams.putString("word_of_the_day", "Peruse");
    launchParams.putString("type", "verb");
    launchParams.putString("pronunciation", "puh-ROOZ");
    launchParams.putStringArray("definitions",       ["to examine or consider with attention and in detail: study", "to look over or through in a casual or cursory manner", "read; especially: to read over in an attentive or leisurely manner"]);
    launchParams.putFloatArray("date", [2021, 5, 18]);
}

function dataSet4() {
    launchParams.putString("word_of_the_day", "Rigmarole");
    launchParams.putString("type", "noun");
    launchParams.putString("pronunciation", "RIG-uh-muh-rol");
    launchParams.putStringArray("definitions", ["confused or meaningless talk", "a complex and sometimes ritualistic procedure"]);
    launchParams.putFloatArray("date", [2021, 6, 4]);
}

function noMockData() {
    // Test result when no passed in data
}

// Expose data set for use
script.api.dataSets = [dataSet0, dataSet1, dataSet2, dataSet3, dataSet4, noMockData];

/* // Example Swift Code to send Word of the Day
    let wordOfTheDay = "Didactic"
    let definition:[String] =  ["Designed or intended to teach", "Intended to convey instruction and information as well as pleasure and entertainment", "Making moral observations"]
    let type = "Adjective"
    let pronunciation = "dye-DAK-tik"
    let date:[Int] = [2021, 6, 5]
        
    let launchDataBuilder = SCSDKLensLaunchDataBuilder()
        
    launchDataBuilder.addNSStringKeyPair("word_of_the_day", value: wordOfTheDay)
    launchDataBuilder.addNSStringKeyPair("type", value: type)
    launchDataBuilder.addNSStringKeyPair("pronunciation", value: pronunciation)
    launchDataBuilder.addNSStringArrayKeyPair("definitions", value: definition)
    launchDataBuilder.addNSNumberArrayKeyPair("date", value: date.map({NSNumber(value: $0)}))
        
    // Send launch data to lens    
    let snapContent = SCSDKLensSnapContent(lensUUID: [Insert Sharable Lens ID ] "")
    snapContent.launchData = SCSDKLensLaunchData(builder: launchDataBuilder)
*/